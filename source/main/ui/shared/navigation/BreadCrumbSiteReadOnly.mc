import Toybox.Lang;
import Toybox.Application.Storage;
import Toybox.Application;

// Read-only cass for only the site (root) level
// For :glance to save memory
(:glance) class BreadCrumbSiteReadOnly {
    static function getSelectedSite( totalSites as Number ) as Number {
        var storedCrumb = Storage.getValue( Constants.STORAGE_BREAD_CRUMBS ) as SerializedBreadCrumb?;

        if( storedCrumb != null && storedCrumb[0] < totalSites ) {
            return storedCrumb[0];
        } else {
            return 0;
        }
    }
}
