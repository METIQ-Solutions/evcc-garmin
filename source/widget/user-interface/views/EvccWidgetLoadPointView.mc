import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Timer;
import Toybox.Application.Properties;
import Toybox.Math;

 class EvccWidgetLoadPointView extends EvccWidgetBaseLoadPointView {

    enum Category {
        CATEGORY_CONNECTED_VEHICLE,
        CATEGORY_HEATER,
        CATEGORY_INTEGRATED_DEVICE
    }
    
    private var _category as Category;
    private var _pageIndex as Number;
    private var _icon as EvccIconBlock.Icon;

    private const LINES_PER_PAGE = 5;

    function initialize( 
        views as ArrayOfSiteViews, 
        parentView as EvccWidgetBaseSiteView?, 
        siteIndex as Number,
        category as Category,
        pageIndex as Number
    ) {
        EvccWidgetBaseLoadPointView.initialize( views, parentView, siteIndex );
        _category = category;
        _pageIndex = pageIndex;
        if( category == CATEGORY_CONNECTED_VEHICLE ) {
            _icon = EvccIconBlock.ICON_CAR;
        } else if( category == CATEGORY_HEATER ) {
            _icon = EvccIconBlock.ICON_HEATER;
        } else if( category == CATEGORY_INTEGRATED_DEVICE ) {
            _icon = EvccIconBlock.ICON_DEVICE;
        } else {
            throw new InvalidValueException( "EvccWidgetLoadPointView: unknown category" );
        }
    }

    public function addContent( block as EvccVerticalBlock, calcDc as EvccDcInterface ) {
        var state = getStateRequest().getState();
        var loadPoints;

        if( _category == CATEGORY_CONNECTED_VEHICLE ) {
            loadPoints = state.getConnectedVehicles().getLoadPoints();
        } else if( _category == CATEGORY_HEATER ) {
            loadPoints = state.getHeaters().getLoadPoints();
        } else if( _category == CATEGORY_INTEGRATED_DEVICE ) {
            loadPoints = state.getIntegratedDevices().getLoadPoints();
        } else {
            throw new InvalidValueException( "EvccWidgetLoadPointView: unknown category" );
        }

        for( 
            var i = _pageIndex * LINES_PER_PAGE; 
            i < EvccHelperUI.min( _pageIndex + LINES_PER_PAGE, loadPoints.size() ); 
            i++ 
        ) {
            addLoadpoint( block, loadPoints[i] );
        }
    }

    // Show the category icon as page title
    function getPageIcon() as EvccIconBlock? {
        return new EvccIconBlock( _icon, {} as DbOptions );
    }
}
