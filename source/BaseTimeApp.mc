using Toybox.Application;
using Toybox.WatchUi;


class BaseTimeApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state) {
    }

    function onStop(state) {
    }

    function getInitialView() {
        return [ new BaseTimeView() ];
    }

    function onSettingsChanged() as Void {
        WatchUi.requestUpdate();
    }

    function getSettingsView() {
        return [ new BaseTimeSettingsMenu(), new BaseTimeSettingsDelegate() ];
    }

}