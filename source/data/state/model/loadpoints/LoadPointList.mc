import Toybox.Lang;

// Class representing a list of load points with aggregated data
// Instances of this class are used to implement three lists,
// one for vehicles, one for heaters and one for integrated devices
(:glance) 
class LoadpointList {
    // The list of loadpoints
    private var _loadpoints as ArrayOfLoadpoints = new ArrayOfLoadpoints[0];
    
    // The number of loadpoints that are charging
    private var _chargingLoadpointCount as Number = 0;
    
    // The total charging power currently consumed by all charging loadpoints
    private var _totalChargingPower as Number = 0;

    // Add a loadpoint
    public function add( loadpoint as Loadpoint ) as Void {
        _loadpoints.add( loadpoint );
        if( loadpoint.isCharging() ) {
            _chargingLoadpointCount++;
            _totalChargingPower += loadpoint.getChargePowerRounded();
        }
    }

    // Get the loadpoints in this list
    public function getLoadpoints() as ArrayOfLoadpoints { return _loadpoints; }
    
    // Get the loadpoints and clear the reference,
    // to be used for serialization
    public function getAndClearLoadpoints() as ArrayOfLoadpoints { 
        var loadpoints = _loadpoints;
        _loadpoints = new ArrayOfLoadpoints[0];
        return loadpoints; 
    }
    
    // Returns the number of loadpoints on the list that are currently charging
    public function getChargingLoadpointCount() as Number { return _chargingLoadpointCount; }
    
    // Returns the total charging power consumed by all charging loadpoints
    public function getTotalChargingPower() as Number { return _totalChargingPower; }
}