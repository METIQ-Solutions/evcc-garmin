import Toybox.Lang;
import Toybox.System;
import Toybox.Graphics;

/*
 * A block that adds horizontal and/or vertical spacing.
 *
 * The spacing is defined by the following options passed to the constructor:
 * :relativeToScreenWidth: width as a percentage of the screen width
 *                         (e.g. 0.2 corresponds to 20% of the screen width, default: 0.0)
 * :relativeToScreenHeight: height as a percentage of the screen height
 *                          (default: 0.0)
 * :relativeToFontHeight: height as a percentage of the font height
 *                        (default: 0.0)
 *
 * If both :relativeToScreenHeight and :relativeToFontHeight are set,
 * :relativeToScreenHeight takes precedence.
 */
 (:glance :exclForMemoryLow) class EvccSpacerBlock extends EvccBlock {

    private var _relativeToScreenWidth as Float;
    private var _relativeToScreenHeight as Float;
    private var _relativeToFontHeight as Float;

    // Constructor
    function initialize( options as DbOptions ) {
        EvccBlock.initialize( options );
        _relativeToScreenWidth = getFloatOption(:relativeToScreenWidth);
        _relativeToScreenHeight = getFloatOption(:relativeToScreenHeight);
        _relativeToFontHeight = getFloatOption(:relativeToFontHeight);
    }

    // Calculate width & height
    protected function calculateWidth() as Number { 
        return ( _relativeToScreenWidth * System.getDeviceSettings().screenWidth ).toNumber();
    }
    protected function calculateHeight() as Number { 
        return ( _relativeToScreenHeight > 0.0 
                    ? _relativeToScreenHeight * System.getDeviceSettings().screenHeight
                    : _relativeToFontHeight * getFontHeight()
        ).toNumber();
    }

    // No drawing is needed
    public function drawPrepared( dc as Dc ) as Void {}
    public function prepareDraw( x as Number, y as Number ) as Void {}
}
