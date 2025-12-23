using Toybox.Application;
using Toybox.Graphics;

import Toybox.Lang;


// Colors
const HOUR_COLOR = Graphics.COLOR_WHITE;
const MINUTES_COLOR = Graphics.COLOR_LT_GRAY;
const BASE_COLOR = 0x038c6e;


// Time rendering
const MAX_HOURS = 23;
const MAX_MINUTES = 59;

const DIGITS = Application.loadResource(Rez.JsonData.Digits) as Array<String>;
const HOUR_PADDING = Application.loadResource(Rez.Strings.HourPadding) as String;
const MINUTES_PADDING = Application.loadResource(Rez.Strings.MinutesPadding) as String;


// Layouts (only for standard time, which is fixed; base time layout is dynamic, depending on the base)
const STANDARD_TIME_LAYOUT_ID = "StandardTimeLayout";


// Fonts
const SINGLE_LINE_HOUR_FONT = Application.loadResource(Rez.Fonts.SingleLineHourFont);
const SINGLE_LINE_MINUTES_FONT = Application.loadResource(Rez.Fonts.SingleLineMinutesFont);
const SINGLE_LINE_SYSTEM_BASE_FONT = Application.loadResource(Rez.Fonts.SingleLineSystemBaseFont);

const DOUBLE_LINE_HOUR_FONT = Application.loadResource(Rez.Fonts.DoubleLineHourFont);
const DOUBLE_LINE_MINUTES_FONT = Application.loadResource(Rez.Fonts.DoubleLineMinutesFont);
const DOUBLE_LINE_SYSTEM_BASE_FONT = Application.loadResource(Rez.Fonts.DoubleLineSystemBaseFont);


// Settings
const CUSTOMIZE_MENU_TITLE = Application.loadResource(Rez.Strings.BaseTime);

const STANDARD_TIME_LABEL = Application.loadResource(Rez.Strings.StandardTimeMenuTitle);
const STANDARD_TIME_PROPERTY = "ShowStandardTime";
const STANDARD_TIME_MODE_DEFAULT = true;

const NUMBER_SYSTEM_LABEL = Application.loadResource(Rez.Strings.NumberSystemMenuTitle);
const NUMBER_SYSTEM_PROPERTY = "NumberSystem";
const NUMBER_SYSTEM_MODE_DEFAULT = 10;

const NUMBER_SYSTEM_NAMES = Application.loadResource(Rez.JsonData.NumberSystems) as Array<String>;
