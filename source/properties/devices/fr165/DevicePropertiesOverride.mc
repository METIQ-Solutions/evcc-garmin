import Toybox.Lang;

/*
 * Provides device-specific overrides for the default properties.
 */
 (:glance) 
class DevicePropertiesOverride extends DeviceProperties {
    
    public static const GLANCE_HAS_LEFT_MARGIN as Boolean = true;

    public static const SELECT_INDICATOR_ANGLE as Number = 27;

    public function initialize() { DeviceProperties.initialize(); }

}