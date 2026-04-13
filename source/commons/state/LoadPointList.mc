import Toybox.Lang;

// Class representing a list of load points with aggregated data
// Instances of this class are used to implement three lists,
// one for vehicles, one for heaters and one for integrated devices
(:glance) 
class LoadpointList {
    // The list of loadpoints
    private var _loadPoints as ArrayOfLoadPoints = new ArrayOfLoadPoints[0];
    
    // The number of loadpoints that are charging
    private var _chargingLoadPointCount as Number = 0;
    
    // The total charging power currently consumed by all charging loadpoints
    private var _totalChargingPower as Number = 0;

    // Add a loadpoint
    public function add( loadPoint as Loadpoint ) as Void {
        _loadPoints.add( loadPoint );
        if( loadPoint.isCharging() ) {
            _chargingLoadPointCount++;
            _totalChargingPower += loadPoint.getChargePowerRounded();
        }
    }

    // Get the loadpoints in this list
    public function getLoadPoints() as ArrayOfLoadPoints { return _loadPoints; }
    
    // Get the loadpoints and clear the reference,
    // to be used for serialization
    public function getAndClearLoadPoints() as ArrayOfLoadPoints { 
        var loadPoints = _loadPoints;
        _loadPoints = new ArrayOfLoadPoints[0];
        return loadPoints; 
    }
    
    // Returns the number of loadpoints on the list that are currently charging
    public function getChargingLoadPointCount() as Number { return _chargingLoadPointCount; }
    
    // Returns the total charging power consumed by all charging loadpoints
    public function getTotalChargingPower() as Number { return _totalChargingPower; }
}