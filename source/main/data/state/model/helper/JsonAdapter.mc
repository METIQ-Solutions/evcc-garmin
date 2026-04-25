import Toybox.Lang;

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

    public function getArray( key as String ) as JsonArray {
        var value = getArrayOrNull( key );
        if( value != null ) {
            return value;
        } else {
            throw new InvalidValueException( "JSON: \"" + key + "\" is missing." );
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
                    throw new InvalidValueException( "JSON: array entry in \"" + key + "\" is not a JSON object." );
                }
            }
            return adArray;
        } else {
            throw new InvalidValueException( "JSON: \"" + key + "\" is not a JSON array." );
        }
    }

    public function getBoolean( key as String ) as Boolean {
        var value = getBooleanOrNull( key );
        if( value != null ) {
            return value;
        } else {
            throw new InvalidValueException( "JSON: \"" + key + "\" is missing." );
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
            throw new InvalidValueException( "JSON: \"" + key + "\" is not a Boolean." );
        }
    }

    public function getFloat( key as String ) as Float {
        var value = getFloatOrNull( key );
        if( value != null ) {
            return value;
        } else {
            throw new InvalidValueException( "JSON: \"" + key + "\" is missing." );
        }
    }

    public function getFloatOrNull( key as String ) as Float? {
        var value = _jsonObject[key];
        if( value instanceof Float || value == null ) {
            return value;
        } else if( value instanceof Number || value instanceof Long || value instanceof Double ) {
            return value.toFloat();
        } else {
            throw new InvalidValueException( "JSON: \"" + key + "\" is not a Float." );
        }
    }

    public function getNumber( key as String ) as Number {
        var value = getNumberOrNull( key );
        if( value != null ) {
            return value;
        } else {
            throw new InvalidValueException( "JSON: \"" + key + "\" is missing." );
        }
    }
    public function getNumberOrNull( key as String ) as Number? {
        var value = _jsonObject[key];
        if( value instanceof Number || value == null ) {
            return value;
        } else if( value instanceof Long || value instanceof Float || value instanceof Double ) {
            return value.toNumber();
        } else {
            throw new InvalidValueException( "JSON: \"" + key + "\" is not a Number." );
        }
    }

    public function getString( key as String ) as String {
        var value = getStringOrNull( key );
        if( value != null ) {
            return value;
        } else {
            throw new InvalidValueException( "JSON: \"" + key + "\" is missing." );
        }
    }

    public function getStringOrNull( key as String ) as String? {
        var value = _jsonObject[key];
        if( value instanceof String || value == null ) {
            return value;
        } else {
            throw new InvalidValueException( "JSON: \"" + key + "\" is not a String." );
        }
    }

    public function getJsonObject( key as String ) as JsonAdapter {
        var value = getJsonObjectOrNull( key );
        if( value != null ) {
            return value;
        } else {
            throw new InvalidValueException( "JSON: \"" + key + "\" is missing." );
        }
    }
    public function getJsonObjectOrNull( key as String ) as JsonAdapter? {
        var value = _jsonObject[key];
        if( value == null ) {
            return null;
        } else if( value instanceof Dictionary ) {
            return new JsonAdapter( value as JsonObject );
        } else {
            throw new InvalidValueException( "JSON: \"" + key + "\" is not a JSON object." );
        }
    }

}