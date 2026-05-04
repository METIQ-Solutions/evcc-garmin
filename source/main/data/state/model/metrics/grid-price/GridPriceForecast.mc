import Toybox.Lang;
import Toybox.Time;

// Class to represent the solar forecast
(:glance) 
class GridPriceForecast {
    private const GRID_PRICE_AVERAGES = [ "next60MinutesAverage", "next60To120MinutesAverage", "remainingTodayAverage", "tomorrowAverage" ];
    private const GRID_PRICE_PERIODS = [ "cheapest1h", "cheapest2h", "cheapest3h", "mostExpensive1h" ];

    private var _averagePrices as Array<Float?> = new Array<Float?>[GRID_PRICE_AVERAGES.size()];
    private var _pricePeriods as Array<PricePeriod?> = new Array<PricePeriod?>[GRID_PRICE_PERIODS.size()];

    public function getAveragePrices() as Array<Float?> { return _averagePrices; }
    public function getPricePeriods() as Array<PricePeriod?> { return _pricePeriods; }
    
    function initialize( grid as JsonAdapter ) {
        for( var i = 0; i < _averagePrices.size(); i++ ) {
            _averagePrices[i] = grid.getFloatOrNull( GRID_PRICE_AVERAGES[i] );
        }

        for( var i = 0; i < _pricePeriods.size(); i++ ) {
            var period = grid.getJsonObjectOrNull( GRID_PRICE_PERIODS[i] );
            if( period != null ) {
                _pricePeriods[i] = new PricePeriod( period );
            }
        }
    }
}