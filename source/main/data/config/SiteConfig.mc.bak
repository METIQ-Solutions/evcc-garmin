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
        _url = Properties.getValue( Constants.PROPERTY_SITE_PREFIX + index + Constants.PROPERTY_SITE_URL_SUFFIX ) as String;
        _user = Properties.getValue( Constants.PROPERTY_SITE_PREFIX + index + Constants.PROPERTY_SITE_USER_SUFFIX ) as String;
        _pass = Properties.getValue( Constants.PROPERTY_SITE_PREFIX + index + Constants.PROPERTY_SITE_PASS_SUFFIX ) as String;

        _basicAuth = ! _user.equals( "" );

        if( _basicAuth && _pass.equals( "" ) ) {
            throw new NoPasswordException( index );
        }

        readScaleForecast( index );

        _isMock = _url.find( "mock.pstmn.io" ) != null;
    }

    public function readScaleForecast( index as Number ) as Void {
        _scaleForecast = Properties.getValue( Constants.PROPERTY_SITE_PREFIX + index + Constants.PROPERTY_SITE_SCALE_FORECAST_SUFFIX ) as Boolean;
    }
}