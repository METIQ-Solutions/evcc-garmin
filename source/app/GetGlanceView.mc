import Toybox.Lang;
import Toybox.WatchUi;

/*
 * This class exists solely to implement getGlanceView() for EvccApp
 * outside the background scope, in order to reduce memory usage.
 */
(:glance) 
class GetGlanceView {
    
    // Returns the GlanceView
    public static function getGlanceView() as [ GlanceView ] or [ GlanceView, GlanceViewDelegate ] or Null {
        try {
            // Logger.debug( "EvccApp: getGlanceView" );

            // Read the site count
            var siteCount = SiteConfigRepository.getSiteCount();

            // We store the active site, so when the widget is reopened, it 
            // starts with the site displayed last. Also the glance is using
            // the active site and is only displaying its data.
            var activeSite = BreadCrumbSiteReadOnly.getSelectedSite( siteCount );

            // We delete any unused site entries from storage
            // This is for the case when sites get deleted from
            // the settings and we want to clean up their persistant
            // data
            StateStore.clearUnusedSites( siteCount );

            if( siteCount > 0 ) {
                return [new EvccGlanceView( activeSite )];
            } else {
                return [new GlanceErrorView( new NoSiteException() )];
            }
        } catch ( ex ) {
            Logger.debugException( ex );
            return [new GlanceErrorView( ex )];
        }
    }
}