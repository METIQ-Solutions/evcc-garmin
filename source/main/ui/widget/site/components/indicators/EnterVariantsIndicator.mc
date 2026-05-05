import Toybox.Math;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;

/* Draws an option indicator next to the enter button.
 *
 * The indicator shows that pressing enter cycles through multiple options.
 * It is rendered as dotted sections, one per option, with the active option
 * highlighted.
 *
 * Separate implementations handle round and rectangular watch faces.
 */

/*
 * On round watch faces, the indicator is rendered as an arc
 * next to the enter button.
 */
(:exclForScreenRectangular) 
class EnterVariantsIndicator extends BaseEnterButtonIndicator {

    // Core parameters controlling the visual appearance of the arc indicator.

    // Angular size (in degrees) of a single drawing step.
    // All strokes and gaps are composed of these discrete steps.
    private const STEP_ANGLE = 2;

    // Ratio between the length of a stroke (visible segment) and the gap
    // between strokes, expressed in number of steps.
    //
    // The gap is always exactly one STEP_ANGLE unit, while the stroke length
    // is calculated as STROKE_TO_GAP_RATIO × STEP_ANGLE.
    //
    // Example:
    // A value of 2 results in a pattern of two steps for the stroke followed
    // by one step for the gap.
    private const STROKE_TO_GAP_RATIO as Number = 2;

    // Parameters passed in at runtime
    private var _totalOptions as Number; // the total number of options
    private var _variantIndex as Number;  // the 0-based index of the current option
    
    // Drawing parameters calculated from the runtime parameters
    private var _angleTotal as Number;
    private var _angleFrom as Float;
    private var _angleTo as Float;

    // Constructor
    public function initialize( optionIndex as Number, totalOptions as Number ) {
        _totalOptions = totalOptions;
        _variantIndex = optionIndex;
        // Defines the angular span of the indicator in degrees,
        // including its total length as well as the start and end angles.
        _angleTotal = STEP_ANGLE * ( _totalOptions * STROKE_TO_GAP_RATIO + _totalOptions - 1 );
        _angleFrom = ANGLE_CENTER - _angleTotal.toFloat()/2;
        _angleTo = ANGLE_CENTER + _angleTotal.toFloat()/2;
        BaseEnterButtonIndicator.initialize();
    }

    // Draws the arc
    public function draw( dc as Dc ) as Void {
        WidgetUiHelper.activateAntiAlias( dc );

        // As background, we draw a wider and longer arc in background color
        // In case of overlaps with content, this visually offsets
        // the select indicator from the underlying content
        dc.setColor( EvccColors.BACKGROUND, EvccColors.BACKGROUND );
        dc.setPenWidth( LINE_WIDTH * 4 );
        dc.drawArc( X, Y, R, Graphics.ARC_COUNTER_CLOCKWISE, _angleFrom - 2, _angleTo + 2 );

        // Draw the actual arc
        dc.setPenWidth( LINE_WIDTH );
        var currentAngle = _angleFrom;
        for( var i = _totalOptions - 1; i >= 0; i-- ) {
            dc.setColor( 
                i == _variantIndex ? EvccColors.NAVIGATION : EvccColors.ACCENT, 
                EvccColors.BACKGROUND 
            );

            var toAngle = currentAngle + STEP_ANGLE*STROKE_TO_GAP_RATIO;
            dc.drawArc( 
                X, Y, R, 
                Graphics.ARC_COUNTER_CLOCKWISE, 
                currentAngle, 
                toAngle 
            );
            currentAngle = toAngle + STEP_ANGLE;
        }
    }
}

/*
 * On rectangular watch faces, the indicator is rendered as a line
 * next to the enter button.
 */
(:exclForScreenRound)
class EnterVariantsIndicator extends BaseEnterButtonIndicator {

    // Core parameters controlling the visual appearance of the arc indicator.

    // Length of a single drawing step in pixel.
    // All strokes and gaps are composed of these discrete steps.
    private const STEP_LENGTH as Number = ( SCREEN_HEIGHT * 0.025 ).toNumber();

    // Ratio between the length of a stroke (visible segment) and the gap
    // between strokes, expressed in number of steps.
    //
    // The gap is always exactly one STEP_LENGTH unit, while the stroke length
    // is calculated as STROKE_TO_GAP_RATIO × STEP_ANGLE.
    //
    // Example:
    // A value of 2 results in a pattern of two steps for the stroke followed
    // by one step for the gap.
    private const STROKE_TO_GAP_RATIO as Float = 1.5;

    // Parameters passed in at runtime
    private var _totalOptions as Number; // the total number of options
    private var _variantIndex as Number;  // the 0-based index of the current option
    
    // Drawing parameters calculated from the runtime parameters
    private var _totalLength as Number;
    private var _yStart as Number;
    private var _yEnd as Number;

    // Constructor
    public function initialize( optionIndex as Number, totalOptions as Number ) {
        _variantIndex = optionIndex;
        _totalOptions = totalOptions;
        _totalLength = ( STEP_LENGTH * ( _totalOptions * STROKE_TO_GAP_RATIO + _totalOptions - 1 ) ).toNumber();
        _yStart = ( Y_CENTER - _totalLength/2 ).toNumber();
        _yEnd = ( Y_CENTER + _totalLength/2 ).toNumber();
        BaseEnterButtonIndicator.initialize();
    }

    // Draw the line
    public function draw( dc as Dc ) as Void {
        WidgetUiHelper.activateAntiAlias( dc );

        // As background, we draw a wider and longer line in background color
        // In case of overlaps with content, this visually offsets
        // the select indicator from the underlying content
        dc.setColor( EvccColors.BACKGROUND, EvccColors.BACKGROUND );
        var offset = LINE_WIDTH * 3;
        dc.setPenWidth( LINE_WIDTH + offset );
        dc.drawLine( X, _yStart - offset, X, _yEnd + offset );

        // Draw the actual line
        dc.setPenWidth( LINE_WIDTH );
        var yStart = _yStart;
        for( var i = 0; i < _totalOptions; i++ ) {
            dc.setColor( 
                i == _variantIndex ? EvccColors.NAVIGATION : EvccColors.ACCENT, 
                EvccColors.BACKGROUND 
            );
            var yEnd = yStart + STEP_LENGTH*STROKE_TO_GAP_RATIO;
            dc.drawLine( X, yStart, X, yEnd );
            yStart = yEnd + STEP_LENGTH;
        }
    }
}