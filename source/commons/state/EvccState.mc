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
    (:exclForMemoryLow) private const FORECAST = "forecast";
    (:exclForMemoryLow) private const STATISTICS = "statistics";

    public function hasBattery() as Boolean { return _hasBattery; }
    public function getBatterySoc() as Number? { return _batterySoc; }
    public function getBatteryPowerRounded() as Number { return EvccHelperBase.roundPower( _batteryPower ); }
    public function getGridPowerRounded() as Number { return EvccHelperBase.roundPower( _gridPower ); }
    public function getHomePowerRounded() as Number { return EvccHelperBase.roundPower( _homePower ); }
    public function getPvPowerRounded() as Number { return EvccHelperBase.roundPower( _pvPower ); }
    public function getSiteTitle() as String { return _siteTitle != null ? _siteTitle : ""; }

    // Loadpoints and their accessor
    // Loadpoints are stored in three lists, depending on their type
    // On low-memory devices, only vehicles are supported
    private var _connectedVehicles as EvccLoadPointList = new EvccLoadPointList();
    (:exclForMemoryLow) private var _heaters as EvccLoadPointList = new EvccLoadPointList();
    (:exclForMemoryLow) private var _integratedDevices as EvccLoadPointList = new EvccLoadPointList();

    // Function to access and clear the loadpoints
    // This is used during serialization and frees the memory
    // immediately, which helps on low memory devices.
    
    // On low-memory devices, only connected vehicles are supported
    (:exclForMemoryStandard) 
    private function getAndClearLoadPoints() as ArrayOfLoadPoints { 
        return _connectedVehicles.getAndClearLoadPoints(); 
    }
    // For others we have this aggregated accessor, which combines the
    // three lists. While this comes at some runtime costs (vs. storing
    // a parallel array of all loadpoints), it conserves memory and needs
    // less code in the low memory variant
    (:exclForMemoryLow) 
    private function getAndClearLoadPoints() as ArrayOfLoadPoints { 
        var merged = new ArrayOfLoadPoints[0];
        merged.addAll( _connectedVehicles.getAndClearLoadPoints() );
        merged.addAll( _heaters.getAndClearLoadPoints() );
        merged.addAll( _integratedDevices.getAndClearLoadPoints() );
        return merged;
    }
    
    // Accessor for the loadpoint lists
    public function getConnectedVehicles() as EvccLoadPointList { return _connectedVehicles; }
    (:exclForMemoryLow) public function getHeaters() as EvccLoadPointList { return _heaters; }
    (:exclForMemoryLow) public function getIntegratedDevices() as EvccLoadPointList { return _integratedDevices; }

    // Accessor for the count of loadpoints
    // Needed only for the categorized, aggregated display not available
    // on low memory devices
    (:exclForMemoryLow) public function getLoadPointCount() as Number {
        return _connectedVehicles.getLoadPoints().size()
               + _heaters.getLoadPoints().size()
               + _integratedDevices.getLoadPoints().size();
    }

    // Accessor for an aggregated list of loadpoints
    (:exclForMemoryLow) 
    public function getLoadPoints() as ArrayOfLoadPoints { 
        var merged = new ArrayOfLoadPoints[0];
        merged.addAll( _connectedVehicles.getLoadPoints() );
        merged.addAll( _heaters.getLoadPoints() );
        merged.addAll( _integratedDevices.getLoadPoints() );
        return merged;
    }

    (:exclForMemoryLow) 
    public static var NUM_OF_LOADPOINT_CATEGORIES as Number = 3;
    (:exclForMemoryLow) 
    public function getAllLoadPointsCategories() as Array<LoadPointCategory> { 
        var lpCategories = [
            [ EvccIconBlock.ICON_CAR, _connectedVehicles ],
            [ EvccIconBlock.ICON_HEATER, _heaters ],
            [ EvccIconBlock.ICON_DEVICE, _integratedDevices ]
        ];
        if( lpCategories.size() != NUM_OF_LOADPOINT_CATEGORIES ) {
            throw new InvalidValueException( "EvccState: number of categories does not match NUM_OF_LOADPOINT_CATEGORIES." );
        }
        return lpCategories;
    }

    (:exclForMemoryLow) 
    public function getLoadPointCategory( index as Number ) as LoadPointCategory { 
        var categories = getAllLoadPointsCategories();
        if( index >= categories.size() ) {
            throw new InvalidValueException( "EvccState: unknown category" );
        }
        return categories[index];
    }

    (:exclForMemoryLow) private var _forecast as EvccSolarForecast?;
    (:exclForMemoryLow) public function getForecast() as EvccSolarForecast? { return _forecast; }
    (:exclForMemoryLow :typecheck([disableBackgroundCheck,disableGlanceCheck])) public function hasForecast() as Boolean { return _forecast == null ? false : _forecast.hasForecast(); }

    (:exclForMemoryLow) protected var _statistics as EvccStatistics?;
    (:exclForMemoryLow) public function getStatistics() as EvccStatistics { return _statistics as EvccStatistics; }
    (:exclForMemoryLow) public function hasStatistics() as Boolean { return _statistics != null; }

    // Creating a new state object.
    
    // The code works both with the response from evcc and the
    // persistated data in storage
    // The URL used by EvccStateRequest filters the returned fields with a
    // jq statement, because processing the full evcc response would take too much
    // space for low-memory devices.
    
    // ATTENTION: therefore if new fields from evcc should be used here, they also need
    // to be added to the jq statement in EvccStateRequest.
    
    // Some classes are not available in background/glance
    // The code handles this, but the typechecker does not know that,
    // so we need to exclude the scope checks.
    function initialize( result as JsonContainer, dataTimestamp as Moment ) {
        _timestamp = dataTimestamp;

        // For battery power we support both the old structure with
        // batterySoc and batteryPower and the new structure with
        // battery.soc and battery.bower.
        var battery = result[BATTERY] as JsonContainer;
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

        var loadPoints = result[LOADPOINTS] as Array;
        // If there are no loadpoints, we get null, not an empty array
        if( loadPoints != null ) {
            for( var i = 0; i < loadPoints.size(); i++ ) {
                var loadPointData = loadPoints[i] as JsonContainer;
                var loadPoint = new EvccLoadPoint( loadPointData, result );
                // In addition to the array of all loadpoints, we also
                // maintain a list of each type, for the display of categories
                if( loadPoint.isVehicle() ) { 
                    _connectedVehicles.add( loadPoint ); 
                } else {
                    initOptionalLoadPoint( loadPoint );
                }
            }
        }

        initOptionalFeatures( result );
    }

    (:exclForMemoryLow :typecheck([disableBackgroundCheck,disableGlanceCheck]))
    function initOptionalLoadPoint( loadPoint as EvccLoadPoint ) as Void {
        if( loadPoint.isHeater() ) {
            _heaters.add( loadPoint );
        } else if ( loadPoint.isIntegratedDevice() ) {
            _integratedDevices.add( loadPoint );
        }
    }

    (:exclForMemoryStandard)
    function initOptionalLoadPoint( loadPoint as EvccLoadPoint ) as Void {
    }

    // Function for parsing optional elements out of the JSON
    // Optional elements are excluded on low-memory devices and
    // in the background service of devices using the tiny glance
    (:exclForMemoryLow :typecheck([disableBackgroundCheck,disableGlanceCheck]))
    function initOptionalFeatures( result as JsonContainer ) as Void {
        // If we are in the glance of a tiny glance device,
        // we do not initialize these elements to save memory
        var forecast = result[FORECAST] as JsonContainer?;
        if( forecast != null ) {
            _forecast = new EvccSolarForecast( forecast );
        }
        var statistics = result[STATISTICS] as JsonContainer?;
        if( statistics != null ) {
            _statistics = new EvccStatistics( statistics );
        }
    }

    // Dummy for low memory devices
    (:exclForMemoryStandard)
    function initOptionalFeatures( result as JsonContainer ) as Void {}

    // Create a dictionary for persisting the state from the data in this class, 
    // with the same structure that is used by the evcc response. Thus the
    // constructor can process both the Dicionary from the web request response
    // and from the storage
    function serialize() as JsonContainer { 
        var result = { 
            GRIDPOWER => _gridPower, // for grid power we serialize using the old structure, see initialize()
            HOMEPOWER => _homePower,
            PVPOWER => _pvPower,
            SITETITLE => _siteTitle
        } as JsonContainer;

        if( _hasBattery ) {
            result[BATTERYSOC] = _batterySoc;
            result[BATTERYPOWER] = _batteryPower;
        }

        var serializedLoadPoints = new Array<Dictionary>[0];

        // In the glance memory can be tight when
        // serializing and storing the state. Therefore we immediately discard
        // each loadpoint, after it was serialized
        var loadPoints = getAndClearLoadPoints();
        for ( ; loadPoints.size() > 0; ) {
            serializedLoadPoints.add( loadPoints[0].serialize() as Dictionary );
            loadPoints.remove( loadPoints[0] );
        }

        result.put( LOADPOINTS, serializedLoadPoints );

        serializeOptionalElements( result );

       return result; 
    }

    // Serialization of optional elements
    // Optional elements are excluded on low-memory devices and
    // in the background service of devices using the tiny glance
    (:exclForMemoryLow :typecheck([disableBackgroundCheck,disableGlanceCheck]))
    private function serializeOptionalElements( result as JsonContainer ) as Void {
        var forecast = _forecast;
        if( forecast != null && hasForecast() ) {
            result.put( FORECAST, forecast.serialize() );
        }
        if( _statistics != null ) {
            result.put( STATISTICS, _statistics.serialize() );
        }
    }
    // Dummy for low memory devices
    (:exclForMemoryStandard)
    private function serializeOptionalElements( result as JsonContainer ) as Void {}

}