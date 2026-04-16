import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;


// A simple glance view for displaying an error message
// It is used for errors that occur before the standard glance view
// is created. Errors happening in the standard glance view are
// displayed there
(:glance :exclForGlanceNone) class GlanceErrorView extends WatchUi.GlanceView {
    private var _ex as Exception;

    function initialize( ex as Exception ) {
        GlanceView.initialize();
        _ex = ex;
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        GlanceErrorView.drawGlanceError( _ex, dc );
    }

    // Function to draw an error on a glance Dc
    // For the glance, the error is aligned to the left
    // and centered vertically, with a slight offset to the top which
    // makes the text align better with the logo
    public static function drawGlanceError( ex as Exception, dc as Dc ) as Void {
        var locX = PropertyHelper.getBoolean( Constants.PROPERTY_GLANCE_MARGIN_LEFT )
                    ? EvccGlanceView.getBaseSpacingInPixel( dc )
                    : 0;
        new WatchUi.TextArea( {
                :text => ExceptionHelper.getErrorMessage( ex ),
                :color => EvccColors.ERROR,
                :backgroundColor => Graphics.COLOR_TRANSPARENT,
                :font => [Graphics.FONT_GLANCE, Graphics.FONT_XTINY],
                :locX => locX,
                :locY => WatchUi.LAYOUT_VALIGN_CENTER,
                :justification => Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER,
                :width => dc.getWidth() - locX,
                :height => dc.getHeight() * 0.9 
            } ).draw( dc );
    }

}
