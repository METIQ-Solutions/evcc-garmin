import Toybox.Lang;
import Toybox.Time;

// Classes in this folder represent the current state of an evcc site
// They implement both the parsing of the JSON dictionary received
// as web response, as well as serializing in a JSON dictionary with
// the same structure for persiting the state in storage

// This is the root class, holding data on site-level
(:glance) class EvccState {
    
    /******** JSON NAMES ********/

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
    private const FORECAST_SOLAR = "solar";
    private const FORECAST_GRID = "grid";
    private const STATISTICS = "statistics";
    private const TARIFF_GRID = "tariffGrid";
    private const SMART_COST_AVAILABLE = "smartCostAvailable";


    /******** MEMBERS AND ACCESSORS ********/


    // Timestamp
    private var _timestamp as Moment;
    public function getTimestamp() as Moment { return _timestamp; }

    // Site title
    private var _siteTitle as String?;
    public function getSiteTitle() as String { return _siteTitle != null ? _siteTitle : ""; }

    // Basic power numbers
    private var _gridPower as Number?;
    private var _homePower as Number?;
    private var _pvPower as Number?;
    public function getGridPowerRounded() as Number { return ExtendedMath.roundPower( _gridPower ); }
    public function getHomePowerRounded() as Number { return ExtendedMath.roundPower( _homePower ); }
    public function getPvPowerRounded() as Number { return ExtendedMath.roundPower( _pvPower ); }


    // Battery and its state and power
    private var _hasBattery as Boolean = false;
    private var _batterySoc as Number? = null;
    private var _batteryPower as Number? = null;
    public function hasBattery() as Boolean { return _hasBattery; }
    public function getBatterySoc() as Number? { return _batterySoc; }
    public function getBatteryPowerRounded() as Number { return ExtendedMath.roundPower( _batteryPower ); }

    // Loadpoints and their accessor
    // Loadpoints are stored in three lists, depending on their type
    // On low-memory devices, only vehicles are supported
    private var _chargers as LoadpointList = new LoadpointList();
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
        merged.addAll( _chargers.getAndClearLoadpoints() );
        merged.addAll( _heaters.getAndClearLoadpoints() );
        merged.addAll( _integratedDevices.getAndClearLoadpoints() );
        return merged;
    }
    
    // Accessor for the loadpoint lists
    public function getChargers() as LoadpointList { return _chargers; }
    public function getHeaters() as LoadpointList { return _heaters; }
    public function getIntegratedDevices() as LoadpointList { return _integratedDevices; }

    // Accessor for the count of loadpoints
    // Needed only for the categorized, aggregated display not available
    // on low memory devices
    public function getLoadpointCount() as Number {
        return _chargers.getLoadpoints().size()
               + _heaters.getLoadpoints().size()
               + _integratedDevices.getLoadpoints().size();
    }

    // Accessor for an aggregated list of loadpoints
    public function getLoadpoints() as ArrayOfLoadpoints { 
        var merged = new ArrayOfLoadpoints[0];
        merged.addAll( _chargers.getLoadpoints() );
        merged.addAll( _heaters.getLoadpoints() );
        merged.addAll( _integratedDevices.getLoadpoints() );
        return merged;
    }

    public static var NUM_OF_LOADPOINT_CATEGORIES as Number = 3;
    // IconBlock is not available in the glance scope of tiny glances
    // The icon is not really needed, so we can just disable the typechecker
    (:typecheck([disableGlanceCheck])) 
    public function getAllLoadpointsCategories() as Array<LoadpointCategory> { 
        var lpCategories = [
            [ IconBlock.ICON_CHARGER, _chargers ],
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

    // Solar forecast
    private var _solarForecast as SolarForecast?;
    public function getSolarForecast() as SolarForecast? { return _solarForecast; }
    public function hasSolarForecast() as Boolean { return _solarForecast != null; }

    // Grid price, current and forecast
    private var _tariffGrid as Float?;
    private var _smartCostAvailable as Boolean;
    private var _gridPrices as GridPriceForecast?;
    public function getGridTariff() as Float? { return _tariffGrid; }
    public function getGridPriceForecast() as GridPriceForecast? { return _gridPrices; }
    public function hasGridPriceForecast() as Boolean { return _gridPrices != null; }

    protected var _statistics as Statistics?;
    public function getStatistics() as Statistics { return _statistics as Statistics; }
    public function hasStatistics() as Boolean { return _statistics != null; }


    /******** CONSTRUCTOR ********/


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
    function initialize( result as JsonAdapter, dataTimestamp as Moment ) {
        _timestamp = dataTimestamp;

        // For battery power we support both the old structure with
        // batterySoc and batteryPower and the new structure with
        // battery.soc and battery.bower.
        var battery = result.getJsonObjectOrNull( BATTERY );
        if( battery != null ) {
            _batterySoc = battery.getNumberOrNull( SOC );
            if( _batterySoc != null ) {
                _batteryPower = battery.getNumber( POWER );
                _hasBattery = true;
            }
        }
        if( ! _hasBattery ) {
            _batterySoc = result.getNumberOrNull( BATTERYSOC );
            if( _batterySoc != null ) {
                _batteryPower = result.getNumber( BATTERYPOWER );
                _hasBattery = true;
            }
        }

        // For grid power we support both the old structure with
        // result.gridPower and the new structure with result.grid.power
        // used by evcc from 0.132.2 onwards
        _gridPower = result.getNumberOrNull( GRIDPOWER );
        if( _gridPower == null ) {
            _gridPower = result.getJsonObject( GRID ).getNumberOrNull( POWER );
        }

        _homePower = result.getNumberOrNull( HOMEPOWER );
        _pvPower = result.getNumberOrNull( PVPOWER );
        _siteTitle = result.getStringOrNull( SITETITLE );

        var loadpoints = result.getArrayOrNull( LOADPOINTS );
        // If there are no loadpoints, we get null, not an empty array
        if( loadpoints != null ) {
            for( var i = 0; i < loadpoints.size(); i++ ) {
                var loadpointData = loadpoints[i];
                var loadpoint = new Loadpoint( loadpointData, result );
                // In addition to the array of all loadpoints, we also
                // maintain a list of each type, for the display of categories
                if( loadpoint.isHeater() ) {
                    _heaters.add( loadpoint );
                } else if ( loadpoint.isIntegratedDevice() ) {
                    _integratedDevices.add( loadpoint );
                } else { 
                    _chargers.add( loadpoint ); 
                }
            }
        }

        _tariffGrid = result.getFloatOrNull( TARIFF_GRID );
        _smartCostAvailable = result.getBooleanOrFalse( SMART_COST_AVAILABLE );

        var forecast = result.getJsonObjectOrNull( FORECAST );
        if( forecast != null ) {
            var solarForecast = forecast.getJsonObjectOrNull( FORECAST_SOLAR );
            if( solarForecast != null) {
                _solarForecast = new SolarForecast( solarForecast );
            }
            if( _smartCostAvailable ) {
                var gridPrices = forecast.getJsonObjectOrNull( FORECAST_GRID );
                if( gridPrices != null ) {
                    _gridPrices = new GridPriceForecast( gridPrices );
                }
            }
        }
        var statistics = result.getJsonObjectOrNull( STATISTICS );
        if( statistics != null ) {
            _statistics = new Statistics( statistics );
        }
    }


    /******** SERIALIZATION ********/


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

        if( _tariffGrid != null ) {
            result.put( TARIFF_GRID, _tariffGrid );
        }
        result.put( SMART_COST_AVAILABLE, _smartCostAvailable );

        if( _solarForecast != null || _gridPrices != null ) {
            var forecast = {} as JsonObject;
            if( _solarForecast != null ) {
                forecast.put( FORECAST_SOLAR, _solarForecast.serialize() );
            }
            if( _gridPrices != null ) {
                forecast.put( FORECAST_GRID, _gridPrices.serialize() );
            }
            result.put( FORECAST, forecast );
        }
        if( _statistics != null ) {
            result.put( STATISTICS, _statistics.serialize() );
        }

       return result; 
    }
}