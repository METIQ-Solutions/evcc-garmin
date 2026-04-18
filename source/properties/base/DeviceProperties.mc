import Toybox.Lang;

/*
 * Device properties define device-specific configuration.
 * This base class provides the default values.
 *
 * This replaces the CIQ API property resources, which are not suitable
 * because their values remain fixed once the app is installed and
 * cannot be overridden by later updates.
 *
 * This class uses a singleton pattern with a twist: for individual devices,
 * a DevicePropertiesOverride class can be provided. This class must extend
 * this base class and be included in the source path via monkey.jungle
 * build instructions. If present, the override class is instantiated instead
 * of the default implementation.
 *
 * Using a singleton is necessary due to a limitation of the Monkey C compiler:
 * accessing inherited static members via the class definition works in
 * instance methods, but not in static methods.
 */
(:glance)
class DeviceProperties {

    /******** PROPERTIES ********/

    // If true, a margin is applied to the left side of the
    // glance content. This is used for devices that have a
    // visual separator between the logo and the content,
    // preventing the content from being too close to the separator.
    public static const GLANCE_HAS_LEFT_MARGIN as Boolean = false;

    // The default vector font faces are:
    // - RobotoRegular: system font on Fenix 8
    // - RobotoCondensedBold: system font on Fenix 8 Solar and older versions
    // The devices where RobotoCondensedBold is system font do not have
    // RobotoRegular, so this one setting works for both types
    public static const VECTOR_FONT_FACE as Array<String> = [ "RobotoRegular", "RobotoCondensedBold" ];

    // Where to show the select button indicator on round screens
    // 30°  = 2 o'clock
    // 27°  = 2 o'clock + 0.5 minutes
    (:exclForScreenRectangular) 
    public static const SELECT_INDICATOR_ANGLE as Number = 30;

    // Where to show the select button indicator on rectangular screens
    // 25 = the center of the indicator is at 25% of the screen height
    (:exclForScreenRound) 
    public static const SELECT_INDICATOR_VERTICAL_POSITION as Number = 25;


    /******** SINGLETON ACCESSOR ********/

    private static var _instance as DeviceProperties?;

    // The singleton accessor returns either an instance of this class
    // or, if available, a device-specific override.
    public static function get() as DeviceProperties {
        if( _instance == null ) {
            if( $ has :DevicePropertiesOverride ) {
                _instance = new DevicePropertiesOverride();
            } else {
                _instance = new DeviceProperties();
            }
        }
        return _instance;
    }


    /******** INSTANCE ********/

    public function initialize() {}

}
