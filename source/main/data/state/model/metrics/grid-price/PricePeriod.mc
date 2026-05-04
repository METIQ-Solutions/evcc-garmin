import Toybox.Lang;
import Toybox.Time;

// Class to represent one of the cheapest/most expensive price periods 
// within the grid price forecast
(:glance)
class PricePeriod {
    private const GRID_PRICE_CHEAPEST_HOUR_AVERAGE = "average";
    private const GRID_PRICE_CHEAPEST_HOUR_START = "start";
    private const GRID_PRICE_CHEAPEST_HOUR_END = "end";

    private var _periodAverage as Float;
    private var _periodStart as Moment;
    private var _periodEnd as Moment;

    public function getAverage() as Float { return _periodAverage; }
    public function getStart() as Moment { return _periodStart; }
    public function getEnd() as Moment { return _periodEnd; }
    
    function initialize( period as JsonAdapter ) {
        _periodAverage = period.getFloat( GRID_PRICE_CHEAPEST_HOUR_AVERAGE );
        _periodStart = period.getMoment( GRID_PRICE_CHEAPEST_HOUR_START );
        _periodEnd = period.getMoment( GRID_PRICE_CHEAPEST_HOUR_END );
    }
}