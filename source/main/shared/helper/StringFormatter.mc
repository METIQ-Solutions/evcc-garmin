import Toybox.Lang;
import Toybox.Graphics;

(:glance)
class StringFormatter {
    
    public static function pad2( value as Number ) as String {
        if (value < 10) {
            return "0" + value.toString();
        }
        return value.toString();
    }
}