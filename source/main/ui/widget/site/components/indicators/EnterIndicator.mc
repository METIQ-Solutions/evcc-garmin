import Toybox.Math;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;

/* This class draws a simple, solid line next to the enter button,
 * to indicate that pressing it will trigger an action.
 * It is used for stateless actions, for example to open lower
 * level views assigned to the current view.
 *
 * There are two implementations of this class: one for round watch
 * faces and one for rectangular ones.
 */

/*
 * On round watch faces, the indicator is rendered as an arc
 * next to the enter button.
 */
(:exclForScreenRectangular) 
class EnterIndicator extends BaseEnterButtonIndicator {

    // Core parameters that can be set to modify the appearance of the arc
    protected const SELECT_LENGTH as Number = 18; // total length of the arc in degree

    // Calculated parameters
    protected const ANGLE_FROM = ANGLE_CENTER - SELECT_LENGTH / 2; // start angle
    protected const ANGLE_TO = ANGLE_CENTER + SELECT_LENGTH / 2; // end angle
 
    public function initialize() {
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
        dc.drawArc( X, Y, R, Graphics.ARC_COUNTER_CLOCKWISE, ANGLE_FROM - 2, ANGLE_TO + 2 );

        // Draw the actual arc
        dc.setColor( EvccColors.NAVIGATION, EvccColors.BACKGROUND );
        dc.setPenWidth( LINE_WIDTH );
        dc.drawArc( X, Y, R, Graphics.ARC_COUNTER_CLOCKWISE, ANGLE_FROM, ANGLE_TO );
    }
   
}

/*
 * On rectangular watch faces, the indicator is rendered as a line
 * next to the enter button.
 */
(:exclForScreenRound)
class EnterIndicator extends BaseEnterButtonIndicator {

    // Calculated parameters
    protected const LINE_LENGTH as Number = ( SCREEN_HEIGHT * LENGTH_RATIO ).toNumber();
    protected const Y_START = Y_CENTER - LINE_LENGTH/2;

    public function initialize() {
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
        dc.drawLine( X, Y_START - offset, X, Y_START + LINE_LENGTH + offset );

        // Draw the actual line
        dc.setColor( EvccColors.NAVIGATION, EvccColors.BACKGROUND );
        dc.setPenWidth( LINE_WIDTH );
        dc.drawLine( X, Y_START, X, Y_START + LINE_LENGTH );
    }
}

/*
 * Same functions used in the past for drawing different types of hint,
 * which are currently not in use.
 */
 
// For showing a visual tap hint

    /*
    private var TOUCH_RADIUS_INNER_FACTOR as Float = 0.02;
    private var TOUCH_RADIUS_OUTER_FACTOR as Float = 0.04;
    private var TOUCH_LINE_WIDTH_FACTOR as Float = 0.01;
    private var TOUCH_ANGLE as Number = 30;
    public function draw( dc as Dc ) as Void {

        // Anti-alias is only available in newer SDK versions
        if( dc has :setAntiAlias ) {
            dc.setAntiAlias( true );
        }
        
        // Set the line width
        var penWidth = Math.round( dc.getWidth() * TOUCH_LINE_WIDTH_FACTOR );

        // Inner radius is the dot, outer the half circle on top of it
        var radiusInner = dc.getWidth() * TOUCH_RADIUS_INNER_FACTOR;
        var radiusOuter = dc.getWidth() * TOUCH_RADIUS_OUTER_FACTOR;


        // Initialize coordinates
        var x = dc.getHeight() / 2;
        var y = dc.getWidth() / 2;
        // The distance from the screen center to the center of the hint
        var centerToCenter = x - radiusOuter - penWidth/2;

        // Use trigonometry to calculate center position of the hint
        // Source for formulas: http://elsenaju.info/Rechnen/Trigonometrie.htm
        
        // For the Math functions, degrees need to be converted to radians
        var radian = TOUCH_ANGLE * 0.017453;
        y = y - centerToCenter * Math.sin( radian );
        x = x + centerToCenter * Math.cos( radian );

        // First draw a bigger version in background color
        // In case of overlaps with content, this visually offsets
        // the select indicator from the underlying content
        dc.setColor( EvccColors.BACKGROUND, EvccColors.BACKGROUND );
        dc.drawArc( x, y, radiusOuter, Graphics.ARC_COUNTER_CLOCKWISE, 340, 200 );
        dc.setPenWidth( penWidth * 4 );
        dc.fillCircle( x, y, radiusInner * 2 );

        // Now draw the indicator in foreground color
        dc.setColor( EvccColors.NAVIGATION, EvccColors.BACKGROUND );
        dc.fillCircle( x, y, radiusInner );
        dc.setPenWidth( penWidth );
        dc.drawArc( x, y, radiusOuter, Graphics.ARC_COUNTER_CLOCKWISE, 0, 180 );
    }

    public function getSpacing( calcDc as EvccDcInterface ) as Number { 
        // The spacing is based on diameter. However, since the hint sits at
        // the 30° (2 o'clock) position, and wider content usually sits further down,
        // we do not need to keep the full spacing. Testing has shown that 1/4
        // of the diameter gives good results.
        var radiusOuter = calcDc.getWidth() * TOUCH_RADIUS_OUTER_FACTOR;
        var diameter = radiusOuter * 2 + Math.round( calcDc.getWidth() * TOUCH_LINE_WIDTH_FACTOR );
        return Math.round( ( diameter / 4 ).toFloat() ).toNumber(); 
    }
    */

// Swipe indicator
    
    /*
    public function draw( dc as Dc ) {
        
        // Anti-alias is only available in newer SDK versions
        if( dc has :setAntiAlias ) {
            dc.setAntiAlias( true );
        }
        dc.setPenWidth( Math.round( dc.getWidth() * 0.01 ) ); // Line width is set here
        dc.drawArc( dc.getWidth() * 1.125 - 20, 
                    dc.getHeight() / 2, 
                    dc.getWidth() / 8,
                    Graphics.ARC_COUNTER_CLOCKWISE,
                    140,
                    220 );
        dc.drawLine( dc.getWidth() - 10, dc.getHeight() / 2, dc.getWidth(), dc.getHeight() / 2 - 5 );
        dc.drawLine( dc.getWidth() - 10, dc.getHeight() / 2, dc.getWidth(), dc.getHeight() / 2 + 5 );
    }
    */
