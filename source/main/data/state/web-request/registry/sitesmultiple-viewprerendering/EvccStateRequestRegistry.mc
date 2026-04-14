import Toybox.Lang;

// In widget mode, this registry singleton centrally manages all WebRequest instances
// This implementation is for devices with multiple sites and pre-rendering of views.
// In this case the WebRequest instances for all sites are kept in memory and active.

(:exclForSitesOne :exclForViewPreRenderingDisabled) public class WebRequestRegistry {
    private static var _stateRequests as Array<WebRequest> = [];
    private static var _stateRequestTimer as EvccMultiWebRequestsHandler?;

    // Sets the active site (information is only passed on to the handler, not needed in this class)
    public static function setActiveSite( activeSite as Number ) as Void { 
        // HelperBase.debug( "WebRequestRegistry: setting activeSite=" + activeSite );
        ( _stateRequestTimer as EvccMultiWebRequestsHandler ).setActiveSite( activeSite );
    }

    // For this instance, we need an initialization function to be called by
    // EvccApp when it is started in widget mode
    // This functions instantiates all state requests and hands them over to 
    // the EvccMultiWebRequestsHandler for the initial loading of data and then 
    // regular request of new data
    public static function start( activeSite as Number ) as Void {
        for( var i = 0; i < SiteConfigRepository.getSiteCount(); i++ ) {
            _stateRequests.add( new WebRequest( i ) );
        }
        _stateRequestTimer = new EvccMultiWebRequestsHandler( _stateRequests, activeSite );
    }

    // Get the state request for a specific site
    // If the array is still empty, we instantiate all state requests
    public static function getWebRequest( site as Number ) as WebRequest {
        return _stateRequests[site];
    }

    // Stop all state requests
    public static function stopWebRequests() as Void {
        if( _stateRequests.size() > 0 ) {
            for( var i = 0; i < _stateRequests.size(); i++ ) {
                _stateRequests[i].persistState();
            }
        }
        // Stop the handler
        // If there is an error before we start the registry, then there may not
        // be a timer to stop. (e.g. if there is no site configuration)
        if( _stateRequestTimer != null ) {
            ( _stateRequestTimer as EvccMultiWebRequestsHandler ).stopRequestTimer();
        }
    }
}