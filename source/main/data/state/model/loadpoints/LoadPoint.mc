import Toybox.Lang;

// Classes in this folder represent the current state of an evcc site
// They implement both the parsing of the JSON dictionary received
// as web response, as well as serializing in a JSON dictionary with
// the same structure for persiting the state in storage

// This class represents a loadpoint
(:glance) class Loadpoint {
    private var _controllable as LoadpointItem?;

    private var _title as String;
    private var _isCharging as Boolean = false;
    private var _chargePower as Number = 0;
    private var _activePhases as Number = 0;
    private var _mode as String? = null;
    private var _chargeRemainingDuration as Number?;
    private var _isOnlyInCategory as Boolean = true; // Each loadpoint starts as only one in the category

    private const TITLE = "title";
    private const CHARGING = "charging";
    private const PHASESACTIVE = "phasesActive";
    private const CONNECTED = "connected";
    private const MODE = "mode";
    private const CHARGEPOWER = "chargePower";
    private const CHARGEREMAININGDURATION = "chargeRemainingDuration";
    private const CHARGERFEATUREHEATING = "chargerFeatureHeating";
    private const CHARGERFEATUREINTEGRATEDDEVICE = "chargerFeatureIntegratedDevice";
    
    function initialize( dataLp as JsonAdapter, dataResult as JsonAdapter ) {
        _title = dataLp.getString( TITLE );
        _isCharging = dataLp.getBoolean( CHARGING );
        _activePhases = dataLp.getNumber( PHASESACTIVE );
        _chargePower = dataLp.getNumber( CHARGEPOWER );
        _mode = dataLp.getString( MODE );
        _chargeRemainingDuration = dataLp.getNumberOrNull( CHARGEREMAININGDURATION );

        if( dataLp.getBooleanOrFalse( CHARGERFEATUREHEATING ) ) {
            _controllable = new Heater( dataLp );
        } else if( dataLp.getBooleanOrFalse( CHARGERFEATUREINTEGRATEDDEVICE ) ) {
            _controllable = new IntegratedDevice( dataLp );
        } else if( dataLp.getBooleanOrFalse( CONNECTED ) ) {
            _controllable = new Vehicle( dataLp, dataResult, _title );
        }
    }

    public function getTitle() as String { return _title; }

    public function isCharging() as Boolean { return _isCharging; }
    public function getActivePhases() as Number { return _activePhases; }
    public function getChargePowerRounded() as Number { return ExtendedMath.roundPower( _chargePower ); }

    public function getControllable() as LoadpointItem? { return _controllable; }

    public function isVehicle() as Boolean { return _controllable instanceof Vehicle; }
    public function getVehicle() as Vehicle? { return isVehicle() ? _controllable as Vehicle : null; }

    public function isHeater() as Boolean { return _controllable instanceof Heater; }
    public function getHeater() as Heater? { return isHeater() ? _controllable as Heater : null; }

    public function isIntegratedDevice() as Boolean { return _controllable instanceof IntegratedDevice; }

    public function getIntegratedDevice() as IntegratedDevice? { return isIntegratedDevice() ? _controllable as IntegratedDevice : null; }

    // Possible values: "pv", "now", "minpv", "off"
    public function getMode() as String { return _mode != null ? _mode : "unknown"; }

    public function getChargeRemainingDuration() as Number { return _chargeRemainingDuration != null ? _chargeRemainingDuration : 0; }

    public function setNotOnlyInCategory() as Void { _isOnlyInCategory = false; }
    public function isOnlyInCategory() as Boolean { return _isOnlyInCategory; }
}
