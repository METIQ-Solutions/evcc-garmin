import Toybox.Lang;

/*
 * Manages the detail views that complement the main view.
 * Decides whether detail views are placed alongside the main view
 * (single site) or as child views (multiple sites).
 * Also initializes the detail views and updates them on each state update.
 */
class DetailViewManager {


    // The main view that this manager is associated with
    var _mainView as MainView;
    

    // References to forecast/statistics detail views
    var _solarForecastView as SolarForecastView?;
    var _gridPriceForecastView as Array<GridPriceForecastView>?;
    var _statisticsView as StatisticsView?;


    // An array with an entry for each loadpoint category,
    // which itself contains an array of detail views showing
    // the loadpoints in that category.
    var _loadpointViews as Array<Array<LoadpointView>>;


    // Tuple containing the target array for the views as the first element,
    // and the parent view as the second element. The target may refer to
    // either sibling or child views, depending on where the detail views
    // (statistics, forecast, ...) should be added.
    var _detailViewTarget as [SiteViewCarousel, EvccSiteViewBase?];


    // Constructor
    // Initializes the loadpoint view array,
    // determines the target for detail views (same level or child level),
    // and initializes the detail views.
    function initialize( mainView as MainView ) {
        _mainView = mainView;

        // Create an array of views for each loadpoint category
        _loadpointViews = new Array<Array<LoadpointView>>[EvccState.NUM_OF_LOADPOINT_CATEGORIES];
        initOrResetLoadpointViewArray();

        // Now we define target to which detail views are added
        // (same level or lower level)
        var siteCount = SiteConfigRepository.getSiteCount();
        var actsAsGlance = mainView.actsAsGlance();
        // Detail views are added to the lower level views if
        // a) we act as glance and there is only one site
        // b) there is more than one site
        // Detail views are added to the same level if
        // we do not act as glance and there is only one site.
        if( ( actsAsGlance && siteCount == 1 ) || ( ! actsAsGlance && siteCount > 1 ) ) {
            _detailViewTarget = [mainView.getLowerLevelViews(), mainView];
        } else if ( siteCount == 1 ) {
            _detailViewTarget = [mainView.getSameLevelViews(), mainView.getParentView()];
        } else {
            throw new OperationNotAllowedException( "DetailViewManager: instantiated for a main view that does not display detail views." );
        }

        initOrUpdateDetailViews( true );
    }


    // Adds a detail view to the target list of views,
    // and sets the added view's page index. Null values
    // are accepted but not added to the list.
    public function addDetailView( view as SiteViewCarouselItem? ) as Void {
        if( view != null ) {
            var detailViews = _detailViewTarget[0];
            if( view instanceof EvccSiteViewBase ) {
                view.setPageIndex( detailViews.size() );
            } else {
                for( var i = 0; i < view.size(); i++ ) {
                    view[i].setPageIndex( detailViews.size() );
                }
            }
            detailViews.add( view );
        }
    }


    // Clears all detail views from the target list of views
    public function clearDetailViews() as Void {
        var detailViews = _detailViewTarget[0];
        for( var i = detailViews.size() - 1; i >= 0; i-- ) {
            if( ! ( detailViews[i] instanceof MainView ) ) {
                detailViews.remove( detailViews[i] );
            }
        }
    }


    // This function initializes a single detail view. To be able to apply the
    // same logic to different detail views, it accepts a class type as input.
    (:typecheck(false))
    private function initDetailView( 
        viewClass, 
        options as EvccSiteViewBase.Options, 
        calledDuringAppStartup as Boolean 
    ) as EvccSiteViewBase {
        
        // Setup the options for the detail view
        options[:views] = _detailViewTarget[0];
        options[:parentView] = _detailViewTarget[1];
        options[:siteIndex] = _mainView.getSiteIndex();

        // Instantiate the detail view
        var view = new viewClass( options ) as EvccSiteViewBase;

        // If we add the view during startup of the app
        // the pre-rendering is already being scheduled
        // by the MultiWebRequestsHandler
        if( ! calledDuringAppStartup ) {
            view.onStateUpdate();
        }

        return view;
    }


    // This function initializes a single detail view. To be able to apply the
    // same logic to different detail views, it accepts a class type as input.
    (:typecheck(false))
    private function ensureDetailView( 
        isNeeded as Boolean,
        currentView as EvccSiteViewBase?,
        viewClass,
        calledDuringAppStartup as Boolean 
    ) as EvccSiteViewBase {
        if( isNeeded && currentView == null ) {
            currentView = initDetailView( viewClass, {}, calledDuringAppStartup ) as SolarForecastView;
        } else if( ! isNeeded && currentView != null ) {
            currentView.dispose();
            currentView = null;
        }
        return currentView;
    }


    // Initializes the content of the loadpoint view array, or resets it
    private function initOrResetLoadpointViewArray() as Void {
        for( var i = 0; i < _loadpointViews.size(); i++ ) {
            _loadpointViews[i] = new Array<LoadpointView>[0];
        }
    }


    // Initializes or updates the list of detail views
    // This is called when the main view is initialized and
    // after that everytime a state update is received.
    public function initOrUpdateDetailViews( calledDuringAppStartup as Boolean ) as Void {
        // Logger.debug("WidgetSiteMain: initOrUpdateDetailViews" );
        var stateRequest = _mainView.getWebRequest();

        // Note that we DO NOT check for stateRequest.hasCurrentState(). In this instance we are not interested
        // whether the stored state is current or not. Regardless of age, if the previous state had a 
        // forecast we assume that there is still a forecast
        // If there is an error, we do not do anything. The actual error will be handled by
        // the views themselves.
        if( ! stateRequest.hasError() && stateRequest.hasState() ) {
            var state = stateRequest.getState();
            
            // We check the forecast and statistic and update
            // the view accordingly
            _solarForecastView = ensureDetailView( state.hasSolarForecast(), _solarForecastView, SolarForecastView, calledDuringAppStartup ) as SolarForecastView?;
            _statisticsView = ensureDetailView( state.hasStatistics(), _statisticsView, StatisticsView, calledDuringAppStartup ) as StatisticsView?;

            if( state.hasGridPriceForecast() ) {
                if( _gridPriceForecastView == null ) {
                    _gridPriceForecastView = [];
                    for( var i = 0; i < GridPriceForecastView.PRICE_PERIODS_LABELS.size(); i++ ) {
                        _gridPriceForecastView.add( 
                            initDetailView( 
                                GridPriceForecastView, 
                                { :pricePeriod => i }, 
                                calledDuringAppStartup 
                            ) as GridPriceForecastView
                        );
                    }
                }
            } else {
                _gridPriceForecastView = null;
            }


            // The list of detail views is re-assembled
            // on every execution from scratch
            clearDetailViews();

            // Prepare the detail views for loadpoints.
            // As above, determine which views are needed, which already exist,
            // and initialize or remove them accordingly.
            // This allows the app to dynamically react to changes in loadpoints,
            // for example when a vehicle is connected while the app is running.
            if( state.getLoadpointCount() <= 2 ) {
                // If there <= 2 loadpoints, there are no detail views
                initOrResetLoadpointViewArray();
            } else {
                var loadpointLists = state.getAllLoadpointsCategories();

                // Ensure that the array of views has been set in accordance
                // with the array of categories
                if( loadpointLists.size() != _loadpointViews.size() ) {
                    throw new InvalidValueException( "DetailViewManager: state load point list count does not match load point view array." );
                }    

                // Iterate through all the loadpoint categories
                for( var category = 0; category < loadpointLists.size(); category++ ) {
                    var loadpoints = loadpointLists[category][1].getLoadpoints();
                    var loadpointCount = loadpoints.size();
                    
                    // If there is only one, it is directly displayed on the main view
                    // and no loadpoint view is required.
                    if( loadpointCount <= 1 ) {
                        _loadpointViews[category] = new Array<LoadpointView>[0];
                    } else {
                        var lpv = 0; // lpv is the index of the loadpoint view
                        var categoryViews = _loadpointViews[category];
                        // Iterate over the loadpoints within the category using the page size as step.
                        // Note that the actual distribution across pages may differ.
                        // For example, with 4 loadpoints and a maximum of 3 per page,
                        // this iteration assumes 3 on the first page and 1 on the second.
                        // However, LoadpointView will redistribute them evenly.
                        for( var lp = 0; lp < loadpoints.size(); lp += LoadpointView.getLoadpointsPerPage( category ) ) {
                            // If there is no view entry yet for this category page,
                            // we initiate one ...
                            if( categoryViews.size() <= lpv ) {
                                categoryViews.add(
                                    initDetailView(
                                        LoadpointView,
                                        { :category => category,
                                          :categoryPageIndex => lpv },
                                        calledDuringAppStartup
                                    ) as LoadpointView
                                );
                            }
                            // ... and add it to the array.
                            addDetailView( categoryViews[lpv] );
                            lpv++;
                        }
                        // If there are more views than we need, we remove them
                        while( lpv < categoryViews.size() ) {
                            var viewToDispose = categoryViews[categoryViews.size()-1];
                            viewToDispose.dispose();
                            categoryViews.remove( viewToDispose );
                        }
                    }
                }
            }

            // In the end, we add the forecast and statistics view
            addDetailView( _solarForecastView );
            addDetailView( _gridPriceForecastView as Array<EvccSiteViewBase> );
            addDetailView( _statisticsView );

            // Once the new array has been defined, check whether the current view
            // has been disposed of. If so, use the delegate to switch to a different
            // view. If at least one view remains on the current level, switch to the
            // first view on that level; otherwise, switch to the parent level.
            var viewBinding = ViewStack.getCurrentView();
            var view = viewBinding[0];
            var delegate = viewBinding[1];

            if( view instanceof EvccSiteViewBase && view.isActiveView() && view.isDisposed() ) {
                if( delegate instanceof SiteCarouselDelegate ) {
                    Logger.debug( "EvccSiteViewBase.dispose: view is active, switching to first view or parent view." );
                    delegate.switchToFirstOrParent();
                } else if( delegate instanceof SiteSimpleDelegate ) {
                    Logger.debug( "EvccSiteViewBase.dispose: single view is active, switching to parent view." );
                    delegate.onBack();
                }
            }
        }
    }

}
