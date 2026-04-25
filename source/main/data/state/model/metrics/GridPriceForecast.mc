import Toybox.Lang;

// Classes in this folder represent the current state of an evcc site
// They implement both the parsing of the JSON dictionary received
// as web response, as well as serializing in a JSON dictionary with
// the same structure for persiting the state in storage

// Class to represent the solar forecast
(:glance) 
class GridPriceForecast {
    private const GRID_PRICE_AVERAGES = [ "next60MinutesAverage", "remainingTodayAverage", "remainingTodayAverage", "tomorrowAverage" ];
    private const GRID_PRICE_CHEAPEST_HOUR = "cheapestHour";
    private const GRID_PRICE_CHEAPEST_HOUR_AVERAGE = "average";
    private const GRID_PRICE_CHEAPEST_HOUR_START = "start";
    private const GRID_PRICE_CHEAPEST_HOUR_END = "end";

    private var _averagePrices as Array<Float> = new Array<Float>[GRID_PRICE_AVERAGES.size()];
    private var _cheapestHourAverage as Float;

    function initialize( grid as JsonAdapter ) {
        for( var i = 0; i < _averagePrices.size(); i++ ) {
            _averagePrices[i] = grid.getFloat( GRID_PRICE_AVERAGES[i] );
        }

        var cheapestHour = grid.getJsonObject( GRID_PRICE_CHEAPEST_HOUR );
        _cheapestHourAverage = cheapestHour.getFloat( GRID_PRICE_CHEAPEST_HOUR_AVERAGE );
        var cheapestHourStart = cheapestHour.getFloat( GRID_PRICE_CHEAPEST_HOUR_START );
        var cheapestHourEnd = cheapestHour.getFloat( GRID_PRICE_CHEAPEST_HOUR_END );
    }

    function serialize() as JsonObject { 
        var gridPrices = {} as JsonObject;
        /*
        var energy = _energy as Array<Float?>;
        if( _hasForecast ) {
            solar[FORECAST_SCALE] = _scale;
            for( var i = 0; i < FORECAST_DAYS.size(); i++ ) {
                if( energy[i] != null ) {
                    var day = {} as JsonObject;
                    day[FORECAST_ENERGY] = energy[i];
                    solar[FORECAST_DAYS[i]] = day;
                }
            }
        }
        */
        return gridPrices;
    }
}