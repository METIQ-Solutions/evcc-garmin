import Toybox.Lang;
import Toybox.Timer;
import Toybox.Application.Properties;

// In widget mode, this registry singleton centrally manages all WebRequest instances

// This implementation is for for devices with multiple sites without pre-rendering of views.
// In this case, only one WebRequest is active at any given time. If the WebRequest 
// for a different site is request, then first the current WebRequest is stopped
// and purged from memory, and second the new one instantiated.

(:exclForSitesOne :exclForViewPreRenderingEnabled) public class WebRequestRegistry {
    private static var _siteIndex as Number?;
    private static var _stateRequest as TimedWebRequest?;

    public static function start( activeSiteIndex as Number ) as Void {}

    // Get the state request for a specific site
    // If the requested site is different from the one currently
    // activated, we discard the old one and create a new state
    // request for the requested site
    public static function getWebRequest( siteIndex as Number ) as WebRequest {
        if( siteIndex != _siteIndex ) {
            if( _stateRequest != null ) {
                _stateRequest.stop();
            }
            _stateRequest = new TimedWebRequest( siteIndex );
            _stateRequest.start();
            _siteIndex = siteIndex;
        }
        return _stateRequest as WebRequest;
    }

    // Stop the currently active state request
    public static function stopWebRequests() as Void {
        if( _stateRequest != null ) {
            _stateRequest.stop();
            _stateRequest = null;
            _siteIndex = null;
        }
    }
}
