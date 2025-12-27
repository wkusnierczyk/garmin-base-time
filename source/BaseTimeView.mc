using Toybox.Application.Properties;
using Toybox.Graphics;
using Toybox.WatchUi;

import Toybox.Lang;


class BaseTimeView extends WatchUi.WatchFace {

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    function onShow() {
    }

    function onUpdate(dc) {

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);
        dc.fillRectangle(0, 0, dc.getWidth(), dc.getHeight());

        var clockTime = System.getClockTime();
        var hour = clockTime.hour;
        var minutes = clockTime.min;
        var seconds = clockTime.sec;

        _drawStandardTime(null, hour, minutes, seconds);
        View.onUpdate(dc);

        _drawBaseTime(dc, hour, minutes, seconds);


    }

    private function _drawBaseTime(dc as Graphics.Dc or Null, hour as Number, minutes as Number, seconds as Number) {
        var base = PropertyUtils.getPropertyElseDefault(NUMBER_SYSTEM_PROPERTY, NUMBER_SYSTEM_MODE_DEFAULT);
        if (base < 4) {
            _drawDoubleLineBaseTime(dc, hour, minutes, seconds, base);
        } else {
            _drawSingleLineBaseTime(dc, hour, minutes, seconds, base);
        }
    }

    private function _drawSingleLineBaseTime(dc as Graphics.Dc or Null, hour as Number, minutes as Number, seconds as Number, base as Number) {

        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerY = height / 2 - 5;

        var hourFont = SINGLE_LINE_HOUR_FONT;
        var minutesFont = SINGLE_LINE_MINUTES_FONT;
        var baseFont = SINGLE_LINE_SYSTEM_BASE_FONT;

        var timeStrings = BaseTime.formatTime(hour, minutes, base);
        var hourString = timeStrings[:hour];
        var minutesString = timeStrings[:minutes];
        var baseString = DIGITS[base];

        var hourWidth = dc.getTextWidthInPixels(hourString, hourFont);
        var minutesWidth = dc.getTextWidthInPixels(minutesString, minutesFont);

        var baseDimensions = dc.getTextDimensions(baseString, baseFont);
        var baseWidth = baseDimensions[0];
        var baseHeight = baseDimensions[1];
        var baseY = centerY + baseHeight / 2;

        var timeWidth = hourWidth + minutesWidth;
        var totalWidth = timeWidth + baseWidth;

        var currentX = (width - totalWidth) / 2;

        dc.setColor(HOUR_COLOR, Graphics.COLOR_TRANSPARENT);
        dc.drawText(currentX, centerY, hourFont, hourString, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        currentX += hourWidth;
        
        dc.setColor(MINUTES_COLOR, Graphics.COLOR_TRANSPARENT);
        dc.drawText(currentX, centerY, minutesFont, minutesString, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        currentX += minutesWidth;

        dc.setColor(BASE_COLOR, Graphics.COLOR_TRANSPARENT);
        dc.drawText(currentX, baseY, baseFont, baseString, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

    }

    private function _drawDoubleLineBaseTime(dc as Graphics.Dc or Null, hour as Number, minutes as Number, seconds as Number, base as Number) {

        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerY = height / 2 - 5;

        var hourFont = DOUBLE_LINE_HOUR_FONT;
        var minutesFont = DOUBLE_LINE_MINUTES_FONT;
        var baseFont = DOUBLE_LINE_SYSTEM_BASE_FONT;

        var timeStrings = BaseTime.formatTime(hour, minutes, base);
        var hourString = timeStrings[:hour];
        var minutesString = timeStrings[:minutes];
        var baseString = DIGITS[base];

        var hourDimensions = dc.getTextDimensions(hourString, hourFont);
        var hourHeight = hourDimensions[1];
        var hourY = centerY - hourHeight / 2;
        
        var minutesDimensions = dc.getTextDimensions(minutesString, minutesFont);
        var minutesWidth = minutesDimensions[0];
        var minutesHeight = minutesDimensions[1];
        var minutesY = centerY + minutesHeight / 2 - 10;

        var baseDimensions = dc.getTextDimensions(baseString, baseFont);
        var baseWidth = baseDimensions[0];
        var baseHeight = baseDimensions[1];
        var baseY = minutesY + baseHeight / 2;

        var totalWidth = minutesWidth + baseWidth;
        var referenceX = (width + totalWidth) / 2;

        dc.setColor(HOUR_COLOR, Graphics.COLOR_TRANSPARENT);
        dc.drawText(referenceX, hourY, hourFont, hourString, Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
        
        dc.setColor(MINUTES_COLOR, Graphics.COLOR_TRANSPARENT);
        dc.drawText(referenceX, minutesY, minutesFont, minutesString, Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.setColor(BASE_COLOR, Graphics.COLOR_TRANSPARENT);
        dc.drawText(referenceX, baseY, baseFont, baseString, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

    }

    private function _drawStandardTime(dc as Graphics.Dc or Null, hour as Number, minutes as Number, seconds as Number) {
        var standardTimeEnabled = PropertyUtils.getPropertyElseDefault(STANDARD_TIME_PROPERTY, STANDARD_TIME_MODE_DEFAULT);
        if (standardTimeEnabled) {
            var standardTime = Lang.format("$1$:$2$:$3$", [
                hour.format("%d"),
                minutes.format("%02d"),
                seconds.format("%02d")
            ]);
            var standardTimeView = View.findDrawableById(STANDARD_TIME_LAYOUT_ID) as WatchUi.Text;
            standardTimeView.setText(standardTime);
        }
    }

}