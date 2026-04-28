import Toybox.Lang;

// Class to represent the solar energy statistics
(:glance) 
class Statistics {
    private var _statistics as Array<StatisticsPeriod> = new Array<StatisticsPeriod>[0];
    public function getStatisticsPeriods() as Array<StatisticsPeriod> { return _statistics; }

    private const STATISTICS_PERIOD = [ "30d", "thisYear", "365d", "total" ];

    function initialize( statistics as JsonAdapter ) {
        for( var i = 0; i < STATISTICS_PERIOD.size(); i++ ) {
            _statistics.add( 
                new StatisticsPeriod( 
                    statistics.getJsonObjectOrNull( STATISTICS_PERIOD[i] ) 
                ) 
            );
        }
    }
}