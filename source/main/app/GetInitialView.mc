import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Math;

/*
 * This class exists solely to implement getInitialView() for EvccApp
 * outside the glance and background scopes, in order to reduce memory usage.
 */
class GetInitialView {
    
    // Called if the app runs in widget mode
    public static function getInitialView() as [Views, InputDelegates] {
        // Logger.debug( "EvccApp: getInitialView" );
        try {
            // Initialize the resources here, to save computing time
            // in the view (reduce chance to trip the watchdog)
            EvccResources.load();

            // Read the site count
            var siteCount = SiteConfigRepository.getSiteCount();

            // The bread crumbs are used to store which sites/pages have been opened last
            var breadCrumb = new BreadCrumb( null );

            // We delete any unused site entries from storage
            // This is for the case when sites get deleted from
            // the settings and we want to clean up their persistant
            // data
            StateStore.clearUnusedSites( siteCount );

            if( siteCount == 0 ) {
                throw new NoSiteException();
            } else {
                // Next we determine the active site
                // Here we need to deal with the case that there is only one site, but there
                // may be multiple detail views. In this case, the root breadcrumb would
                // actually identify the detail view.
                // The getSelectedChild() is implemented to receive the maximum number of children
                // verify that the returned child is within that boundary and if needed reset
                // the breadcrumb.
                // So in this case we should not request the current site from the breadcrumb
                // but just take 0 as current site
                var activeSite = siteCount == 1 ? 0 : breadCrumb.getSelectedChild( siteCount );
                
                // We start the state request registry
                WebRequestRegistry.start( activeSite );

                var views = MainView.getAllSiteViews();
                // We use the number of views to determine the maximum number of children
                // since it can be either multiple sites, or one site with detailed views
                // (such as forecast) presented on the same level
                var activeView = breadCrumb.getSelectedChild( views.size() );
                var delegate = new SiteCarouselDelegate( views, breadCrumb );
                
                // Start with the active page
                return [views[activeView], delegate];
            }
        } catch ( ex ) {
            Logger.debugException( ex );
            return [new ErrorView( ex ), new SiteSimpleDelegate()];
        }
    }
}