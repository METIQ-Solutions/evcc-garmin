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

    private const VEHICLENAME = "vehicleName";
    public static const VEHICLES = "vehicles";
    private const VH_TITLE = "title";
    private const VEHICLESOC = "vehicleSoc";

    function initialize( dataLp as JsonAdapter, dataResult as JsonAdapter ) {
        LoadpointItem.initialize( dataLp );

        var name = dataLp.getStringOrNull( VEHICLENAME );
        var title = null;
        var vehicles = dataResult.getJsonObjectOrNull( VEHICLES );

        // If there is no name, then it is a guest vehicle
        if( name == null || name.equals( "" ) ) {
            title = "Guest";
            _isGuest = true;
        } else {
            // If it is not a guest, we lookup the SoC and vehicle title
            _soc = dataLp.getNumber( VEHICLESOC );
            
            if( vehicles != null ) {
                var vehicle = vehicles.getJsonObjectOrNull( name );
                if( vehicle != null ) {
                    title = vehicle.getString( VH_TITLE );
                }
            }
        }

        if( title != null ) {
            _title = title;
        } else {
            throw new InvalidValueException( "JSON: could not find vehicle " + name );
        }
    }
    
    public function getTitle() as String { return _title; }
    public function getSoc() as Number { return _soc; }
    public function isGuest() as Boolean { return _isGuest; }
}
