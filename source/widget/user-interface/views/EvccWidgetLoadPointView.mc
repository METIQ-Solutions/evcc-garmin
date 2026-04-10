import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Timer;
import Toybox.Application.Properties;
import Toybox.Math;

 class EvccWidgetLoadPointView extends EvccWidgetBaseLoadPointView {

    // Options for constructor
    typedef Options as {
        :views as ArrayOfSiteViews, 
        :parentView as EvccWidgetBaseSiteView?, 
        :siteIndex as Number,
        :category as Number,
        :pageIndex as Number
    };

    private var _category as Number;
    private var _pageIndex as Number;
    private var _icon as EvccIconBlock.Icon;

    private const LINES_PER_PAGE = 5;

    function initialize( options as Options ) {
        EvccWidgetBaseLoadPointView.initialize( options );
        _category = options[:category] as Number;
        _pageIndex = options[:pageIndex] as Number;
        _icon = getStateRequest().getState().getLoadPointCategory( _category )[0];
    }

    public function addContent( block as EvccVerticalBlock, calcDc as EvccDcInterface ) {
        var loadPoints = getStateRequest().getState().getLoadPointCategory( _category )[1].getLoadPoints();

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
