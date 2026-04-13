import Toybox.Lang;

/*
 * Main view showing the most important aspects of a single evcc instance.
 * Also responsible for initializing and updating the detail views
 * via the associated DetailViewManager.
 */
 class MainView extends EvccSiteViewBase {


    /******** TYPES ********/


    // Options for constructor
    typedef Options as {
        :views as ArrayOfSiteViews, 
        :parentView as EvccSiteViewBase?, 
        :siteIndex as Number,
        :actsAsGlance as Boolean
    };


    /******** STATIC ********/


    // This function returns a list of views for all sites
    public static function getAllSiteViews() as ArrayOfSiteViews {
        var views = new ArrayOfSiteViews[0];
        var siteCount = SiteConfiguration.getSiteCount();
        for( var i = 0; i < siteCount; i++ ) {
            // The view adds itself to views
            new MainView( {
                :actAsGlance => false, 
                :views => views,
                :siteIndex => i
            } );
        }
        return views;
    }


    /******** INSTANCE ********/


    // Indicates that we act as glance and present only one site
    // If a device does not support glances, then in the initial
    // widget view only one site can be presented, which is the active
    // site (_actsAsGlance=true). Only if that one site is selected, the 
    // other sites will be presented as sub view and can be cycled through.
    var _actsAsGlance as Boolean;


    // The detail view manager initializes detail views and updates
    // the list of detail views with every state update
    (:exclForMemoryLow)
    var _detailViewManager as DetailViewManager?;


    // Constructor
    // Low memory version, without detail views
    (:exclForMemoryStandard)
    function initialize( options as Options ) {
        var views = options[:views] as ArrayOfSiteViews;
        options[:pageIndex] = views.size();
        views.add( self );

        EvccSiteViewBase.initialize( options );

        _actsAsGlance = options[:actAsGlance] as Boolean;
    }


    // Constructor
    // Standard version, with detail views and multi-site support
    (:exclForMemoryLow)
    function initialize( options as Options ) {

        var views = options[:views] as ArrayOfSiteViews;
        options[:pageIndex] = views.size();
        views.add( self );

        EvccSiteViewBase.initialize( options );

        _actsAsGlance = options[:actAsGlance] as Boolean;

        // We add the sites as lower level views if the current view
        // acts as glance in the widget carousel and there are more
        // than one sites. In this case there are no detail views.
        if( _actsAsGlance && SiteConfiguration.getSiteCount() > 1 ) {
            addLowerLevelViews( MainView.getAllSiteViews() );
        } else {
            // In all other cases we instantiate a detail view manager.
            _detailViewManager = new DetailViewManager( self );
        }
    }


    // See _actsAsGlance
    public function actsAsGlance() as Boolean { return _actsAsGlance; }


    // Helper function to add the charge power of a loadpoint to a line
    private function addChargePower( line as HorizontalBlock, loadpoint as Loadpoint ) as Void {
        line.addText( " " );
        line.addIcon( IconBlock.ICON_ACTIVE_PHASES, { :charging => true, :activePhases => loadpoint.getActivePhases() } );
        line.addText( " " + HelperWidget.formatPower( loadpoint.getChargePowerRounded() ) );
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
    public function addContent( block as VerticalBlock, calcDc as EvccDcInterface ) {
        var state = getStateRequest().getState();
        var variableLineCount = 0;

        // PV
        block.addBlock( renderBasicElement( IconBlock.ICON_SUN, null, state.getPvPowerRounded(), IconBlock.ICON_ARROW_RIGHT ) );
        // Grid
        block.addBlock( renderBasicElement( IconBlock.ICON_GRID, null, state.getGridPowerRounded(), IconBlock.ICON_POWER_FLOW ) );
        // Battery
        if( state.hasBattery() ) {
            block.addBlock( renderBasicElement( IconBlock.ICON_BATTERY, HelperUI.formatSoc( state.getBatterySoc() ), state.getBatteryPowerRounded(), IconBlock.ICON_POWER_FLOW ) );
            variableLineCount++;
        }                

        // Loadpoints
        var loadPointList = state.getConnectedVehicles();
        var loadPoints = loadPointList.getLoadPoints();
        var hasLoadPoint = false;
        var showChargingDetails = MAX_VAR_LINES - variableLineCount >= loadPoints.size() + ( loadPointList.getChargingLoadPointCount() * SMALL_LINE );
        for (var i = 0; i < loadPoints.size() && variableLineCount < MAX_VAR_LINES; i++) {
            var loadPoint = loadPoints[i] as Loadpoint;
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
        block.addBlock( renderBasicElement( IconBlock.ICON_HOME, null, state.getHomePowerRounded(), IconBlock.ICON_ARROW_LEFT ) );

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
    public function addContent( block as VerticalBlock, calcDc as EvccDcInterface ) {
        var state = getStateRequest().getState();
        var variableLineCount = 0;

        // PV
        block.addBlock( renderBasicElement( IconBlock.ICON_SUN, null, state.getPvPowerRounded(), IconBlock.ICON_ARROW_RIGHT ) );
        // Grid
        block.addBlock( renderBasicElement( IconBlock.ICON_GRID, null, state.getGridPowerRounded(), IconBlock.ICON_POWER_FLOW ) );
        // Battery
        if( state.hasBattery() ) {
            block.addBlock( renderBasicElement( IconBlock.ICON_BATTERY, HelperUI.formatSoc( state.getBatterySoc() ), state.getBatteryPowerRounded(), IconBlock.ICON_POWER_FLOW ) );
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
                        IconBlock.ICON_ARROW_LEFT
                    ) );
                }
            }
        }

        // Home
        block.addBlock( renderBasicElement( IconBlock.ICON_HOME, null, state.getHomePowerRounded(), IconBlock.ICON_ARROW_LEFT ) );

        // If there is too much space above and below the content,
        // the lines will be spread out vertically
        block.setOption( :spreadToHeight, getContentArea().height );
    }


    // Adds the display line(s) for a single loadpoint to the given block.
    // Loadpoints that should not be displayed are ignored.
    // Returns true if the loadpoint was added, otherwise false.
    // Ignored are loadpoints without a vehicle that are neither heaters
    // nor integrated devices.
    (:exclForMemoryLow)
    private function addLoadpoint( block as VerticalBlock, loadpoint as Loadpoint ) as Boolean {
        // Route to different rendering functions for each
        // type of loadpoint (connected vehicle, heater, integrated device)
        if( loadpoint.isHeater() ) {
            block.addBlock( renderHeater( loadpoint ) );
            return true;
        } else if( loadpoint.isVehicle() ) {
            // EV chargers are shown only if a vehicle is connected
            var loadpointLine = renderVehicle( loadpoint, true );
            block.addBlock( loadpointLine );
            // If the vehicle is charging, a separate line with details
            // will be added
            if( loadpoint.isCharging() ) {
                block.addBlock( renderVehicleChargingDetails( loadpoint, loadpointLine.getOption( :marginLeft ) as Number ) );
            }
            return true;
        } else if( loadpoint.isIntegratedDevice() ) {
            block.addBlock( renderIntegratedDevice( loadpoint ) );
            return true;
        } else {
            return false;
        }
    }


    // Helper function to add the charging mode of a loadpoint to a line
    private function addMode( line as HorizontalBlock, loadpoint as Loadpoint ) as Void {
        line.addTextWithOptions( " (" + HelperWidget.formatMode( loadpoint ) + ")", { :relativeFont => 4 } );
    }


    // Helper function to add the title of the controllable device (vehicle, heater or integreated device)
    private function addTitle( line as HorizontalBlock, controllable as Controllable ) as Void {
        line.addTextWithOptions( controllable.getTitle(), { :isTruncatable => true } as DbOptions );
    }


    // Returns the detail view manager for this view
    // If we act as glance (see above) and there is more than
    // one site, there are no detail views and this function
    // will return null.
    (:exclForMemoryLow)
    public function getDetailViewManager() as DetailViewManager? { return _detailViewManager; }


    // Only with view pre-rendering there is an exception
    // handler at which we have to register exceptions occuring during onShow
    // for it to be displayed in onUpdate.
    (:exclForViewPreRenderingDisabled)
    private function handleOnShowException( ex as Exception ) as Void {
        getTaskExceptionState().registerException( ex );
    }
    (:exclForViewPreRenderingEnabled)
    private function handleOnShowException( ex as Exception ) as Void {}


    // Called when the view is shown first, or returned to
    // If we act as glance, we update the current site
    function onShow() as Void {
        try {
            // HelperBase.debug( "Widget: onShow" );
            // If we are in glance view, it may happen that we are
            // returning from the sub views showing multiple sites,
            // and we have to switch the glance view to the 
            // site last selected
            if( _actsAsGlance ) {
                var siteCount = SiteConfiguration.getSiteCount();
                // Only if there is more than one site, we set the site
                // index to the currently active, in case the currently
                // active was changed in the lower level views
                if( siteCount > 1 ) {
                    // setSiteIndex will also update the content
                    // if the site index has changed
                    setSiteIndex( BreadCrumbSiteReadOnly.getSelectedSite( siteCount ) );
                }
            }
            EvccSiteViewBase.onShow();
        } catch ( ex ) {
            // setSiteIndex pre-renders the content in case the
            // index changed, and we need to log any exceptions
            // coming from that
            handleOnShowException( ex );
            HelperBase.debugException( ex );
        }
    }


    // With every new web response we check if the list of 
    // detail views needs to be updated.
    // For example, the state in storage used during initialization may not
    // yet include a forecast, but it was activated in the meantime and
    // will then be part of the first server response.
    // Also vehicles could be connected or disconnected while the app is running, changing
    // the number of connected vehicle loadpoints, which may or may not require a detail
    // view.

    // ... if view prerendering is disabled, we do this in the onUpdate ...
    (:exclForMemoryLow :exclForViewPreRenderingEnabled) 
    function onUpdate( dc as Dc ) as Void {
        initOrUpdateDetailViews( false );
        EvccSiteViewBase.onUpdate( dc );
    }

    // ... if view prerendering is enabled, we have to do this earlier,
    // when onStateChange is called, so that the further prerendering
    // of the page and select indicator is already is based on the adapted 
    // detail views.
    (:exclForViewPreRenderingDisabled) function prepareImmediately() as Void {
        // HelperBase.debug( "WidgetSiteMain: prepareImmediately site=" + getSiteIndex() );
        if( _detailViewManager != null ) {
            _detailViewManager.initOrUpdateDetailViews( false );
        }
        EvccSiteViewBase.prepareImmediately();
    }
    (:exclForViewPreRenderingDisabled) function prepareByTasks() as Void {
        // HelperBase.debug("WidgetSiteMain: prepareByTasks site=" + getSiteIndex() );
        if( _detailViewManager != null ) {
            TaskQueue.getInstance().add( new InitOrUpdateDetailViewsTask( self ) );
        }
        EvccSiteViewBase.prepareByTasks();
    }


    // Function to generate line for PV, grid, battery and home
    private function renderBasicElement( icon as IconBlock.Icon, text as String?, power as Number, flowIcon as IconBlock.Icon ) as HorizontalBlock {
        var state = getStateRequest().getState();
        var lineOptions = {};
        var iconOptions = {};
        if( icon == IconBlock.ICON_BATTERY ) { 
            // For battery the SoC is used to choose on of the icons with different fill
            iconOptions[:batterySoc] = state.getBatterySoc(); 
        }
        var line = new HorizontalBlock( lineOptions );
        line.addIcon( icon, iconOptions );
        // If a text was provided, we show it after the icon
        if( text != null ) { line.addText( " " + text ); }

        if( power != 0 ) {
            line.addText( " " );
            var flowOptions = {};
            if( flowIcon == IconBlock.ICON_POWER_FLOW ) { flowOptions[:power] = power; }
            line.addIcon( flowIcon, flowOptions );
        }
        // For battery and loadpoints we show the power only if it is not 0,
        // for all others we always show it
        if( ( icon != IconBlock.ICON_BATTERY 
              && icon != IconBlock.ICON_CAR 
              && icon != IconBlock.ICON_HEATER
              && icon != IconBlock.ICON_DEVICE
            ) 
            || power != 0 
        ) {
            line.addText( " " + HelperWidget.formatPower( power.abs() ) );
        }
        return line;
    }


    // Function to generate the main line representing a connected vehicle
    private function renderVehicle( loadpoint as Loadpoint, showChargingDetails as Boolean ) as HorizontalBlock {
        var vehicle = loadpoint.getVehicle() as ConnectedVehicle;

        var line = new HorizontalBlock( { :truncateSpacing => getContentArea().truncateSpacing } );
        
        addTitle( line, vehicle );
        
        // For guest vehicles there is no SoC
        if( ! vehicle.isGuest() ) {
            line.addText( " " + HelperUI.formatSoc( vehicle.getSoc() ) );
        }

        // If the vehicle is charging, we show the power
        if( loadpoint.isCharging() ) {
            addChargePower( line, loadpoint );
            if( ! showChargingDetails ) {
                line.addTextWithOptions( " (" +  HelperWidget.formatMode( loadpoint ) + ")", { :relativeFont => 4 } );
            }
        }

        if( ! loadpoint.isCharging() || ! showChargingDetails ) {
            addMode( line, loadpoint );
        }

        return line;
    }


    // Function to generate the charging info line below main vehicle line
    private function renderVehicleChargingDetails( loadpoint as Loadpoint, marginLeft as Number ) as HorizontalBlock {
        var lineCharging = new HorizontalBlock( { :relativeFont => 3, :marginLeft => marginLeft } );
        lineCharging.addText( HelperWidget.formatMode( loadpoint ) );
        if( loadpoint.getChargeRemainingDuration() > 0 ) {
            lineCharging.addText( " - " );
            lineCharging.addIcon( IconBlock.ICON_DURATION, {} as DbOptions );
            lineCharging.addText( " " + HelperWidget.formatDuration( loadpoint.getChargeRemainingDuration() ) );
        }
        return lineCharging;
    }


    // Function to generate the line for heater loadpoints
    (:exclForMemoryLow)
    private function renderHeater( loadpoint as Loadpoint ) as HorizontalBlock {
        var heater = loadpoint.getHeater() as Heater;
        var line = new HorizontalBlock( { :truncateSpacing => getContentArea().truncateSpacing } );
        
        addTitle( line, heater );

        line.addText( " " + HelperWidget.formatTemp( heater.getTemperature() ) );
        
        // If the heater is operating, we show the power
        if( loadpoint.getChargePowerRounded() > 0 ) {
            addChargePower( line, loadpoint );
        }

        addMode( line, loadpoint );

        return line;
    }


    // Function to generate the line for integrated device loadpoints
    (:exclForMemoryLow)
    private function renderIntegratedDevice( loadpoint as Loadpoint ) as HorizontalBlock {
        var integratedDevice = loadpoint.getIntegratedDevice() as IntegratedDevice;
        var line = new HorizontalBlock( { :truncateSpacing => getContentArea().truncateSpacing } );
        
        addTitle( line, integratedDevice );
        
        // If the integrated device is operating, we show the power
        if( loadpoint.getChargePowerRounded() > 0 ) {
            addChargePower( line, loadpoint );
        }

        addMode( line, loadpoint );
        
        return line;
    }

}
