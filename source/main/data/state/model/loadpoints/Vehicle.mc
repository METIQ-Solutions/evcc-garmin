import Toybox.Lang;

// Classes in this folder represent the current state of an evcc site
// They implement both the parsing of the JSON dictionary received
// as web response, as well as serializing in a JSON dictionary with
// the same structure for persiting the state in storage

// Class representing a vehicle connected to a loadpoint
// Currently only connected vehicles are relevant, others
// are ignored
(:glance) class Vehicle extends LoadpointItem {
    private var _title as String;
    private var _soc as Number = 0;
    private var _isGuest as Boolean = false;
    private var _isConnected as Boolean = false;

    private static const CONNECTED = "connected";
    public static const VEHICLES = "vehicles";
    private static const VEHICLETITLE = "vehicleTitle";
    private static const VEHICLESOC = "vehicleSoc";

    public static function isVehicle( dataLp as JsonAdapter ) as Boolean {
        return dataLp.getBooleanOrFalse( CONNECTED ) || dataLp.getNumberOrZero( VEHICLESOC ) > 0;
    }

    public function initialize( dataLp as JsonAdapter ) {
        LoadpointItem.initialize( dataLp );

        var title = dataLp.getStringOrNull( VEHICLETITLE );
        _isConnected = dataLp.getBooleanOrFalse( CONNECTED );
        _soc = dataLp.getNumberOrZero( VEHICLESOC );

        // If there is no name, then it is a guest vehicle
        if( _isConnected && ( title == null || title.equals( "" ) ) ) {
            _title = "Guest";
            _isGuest = true;
        } else if( _isConnected || _soc > 0 ) {
            // If it is not a guest, we lookup the SoC and vehicle title
            if( title == null || title.equals( "" ) ) {
                throw new InvalidValueException( "JSON: vehicle connected or SoC provided, but vehicle title is empty." );
            }
            _title = title;
        } else {
            throw new InvalidValueException( "JSON: class Vehicle was instantiated without vehicle data present." );
        }
    }
    
    public function getTitle() as String { return _title; }
    public function getSoc() as Number { return _soc; }
    public function isGuest() as Boolean { return _isGuest; }
    public function isConnected() as Boolean { return _isConnected; }
}
