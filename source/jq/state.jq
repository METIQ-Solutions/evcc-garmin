# FUNCTIONS

# Calculates the average from a list of values
def avg:
    if length > 0 then
        add / length
    else
        null
    end;

# Calculates the average of values that fall between
# two timestamps
def grid_avg_between($grid; $from; $to):
    [
        ($grid // [])[]
        | select(.start >= $from and .start < $to)
        | .value
    ]
    | avg;

# Adds the given number of days to the current timestamp
# and outputs the date of the resulting timestamp
def local_day($offset):
    (now + $offset)
    | strflocaltime("%Y-%m-%d");

# Adds the given number of seconds to the current timestamp
# and outputs the resulting timestamp
def localtime_after($seconds):
    (now + $seconds)
    | strflocaltime("%Y-%m-%dT%H:%M:%S%z")
    | sub("(..)$"; ":\\1");

# Find the window with the given length ($slots) where
# the average price is the lowest ($mode="min") or 
# highest ($mode="max")
def price_period($slots; $mode):
    localtime_after(0) as $from
    | [ .[] | select(.start >= $from) ] as $entries
    | if ($entries | length) >= $slots then
        [
            range(0; ($entries | length) - $slots + 1) as $i
            | ($entries[$i:$i + $slots]) as $window
            | {
                start: $window[0].start,
                end: $window[-1].end,
                average: (($window | map(.value) | add) / $slots)
            }
        ]
        | if $mode == "max" then
            max_by(.average)
          else
            min_by(.average)
          end
      else
        null
      end;

# MAIN FILTER

. as $root
    # The filter supports either the legacy structure
    # with a "result" root element or the new one without
    | ($root.result // $root) as $data
    | {
        batteryPower: $data.batteryPower,
        batterySoc: $data.batterySoc,
        battery:
            if ($data.battery | type) == "object" then
                {
                    power: $data.battery.power,
                    soc: $data.battery.soc
                }
            else
                null
            end,
        forecast: {
            # For grid, evcc delivers only time series, which is too large
            # to be processed within the app. Therefore we use JQ to aggregate
            # all values that are displayed already on the server-side
            grid: 
                # Use this when testing grid price forecast on an instance without
                # smart costs enabled
                # if true then 
                if $data.smartCostAvailable then 
                    {
                        next60MinutesAverage: (
                            localtime_after(0) as $from
                            | localtime_after(3600) as $to
                            | grid_avg_between($data.forecast.grid; $from; $to)
                        ),
                        next60To120MinutesAverage: (
                            localtime_after(3600) as $from
                            | localtime_after(7200) as $to
                            | grid_avg_between($data.forecast.grid; $from; $to)
                        ),
                        remainingTodayAverage: (
                            localtime_after(0) as $from
                            | local_day(86400) as $nextDay
                            | [
                                ($data.forecast.grid // [])[]
                                | select(.start >= $from and (.start | startswith($nextDay) | not))
                                | .value
                            ]
                            | avg
                        ),
                        tomorrowAverage: (
                            local_day(86400) as $day
                            | [
                                ($data.forecast.grid // [])[]
                                | select(.start | startswith($day))
                                | .value
                            ]
                            | avg
                        ),
                        cheapest1h: (
                            ($data.forecast.grid // [])
                            | price_period(4; "min")
                        ),
                        cheapest2h: (
                            ($data.forecast.grid // [])
                            | price_period(8; "min")
                        ),
                        cheapest3h: (
                            ($data.forecast.grid // [])
                            | price_period(12; "min")
                        ),
                        mostExpensive1h: (
                            ($data.forecast.grid // [])
                            | price_period(4; "max")
                        ) 
                    }
                else
                    null
                end,
            solar: (
                $data.forecast.solar
                | {
                    scale,
                    today: {
                        energy: .today.energy
                    },
                    tomorrow: {
                        energy: .tomorrow.energy
                    },
                    dayAfterTomorrow: {
                        energy: .dayAfterTomorrow.energy
                    }
                }
            )
        },
        gridPower: $data.gridPower,
        grid: {
            power: $data.grid.power
        },
        homePower: $data.homePower,
        loadpoints: [
            (
                $data.loadpoints[]
                | {
                    chargePower,
                    chargerFeatureHeating,
                    chargerFeatureIntegratedDevice,
                    charging,
                    connected,
                    vehicleName,
                    vehicleSoc,
                    title,
                    phasesActive,
                    mode,
                    chargeRemainingDuration
                }
            )
        ],
        pvPower: $data.pvPower,
        siteTitle: $data.siteTitle,
        smartCostAvailable: $data.smartCostAvailable,
        statistics: (
            $data.statistics
            | map_values({ solarPercentage })
        ),
        tariffGrid: $data.tariffGrid,
        vehicles: (
            $data.vehicles
            | map_values({ title })
        )
    }
    # This final function removes any empty objects or arrays
    | walk(
        if type == "object" then
            with_entries(select(.value != null and .value != {} and .value != []))
        elif type == "array" then
            map(select(. != null and . != {} and . != []))
        else
            .
        end
    )