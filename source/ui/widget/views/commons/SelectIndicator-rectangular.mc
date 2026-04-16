import Toybox.Math;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;

(:exclForSelectRound30 :exclForSelectRound27 :exclForSelectRoundTouch :exclForSelectNone) 
class SelectIndicator {
    private const SELECT_LINE_WIDTH_FACTOR as Float = 0.01; // factor applied to dc width to calculate the width of the indicator
    private const SELECT_LENGTH_FACTOR as Float = 0.2;      // factor applied to dc height to calculate the length of the select indicator

    public function draw( dc as Dc ) as Void {
        // Constants are put inside the function, otherwise they'd need the annotations
        
        // Anti-alias is only available in newer SDK versions
        if( dc has :setAntiAlias ) {
            dc.setAntiAlias( true );
        }
        
        // Calculate all parameters for the arc
        var lineWidth = dc.getWidth() * SELECT_LINE_WIDTH_FACTOR;
        var lineLength = dc.getHeight() * SELECT_LENGTH_FACTOR;
        var x = dc.getWidth() - lineWidth/2;
        var yStart = dc.getHeight()*0.25 - lineLength/2;
        
        // Now draw the indicator in foreground color
        dc.setColor( EvccColors.FOREGROUND, EvccColors.BACKGROUND );
        dc.setPenWidth( lineWidth );
        dc.drawLine( x, yStart, x, yStart + lineLength );
    }
    public function getSpacing( calcDc as EvccDcInterface ) as Number { return Math.round( calcDc.getWidth() * SELECT_LINE_WIDTH_FACTOR ).toNumber(); }
}