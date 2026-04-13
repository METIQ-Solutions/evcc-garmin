import Toybox.Lang;

// Classes in this folder represent the current state of an evcc site
// They implement both the parsing of the JSON dictionary received
// as web response, as well as serializing in a JSON dictionary with
// the same structure for persiting the state in storage

// This class represents a loadpoint
(:glance) class Loadpoint {
    private var _controllable as Controllable?;

    private var _isCharging as Boolean = false;
    private var _chargePower as Number = 0;
    private var _activePhases as Number = 0;
    private var _mode as String? = null;
    private var _chargeRemainingDuration as Number?;

    private const CHARGING = "charging";
    private const PHASESACTIVE = "phasesActive";
    private const CONNECTED = "connected";
    private const MODE = "mode";
    private const CHARGEPOWER = "chargePower";
    private const CHARGEREMAININGDURATION = "chargeRemainingDuration";
    private const CHARGERFEATUREHEATING = "chargerFeatureHeating";
    private const CHARGERFEATUREINTEGRATEDDEVICE = "chargerFeatureIntegratedDevice";
    
    function initialize( dataLp as JsonContainer, dataResult as JsonContainer ) {
        _isCharging = dataLp[CHARGING] as Boolean;
        _activePhases = dataLp[PHASESACTIVE] as Number;
        _chargePower = dataLp[CHARGEPOWER] as Number;
        _mode = dataLp[MODE] as String;
        _chargeRemainingDuration = dataLp[CHARGEREMAININGDURATION] as Number?;

        _controllable = readControllable( dataLp, dataResult );
    }

    (:exclForMemoryLow :typecheck(disableGlanceCheck))
    private function readControllable( 
        dataLp as JsonContainer, 
        dataResult as JsonContainer 
    ) as Controllable? {
        if( HelperUI.readBoolean( dataLp, CHARGERFEATUREHEATING ) && ! ( EvccApp.isGlance && EvccApp.deviceUsesTinyGlance ) ) {
            return new Heater( dataLp );
        } else if( HelperUI.readBoolean( dataLp, CHARGERFEATUREINTEGRATEDDEVICE ) && ! ( EvccApp.isGlance && EvccApp.deviceUsesTinyGlance ) ) {
            return new IntegratedDevice( dataLp );
        } else if( HelperUI.readBoolean( dataLp, CONNECTED ) ) {
            return new ConnectedVehicle( dataLp, dataResult );
        }
        return null;
    }

    (:exclForMemoryStandard)
    private function readControllable( 
        dataLp as JsonContainer, 
        dataResult as JsonContainer 
    ) as Controllable? {
        if(    ! HelperUI.readBoolean( dataLp, CHARGERFEATUREHEATING )
            && ! HelperUI.readBoolean( dataLp, CHARGERFEATUREINTEGRATEDDEVICE ) 
            &&   HelperUI.readBoolean( dataLp, CONNECTED ) ) {
            
            return new ConnectedVehicle( dataLp, dataResult );
        }
        return null;
    }

    (:typecheck(disableGlanceCheck))
    function serialize() as JsonContainer {
        var loadpoint = { 
            CHARGING => _isCharging,
            PHASESACTIVE => _activePhases,
            CHARGEPOWER => _chargePower,
            MODE => _mode,
            CHARGEREMAININGDURATION => _chargeRemainingDuration
        } as JsonContainer;

        serializeControllable( loadpoint );

        return loadpoint;
    }

    (:exclForMemoryLow :typecheck(disableGlanceCheck))
    function serializeControllable( loadpoint as JsonContainer ) as JsonContainer {
        if( _controllable != null ) {
            _controllable.serialize( loadpoint );
            if( _controllable instanceof ConnectedVehicle ) {
                loadpoint[CONNECTED] = true;
            } else if( _controllable instanceof Heater ) {
                loadpoint[CONNECTED] = true;
                loadpoint[CHARGERFEATUREHEATING] = true;
            } else if( _controllable instanceof IntegratedDevice ) {
                loadpoint[CONNECTED] = true;
                loadpoint[CHARGERFEATUREINTEGRATEDDEVICE] = true;
            }
        }

        return loadpoint;
    }

    (:exclForMemoryStandard)
    function serializeControllable( loadpoint as JsonContainer ) as JsonContainer {
        if( _controllable != null ) {
            _controllable.serialize( loadpoint );
            loadpoint[CONNECTED] = true;
        }
        return loadpoint;
    }

    public function isCharging() as Boolean { return _isCharging; }
    public function getActivePhases() as Number { return _activePhases; }
    public function getChargePowerRounded() as Number { return HelperBase.roundPower( _chargePower ); }

    (:exclForMemoryLow)
    public function getControllable() as Controllable? { return _controllable; }

    public function isVehicle() as Boolean { return _controllable instanceof ConnectedVehicle; }
    public function getVehicle() as ConnectedVehicle? { return isVehicle() ? _controllable as ConnectedVehicle : null; }

    (:exclForMemoryLow :typecheck(disableGlanceCheck))
    public function isHeater() as Boolean { return _controllable instanceof Heater; }
    (:exclForMemoryStandard)
    public function isHeater() as Boolean { return false; }
    public function getHeater() as Heater? { return isHeater() ? _controllable as Heater : null; }

    (:exclForMemoryLow :typecheck(disableGlanceCheck))
    public function isIntegratedDevice() as Boolean { return _controllable instanceof IntegratedDevice; }
    (:exclForMemoryStandard)
    public function isIntegratedDevice() as Boolean { return false; }

    public function getIntegratedDevice() as IntegratedDevice? { return isIntegratedDevice() ? _controllable as IntegratedDevice : null; }

    // Possible values: "pv", "now", "minpv", "off"
    public function getMode() as String { return _mode != null ? _mode : "unknown"; }

    public function getChargeRemainingDuration() as Number { return _chargeRemainingDuration != null ? _chargeRemainingDuration : 0; }
}
