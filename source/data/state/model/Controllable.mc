import Toybox.Lang;

// Classes in this folder represent the current state of an evcc site
// They implement both the parsing of the JSON dictionary received
// as web response, as well as serializing in a JSON dictionary with
// the same structure for persiting the state in storage

// Class representing an integrated device
(:glance) class Controllable {
    private var _title as String = "";
    
    protected const LP_TITLE = "title";

    function initialize( dataLp as JsonObject ) {
        _title = dataLp[LP_TITLE] as String;
    }

    function serialize( loadpoint as JsonObject ) as JsonObject {
        loadpoint[LP_TITLE] = _title;
        return loadpoint;
    }

    public function getTitle() as String { return _title; }
}
