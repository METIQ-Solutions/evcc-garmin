import Toybox.Lang;
import Toybox.Time;

/*
 * Contains types and an adapter class for reading data from a JSON object.
 */

// This types are used by the API to represent a JSON object
typedef JsonObject as Dictionary<String,Object?>;
typedef JsonArray as Array<JsonAdapter>;

(:glance) 
class JsonAdapter {

    private var _jsonObject as JsonObject;

    public function initialize( jsonObject as JsonObject ) {
        _jsonObject = jsonObject;
    }

    (:debug)
    public function debug() as Void {
        Logger.debug( "JSON Object:" );
        var keys = _jsonObject.keys();
        for( var i = 0; i < keys.size(); i++ ) {
            var key = keys[i];
            Logger.debug( "    " + key + " = " + _jsonObject[key] );
        }
    }

    public function getArray( key as String ) as JsonArray {
        var value = getArrayOrNull( key );
        if( value != null ) {
            return value;
        } else {
            throw new InvalidValueException( "JSON: " + key + " is missing." );
        }
    }

    public function getArrayOrNull( key as String ) as JsonArray? {
        var jsonArray = _jsonObject[ key ];
        if( jsonArray == null ) {
            return null;
        } else if( jsonArray instanceof Array ) {
            var adArray = new Array<JsonAdapter>[0];
            for( var i = 0; i < jsonArray.size(); i++ ) {
                var jsonEntry = jsonArray[i];
                if( jsonEntry instanceof Dictionary ) {
                    adArray.add( new JsonAdapter( jsonEntry as JsonObject ) );
                } else {
                    throw new InvalidValueException( "JSON: array entry in " + key + " is not a JSON object." );
                }
            }
            return adArray;
        } else {
            throw new InvalidValueException( "JSON: " + key + " is not a JSON array." );
        }
    }

    public function getBoolean( key as String ) as Boolean {
        var value = getBooleanOrNull( key );
        if( value != null ) {
            return value;
        } else {
            throw new InvalidValueException( "JSON: " + key + " is missing." );
        }
    }

    public function getBooleanOrFalse( key as String ) as Boolean {
        var value = getBooleanOrNull( key );
        return value != null && ( value as Boolean );
    }

    public function getBooleanOrNull( key as String ) as Boolean? {
        var value = _jsonObject[key];
        if( value instanceof Boolean || value == null ) {
            return value;
        } else {
            throw new InvalidValueException( "JSON: " + key + " is not a Boolean." );
        }
    }

    public function getFloat( key as String ) as Float {
        var value = getFloatOrNull( key );
        if( value != null ) {
            return value;
        } else {
            throw new InvalidValueException( "JSON: " + key + " is missing." );
        }
    }

    public function getFloatOrNull( key as String ) as Float? {
        var value = _jsonObject[key];
        if( value instanceof Float || value == null ) {
            return value;
        } else if( value instanceof Number || value instanceof Long || value instanceof Double ) {
            return value.toFloat();
        } else {
            throw new InvalidValueException( "JSON: " + key + " is not a Float." );
        }
    }

    public function getMoment( key as String ) as Moment {
        var value = getMomentOrNull( key );
        if( value != null ) {
            return value;
        } else {
            throw new InvalidValueException( "JSON: " + key + " is missing." );
        }
    }

    public function getMomentOrNull( key as String ) as Moment? {
        var value = getStringOrNull( key );
        if( value == null ) {
            return null;
        } else {
            return parseIsoLocalMoment( value );
        }
    }

    public function getNumber( key as String ) as Number {
        var value = getNumberOrNull( key );
        if( value != null ) {
            return value;
        } else {
            throw new InvalidValueException( "JSON: " + key + " is missing." );
        }
    }
    public function getNumberOrNull( key as String ) as Number? {
        var value = _jsonObject[key];
        if( value instanceof Number || value == null ) {
            return value;
        } else if( value instanceof Long || value instanceof Float || value instanceof Double ) {
            return value.toNumber();
        } else {
            throw new InvalidValueException( "JSON: " + key + " is not a Number." );
        }
    }

    public function getString( key as String ) as String {
        var value = getStringOrNull( key );
        if( value != null ) {
            return value;
        } else {
            throw new InvalidValueException( "JSON: " + key + " is missing." );
        }
    }

    public function getStringOrNull( key as String ) as String? {
        var value = _jsonObject[key];
        if( value instanceof String || value == null ) {
            return value;
        } else {
            throw new InvalidValueException( "JSON: " + key + " is not a String." );
        }
    }

    public function getJsonObject( key as String ) as JsonAdapter {
        var value = getJsonObjectOrNull( key );
        if( value != null ) {
            return value;
        } else {
            throw new InvalidValueException( "JSON: " + key + " is missing." );
        }
    }
    public function getJsonObjectOrNull( key as String ) as JsonAdapter? {
        debug();
        var value = _jsonObject[key];
        if( value == null ) {
            return null;
        } else if( value instanceof Dictionary ) {
            return new JsonAdapter( value as JsonObject );
        } else {
            throw new InvalidValueException( "JSON: " + key + " is not a JSON object." );
        }
    }

    private function parseIsoLocalMoment( value as String ) as Moment? {
        // Minimal length check: "YYYY-MM-DDTHH:MM:SS"
        if (value == null || value.length() < 19) {
            return null;
        }

        var year  = parseNumberOrNull(value.substring(0, 4));
        var month = parseNumberOrNull(value.substring(5, 7));
        var day   = parseNumberOrNull(value.substring(8, 10));
        var hour  = parseNumberOrNull(value.substring(11, 13));
        var min   = parseNumberOrNull(value.substring(14, 16));
        var sec   = parseNumberOrNull(value.substring(17, 19));

        var offsetSign = value.substring(19, 20);
        var offsetHour = parseNumberOrNull(value.substring(20, 22));

        // Validate everything before constructing Moment
        if (year == null || month == null || day == null ||
            hour == null || min == null || sec == null) {
            return null;
        }

        var moment = Gregorian.moment({
            :year   => year,
            :month  => month,
            :day    => day,
            :hour   => hour,
            :minute => min,
            :second => sec
        });

        /*
        Logger.debug( "Year: " + year );
        Logger.debug( "Month: " + month );
        Logger.debug( "Day: " + day );
        Logger.debug( "Hour: " + hour );
        Logger.debug( "Minute: " + min );
        Logger.debug( "Second: " + sec );
        Logger.debug( "offsetSign: " + offsetSign );
        Logger.debug( "offsetHour: " + offsetHour );
        */

        if( offsetSign != null && offsetHour != null ) {
            var offsetSecond = offsetHour * 3600;
            if( offsetSign.equals( "+" ) ) {
                offsetSecond = - offsetSecond;
            }
            moment = moment.add( new Time.Duration( offsetSecond ) );
        }

        return moment;
    }

    private function parseNumberOrNull( s as String? ) as Number? {
        if( s == null ) {
            return null;
        }
        return s.toNumber();
    }


    public static function momentToIsoLocalString( moment as Moment ) as String {
        var info = Gregorian.info( moment, Time.FORMAT_SHORT );

        var month = info.month;
        if( ! ( month instanceof Number ) ) {
            throw new InvalidValueException( "Failed to serialize timestamp: the month value is not a valid number." );
        }

        return info.year.toString()
            + "-" + StringFormatter.pad2( month )
            + "-" + StringFormatter.pad2( info.day )
            + "T" + StringFormatter.pad2( info.hour )
            + ":" + StringFormatter.pad2( info.min )
            + ":" + StringFormatter.pad2( info.sec );
    }

}