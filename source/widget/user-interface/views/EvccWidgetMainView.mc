import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Timer;
import Toybox.Application.Properties;
import Toybox.Math;

 // The main view showing the most important aspects of the state of one evcc instance
 class EvccWidgetMainView extends EvccWidgetBaseLoadPointView {

    // Options for constructor
    typedef Options as {
        :views as ArrayOfSiteViews, 
        :parentView as EvccWidgetBaseSiteView?, 
        :siteIndex as Number,
        :actsAsGlance as Boolean
    };

    // This function returns a list of views for all sites
    static function getAllSiteViews() as ArrayOfSiteViews {
        var views = new ArrayOfSiteViews[0];
        var siteCount = EvccSiteConfiguration.getSiteCount();
        for( var i = 0; i < siteCount; i++ ) {
            // The view adds itself to views
            views.add( new EvccWidgetMainView( {
                :actAsGlance => false, 
                :views => views,
                :siteIndex => i,
                :pageIndex => views.size()
            } ) );
        }
        return views;
    }
    
    // Indicates that we act as glance and present only one site
    // If a device does not support glances, then in the initial
    // widget view only one site can be presented, which is the active
    // site (_actAsGlance=true). Only if that one site is selected, the 
    // other sites will be presented as sub view and can be cycled through.
    var _actAsGlance as Boolean;
    
    // References to detail views
    var _forecastView as EvccWidgetForecastView?;
    var _statisticsView as EvccWidgetStatisticsView?;

    // An array with an entry for each loadpoint category,
    // which itself contains an array of detail views showing
    // the loadpoints in that category.
    var _loadPointViews as Array<Array<EvccWidgetLoadPointView>>;

    // Tuple containing the target array for the views as the first element,
    // and the parent view as the second element. The target may refer to
    // either sibling or child views, depending on where the detail views
    // (statistics, forecast, ...) should be added.
    var _detailViewTarget as [ArrayOfSiteViews, EvccWidgetBaseSiteView?]?;

    function initialize( options as Options ) {
        // EvccHelperBase.debug("Widget: initialize");
        EvccWidgetBaseLoadPointView.initialize( options );

        _actAsGlance = options[:actAsGlance] as Boolean;

        // Create an array of views for each loadpoint category
        _loadPointViews = new Array<Array<EvccWidgetLoadPointView>>[EvccState.NUM_OF_LOADPOINT_CATEGORIES];
        for( var i = 0; i < _loadPointViews.size(); i++ ) {
            _loadPointViews[i] = new Array<EvccWidgetLoadPointView>[0];            
        }

        // Now we define the target array used for detail views
        var siteCount = EvccSiteConfiguration.getSiteCount();
        // If we act as glance, and there is only one site, then we add the detail view to the lower level views
        // Also if we do not act as glance, but there is more than one site, it goes to the lower level views 
        if( ( _actAsGlance && siteCount == 1 ) || ( ! _actAsGlance && siteCount > 1 ) ) {
            _detailViewTarget = [getLowerLevelViews(), self];
        // But if we are not acting as glance and there is only one site, we directly add the
        // detail view to the same level view
        } else if ( siteCount == 1 ) {
            _detailViewTarget = [getSameLevelViews(), self.getParentView()];
        }

        // And then we add the detail or lower level views
        // If we are acting as glance and there is more than one site,
        // we just add all sites as lower level views
        if( _actAsGlance && EvccSiteConfiguration.getSiteCount() > 1 ) {
            addLowerLevelViews( getAllSiteViews() );
        } else {
            // In all other cases we add the detail views.
            // If we act as glance and have only one site, they will be added as lower level views
            // If we do not act as glance, they will be either added to the lower level if there
            // are multiple sites, or to the same level
            initOrUpdateDetailViews( true );
        }
    }

    // See _actAsGlance
    public function actsAsGlance() as Boolean { return _actAsGlance; }

    // This function initializes a detail view. To be able to apply the
    // same logic to different detail views, it accepts a class type as input
    (:exclForMemoryLow :typecheck(false))
    private function initDetailView( 
        viewClass, 
        options as EvccWidgetBaseSiteView.Options, 
        calledDuringAppStartup as Boolean 
    ) as EvccWidgetBaseSiteView {

        // We have to check for null since if we act as glance and have multiple 
        // sites, the view is not added since the sites views are the lower level views 
        if( _detailViewTarget == null ) {
            throw new OperationNotAllowedException( "EvccWidgetMainView: called initDetailView without a detail view target." );
        }

        options[:views] = _detailViewTarget[0];
        options[:parentView] = _detailViewTarget[1];
        options[:siteIndex] = getSiteIndex();

        var view = new viewClass( options ) as EvccWidgetBaseSiteView;

        // If we already can add the view during startup of the app
        // the pre-rendering is already being scheduled
        // by the EvccMultiStateRequestsHandler
        if( ! calledDuringAppStartup ) {
            view.onStateUpdate();
        }

        return view;
    }

    // Dummy function for low memory devices
    (:exclForMemoryStandard)   
    public function initOrUpdateDetailViews( calledDuringAppStartup as Boolean ) as Void {}

    // Detail views present additional data for a particular site. This function adds 
    // detail views for this site, either to the lower level or to the same level views, 
    // depending on the situation.
    // Detail views are not available on low-memory devices.    
    // ATTENTION: this function is called everytime there is a new web response, since changed
    // data may lead to additional views being displayed. Therefore, this function has to protect 
    // itself from adding the same view twice.
    (:exclForMemoryLow)   
    public function initOrUpdateDetailViews( calledDuringAppStartup as Boolean ) as Void {
        // EvccHelperBase.debug("WidgetSiteMain: initOrUpdateDetailViews" );
        var stateRequest = getStateRequest();

        // Note that we DO NOT check fore staterq.hasCurrentState(). In this instance we are not interested
        // whether the stored state is current or not. Regardless of age, if the previous state had a 
        // forecast we assume that there is still a forecast
        // If there is an error, we do not add anything. The actual error will be handled by
        // the content assembly of this view.
        if( ! stateRequest.hasError() && stateRequest.hasState() && _detailViewTarget != null ) {
            var detailViews = _detailViewTarget[0];
            var state = stateRequest.getState();
            if( state.hasForecast() ) {
                if( _forecastView == null ) {
                    _forecastView = initDetailView( EvccWidgetForecastView, {}, calledDuringAppStartup ) as EvccWidgetForecastView;
                }
            } else {
                _forecastView = null;
            }
            if( state.hasStatistics() ) {
                if( _statisticsView == null ) {
                    _statisticsView = initDetailView( EvccWidgetStatisticsView, {}, calledDuringAppStartup ) as EvccWidgetStatisticsView;
                }
            } else {
                _statisticsView = null;
            }

            while( detailViews.size() > 0 ) {
                detailViews.remove( detailViews[detailViews.size()-1] );
            }

            var detailViewsRaw = [
                _forecastView,
                _statisticsView
            ];

            for( var i = 0; i < detailViewsRaw.size(); i++ ) {
                if( detailViewsRaw[i] != null ) {
                    var view = detailViewsRaw[i] as EvccWidgetBaseSiteView;
                    view.setPageIndex( detailViews.size() );
                    detailViews.add( view );
                }
            }
        }
    }

    // If we act as glance, we update the current site
    function onShow() as Void {
        try {
            // EvccHelperBase.debug( "Widget: onShow" );
            // If we are in glance view, it may happen that we are
            // returning from the sub views showing multiple sites,
            // and we have to switch the glance view to the 
            // site last selected
            if( _actAsGlance ) {
                var siteCount = EvccSiteConfiguration.getSiteCount();
                // Only if there is more than one site, we set the site
                // index to the currently active, in case the currently
                // active was changed in the lower level views
                if( siteCount > 1 ) {
                    // setSiteIndex will also update the content
                    // if the site index has changed
                    setSiteIndex( EvccBreadCrumbSiteReadOnly.getSelectedSite( siteCount ) );
                }
            }
            EvccWidgetBaseSiteView.onShow();
        } catch ( ex ) {
            // setSiteIndex pre-renders the content in case the
            // index changed, and we need to log any exceptions
            // coming from that
            handleOnShowException( ex );
            EvccHelperBase.debugException( ex );
        }
    }

    // Only with view pre-rendering there is an exception
    // handler at which we have to register the exception
    // for it to be displayed in onUpdate.
    (:exclForViewPreRenderingDisabled)
    private function handleOnShowException( ex as Exception ) as Void {
        getExceptionHandler().registerException( ex );
    }
    (:exclForViewPreRenderingEnabled)
    private function handleOnShowException( ex as Exception ) as Void {}

    // With every new web response we check if there are maybe new detail views to be displayed
    // This is important when we initially do not have an up-to-date state and therefore 
    // state-dependent detail views are not added in the initOrUpdateDetailViews() call from the 
    // constructor ...

    // ... if view prerendering is disabled, we do this in the onUpdate ...
    (:exclForViewPreRenderingEnabled) 
    function onUpdate( dc as Dc ) as Void {
        initOrUpdateDetailViews( false );
        EvccWidgetBaseSiteView.onUpdate( dc );
    }

    // ... if view prerendering is enabled, we have to do this earlier,
    // when onStateChange is called, so that the further prerendering
    // of the page and select indicator is already is based on the adapted 
    // detail views.
    (:exclForViewPreRenderingDisabled) function prepareImmediately() as Void {
        // EvccHelperBase.debug( "WidgetSiteMain: prepareImmediately site=" + getSiteIndex() );
        initOrUpdateDetailViews( false );
        EvccWidgetBaseSiteView.prepareImmediately();
    }
    (:exclForViewPreRenderingDisabled) function prepareByTasks() as Void {
        // EvccHelperBase.debug("WidgetSiteMain: prepareByTasks site=" + getSiteIndex() );
        EvccTaskQueue.getInstance().add( new EvccinitOrUpdateDetailViewsTask( self ) );
        EvccWidgetBaseSiteView.prepareByTasks();
    }


    // The addContent function generates the content of
    // this view.
    // There are two versions, one for low memory devices, and one for all other devices
    // There is some redundancy between the two functions, but since low memory devices
    // will at some point be removed from the code, they were kept completely separate
    // instead of trying to put common code in common functions.

    // For low memory, we display loadpoints only in the main view, and to the
    // extend they fit on the screen (if there are more, they are simply not shown)
    (:exclForMemoryStandard) private const SMALL_LINE as Float = 0.6; // site title, charging details and logo count only as the fraction of a line specified here
    (:exclForMemoryStandard) private const MAX_VAR_LINES as Number = 6; // 1 x site title, 1 x battery, 2 x loadpoints with 2 lines each
    (:exclForMemoryStandard)
    public function addContent( block as EvccVerticalBlock, calcDc as EvccDcInterface ) {
        var state = getStateRequest().getState();
        var variableLineCount = 0;

        // PV
        block.addBlock( renderBasicElement( EvccIconBlock.ICON_SUN, null, state.getPvPowerRounded(), EvccIconBlock.ICON_ARROW_RIGHT ) );
        // Grid
        block.addBlock( renderBasicElement( EvccIconBlock.ICON_GRID, null, state.getGridPowerRounded(), EvccIconBlock.ICON_POWER_FLOW ) );
        // Battery
        if( state.hasBattery() ) {
            block.addBlock( renderBasicElement( EvccIconBlock.ICON_BATTERY, EvccHelperUI.formatSoc( state.getBatterySoc() ), state.getBatteryPowerRounded(), EvccIconBlock.ICON_POWER_FLOW ) );
            variableLineCount++;
        }                

        // Loadpoints
        var loadPointList = state.getConnectedVehicles();
        var loadPoints = loadPointList.getLoadPoints();
        var hasLoadPoint = false;
        var showChargingDetails = MAX_VAR_LINES - variableLineCount >= loadPoints.size() + ( loadPointList.getChargingLoadPointCount() * SMALL_LINE );
        for (var i = 0; i < loadPoints.size() && variableLineCount < MAX_VAR_LINES; i++) {
            var loadPoint = loadPoints[i] as EvccLoadPoint;
            if( loadPoint.isVehicle() ) {
                var loadPointLine = renderVehicle( loadPoint, showChargingDetails );
                block.addBlock( loadPointLine );
                variableLineCount++;
                hasLoadPoint = true;
                if( loadPoint.isCharging() && showChargingDetails ) {
                    block.addBlock( renderVehicleChargingDetails( loadPoint, loadPointLine.getOption( :marginLeft ) as Number ) );
                    variableLineCount += SMALL_LINE;
                }
            }
        }
        if( ! hasLoadPoint ) {
            block.addText( "No vehicle" );
            variableLineCount++;
        }

        // Home
        block.addBlock( renderBasicElement( EvccIconBlock.ICON_HOME, null, state.getHomePowerRounded(), EvccIconBlock.ICON_ARROW_LEFT ) );

        // If there is too much space above and below the content,
        // the lines will be spread out vertically
        block.setOption( :spreadToHeight, getContentArea().height );
    }


    // For standard devices, we display the same basic elements,
    // but with more advanced logic for loadpoints.
    // If there are two or less loadpoints, they will directly
    // be displayed in the main view.
    // If they are more, then loadpoints that belong to the same 
    // category (vehicles, heaters, integrated devices) will be grouped
    // into one category, with a summary line being displayed.
    // In this case initOrUpdateDetailViews() will add detail views that then
    // display the loadpoints in that category.
    (:exclForMemoryLow)
    public function addContent( block as EvccVerticalBlock, calcDc as EvccDcInterface ) {
        var state = getStateRequest().getState();
        var variableLineCount = 0;

        // PV
        block.addBlock( renderBasicElement( EvccIconBlock.ICON_SUN, null, state.getPvPowerRounded(), EvccIconBlock.ICON_ARROW_RIGHT ) );
        // Grid
        block.addBlock( renderBasicElement( EvccIconBlock.ICON_GRID, null, state.getGridPowerRounded(), EvccIconBlock.ICON_POWER_FLOW ) );
        // Battery
        if( state.hasBattery() ) {
            block.addBlock( renderBasicElement( EvccIconBlock.ICON_BATTERY, EvccHelperUI.formatSoc( state.getBatterySoc() ), state.getBatteryPowerRounded(), EvccIconBlock.ICON_POWER_FLOW ) );
            variableLineCount++;
        }

        // Loadpoints
        // If there are two or less loadpoints, we show them directly
        if( state.getLoadPointCount() <= 2 ) {
            var loadPoints = state.getLoadPoints();
            var hasLoadPoint = false;
            for( var i = 0; i < loadPoints.size(); i++ ) {
                hasLoadPoint = hasLoadPoint || addLoadpoint( block, loadPoints[i] );
            }
            // We check if at least one of the two loadpoints
            // was displayed. addLoadPoint will ignore loadpoints that
            // have no connected vehicle and are not a heater or integrated device
            if( ! hasLoadPoint ) {
                block.addText( "No vehicle" );
            }
        } else {
            // If there are more, we look at them per category
            // First we assemble a 2d array with the icon and loadpoint list
            // for each category
            var loadPointLists = state.getAllLoadPointsCategories();
            
            // Then we loop through all categories
            for( var i = 0; i < loadPointLists.size(); i++ ) {
                var loadPoints = loadPointLists[i][1].getLoadPoints();
                var loadPointCount = loadPoints.size();
                // If there is only one loadpoint in the category, we directly
                // display it
                if( loadPointCount == 1 ) {
                    addLoadpoint( block, loadPoints[0] );
                } else if( loadPointCount > 1 ) {
                    // If there are more than one, we add a summary line
                    var loadPointList = loadPointLists[i][1];
                    block.addBlock( renderBasicElement( 
                        loadPointLists[i][0],
                        loadPointList.getChargingLoadPointCount() + "/" + loadPointList.getLoadPoints().size(),
                        loadPointList.getTotalChargingPower(),
                        EvccIconBlock.ICON_ARROW_LEFT
                    ) );
                }
            }
        }

        // Home
        block.addBlock( renderBasicElement( EvccIconBlock.ICON_HOME, null, state.getHomePowerRounded(), EvccIconBlock.ICON_ARROW_LEFT ) );

        // If there is too much space above and below the content,
        // the lines will be spread out vertically
        block.setOption( :spreadToHeight, getContentArea().height );
    }

    // Function to generate line for PV, grid, battery and home
    private function renderBasicElement( icon as EvccIconBlock.Icon, text as String?, power as Number, flowIcon as EvccIconBlock.Icon ) as EvccHorizontalBlock {
        var state = getStateRequest().getState();
        var lineOptions = {};
        var iconOptions = {};
        if( icon == EvccIconBlock.ICON_BATTERY ) { 
            // For battery the SoC is used to choose on of the icons with different fill
            iconOptions[:batterySoc] = state.getBatterySoc(); 
        }
        var line = new EvccHorizontalBlock( lineOptions );
        line.addIcon( icon, iconOptions );
        // If a text was provided, we show it after the icon
        if( text != null ) { line.addText( " " + text ); }

        if( power != 0 ) {
            line.addText( " " );
            var flowOptions = {};
            if( flowIcon == EvccIconBlock.ICON_POWER_FLOW ) { flowOptions[:power] = power; }
            line.addIcon( flowIcon, flowOptions );
        }
        // For battery and loadpoints we show the power only if it is not 0,
        // for all others we always show it
        if( ( icon != EvccIconBlock.ICON_BATTERY 
              && icon != EvccIconBlock.ICON_CAR 
              && icon != EvccIconBlock.ICON_HEATER
              && icon != EvccIconBlock.ICON_DEVICE
            ) 
            || power != 0 
        ) {
            line.addText( " " + EvccHelperWidget.formatPower( power.abs() ) );
        }
        return line;
    }
}
