using Toybox.Application.Properties;
using Toybox.WatchUi;

import Toybox.Lang;


class BaseTimeSettingsMenu extends WatchUi.Menu2 {

    function initialize() {

        Menu2.initialize({:title => CUSTOMIZE_MENU_TITLE});

        var standardTimeEnabled = PropertyUtils.getPropertyElseDefault(STANDARD_TIME_PROPERTY, STANDARD_TIME_MODE_DEFAULT);
        addItem(new WatchUi.ToggleMenuItem(
            STANDARD_TIME_LABEL, 
            null, 
            STANDARD_TIME_PROPERTY, 
            standardTimeEnabled, 
            null
        ));

        var numberSystemSelection = PropertyUtils.getPropertyElseDefault(NUMBER_SYSTEM_PROPERTY, NUMBER_SYSTEM_MODE_DEFAULT);
        var numberSystemName = NUMBER_SYSTEM_NAMES[numberSystemSelection - 2];
        addItem(new WatchUi.MenuItem(
            NUMBER_SYSTEM_LABEL, 
            numberSystemName, 
            NUMBER_SYSTEM_PROPERTY, 
            null
        ));

    }

}

class BaseTimeSettingsDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {

        var id = item.getId();
        
        if (id.equals(STANDARD_TIME_PROPERTY) && item instanceof WatchUi.ToggleMenuItem) {
            Properties.setValue(STANDARD_TIME_PROPERTY, item.isEnabled());
        }

        if (id.equals(NUMBER_SYSTEM_PROPERTY) && item instanceof WatchUi.MenuItem) {
            var currentSystem = PropertyUtils.getPropertyElseDefault(NUMBER_SYSTEM_PROPERTY, NUMBER_SYSTEM_MODE_DEFAULT);
            var newSystem = ((currentSystem - 1) % NUMBER_SYSTEM_NAMES.size()) + 2;
            Properties.setValue(NUMBER_SYSTEM_PROPERTY, newSystem);
            item.setSubLabel(NUMBER_SYSTEM_NAMES[newSystem - 2]);
        }

    }

    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }

}
