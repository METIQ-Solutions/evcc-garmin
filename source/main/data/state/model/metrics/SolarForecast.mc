import Toybox.Lang;

// Classes in this folder represent the current state of an evcc site
// They implement both the parsing of the JSON dictionary received
// as web response, as well as serializing in a JSON dictionary with
// the same structure for persiting the state in storage

// Class to represent the solar forecast
(:glance) 
class SolarForecast {
    private const FORECAST_DAYS = [ "today", "tomorrow", "dayAfterTomorrow" ];
    private const FORECAST_ENERGY = "energy";
    private const FORECAST_SCALE = "scale";

    private var _scale as Float;
    function getScale() as Float { return _scale; }
    
    private var _energy as Array<Float> = new Array<Float>[FORECAST_DAYS.size()];
    function getEnergy() as Array<Float> { return _energy; }

    function initialize( solarForecast as JsonAdapter ) {
        var scale = solarForecast.getFloatOrNull( FORECAST_SCALE );
        _scale = scale != null ? scale : 1.0;
        for( var i = 0; i < FORECAST_DAYS.size(); i++ ) {
            _energy[i] = solarForecast.getJsonObject( FORECAST_DAYS[i] ).getFloat( FORECAST_ENERGY );
        }
    }

    function serialize() as JsonObject { 
        var solar = {} as JsonObject;
        solar[FORECAST_SCALE] = _scale;
        for( var i = 0; i < _energy.size(); i++ ) {
            solar[FORECAST_DAYS[i]] = { FORECAST_ENERGY => _energy[i] };
        }
        return solar;
    }
}