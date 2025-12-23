using Toybox.Application;
using Toybox.Test;

import Toybox.Lang;


const TEST_NAME = "name";
const TEST_BASE = "base";
const TEST_TIME = "time";
const TEST_TIME_HOUR = "hour";
const TEST_TIME_MINUTES = "minutes";
const TEST_EXPECTED = "expected";
const TEST_BASE_TIME_ERROR_TEMPLATE = "Test '$1$' failed: expected '$2$:$3$', got '$4$:$5$'";


(:test)
function testBaseTime(logger) as Boolean {
    var tests = Application.loadResource(Rez.JsonData.BaseTimeTests) as Array<Dictionary>;
    var pass = true;
    for (var i = 0; i < tests.size(); i++) {
        var test = tests[i];
        var name = test[TEST_NAME] as String;
        var base = test[TEST_BASE] as Number;
        var time = test[TEST_TIME] as Dictionary;
        var hour = time[TEST_TIME_HOUR] as Number;
        var minutes = time[TEST_TIME_MINUTES] as Number;
        var expected = test[TEST_EXPECTED] as Dictionary<String, String>;
        var expectedHour = expected[TEST_TIME_HOUR] as String;
        var expectedMinutes = expected[TEST_TIME_MINUTES] as String;
        var result = BaseTime.formatTime(hour, minutes, base) as Dictionary<Object, String>;
        var resultHour = result[:hour] as String;
        var resultMinutes = result[:minutes] as String;
        if (!resultHour.equals(expectedHour) || !resultMinutes.equals(expectedMinutes)) {
            var message = Lang.format(TEST_BASE_TIME_ERROR_TEMPLATE, [name, expectedHour, expectedMinutes, resultHour, resultMinutes]);
            logger.error(message);
            pass = false;
        }
    }
    return pass;
}
