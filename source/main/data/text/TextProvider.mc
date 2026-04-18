import Toybox.Lang;
import Toybox.Application;

/*
 * Provides access to string resources.
 */
(:glance) 
class TextProvider {

    public static function getVersion() as String {
        return Application.loadResource( Rez.Strings.AppVersion ) as String;
    }

}

