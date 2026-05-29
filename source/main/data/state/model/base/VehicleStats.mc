import Toybox.Lang;

// This class holds statistics on the (guest) vehicles
// in the system
(:glance) class VehicleStats {
    
    private var _guestCount as Number;
    public function getGuestCount() as Number { return _guestCount; }    
    private var _vehicleCount as Number;
    public function getVehicleCount() as Number { return _vehicleCount; }    

    function initialize( result as JsonAdapter, guestCount as Number ) {
        _guestCount = guestCount;
        var vehicles = result.getJsonObjectOrNull( Vehicle.VEHICLES );
        _vehicleCount = vehicles == null ? 0 : vehicles.size();
    }
}