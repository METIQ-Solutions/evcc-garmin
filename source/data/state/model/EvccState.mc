import Toybox.Lang;
import Toybox.Time;

// Classes in this folder represent the current state of an evcc site
// They implement both the parsing of the JSON dictionary received
// as web response, as well as serializing in a JSON dictionary with
// the same structure for persiting the state in storage

// This is the root class, holding data on site-level
(:glance) class EvccState {
    
    private var _timestamp as Moment;
    public function getTimestamp() as Moment { return _timestamp; }

    private var _hasBattery as Boolean = false;
    private var _batterySoc as Number? = null;
    private var _batteryPower as Number? = null;
    private var _gridPower as Number?;
    private var _homePower as Number?;
    private var _pvPower as Number?;
    private var _siteTitle as String?;

    private const BATTERYSOC = "batterySoc";
    private const BATTERYPOWER = "batteryPower";
    private const BATTERY = "battery";
    private const SOC = "soc";
    private const GRIDPOWER = "gridPower";
    private const GRID = "grid";
    private const POWER = "power";
    private const HOMEPOWER = "homePower";
    private const PVPOWER = "pvPower";
    public static const SITETITLE = "siteTitle";
    private const LOADPOINTS = "loadpoints";
    private const FORECAST = "forecast";
    private const STATISTICS = "statistics";

    public function hasBattery() as Boolean { return _hasBattery; }
    public function getBatterySoc() as Number? { return _batterySoc; }
    public function getBatteryPowerRounded() as Number { return HelperBase.roundPower( _batteryPower ); }
    public function getGridPowerRounded() as Number { return HelperBase.roundPower( _gridPower ); }
    public function getHomePowerRounded() as Number { return HelperBase.roundPower( _homePower ); }
    public function getPvPowerRounded() as Number { return HelperBase.roundPower( _pvPower ); }
    public function getSiteTitle() as String { return _siteTitle != null ? _siteTitle : ""; }

    // Loadpoints and their accessor
    // Loadpoints are stored in three lists, depending on their type
    // On low-memory devices, only vehicles are supported
    private var _connectedVehicles as LoadpointList = new LoadpointList();
    private var _heaters as LoadpointList = new LoadpointList();
    private var _integratedDevices as LoadpointList = new LoadpointList();

    // Function to access and clear the loadpoints
    // This is used during serialization and frees the memory
    // immediately, which helps on low memory devices.
    
    // For others we have this aggregated accessor, which combines the
    // three lists. While this comes at some runtime costs (vs. storing
    // a parallel array of all loadpoints), it conserves memory and needs
    // less code in the low memory variant
    private function getAndClearLoadpoints() as ArrayOfLoadpoints { 
        var merged = new ArrayOfLoadpoints[0];
        merged.addAll( _connectedVehicles.getAndClearLoadpoints() );
        merged.addAll( _heaters.getAndClearLoadpoints() );
        merged.addAll( _integratedDevices.getAndClearLoadpoints() );
        return merged;
    }
    
    // Accessor for the loadpoint lists
    public function getConnectedVehicles() as LoadpointList { return _connectedVehicles; }
    public function getHeaters() as LoadpointList { return _heaters; }
    public function getIntegratedDevices() as LoadpointList { return _integratedDevices; }

    // Accessor for the count of loadpoints
    // Needed only for the categorized, aggregated display not available
    // on low memory devices
    public function getLoadpointCount() as Number {
        return _connectedVehicles.getLoadpoints().size()
               + _heaters.getLoadpoints().size()
               + _integratedDevices.getLoadpoints().size();
    }

    // Accessor for an aggregated list of loadpoints
    public function getLoadpoints() as ArrayOfLoadpoints { 
        var merged = new ArrayOfLoadpoints[0];
        merged.addAll( _connectedVehicles.getLoadpoints() );
        merged.addAll( _heaters.getLoadpoints() );
        merged.addAll( _integratedDevices.getLoadpoints() );
        return merged;
    }

    public static var NUM_OF_LOADPOINT_CATEGORIES as Number = 3;
    // IconBlock is not available in the glance scope of tiny glances
    // The icon is not really needed, so we can just disable the typechecker
    (:exclForMemoryLow :typecheck([disableGlanceCheck])) 
    public function getAllLoadpointsCategories() as Array<LoadpointCategory> { 
        var lpCategories = [
            [ IconBlock.ICON_CAR, _connectedVehicles ],
            [ IconBlock.ICON_HEATER, _heaters ],
            [ IconBlock.ICON_DEVICE, _integratedDevices ]
        ];
        if( lpCategories.size() != NUM_OF_LOADPOINT_CATEGORIES ) {
            throw new InvalidValueException( "EvccState: number of categories does not match NUM_OF_LOADPOINT_CATEGORIES." );
        }
        return lpCategories;
    }

    public function getLoadpointCategory( index as Number ) as LoadpointCategory { 
        var categories = getAllLoadpointsCategories();
        if( index >= categories.size() ) {
            throw new InvalidValueException( "EvccState: unknown category" );
        }
        return categories[index];
    }

    private var _forecast as SolarForecast?;
    public function getForecast() as SolarForecast? { return _forecast; }
    (:exclForMemoryLow :typecheck([disableBackgroundCheck,disableGlanceCheck])) public function hasForecast() as Boolean { return _forecast == null ? false : _forecast.hasForecast(); }

    protected var _statistics as Statistics?;
    public function getStatistics() as Statistics { return _statistics as Statistics; }
    public function hasStatistics() as Boolean { return _statistics != null; }

    // Creating a new state object.
    
    // The code works both with the response from evcc and the
    // persistated data in storage
    // The URL used by WebRequest filters the returned fields with a
    // jq statement, because processing the full evcc response would take too much
    // space for low-memory devices.
    
    // ATTENTION: therefore if new fields from evcc should be used here, they also need
    // to be added to the jq statement in WebRequest.
    
    // Some classes are not available in background/glance
    // The code handles this, but the typechecker does not know that,
    // so we need to exclude the scope checks.
    function initialize( result as JsonObject, dataTimestamp as Moment ) {
        _timestamp = dataTimestamp;

        // For battery power we support both the old structure with
        // batterySoc and batteryPower and the new structure with
        // battery.soc and battery.bower.
        var battery = result[BATTERY] as JsonObject;
        if( battery != null && battery[SOC] != null ) {
            _batterySoc = battery[SOC] as Number;
            _batteryPower = battery[POWER] as Number;
            _hasBattery = true;
        } else if( result[BATTERYSOC] != null ) {
            _batterySoc = result[BATTERYSOC] as Number;
            _batteryPower = result[BATTERYPOWER] as Number;
            _hasBattery = true;
        }

        // For grid power we support both the old structure with
        // result.gridPower and the new structure with result.grid.power
        // used by evcc from 0.132.2 onwards
        _gridPower = result[GRIDPOWER] as Number?;
        if( _gridPower == null ) {
            var grid = result[GRID] as Array;
            _gridPower = grid[POWER] as Number?;
        }

        _homePower = result[HOMEPOWER] as Number?;
        _pvPower = result[PVPOWER] as Number?;
        _siteTitle = result[SITETITLE] as String?;

        var loadpoints = result[LOADPOINTS] as Array;
        // If there are no loadpoints, we get null, not an empty array
        if( loadpoints != null ) {
            for( var i = 0; i < loadpoints.size(); i++ ) {
                var loadpointData = loadpoints[i] as JsonObject;
                var loadpoint = new Loadpoint( loadpointData, result );
                // In addition to the array of all loadpoints, we also
                // maintain a list of each type, for the display of categories
                if( loadpoint.isVehicle() ) { 
                    _connectedVehicles.add( loadpoint ); 
                } else if( loadpoint.isHeater() ) {
                    _heaters.add( loadpoint );
                } else if ( loadpoint.isIntegratedDevice() ) {
                    _integratedDevices.add( loadpoint );
                }
            }
        }

        var forecast = result[FORECAST] as JsonObject?;
        if( forecast != null ) {
            _forecast = new SolarForecast( forecast );
        }
        var statistics = result[STATISTICS] as JsonObject?;
        if( statistics != null ) {
            _statistics = new Statistics( statistics );
        }
    }

    // Create a dictionary for persisting the state from the data in this class, 
    // with the same structure that is used by the evcc response. Thus the
    // constructor can process both the Dicionary from the web request response
    // and from the storage
    function serialize() as JsonObject { 
        var result = { 
            GRIDPOWER => _gridPower, // for grid power we serialize using the old structure, see initialize()
            HOMEPOWER => _homePower,
            PVPOWER => _pvPower,
            SITETITLE => _siteTitle
        } as JsonObject;

        if( _hasBattery ) {
            result[BATTERYSOC] = _batterySoc;
            result[BATTERYPOWER] = _batteryPower;
        }

        var serializedLoadpoints = new Array<Dictionary>[0];

        // In the glance memory can be tight when
        // serializing and storing the state. Therefore we immediately discard
        // each loadpoint, after it was serialized
        var loadpoints = getAndClearLoadpoints();
        for ( ; loadpoints.size() > 0; ) {
            serializedLoadpoints.add( loadpoints[0].serialize() as Dictionary );
            loadpoints.remove( loadpoints[0] );
        }

        result.put( LOADPOINTS, serializedLoadpoints );

        var forecast = _forecast;
        if( forecast != null && hasForecast() ) {
            result.put( FORECAST, forecast.serialize() );
        }
        if( _statistics != null ) {
            result.put( STATISTICS, _statistics.serialize() );
        }

       return result; 
    }

}