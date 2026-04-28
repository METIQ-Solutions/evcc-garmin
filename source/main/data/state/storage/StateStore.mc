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
        // Logger.debug("StateStore: initialize");
        _siteIndex = siteIndex;
    }


    // Delete site indexes from storage that are not in use anymore
    public static function clearUnusedSites( totalSites as Number ) as Void {
        for( var i = totalSites; i < Constants.MAX_SITES; i++ ) {
            // Logger.debug( "StateStore: clearing site " + i );
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
        // Logger.debug( "StateStore: reading site " + _siteIndex );
        var siteData = Storage.getValue( Constants.STORAGE_SITE_PREFIX + _siteIndex ) as Dictionary<String,Object>;
        var state = null;

        if( siteData != null ) {
            var stateData = siteData[NAME_DATA] as JsonObject;
            if( stateData != null ) {
                var siteTitle = stateData[EvccState.SITETITLE] as String?;
                if( siteTitle != null && ! siteTitle.equals( "" ) ) {
                    state = new EvccState( new JsonAdapter( stateData ), new Moment( siteData[NAME_DATATIMESTAMP] as Number ) );
                }
            }
        }
        return state;
    }


    public function setState( json as JsonObject ) as Void {
        // Logger.debug( "StateStore: storing site " + _siteIndex );
        var timestamp = Time.now();
        var siteData = {} as JsonObject;
        siteData[NAME_DATA] = json;
        siteData[NAME_DATATIMESTAMP] = timestamp.value();
        Storage.setValue( Constants.STORAGE_SITE_PREFIX + _siteIndex, siteData as Lang.Dictionary<Storage.KeyType, Storage.ValueType> );
        _state = new EvccState( new JsonAdapter( json ), timestamp );
    }
}