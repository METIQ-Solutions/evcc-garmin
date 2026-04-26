import Toybox.Lang;
import Toybox.Time;

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
    private var _cheapestHourStart as Moment;
    private var _cheapestHourEnd as Moment;

    function initialize( grid as JsonAdapter ) {
        grid.debug();

        for( var i = 0; i < _averagePrices.size(); i++ ) {
            _averagePrices[i] = grid.getFloat( GRID_PRICE_AVERAGES[i] );
        }

        var cheapestHour = grid.getJsonObject( GRID_PRICE_CHEAPEST_HOUR );
        _cheapestHourAverage = cheapestHour.getFloat( GRID_PRICE_CHEAPEST_HOUR_AVERAGE );
        _cheapestHourStart = cheapestHour.getMoment( GRID_PRICE_CHEAPEST_HOUR_START );
        _cheapestHourEnd = cheapestHour.getMoment( GRID_PRICE_CHEAPEST_HOUR_END );
    }

    function serialize() as JsonObject { 
        var gridPrices = {} as JsonObject;
        for( var i = 0; i < _averagePrices.size(); i++ ) {
            gridPrices.put( GRID_PRICE_AVERAGES[i], _averagePrices[i] );
        }
        var cheapestHour = {} as JsonObject;
        cheapestHour.put( GRID_PRICE_CHEAPEST_HOUR_AVERAGE, _cheapestHourAverage );
        cheapestHour.put( 
            GRID_PRICE_CHEAPEST_HOUR_START, 
            JsonAdapter.momentToIsoLocalString( _cheapestHourStart ) 
        );
        cheapestHour.put( 
            GRID_PRICE_CHEAPEST_HOUR_END, 
            JsonAdapter.momentToIsoLocalString( _cheapestHourEnd ) 
        );
        gridPrices.put( GRID_PRICE_CHEAPEST_HOUR, cheapestHour );
        return gridPrices;
    }
}