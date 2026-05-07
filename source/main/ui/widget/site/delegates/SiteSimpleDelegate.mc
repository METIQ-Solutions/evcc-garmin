import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application;

// Delegate processing user input for single screen mode (only one site)
class SiteSimpleDelegate extends WatchUi.BehaviorDelegate {
    function initialize() {
        // Logger.debug( "SiteSimpleDelegate: initialize" );
        BehaviorDelegate.initialize();
    }

    public function onBack() as Boolean {
        ViewStack.popView( WatchUi.SLIDE_RIGHT );
        return true;
    }

    public function onMenu() as Boolean {
        // Logger.debug( "SiteSimpleDelegate: onMenu" );
        ViewStack.pushView( new SystemInfoView(), new SystemInfoDelegate(), WatchUi.SLIDE_BLINK );
        return true;
    }

    // Tap and hold on the touch screen also triggers the system info view
    // This was introduced for Vivoactive6, since that watch does not have
    // the onMenu behavior anymore.
    public function onHold( clickEvent ) as Boolean {
        // Logger.debug( "SiteSimpleDelegate: onHold" );
        return onMenu();
    }
}