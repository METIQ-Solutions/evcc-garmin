import Toybox.Lang;
import Toybox.Application.Storage;
import Toybox.Application;
import Toybox.Time;

// This class provides access to the site states in persistant storage
(:glance) 
class StateStore {


    private static const NAME_DATA = "data";
    private static const NAME_DATATIMESTAMP = "dataTimestamp";

    private var _siteIndex as Number;
    
    private var _state as EvccState?;


    // Constructor
    public function initialize( siteIndex as Number ) {
        // HelperBase.debug("StateStore: initialize");
        _siteIndex = siteIndex;
    }


    // Delete site indexes from storage that are not in use anymore
    public static function clearUnusedSites( totalSites as Number ) as Void {
        for( var i = totalSites; i < Constants.MAX_SITES; i++ ) {
            // HelperBase.debug( "StateStore: clearing site " + i );
            Storage.deleteValue( Constants.STORAGE_SITE_PREFIX + i );
        }
    }


    // The standard getState returns buffered states if available ...
    // Note that this function returns the state regardless of timestamp
    // If you want state only if it is current, check WebRequest.hasLoaded
    function getState() as EvccState? {
        if( _state == null ) {
            _state = getStateFromStorage();
        }
        return _state;
    }


    // ... getStateFromStorage goes directly to the persistant storage
    // this is used in situations where the data is put in storage by
    // the background service (e.g. the tiny glance)
    function getStateFromStorage() as EvccState? {
        // HelperBase.debug( "StateStore: reading site " + _siteIndex );
        var siteData = Storage.getValue( Constants.STORAGE_SITE_PREFIX + _siteIndex ) as Dictionary<String,Object>;
        var state = null;

        if( siteData != null ) {
            var stateData = siteData[NAME_DATA] as JsonObject;
            if( stateData != null ) {
                var siteTitle = stateData[EvccState.SITETITLE] as String?;
                if( siteTitle != null && ! siteTitle.equals( "" ) ) {
                    state = new EvccState( stateData, new Moment( siteData[NAME_DATATIMESTAMP] as Number ) );
                }
            }
        }
        return state;
    }


    // Persist the data to storage
    // Having this separately from setState() fullfils two purposes
    // First, it reduces the write operations to persistant storage
    // Second, setState() is called in the same time as the JSON response
    // is processed. Storage.setValue() is also memory-intensive, so doing
    // both at once would cause out of memory errors. So instead we have persist()
    // be called when the application is stopped, at that point, there is no
    // JSON data in dictionary form in memory anymore.
    public function persist() as Void {
        var state = _state;
        if( state != null ) {
            // HelperBase.debug( "StateStore: persisting site " + _siteIndex );
            var stateData = state.serialize();
            var stateTimestamp = state.getTimestamp();
            state = null;
            _state = null;

            var siteData = {} as JsonObject;
            siteData[NAME_DATA] = stateData;
            siteData[NAME_DATATIMESTAMP] = stateTimestamp.value();

            Storage.setValue( Constants.STORAGE_SITE_PREFIX + _siteIndex, siteData as Lang.Dictionary<Storage.KeyType, Storage.ValueType> );
        }
    }


    public function setState( result as JsonObject ) as Void {
        // HelperBase.debug( "StateStore: storing site " + _siteIndex );
        _state = new EvccState( result, Time.now() );
    }
}