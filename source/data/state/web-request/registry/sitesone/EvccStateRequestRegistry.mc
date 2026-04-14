import Toybox.Lang;
import Toybox.Timer;
import Toybox.Application.Properties;

// In widget mode, this registry singleton centrally manages all WebRequest instances

// This is the simplest version, for devices with only one site

(:exclForSitesMultiple) public class WebRequestRegistry {
    private static var _stateRequest as TimedWebRequest?;

    public static function start( activeSiteIndex as Number ) as Void {}

    // Get the state request for the site
    // siteIndex is only kept as parameter to be compatible with the
    // other implementations, but in this scenario will always be 0.
    public static function getWebRequest( siteIndex as Number ) as WebRequest {
        if( _stateRequest == null ) {
            _stateRequest = new TimedWebRequest( siteIndex );
            _stateRequest.start();
        }
        return _stateRequest as WebRequest;
    }

    // Stop the state request
    public static function stopWebRequests() as Void {
        if( _stateRequest != null ) {
            _stateRequest.stop();
            _stateRequest = null;
        }
    }
}