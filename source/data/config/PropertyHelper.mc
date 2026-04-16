import Toybox.Lang;
import Toybox.Application;

/*
 * Provides access to properties.
 */
(:glance) 
class PropertyHelper {

    public static function getBoolean( key as String ) as Boolean {
        try {
            var value = Properties.getValue( key );
            return value instanceof Boolean
                    ? value as Boolean
                    : false;
        } catch ( ex ) {
            // as Lang.UnexpectedTypeException
            return false;
        }
    }

}

