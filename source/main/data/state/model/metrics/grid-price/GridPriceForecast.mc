import Toybox.Lang;
import Toybox.Time;

// Class to represent the solar forecast
(:glance) 
class GridPriceForecast {
    private const GRID_PRICE_AVERAGES = [ "next60MinutesAverage", "next60To120MinutesAverage", "remainingTodayAverage", "tomorrowAverage" ];
    private const GRID_PRICE_CHEAPEST_HOUR = "cheapestPeriod";

    private var _averagePrices as Array<Float?> = new Array<Float?>[GRID_PRICE_AVERAGES.size()];
    private var _cheapestPeriod as CheapestPeriod?;

    public function getAveragePrices() as Array<Float?> { return _averagePrices; }
    public function getCheapestPeriod() as CheapestPeriod? { return _cheapestPeriod; }
    
    function initialize( grid as JsonAdapter ) {
        for( var i = 0; i < _averagePrices.size(); i++ ) {
            _averagePrices[i] = grid.getFloatOrNull( GRID_PRICE_AVERAGES[i] );
        }

        var cheapestHour = grid.getJsonObjectOrNull( GRID_PRICE_CHEAPEST_HOUR );

        if( cheapestHour != null ) {
            _cheapestPeriod = new CheapestPeriod( cheapestHour );
        }
    }
}