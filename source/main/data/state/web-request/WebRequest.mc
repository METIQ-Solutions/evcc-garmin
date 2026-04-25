import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application.Properties;
import Toybox.Time;
import Toybox.PersistedContent;

// The interface to be implemented by objects passed in as callbacks
typedef WebRequestCallback as interface {
    function onStateUpdate() as Void;
};

// The state request manages the HTTP request to the evcc instance.

// - It has a makeRequest function for making a request
// - It makes the result (a state or an error) available.
//   The result is made available as JSON only, not as EvccState
// - Once a web response arrives, it calls only the first registered callback,
//   which is the background service
// - parsing the JSON into an EvccState object
// - a function to load an initial state from storage
// - accessors that are only required by UI components
// - for devices with standard memory additional JQ filters 
// - additional callback logic for multiple callbacks and
//   calling WatchUi.requestUpdate
// - persisting the EvccState object via the StateStore

(:glance) 
class WebRequest {
    
    // Other classes can register callback methods that will 
    // be called whenever a new web response is received
    private var _callbacks as Array<WebRequestCallback> = [];

    // How long a state is valid
    private var _dataExpiry as Number;

    private var _error as Boolean = false;
    private var _errorMessage as String = "";
    private var _errorCode as String = "";

    private var _hasCurrentState as Boolean = false;

    private var _json as JsonObject?;

    // How often the state should be requested
    private var _refreshInterval as Number;

    // Instance of the state store for persisting the state
    private var _stateStore as StateStore;

    private var _siteIndex as Number;


    // Constructor
    public function initialize( siteIndex as Number ) {
        _siteIndex = siteIndex;
        _refreshInterval = Properties.getValue( Constants.PROPERTY_REFRESH_INTERVAL ) as Number;
        _dataExpiry = Properties.getValue( Constants.PROPERTY_DATA_EXPIRY ) as Number;
        _stateStore = new StateStore( siteIndex );
    }


    // If there was a web request error, throw an exception
    public function checkForError() as Void {
        if( _error ) {
            throw new WebRequestException( _errorMessage, _errorCode );
        }
    }


    // The JSON can be accessed once and is then nulled, to conserve memory
    public function consumeJson() as JsonObject? {
        var json = _json;
        _json = null;
        return json;
    }

    // Current state is true if either data from storage that is within the
    // expiry time has been loaded, or a web response has been received
    // also an error is counted as current state
    public function hasCurrentState() as Boolean { return _hasCurrentState; }

    // hasState is true if a state is available, even if it is expired
    // this can be used for decision 
    public function hasState() as Boolean { return _stateStore.getState() != null; }

    // Accessor for error case
    public function getErrorMessage() as String { return _errorMessage; }
    public function getErrorCode() as String { return _errorCode; }

    // Accessor for refresh interval
    public function getRefreshInterval() as Number { return _refreshInterval; }

    // Accessor for the site index
    public function getSiteIndex() as Number { return _siteIndex; }

    // Accessor for the state
    public function getState() as EvccState { return _stateStore.getState() as EvccState; }

    // True if an error has occured
    public function hasError() as Boolean { return _error; }

    // Indicates to the parent class that a previousy valid state is available and
    // therefore errors do not yet need to be reported
    public function hasPreviousValidState() as Boolean { 
        var state = _stateStore.getState();
        return 
            state != null && Time.now().compare( state.getTimestamp() ) <= _dataExpiry; 
    }


    // This is used only after the initial loadInitialState for the
    // active site. The first callback is the main view, and for the
    // active site the pre-rendering is anyway then done in the
    // first onUpdate
    public function invokeAllCallbacksButFirst() as Void {
        // Logger.debug( "WebRequest: invoking callbacks except first" );
        for( var i = 1; i < _callbacks.size(); i++ ) {
            _callbacks[i].onStateUpdate();
        }
    }


    public function invokeCallbacks() as Void {
        // Logger.debug( "WebRequest: invoking callbacks" );
        if( _callbacks.size() == 0 ) {
            // If not callbacks are registered, we request a screen update from WatchUi
            // Note that the background task has to register a callback, otherwise
            // this call would trip an error
            WatchUi.requestUpdate();
        } else {
            for( var i = 0; i < _callbacks.size(); i++ ) {
                // Logger.debug( "WebRequest: invoking callback " + (i+1) + "/" + _callbacks.size() );
                _callbacks[i].onStateUpdate();
            }
        }
    }


    // Loads the initial state from storage
    // If none is available or it is outdated, makes an immediate web request
    public function loadInitialState() as Void {
        // Logger.debug("WebRequest: loadInitialState site=" + _siteIndex );

        // Only when this state request is started we load the state data
        // We cannot load the state in initialize, because on some devices,
        // there is not enough memory for having all the states in memory
        var state = _stateStore.getState() as EvccState?;
        
        // If no stored data is found a request is made immediately
        if( state == null ) {
            // Logger.debug( "WebRequest: no stored data found");
            makeRequest(); 
        } else { 
            var dataAge = Time.now().compare( state.getTimestamp() );
            // If the persisted data is older than the expiry time it is not used and a request is made immediately
            if( dataAge > _dataExpiry ) {
                // Logger.debug( "WebRequest: stored data too old!" ); 
                makeRequest(); 
            } else { 
                // otherwise the data is used, but if it is older than refreshInterval, a request is made immediately^
                // if the device is using tiny glance, then also a request is made immediately, because the data obtained by
                // the tiny glance may be incomplete due to memory restrictions in the tiny glance's background service. 
                // Logger.debug( "WebRequest: using stored data" );
                _hasCurrentState = true;
                if( dataAge > _refreshInterval ) {
                    makeRequest(); 
                }
            }
        }
    }


    // Make the web request
    // For some reason this function shows scope errors when compiling
    // with SDK >= 8.2. Therefore we disable the scope check.
    (:typecheck([disableGlanceCheck]))
    public function makeRequest() as Void {
        // Logger.debug( "WebRequest: makeRequest site=" + _siteIndex );
        var siteConfig = new SiteConfig( _siteIndex );

        var url = siteConfig.getUrl() + "/api/state";
        var parameters = { "jq" => EVCC_JQ_FILTER };

        // Logger.debug( JQ );
        
        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        };

        // Add basic authentication
        if( siteConfig.needsBasicAuth() ) {
            options[:headers] = { 
                "Authorization" => "Basic " + StringUtil.encodeBase64( Lang.format( "$1$:$2$", [siteConfig.getUser(), siteConfig.getPassword() ] ) )
            };
        }

        Communications.makeWebRequest( url, parameters, options, method(:onReceive) );
        // Logger.debug("WebRequest: makeRequest done" );
    }


     // Receive the data from the web request
    public function onJsonReceive() as Void {
        var json = consumeJson();
        if( json != null ) {
            _stateStore.setState( json );
        }
    }


    // Receive the data from the web request
    // For some reason this function shows scope errors when compiling
    // with SDK >= 8.2. Therefore we disable the scope check.
    (:typecheck([disableGlanceCheck]))
    public function onReceive( responseCode as Number, data as Dictionary<String,Object?> or String or PersistedContent.Iterator or Null ) as Void {
        // Logger.debug("WebRequest: onReceive site=" + _siteIndex );
        _hasCurrentState = true;
        _error = false; _errorMessage = ""; _errorCode = "";
        
        if( responseCode == 200 ) {
            if( data instanceof Dictionary ) {
                _json = data as JsonObject;
                onJsonReceive();
            } else {
                _errorMessage = "Unexpected response: " + data;
                _error = true;
            }
        // To mask temporary errors because of instable connections, we report
        // errors only if the data we have now has expired, otherwise we continue
        // to display the existing data
        } else if( ! hasPreviousValidState() ) {
            _error = true;
            if ( responseCode == -104 ) {
                _errorMessage = "No phone"; _errorCode = "";
            } else {
                _errorMessage = "Request failed"; _errorCode = responseCode.toString();
                // Logger.debug("WebRequest: request failed" );
            }
        }

        // Trigger the callback logic, see below
        invokeCallbacks();
        // Logger.debug("WebRequest: onReceive done" );
    }


    // Override the parent function to persist the
    // state class in the state store instead of the JSON
    public function persistState() as Void { 
        _stateStore.persist();
    }


    // Register a callback
    public function registerCallback( callback as WebRequestCallback ) as Void {
        _callbacks.add( callback );
    }


    // Unregister a callback
    public function unregisterCallback( callback as WebRequestCallback ) as Void {
        // Logger.debug( "WebRequest: unregistering callback" );
        if( ! _callbacks.remove( callback ) ) {
            throw new InvalidValueException( "WebRequest: unregistering callback failed." );
        }
    }

}