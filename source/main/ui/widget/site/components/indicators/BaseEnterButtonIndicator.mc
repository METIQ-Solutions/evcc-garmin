import Toybox.Math;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;

/*
 * Abstract base class for drawing an indicator next to the enter
 * key, signaling that an action is available.
 *
 * There are two implementations of this class: one for round watch
 * faces and one for rectangular ones.
 *
 * The base class calculates common parameters that are used by
 * subclasses to render the actual indicator.
 */

/*
 * On round watch faces, the indicator is rendered as an arc
 * next to the enter button.
 */
(:exclForScreenRectangular) 
class BaseEnterButtonIndicator {

    // Screen width is needed to calculate the parameters for the arc
    protected const SCREEN_WIDTH = System.getDeviceSettings().screenWidth;

    // Core parameters that can be set to modify the appearance of the arc
    protected const SELECT_RADIUS_RATIO as Float = 0.49; // factor applied to dc width to calculate the radius of the arc
    protected const SELECT_LINE_WIDTH_RATIO as Float = 0.01; // factor applied to dc width to calculate the width of the arc

    // Calculated parameters
    protected const LINE_WIDTH = SCREEN_WIDTH * SELECT_LINE_WIDTH_RATIO;
    protected const X = SCREEN_WIDTH / 2; // center x of the arc
    protected const Y = SCREEN_WIDTH / 2; // center y of the arc
    protected const R = SCREEN_WIDTH * SELECT_RADIUS_RATIO; // radius of the arc
    
    // The device-specific position of the enter button,
    // expressed as angle
    protected const ANGLE_CENTER = DeviceProperties.get().SELECT_INDICATOR_ANGLE;
 
    protected function initialize() {}
    
    // Drawing function, to be implemented by subclasses
    public function draw( dc as Dc ) as Void {}

    // Returns the spacing that should be applied on the right side
    // of content if the select indicator is drawn
    public function getSpacing( calcDc as EvccDcInterface ) as Number { return Math.round( calcDc.getWidth() * SELECT_LINE_WIDTH_RATIO ).toNumber(); }
   
}

/*
 * On rectangular watch faces, the indicator is rendered as a line
 * next to the enter button.
 */
(:exclForScreenRound)
class BaseEnterButtonIndicator {

    // Screen dimensions are needed to calculate the parameters for the line
    protected const SCREEN_WIDTH as Number = System.getDeviceSettings().screenWidth;
    protected const SCREEN_HEIGHT as Number = System.getDeviceSettings().screenHeight;

    // Core parameters that can be set to modify the appearance of the line
    protected const LINE_WIDTH_RATIO as Float = 0.01; // factor applied to dc width to calculate the width of the indicator
    protected const LENGTH_RATIO as Float = 0.2;      // factor applied to dc height to calculate the length of the select indicator

    // Calculated parameters
    protected const LINE_WIDTH as Number = ( SCREEN_WIDTH * LINE_WIDTH_RATIO ).toNumber();
    protected const X as Number = SCREEN_WIDTH - LINE_WIDTH/2; // x position of the line

    // The device-specific vertical position of the button,
    // expressed as a percentage of the screen height (0–100).
    // It is converted to a ratio by multiplying by 0.01.
    protected const Y_CENTER = SCREEN_HEIGHT * 0.01 * DeviceProperties.get().SELECT_INDICATOR_VERTICAL_POSITION;
    
    protected function initialize() {}

    // Drawing function, to be implemented by subclasses
    public function draw( dc as Dc ) as Void {}

    // Returns the spacing that should be applied on the right side
    // of content if the select indicator is drawn
    public function getSpacing( calcDc as EvccDcInterface ) as Number { return Math.round( calcDc.getWidth() * LINE_WIDTH_RATIO ).toNumber(); }
}