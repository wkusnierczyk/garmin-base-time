# Garmin Base Time

A minimalist, elegant, typography-focused Garmin Connect IQ watch face that displays the current time using base $n$ ($n = 2..16$) numerals.

![Base 10](resources/graphics/base-decimal.png)
![Base 6](resources/graphics/base-hexadecimal-standard.png)
![Base 2](resources/graphics/base-binary-standard.png)

Available from [Garmin Connect IQ Developer portal](https://apps.garmin.com/apps/0aa8216b-15a2-4fc1-9c7e-9b3731efb8e7).

## Contents

* [Base n time](#base-n-time)
* [Project structure](#project-structure)
* [Fonts](#fonts)
* [Build, test, deploy](#build-test-deploy)

## Base n time

A [positional system](https://en.wikipedia.org/wiki/Positional_notation) is a numeral system in which the contribution of a digit to the value of a number is the value of the digit multiplied by a factor determined by the position of the digit.
In the commonly used _decimal_ positional number system, the total value of a numeral is calculated by multiplying each digit by the respective power of 10, and summing those up.

For example, the value of $123_{10}$ (`123` in base 10, or decimal) is calculated as follows: $3 \times 10^0 + 2 \times 10^1 + 1 \times 10^2 = 3 + 20 + 100 = 100$. (Note that the calculation is show in the decimal system.)

Besides decimal, positional systems with other bases are in use. In computing, it is common to represent numbers in _octal_ (base 8) and _hexadecimal_ (base 16) systems.

For example, the value of $123_{16}$ (`123` in base 16, or hexadecimal) is calculated as follows: $3 \times 16^0 + 2 \times 16^1 + 1 \times 16^2 = 3 + 32 + 256 = 291$.  (Note that the calculation is show in the decimal system.)

The Garmin Base Time watch face displays time as hours and minutes in a base-$n$ number system, with the base $n$ set to an integer between 2 and 16.
The following table names the available number systems:

| System       | Base (decimal) | Base (n+1) |
|:-------------|---------------:|-----------:|
| Binary       |              2 |          2 |
| Ternary      |              3 |          3 |
| Quaternary   |              4 |          4 |
| Quinary      |              5 |          5 |
| Senary       |              6 |          6 |
| Septenary    |              7 |          7 |
| Octal        |              8 |          8 |
| Nonary       |              9 |          9 |
| Decimal      |             10 |          A |
| Undecimal    |             11 |          B |
| Duodecimal   |             12 |          C |
| Tridecimal   |             13 |          D |
| Tetradecimal |             14 |          E |
| Pentadecimal |             15 |          F |
| Hexadecimal  |             16 |          G |

**Note**  
The base of the currently used number system is displayed as a subscript, using a smaller, colored font. 
The convention is to use the corresponding numeral in the next higher ($n+1$) number system.
For example:
* The _octal_ (base 8) system is indicated with the digit `8` from the _nonal_ (base 9) system; note that there is no digit `8` in the octal system. (Conveniently, `8` is also a digit in the decimal system, with the same value as `8` in the nonal system.)
* The _hexadecimal_ (base 16) system is indicated with the digit `G` from the _heptadecimal_ (base 17) system; note that there is no digit `G` in the hexadecimal system. (There also is no digit `G` in the decimal system.)

This convention has been chosen to consistently display all system base indicators with one digit.
The alternatve of using the decimal system would lead to double-digit indicators for the decimal system and above.
(Using a base-$n$ numeral to indicate base $n$ was not an option, as in _any_ number system that numeral would be... `10`.)

The base can be selected in the user settings menu in the device.
Optionally, the user may turn on standard time, displayed in smaller font below the decimal time, using on-watch customization settings.

## Project structure

```bash
FrenchTime
├── LICENSE                        # MIT license
├── Makefile                       # Convenience makefile
├── manifest.xml
├── monkey.jungle
├── README.md                      # This readme file
├── resources
│   ├── drawables
│   │   ├── drawables.xml
│   │   └── launcher_icon.svg      # Launcher icon
│   ├── fonts
│   │   ├── fonts.xml              # Font map 
│   │   ├── [ttf, fnt, png fonts]  # Source (ttf) and converted (fnt, png) fonts
│   │   └── OFL.txt, UFL.txt       # Font licenses
│   ├── graphics
│   │   └── *.png                  # Graphics (screenshots, screen captures, hero images)
│   ├── layouts
│   │   └── layout.xml             # Layout map (for standard time only)
│   ├── settings                   # User settings
│   │   ├── properties.xml         
│   │   └── settings.xml
│   ├── strings
│   │   └── strings.xml            # i18n-ready (English version provided)
│   └── tests
│       └── base_time_tests.xml    # Data for unit tests
├── resources-round-*              # Screen resolution-specific resources
│   └── ...
└── source
    ├── BaseTime.mc                # Time string calculation and formatting
    ├── BaseTimeApp.mc             # Application entry point
    ├── BaseTimeConstants.mc       # Constants used throughout the sources
    ├── BaseTimeSettings.mc        # User settings menu
    ├── BaseTimeTests.mc           # Unit tests
    ├── BaseTimeView.mc            # Watch face geometry
    └── PropertyUtils.mc           # Utility functions for properties
```

## Fonts

The Base Time watch face uses custom fonts:

* [SUSEMono](https://fonts.google.com/specimen/SUSE+Mono) for the Base-n time (hours and base indicators in SUSEMono-Bold, minutes in SUSEMono-Regular).
* [Ubuntu](https://fonts.google.com/specimen/SUSE+Mono) for standard time (Ubuntu-Regular).

The development process was as follows:

* The fonts were downloaded from [Google Fonts](https://fonts.google.com/) as True Type  (`.ttf`) fonts.
* The fonts were converted to bitmaps as `.fnt` and `.png` pairs using the open source command-line [`ttf2bmp`](https://github.com/wkusnierczyk/ttf2bmp) converter.
* The font sizes were established to match the Garmin Fenix 7X Solar watch 280x280 pixel screen resolution.
* The fonts were then scaled proportionally to match other screen sizes available on Garmin watches with round screens using the included [utility script](utils/scale_fonts.py).

The table below lists all font sizes provided for the supported screen resolutions.

| Element                 | Font             | 218 | 240 | 260 | 280 | 360 | 390 | 416 | 454 |
| :---------------------- | :--------------- | --: | --: | --: | --: | --: | --: | --: | --: |
| Single line hour        | SUSEMono bold    |  47 |  51 |  56 |  60 |  77 |  84 |  89 |  97 |
| Single line minutes     | SUSEMono regular |  47 |  51 |  56 |  60 |  77 |  84 |  89 |  97 |
| Single line system base | SUSEMono bold    |  23 |  26 |  28 |  30 |  39 |  42 |  45 |  49 |
| Double line hour        | SUSEMono bold    |  39 |  43 |  46 |  50 |  64 |  70 |  74 |  81 |
| Double line minutes     | SUSEMono regular |  39 |  43 |  46 |  50 |  64 |  70 |  74 |  81 |
| Double line system base | SUSEMono bold    |  19 |  21 |  23 |  25 |  32 |  35 |  37 |  41 |
| Standard time           | Ubuntu regular   |  23 |  26 |  28 |  30 |  39 |  42 |  45 |  49 |


## Build, test, deploy

To modify and build the sources, you need to have installed:

* [Visual Studio Code](https://code.visualstudio.com/) with [Monkey C extension](https://developer.garmin.com/connect-iq/reference-guides/visual-studio-code-extension/).
* [Garmin Connect IQ SDK](https://developer.garmin.com/connect-iq/sdk/).

Consult [Monkey C Visual Studio Code Extension](https://developer.garmin.com/connect-iq/reference-guides/visual-studio-code-extension/) for how to execute commands such as `build` and `test` to the Monkey C runtime.

You can use the included `Makefile` to conveniently trigger some of the actions from the command line.

```bash
# build binaries from sources
make build

# run unit tests
make test

# run the simulation
make run
```

To sideload your application to your Garmin watch, see [developer.garmin.com/connect-iq/connect-iq-basics/your-first-app](https://developer.garmin.com/connect-iq/connect-iq-basics/your-first-app/).
