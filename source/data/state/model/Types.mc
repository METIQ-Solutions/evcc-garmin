import Toybox.Lang;

// This type is used by the API to represent a JSON object
typedef JsonObject as Dictionary<String,Object?>;

// A loadpoint category represents the category identified by
// its icon, and a list of load points belonging to it
typedef LoadpointCategory as [ IconBlock.Icon, LoadpointList ];

typedef ArrayOfLoadpoints as Array<Loadpoint>;