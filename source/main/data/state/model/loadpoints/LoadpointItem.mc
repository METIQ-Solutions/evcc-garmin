import Toybox.Lang;

// Classes in this folder represent the current state of an evcc site
// They implement both the parsing of the JSON dictionary received
// as web response, as well as serializing in a JSON dictionary with
// the same structure for persiting the state in storage

// Class representing the item connected to a loadpoint
// Currently there is no common data/functionality, but this
// base class is retained for future use.
(:glance) class LoadpointItem {
    function initialize( dataLp as JsonAdapter ) {
    }

    function serialize( loadpoint as JsonObject ) as JsonObject {
        return loadpoint;
    }
}
