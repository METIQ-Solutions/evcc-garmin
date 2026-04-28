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
    private var _isOnlyVehicle as Boolean = false;

    private const VEHICLENAME = "vehicleName";
    private const VEHICLES = "vehicles";
    private const VH_TITLE = "title";
    private const VEHICLESOC = "vehicleSoc";

    function initialize( dataLp as JsonAdapter, dataResult as JsonAdapter, lpTitle as String ) {
        LoadpointItem.initialize( dataLp );

        var name = dataLp.getStringOrNull( VEHICLENAME );
        var title = null;

        // For guest vehicles we use the loadpoint title as name/title
        if( name == null || name.equals( "" ) ) {
            title = lpTitle;
            _isGuest = true;
        } else {
            // If it is not a guest, we lookup the SoC and vehicle title
            _soc = dataLp.getNumber( VEHICLESOC );
            
            var vehicles = dataResult.getJsonObjectOrNull( VEHICLES );
            if( vehicles != null ) {
                if( vehicles.size() == 1 ) {
                    _isOnlyVehicle = true;                    
                }
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
    public function isOnlyVehicle() as Boolean { return _isOnlyVehicle; }
}
