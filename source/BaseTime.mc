using Toybox.Application;

import Toybox.Lang;


module BaseTime {

    function formatTime(hour as Number, minutes as Number, base as Number) as Dictionary<Object, String> {
        var maxHourLength = _toString(MAX_HOURS, base).length();
        var maxMinuteLength = _toString(MAX_MINUTES, base).length();
        var hourPadded = _pad(_toString(hour, base), HOUR_PADDING, maxHourLength);
        var minutesPadded = _pad(_toString(minutes, base), MINUTES_PADDING, maxMinuteLength);
        return {
            :hour => hourPadded, 
            :minutes => minutesPadded
        };
    }

    function _toString(number as Number, base as Number) as String {
        if (number == 0) {
            return DIGITS[0];
        }
        var result = "";
        var current = number;
        while (current > 0) {
            var remainder = current % base;
            current = current / base;
            result = DIGITS[remainder] + result;
        }
        return result;
    }

    function _pad(string as String, pad as String, length as Number) as String {
        while (string.length() < length) {
            string = pad + string;
        }
        return string;
    }

}
