import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Math;

// A simple widget view for displaying an error message
// It is used for errors that occur before the standard widget view
// is created. Errors happening in the standard widget view are
// displayed there
class ErrorView extends WatchUi.View {
    

    /******** STATIC ********/


    // Function to draw an error on a widget Dc
    // For the widget, the error is centered vertically and horizontally
    // The area for the text is the square that fits into the round watch face
    // This way we maximize the available area. There may be some overlaps with the
    // shell, for especially with the page title of detail views, but that is
    // acceptable. Otherwise we'd have to take the content area and calculate the coordinates
    // of the largest rectangle that fits into both the circle and the (non-aligned)
    // content area, which would be a quite complicated algorithm.
    public static function drawWidgetError( ex as Exception, dc as Dc ) as Void {
        // The text area will be in the square fitting into
        // the round watch face
        var width = dc.getWidth() / Math.sqrt( 2 );
        new WatchUi.TextArea( {
                :text => ExceptionHelper.getErrorMessage( ex ),
                :color => EvccColors.ERROR,
                :backgroundColor => EvccColors.BACKGROUND,
                :font => EvccResources.getGarminFonts(),
                :locX => WatchUi.LAYOUT_HALIGN_CENTER,
                :locY => WatchUi.LAYOUT_VALIGN_CENTER,
                :justification => Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER,
                :width => width,
                :height => width 
            } ).draw( dc );
    }


    /******** INSTANCE ********/


    private var _ex as Exception;

    function initialize( ex as Exception ) {
        View.initialize();
        _ex = ex;
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        WidgetUiHelper.clearDc( dc );
        drawWidgetError( _ex, dc );
    }

}
