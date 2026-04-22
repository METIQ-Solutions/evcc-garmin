import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application;

// Delegate for the system info view, only used to override the slide behavior
class SystemInfoDelegate extends WatchUi.BehaviorDelegate {
    function initialize() {
        BehaviorDelegate.initialize();
    }

    public function onBack() as Boolean {
        ViewStack.popView( WatchUi.SLIDE_BLINK );
        return true;
    }
}