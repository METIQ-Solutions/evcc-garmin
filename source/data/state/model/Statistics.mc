import Toybox.Lang;

// Classes in this folder represent the current state of an evcc site
// They implement both the parsing of the JSON dictionary received
// as web response, as well as serializing in a JSON dictionary with
// the same structure for persiting the state in storage

// Class to represent the solar forecast
(:glance :exclForMemoryLow) 
class Statistics {
    private var _statistics as Array<StatisticsPeriod> = new Array<StatisticsPeriod>[0];
    public function getStatisticsPeriods() as Array<StatisticsPeriod> { return _statistics; }

    private const STATISTICS_PERIOD = [ "30d", "thisYear", "365d", "total" ];

    function initialize( statistics as JsonObject ) {
        for( var i = 0; i < STATISTICS_PERIOD.size(); i++ ) {
            _statistics.add( 
                new StatisticsPeriod( 
                    statistics[STATISTICS_PERIOD[i]]
                ) 
            );
        }
    }

    function serialize() as JsonObject { 
        var statistics = {} as JsonObject;
 
        for( var i = 0; i < STATISTICS_PERIOD.size(); i++ ) {
            statistics[STATISTICS_PERIOD[i]] = _statistics[i].serialize();
        }
        return statistics;
    }
}

(:glance :exclForMemoryLow) class StatisticsPeriod {
    
    // If no value is found, the solar percentage is left at null    
    private var _solarPercent as Float?;
    function getSolarPercent() as Float? { return _solarPercent; }

    private const STATISTICS_SOLAR_PERCENTAGE = "solarPercentage";

    // Constructor
    // The solar percentage is set only if valid data is found
    function initialize( statisticsPeriod as Object? ) {
        if( statisticsPeriod instanceof Dictionary ) {
            var solarPercent = statisticsPeriod[STATISTICS_SOLAR_PERCENTAGE];
            if( solarPercent instanceof Float ) {
                _solarPercent = solarPercent;
            }
        }
    }

    function serialize() as JsonObject { 
        return { STATISTICS_SOLAR_PERCENTAGE => _solarPercent } as JsonObject;
    }
}