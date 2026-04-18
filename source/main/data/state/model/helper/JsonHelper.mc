import Toybox.Lang;

/*
 * Contains types and helper functions for reading data from a JsonObject.
 */

// This type is used by the API to represent a JSON object
typedef JsonObject as Dictionary<String,Object?>;

(:glance) 
class JsonHelper {

    // Read a Boolean value from a JsonObject, defaulting to false if it is not present
    public static function readBoolean( json as JsonObject, field as String ) as Boolean {
        var value = json[field];
        return value != null && ( value as Boolean );
    }

}