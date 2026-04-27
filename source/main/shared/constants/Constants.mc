import Toybox.Graphics;

// This class holds constants that are used across the code base,
// mainly for defining keys for storage and properties
(:glance) class Constants {
    // Names of elements in persistant storage
    public static const STORAGE_SITE_PREFIX = "site_";
    public static const STORAGE_BREAD_CRUMBS = "breadCrumbs";
    
    // Error messages to be passed on from the background to
    // foreground tasks
    public static const STORAGE_BG_ERROR_MSG = "bgErrorMsg";
    public static const STORAGE_BG_ERROR_CODE = "bgErrorCode";

    // Names of elements in the properties
    public static const PROPERTY_SITE_PREFIX = "s";
    public static const PROPERTY_SITE_URL_SUFFIX = "_url";
    public static const PROPERTY_SITE_USER_SUFFIX = "_usr";
    public static const PROPERTY_SITE_PASS_SUFFIX = "_pss";
    public static const PROPERTY_SITE_SCALE_FORECAST_SUFFIX = "_sfc";
    public static const PROPERTY_REFRESH_INTERVAL = "refreshInterval";
    public static const PROPERTY_DATA_EXPIRY = "dataExpiry";

    // Number of sites supported, needs to match the number of settings
    // defined in settings.xml
    public static const MAX_SITES = 5;
}