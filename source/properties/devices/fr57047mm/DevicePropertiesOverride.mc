import Toybox.Lang;

/*
 * Provides device-specific overrides for the default properties.
 */
 (:glance) 
class DevicePropertiesOverride extends DeviceProperties {
    
    public static const SELECT_INDICATOR_ANGLE as Number = 25;

    public function initialize() { DeviceProperties.initialize(); }

}