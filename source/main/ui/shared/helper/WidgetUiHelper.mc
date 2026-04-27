import Toybox.Lang;
import Toybox.Graphics;

// Helper functions for Widget UI rendering
class WidgetUiHelper extends GlanceUiHelper {
    
    // Sets the colors and clears the device context
    public static function clearDc( dc as Dc ) as Void {
        dc.setColor( EvccColors.CONTENT, EvccColors.BACKGROUND );
        dc.clear();
    }


    // Function to format power values for the main view
    public static function formatPower( power as Number? ) as String {
        // We always use kW, even for small values, to make
        // the display consistent
        if( power == null ) { power = 0; }
        return ( power / 1000.0 ).format("%.1f") + "kW";
    }


    // Format temperature of heaters
    public static function formatTemp( temp as Number ) as String { 
        if( temp != null ) {
            return temp.format("%.0f") + "°";
        } else {
            return "";
        }
    }


    // Returns a formatted string of duration specified in nano seconds (as provided in the evcc response)
    // Format is the same as used on the evcc Web UI (hh:mm h or mm:ss m)
    public static function formatDuration( duration as Number ) as String { 
        // Earlier evcc versions use nanoseconds, later ones (>~ 0.127.1)
        // use seconds. If the value is greater than a billion, we assume it
        // is nanos and convert to seconds
        if( duration > 1000000000 ) {
            duration = ( duration / 1000000000 ) as Number;
        }
        var hours = ( ( duration / 60 ) / 60 ) as Number;
        if( hours > 0 ) {
            var minutes = ( ( duration / 60 ) % 60 ) as Number;
            return hours.format("%02d") + ":" + minutes.format("%02d") + " h"; 
        } else {
            var minutes = ( duration / 60 ) as Number;
            var seconds = ( duration % 60 ) as Number;
            return minutes.format("%02d") + ":" + seconds.format("%02d") + " m"; 
        }
    }


    // Returns the text to be displayed for the charging mode
    public static function formatMode( loadpoint as Loadpoint ) as String { 
        var mode = loadpoint.getMode();
        if( mode.equals( "pv" ) ) { return "SOLAR"; }
        else if( mode.equals( "minpv" ) ) { return "MIN+SOLAR"; }
        else if( mode.equals( "now" ) ) { return "FAST"; }
        else if( mode.equals( "off" ) ) { return "OFF"; }
        else { return mode; }
    }

    
    // Needed to satisfy the compiler
    private function initialize() {
        GlanceUiHelper.initialize();
    }

}