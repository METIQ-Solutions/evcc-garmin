import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.Math;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Application;

// Helper functions for Glance UI rendering
(:glance) 
class GlanceUiHelper {

    // Format SoC of battery or vehicles
    public static function formatSoc( soc as Number? ) as String { 
        if( soc != null ) {
            return soc.format("%.0f") + "%";
        } else {
            return "";
        }
    }

}

