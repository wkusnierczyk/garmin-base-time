import argparse
import dataclasses
import json
import os
import re
import subprocess
import sys
import xml.etree.ElementTree as ET

from collections import defaultdict

# --- Configuration & Defaults ---

DEFAULT_RESOURCES_DIR = "resources"
DEFAULT_FONTS_SUBDIR = "fonts"
DEFAULT_XML_FILENAME = "fonts.xml"
DEFAULT_TOOL_PATH = "ttf2bmp"

# Fallbacks if JSON is missing specific data
DEFAULT_REFERENCE_DIAMETER = 280
DEFAULT_CHARSET = "0123456789:" 
DEFAULT_HINTING = "none"

# Output naming convention
TARGET_RESOURCES_DIR_PREFIX = "resources-round-"
TARGET_RESOURCES_DIR_INFIX = "x"
TARGET_RESOURCES_DIR_TEMPLATE = f"{TARGET_RESOURCES_DIR_PREFIX}{{diameter}}{TARGET_RESOURCES_DIR_INFIX}{{diameter}}"

# fonts.xml file conventions
XML_FONT_CHARSETS_NODE = "FontCharsets"
XML_SCREEN_DIAMETERS_NODE = "ScreenDiameters"
JSON_REFERENCE_DIAMETER_KEY = "referenceDiameter"
JSON_TARGET_DIAMETERS_KEY = "targetDiameters"
JSON_FONT_ID_KEY = "fontId"
JSON_CHARSET_KEY = "fontCharset"

XML_FONT_NODE_PATTERN = ".//font"
XML_FONT_NODE_ID_ATTRIBUTE = "id"
XML_FONT_NODE_FILENAME_ATTRIBUTE = "filename"

XML_JSON_NODE_PATTERN = ".//jsonData"
XML_JSON_NODE_ID_ATTRIBUTE = "id"

XML_ENCODING = "UTF-8"


# Font tool invocation options
FONT_TOOL_SOURCE_TTF_OPTION = "-f"
FONT_TOOL_CHARSET_OPTION = "-c"
FONT_TOOL_HINTING_OPTION = "-hinting"
FONT_TOOL_SIZE_OPTION = "-s"
FONT_TOOL_OUTPUT_OPTION = "-o"


# Parsing font name (.*) and font size (\d+) out of an fnt font file name
FNT_FILENAME_PARSE_REGEX = r"^(.*)-(\d+)\.fnt$"


# --- Data Structures ---

@dataclasses.dataclass
class FontTask:
    """Represents a single font entry from fonts.xml to be processed."""
    xml_node: ET.Element            # The XML Element object
    font_id: str                    # e.g. "HourFont"
    font_name: str                  # e.g. "Ubuntu-Bold"
    fnt_filename: str               # e.g. "Ubuntu-Bold-60.fnt"
    ttf_filename: str               # e.g. "Ubuntu-Bold.ttf"
    reference_size: int             # e.g. 60
    target_size: int                # e.g. 80 (to be calculated in the pipeline)
    charset: str                    # e.g. "0123456789:"

# --- Processor Logic ---

class FontProcessor:
    """
    Processes fonts.xml, parses all font information, generates per-diameter directories, 
    generates font bitmaps at target sizes.
    """
    
    def __init__(self):
        # Paths
        self.resources_dir = DEFAULT_RESOURCES_DIR
        self.fonts_subdir = DEFAULT_FONTS_SUBDIR
        self.resources_fonts_path = os.path.join(self.resources_dir, self.fonts_subdir)
        self.xml_file_name = DEFAULT_XML_FILENAME
        self.xml_file_path = os.path.join(self.resources_fonts_path, DEFAULT_XML_FILENAME)
        self.font_tool_path = DEFAULT_TOOL_PATH
        
        # Configuration to be parsed from XML
        self.reference_diameter = DEFAULT_REFERENCE_DIAMETER
        self.target_diameters = []
        self.font_tasks = []


    # --- Configuration 

    def with_resources_dir(self, resources_dir=None):
        if resources_dir:
            self.resources_dir = resources_dir
            self._set_resources_paths
        return self
    
    def with_fonts_subdir(self, fonts_subdir=None):
        if fonts_subdir:
            self.fonts_subdir = fonts_subdir
            self._set_resources_paths()
        return self
    
    def with_xml_file_name(self, xml_file_name=None):
        if xml_file_name:
            self.xml_file_name = xml_file_name
            self._set_resources_paths()
        return self
    
    def _set_resources_paths(self):
        self.resources_fonts_path = os.path.join(self.resources_dir)
        self.xml_file_path = os.path.join(self.resources_fonts_path, self.xml_file_name)
        return self

    def with_font_tool_path(self, font_tool_path=None):
        if font_tool_path:
            self.font_tool_path = font_tool_path
        return self

    def with_reference_diameter(self, reference_diameter=None):
        if reference_diameter:
            self.reference_diameter = reference_diameter
        return self
    
    def with_target_diameters(self, target_diameters=None):
        if target_diameters:
            self.target_diameters = target_diameters
        return self


    # --- XML Parsing

    def parse_source_xml(self):
        """
        Reads fonts file (default: resources/fonts/fonts.xml).
        Extracts font maps (font id, font fnt file).
        Extracts fnt font names, ttf font file names, font sizes.
        Extracts JSON config for font charsets.
        Extracts JSON config for target screen diameters.
        """

        xml_file_path = self.xml_file_path
        if not os.path.exists(xml_file_path):
            self._fail(f"Font xml file '{xml_file_path}' not found.")

        try:
            tree = ET.parse(xml_file_path)
            root = tree.getroot()

            # 1. Parse Screen Diameters
            diameters_node = self._find_json_node(root, XML_SCREEN_DIAMETERS_NODE)
            if not diameters_node is not None:
                self._fail(f"<jsonData id='{XML_SCREEN_DIAMETERS_NODE}'> not found in XML.")
            
            diameters_config = json.loads(diameters_node.text)
            self.reference_diameter = diameters_config.get(JSON_REFERENCE_DIAMETER_KEY)
            self.target_diameters = diameters_config.get(JSON_TARGET_DIAMETERS_KEY)
            if not self.reference_diameter or not self.target_diameters:
                self._fail(f"Invalid {XML_SCREEN_DIAMETERS_NODE} JSON configuration.")

            # 2. Parse Charsets
            charsets_node = self._find_json_node(root, XML_FONT_CHARSETS_NODE)
            charsets_map = {}
            if charsets_node is not None:
                charsets = json.loads(charsets_node.text)
                charsets_map = {item[JSON_FONT_ID_KEY]: item[JSON_CHARSET_KEY] for item in charsets}
            else:
                self._warn(f"<jsonData id='{XML_FONT_CHARSETS_NODE}'> not found, using default charset.")

            # 3. Parse Font Definitions
            self.font_tasks = []
            
            for font_node in root.findall(XML_FONT_NODE_PATTERN):
                font_id = font_node.get(XML_FONT_NODE_ID_ATTRIBUTE)
                fnt_filename = font_node.get(XML_FONT_NODE_FILENAME_ATTRIBUTE)
                
                match = re.search(FNT_FILENAME_PARSE_REGEX, fnt_filename)
                if not match:
                    self._warn(f"Skipping {fnt_filename} (Format '<font-name>-<fonts-size>.fnt' required)")
                    continue

                font_name = match.group(1)
                ttf_filename = f"{font_name}.ttf"
                font_size = int(match.group(2))
                
                charset = charsets_map.get(font_id, DEFAULT_CHARSET)

                task = FontTask(
                    xml_node=font_node, 
                    font_id=font_id, 
                    fnt_filename=fnt_filename,
                    font_name=font_name,
                    ttf_filename=ttf_filename, 
                    reference_size=font_size, 
                    target_size=None,
                    charset=charset
                )
                self.font_tasks.append(task)

        except ET.ParseError as e:
            self._fail(f"Parsing XML failed with error: {e}")
        except json.JSONDecodeError as e:
            self._fail(f"Parsing JSON data in XML failed with error: {e}")

        return self

    def _find_json_node(self, root, json_id):
        for node in root.findall(XML_JSON_NODE_PATTERN):
            if node.get(XML_JSON_NODE_ID_ATTRIBUTE) == json_id:
                return node
        return None

    # --- Execution Pipeline ---

    def execute(self):
        self._info("Font processing pipeline")
        self._info(f"* Reference diameter: {self.reference_diameter}")
        self._info(f"* Target diameters: {self.target_diameters}")
        self._info("Starting batch processing...")
        
        # Validation
        self._validate_sources()

        # Processing Loop
        for diameter in self.target_diameters:
            self._process_diameter(diameter)
            
        self._info("Batch processing complete.")

    def _validate_sources(self):
        missing = []

        # Check unique TTFs required
        required_ttf_filenames = set(task.ttf_filename for task in self.font_tasks)
        
        for ttf_filename in required_ttf_filenames:
            path = os.path.join(self.resources_fonts_path, ttf_filename)
            if not os.path.exists(path):
                missing.append(ttf_filename)
        
        if missing:
            self._error("Missing Source TTF Files")
            for ttf_filename in missing: self._error(f" - {ttf_filename}")
            sys.exit(1)

    def _process_diameter(self, target_diameter):
        self._info(f"Processing target diameter: {target_diameter}")
        
        target_dir, target_xml = self._prepare_target(target_diameter)
        
        target_tree = ET.parse(target_xml)
        target_root = target_tree.getroot()
        target_node_map = {node.get(XML_FONT_NODE_ID_ATTRIBUTE): node 
                           for node in target_root.findall(XML_FONT_NODE_PATTERN)}

        # Group Tasks for Batching
        # Key: (ttf_name, charset) -> Value: List of tasks
        work_batches = defaultdict(list)

        for task in self.font_tasks:
            target_size = self._calculate_size(task.reference_size, target_diameter)
            task = dataclasses.replace(task, target_size=target_size)
            work_batches[(task.ttf_filename, task.charset)].append(task)

        # Execute Batches
        for (ttf_filename, charset), tasks in work_batches.items():
            source_ttf_path = os.path.join(self.resources_fonts_path, ttf_filename)
            
            unique_sizes = sorted(list(set(task.target_size for task in tasks)))
            size_arg = ",".join(map(str, unique_sizes))
            
            # cmd: ttf2bmp -f source-ttf-file -c target-charset -s target-sizes -o target_dir --hinting none
            font_tool_cmd = [
                self.font_tool_path,
                FONT_TOOL_SOURCE_TTF_OPTION, source_ttf_path,
                FONT_TOOL_CHARSET_OPTION, charset,
                FONT_TOOL_HINTING_OPTION, DEFAULT_HINTING,
                FONT_TOOL_SIZE_OPTION, size_arg,
                FONT_TOOL_OUTPUT_OPTION, target_dir
            ]
            
            try:
                # Execute ttf-to-bmp font conversion tool
                subprocess.run(font_tool_cmd, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                
                # Update generated filenames in XML
                for task in tasks:
                    new_filename = f"{task.font_name}-{task.target_size}.fnt"
                    if task.font_id in target_node_map:
                        node = target_node_map[task.font_id]
                        node.set(XML_FONT_NODE_FILENAME_ATTRIBUTE, new_filename)

            except subprocess.CalledProcessError as e:
                self._fail(f"Failed processing TTF file '{ttf_filename}': {e}")
            except FileNotFoundError:
                self._fail(f"font processing tool '{self.font_tool_path}'not found.")

        target_tree.write(target_xml, encoding=XML_ENCODING, xml_declaration=True)

    def _prepare_target(self, diameter):
        target_resources_dir = TARGET_RESOURCES_DIR_TEMPLATE.format(diameter=diameter)
        target_fonts_dir = os.path.join(target_resources_dir, DEFAULT_FONTS_SUBDIR)
        
        if not os.path.exists(target_fonts_dir):
            os.makedirs(target_fonts_dir)
            
        target_xml_path = os.path.join(target_fonts_dir, DEFAULT_XML_FILENAME)
        
        try:
            tree = ET.parse(os.path.join(self.resources_fonts_path, DEFAULT_XML_FILENAME))
            root = tree.getroot()
            for json_node in root.findall(XML_JSON_NODE_PATTERN):
                root.remove(json_node)                
            tree.write(target_xml_path, encoding=XML_ENCODING, xml_declaration=True)
            
        except ET.ParseError:
            self._fail("Error preparing target XML.")
            
        return target_fonts_dir, target_xml_path

    def _calculate_size(self, original_size, target_diameter):
        return int(round(float(original_size) / self.reference_diameter * target_diameter))

    def _info(self, message):
        self._stderr(f"{message}")

    def _warn(self, message):
        self._stderr(f"Warning: {message}")

    def _error(self, message):
        self._stderr(f"Error: {message}")

    def _fail(self, message):
        self._error(message)
        sys.exit(1)

    def _stderr(self, message):
        print(message, file=sys.stderr)


# --- Main Entry Point ---

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--resources-dir", 
                        help="Override reference resources directory name")
    parser.add_argument("--fonts-subdir", 
                        help="Override reference fonts subdirectory name")
    parser.add_argument("--xml-file", 
                        help="Override XML fonts filename")
    parser.add_argument("--reference-diameter", 
                        type=int, 
                        help="Override reference screen diameter")
    parser.add_argument("--target-diameters", 
                        help="Override target screen diameters")
    parser.add_argument("--tool-path", 
                        help="Override path to TTF-to-bitmap conversion tool")
    args = parser.parse_args()

    (
        FontProcessor()
        .with_resources_dir(args.resources_dir)
        .with_fonts_subdir(args.fonts_subdir)
        .with_xml_file_name(args.xml_file)
        .with_reference_diameter(args.reference_diameter)
        .with_target_diameters(args.target_diameters)
        .with_font_tool_path(args.tool_path)
        .parse_source_xml()
        .execute()
    )