import Toybox.Lang;
import Toybox.Time;

// Class to represent the cheapest hour within the grid price forecast
(:glance)
class CheapestPeriod {
    private const GRID_PRICE_CHEAPEST_HOUR_AVERAGE = "average";
    private const GRID_PRICE_CHEAPEST_HOUR_START = "start";
    private const GRID_PRICE_CHEAPEST_HOUR_END = "end";

    private var _cheapestPeriodAverage as Float;
    private var _cheapestPeriodStart as Moment;
    private var _cheapestPeriodEnd as Moment;

    public function getCheapestPeriodAverage() as Float { return _cheapestPeriodAverage; }
    public function getCheapestPeriodStart() as Moment { return _cheapestPeriodStart; }
    public function getCheapestPeriodEnd() as Moment { return _cheapestPeriodEnd; }
    
    function initialize( cheapestHour as JsonAdapter ) {
        _cheapestPeriodAverage = cheapestHour.getFloat( GRID_PRICE_CHEAPEST_HOUR_AVERAGE );
        _cheapestPeriodStart = cheapestHour.getMoment( GRID_PRICE_CHEAPEST_HOUR_START );
        _cheapestPeriodEnd = cheapestHour.getMoment( GRID_PRICE_CHEAPEST_HOUR_END );
    }

}