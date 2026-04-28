import Toybox.Lang;

// Class to represent one solar energy statistics period
// (e.g. last 30 days)
(:glance) 
class StatisticsPeriod {
    
    // If no value is found, the solar percentage is left at null    
    private var _solarPercent as Float?;
    function getSolarPercent() as Float? { return _solarPercent; }

    private const STATISTICS_SOLAR_PERCENTAGE = "solarPercentage";

    // Constructor
    // The solar percentage is set only if valid data is found
    function initialize( statisticsPeriod as JsonAdapter? ) {
        if( statisticsPeriod != null ) {
            _solarPercent = statisticsPeriod.getFloatOrNull( STATISTICS_SOLAR_PERCENTAGE );
        }
    }
}