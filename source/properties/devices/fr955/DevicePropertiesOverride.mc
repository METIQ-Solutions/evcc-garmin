import Toybox.Lang;

/*
 * Provides device-specific overrides for the default properties.
 */
 (:glance) 
class DevicePropertiesOverride extends DeviceProperties {
    
    public static const VECTOR_FONT_FACE as Array<String> = [ "RobotoCondensedRegular" ];

    public function initialize() { DeviceProperties.initialize(); }

}