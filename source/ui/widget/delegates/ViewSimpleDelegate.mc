import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application;

// Delegate processing user input for single screen mode (only one site)
class ViewSimpleDelegate extends WatchUi.BehaviorDelegate {
    function initialize() {
        // HelperBase.debug( "ViewSimpleDelegate: initialize" );
        BehaviorDelegate.initialize();
    }

    public function onBack() as Boolean {
        ViewStack.popView( WatchUi.SLIDE_BLINK );
        return true;
    }

    public function onMenu() as Boolean {
        // HelperBase.debug( "ViewSimpleDelegate: onMenu" );
        WatchUi.pushView( new SystemInfoView(), new ViewSystemInfoDelegate(), WatchUi.SLIDE_BLINK );
        return true;
    }

    // Tap and hold on the touch screen also triggers the system info view
    // This was introduced for Vivoactive6, since that watch does not have
    // the onMenu behavior anymore.
    public function onHold( clickEvent ) as Boolean {
        // HelperBase.debug( "ViewSimpleDelegate: onHold" );
        return onMenu();
    }
}