import Toybox.Lang;
import Toybox.Time;

// Class to represent the cheapest hour within the grid price forecast
(:glance)
class CheapestHour {
    private const GRID_PRICE_CHEAPEST_HOUR_AVERAGE = "average";
    private const GRID_PRICE_CHEAPEST_HOUR_START = "start";
    private const GRID_PRICE_CHEAPEST_HOUR_END = "end";

    private var _cheapestHourAverage as Float;
    private var _cheapestHourStart as Moment;
    private var _cheapestHourEnd as Moment;

    public function getCheapestHourAverage() as Float { return _cheapestHourAverage; }
    public function getCheapestHourStart() as Moment { return _cheapestHourStart; }
    public function getCheapestHourEnd() as Moment { return _cheapestHourEnd; }
    
    function initialize( cheapestHour as JsonAdapter ) {
        _cheapestHourAverage = cheapestHour.getFloat( GRID_PRICE_CHEAPEST_HOUR_AVERAGE );
        _cheapestHourStart = cheapestHour.getMoment( GRID_PRICE_CHEAPEST_HOUR_START );
        _cheapestHourEnd = cheapestHour.getMoment( GRID_PRICE_CHEAPEST_HOUR_END );
    }

}