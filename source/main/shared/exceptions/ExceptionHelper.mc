import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.Math;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Application;

// UI helper is available in glance and foreground scope
(:glance) 
class ExceptionHelper {

    // Assemble the error message from an exception
    public static function getErrorMessage( ex as Exception ) as String {
        if( ex instanceof EvccBaseException ) {
            return ex.getScreenMessage();
        } else {
            // For unknown errors we show the evcc version, to help supporting
            // users on the forum. Also unknown errors are displayed in a text
            // area to be able to show their full text
            return ex.getErrorMessage() + "\nevvcg " + TextProvider.getVersion();
        }
    }

}

