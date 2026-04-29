import Toybox.Lang;

// In widget mode, this registry singleton centrally manages all WebRequest instances
// The WebRequest instances for all sites are kept in memory and active.

public class WebRequestRegistry {
    private static var _stateRequests as Array<WebRequest> = [];
    private static var _stateRequestTimer as MultiWebRequestsHandler?;

    // Sets the active site (information is only passed on to the handler, not needed in this class)
    public static function setActiveSite( activeSite as Number ) as Void { 
        // Logger.debug( "WebRequestRegistry: setting activeSite=" + activeSite );
        ( _stateRequestTimer as MultiWebRequestsHandler ).setActiveSite( activeSite );
    }

    // This functions instantiates all state requests and hands them over to 
    // the MultiWebRequestsHandler for the initial loading of data and then 
    // regular request of new data
    public static function start( activeSite as Number ) as Void {
        for( var i = 0; i < SiteConfigRepository.getSiteCount(); i++ ) {
            _stateRequests.add( new WebRequest( i ) );
        }
        _stateRequestTimer = new MultiWebRequestsHandler( _stateRequests, activeSite );
    }

    // Get the state request for a specific site
    public static function getWebRequest( site as Number ) as WebRequest {
        return _stateRequests[site];
    }

    // Stop all state requests
    public static function stop() as Void {
        // Stop the handler
        // If there is an error before we start the registry, then there may not
        // be a timer to stop. (e.g. if there is no site configuration)
        if( _stateRequestTimer != null ) {
            ( _stateRequestTimer as MultiWebRequestsHandler ).stopRequestTimer();
        }
    }
}