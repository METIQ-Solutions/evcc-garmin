import Toybox.Lang;
import Toybox.Background;
import Toybox.System;
import Toybox.Application.Storage;

// The background service 
// Used for the tiny glance only
// Devices that use the tiny glance do not make enough memory available to the glance
// for processing the request. Therefore the request to evcc is made in this background
// task, and the result passed to the glance via storage
(:background :exclForGlanceFull :exclForGlanceNone) class EvccServiceDelegate extends Toybox.System.ServiceDelegate {
	var _siteIndex as Number;
    var _stateRequest as EvccBackgroundWebRequest;

    public function initialize( siteIndex as Number ) {
        // HelperBase.debug( "EvccServiceDelegate: initialize" );
        System.ServiceDelegate.initialize();
        _siteIndex = siteIndex;
        _stateRequest = new EvccBackgroundWebRequest( _siteIndex );
        _stateRequest.registerCallback( self );
	}
	
    // When the background timer triggers, we initiate the
    // web request to evcc.
    public function onTemporalEvent() {
        // HelperBase.debug( "EvccServiceDelegate: onTemporalEvent" );
        try {
            // We do not want to start the state request timer with .start()
            // but only do a single request. Start would not work, since
            // in the background no timers can be created
            _stateRequest.makeRequest();
        } catch ( ex ) {
            HelperBase.debugException( ex );
        }
    }

    // Once the response is received, we either persist an error
    // or the result
    public function onStateUpdate() as Void {
        // HelperBase.debug( "EvccServiceDelegate: onStateUpdate" );
        if( _stateRequest.hasError() ) {
            Storage.setValue( Constants.STORAGE_BG_ERROR_MSG, _stateRequest.getErrorMessage() );
            Storage.setValue( Constants.STORAGE_BG_ERROR_CODE, _stateRequest.getErrorCode() );
        } else {
            Storage.deleteValue( Constants.STORAGE_BG_ERROR_MSG );
            Storage.deleteValue( Constants.STORAGE_BG_ERROR_CODE );
            _stateRequest.persistState();
        }
    }
}
