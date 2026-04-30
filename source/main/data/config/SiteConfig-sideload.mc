import Toybox.Lang;
import Toybox.Application.Properties;

// This class represents the configuration of one site
(:glance) class SiteConfig {
    private var _url as String;
    private var _user as String;
    private var _pass as String;
    private var _basicAuth as Boolean = false;
    private var _scaleForecast as Boolean = true;
    private var _isMock as Boolean = false;

    public function getUrl() as String { return _url; }
    public function needsBasicAuth() as Boolean { return _basicAuth; }
    public function getUser() as String { return _user; }
    public function getPassword() as String { return _pass; }
    public function scaleForecast() as Boolean { return _scaleForecast; }
    public function isMock() as Boolean { return _isMock; }
    
    public function initialize( index as Number ) {
        if( index == 0 ) {
            _url = "http://net-nas-1:7070";
            _scaleForecast = true;
            _user = "";
            _pass = "";
            _basicAuth = false;
            _isMock = false;
        } else {
            _url = "http://net-nas-3:7070";
            _scaleForecast = false;
            _user = "";
            _pass = "";
            _basicAuth = false;
            _isMock = false;
        }
    }
}

 