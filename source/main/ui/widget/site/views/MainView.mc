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
        var siteCount = SiteConfigRepository.getSiteCount();
        for( var i = 0; i < siteCount; i++ ) {
            // The main view adds itself to views
            new MainView( { :views => views, :siteIndex => i } );
        }
        return views;
    }


    /******** INSTANCE ********/


    // The detail view manager initializes detail views and updates
    // the list of detail views with every state update
    private var _detailViewManager as DetailViewManager;


    // Constructor
    public function initialize( options as Options ) {

        var views = options[:views] as ArrayOfSiteViews;
        options[:pageIndex] = views.size();
        views.add( self );

        EvccSiteViewBase.initialize( options );

        _detailViewManager = new DetailViewManager( self );
    }


    // Helper function to add the charge power of a loadpoint to a line
    private function addChargePower( line as HorizontalBlock, loadpoint as Loadpoint ) as Void {
        line.addText( " " );
        line.addIcon( IconBlock.ICON_ACTIVE_PHASES, { :charging => true, :activePhases => loadpoint.getActivePhases() } );
        line.addText( " " + WidgetUiHelper.formatPower( loadpoint.getChargePowerRounded() ) );
    }


    // The addContent function generates the content of
    // this view. We display the same basic elements,
    // but with more advanced logic for loadpoints.
    // If there are two or less loadpoints, they will directly
    // be displayed in the main view.
    // If they are more, then loadpoints that belong to the same 
    // category (vehicles, heaters, integrated devices) will be grouped
    // into one category, with a summary line being displayed.
    // In this case initOrUpdateDetailViews() will add detail views that then
    // display the loadpoints in that category.
    public function addContent( block as VerticalBlock, calcDc as EvccDcInterface ) {
        var state = getWebRequest().getState();
        var variableLineCount = 0;

        // PV
        block.addBlock( renderBasicElement( IconBlock.ICON_SUN, null, state.getPvPowerRounded(), IconBlock.ICON_ARROW_RIGHT ) );
        // Grid
        block.addBlock( renderBasicElement( IconBlock.ICON_GRID, null, state.getGridPowerRounded(), IconBlock.ICON_POWER_FLOW ) );
        // Battery
        if( state.hasBattery() ) {
            block.addBlock( renderBasicElement( IconBlock.ICON_BATTERY, WidgetUiHelper.formatSoc( state.getBatterySoc() ), state.getBatteryPowerRounded(), IconBlock.ICON_POWER_FLOW ) );
            variableLineCount++;
        }

        // Loadpoints
        // If there are two or less loadpoints, we show them directly
        if( state.getLoadpointCount() <= 2 ) {
            var loadpoints = state.getLoadpoints();
            for( var i = 0; i < loadpoints.size(); i++ ) {
                addLoadpoint( block, loadpoints[i] );
            }
        } else {
            // If there are more, we look at them per category
            // First we assemble a 2d array with the icon and loadpoint list
            // for each category
            var loadpointLists = state.getAllLoadpointsCategories();
            
            // Then we loop through all categories
            for( var i = 0; i < loadpointLists.size(); i++ ) {
                var loadpoints = loadpointLists[i][1].getLoadpoints();
                var loadpointCount = loadpoints.size();
                // If there is only one loadpoint in the category, we directly
                // display it
                if( loadpointCount == 1 ) {
                    addLoadpoint( block, loadpoints[0] );
                } else if( loadpointCount > 1 ) {
                    // If there are more than one, we add a summary line
                    var loadpointList = loadpointLists[i][1];
                    block.addBlock( renderBasicElement( 
                        loadpointLists[i][0],
                        loadpointList.getChargingLoadpointCount() + "/" + loadpointList.getLoadpoints().size(),
                        loadpointList.getTotalChargingPower(),
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
    private function addLoadpoint( block as VerticalBlock, loadpoint as Loadpoint ) as Void {
        // Route to different rendering functions for each
        // type of loadpoint (connected vehicle, heater, integrated device)
        if( loadpoint.isHeater() || loadpoint.isIntegratedDevice() ) {
            block.addBlock( renderAuxDevice( loadpoint ) );
        } else if( loadpoint.isVehicle() ) {
            var loadpointLine = renderVehicle( loadpoint );
            block.addBlock( loadpointLine );
            // If the vehicle is charging, a separate line with details will be added
            if( loadpoint.isCharging() ) {
                block.addBlock( renderVehicleChargingDetails( loadpoint, loadpointLine.getOption( :marginLeft ) as Number ) );
            }
        } else {
            block.addBlock( renderDisconnectedLoadpoint( loadpoint ) );
        }
    }


    // Helper function to add the charging mode of a loadpoint to a line
    private function addMode( line as HorizontalBlock, loadpoint as Loadpoint ) as Void {
        line.addTextWithOptions( " (" + WidgetUiHelper.formatMode( loadpoint ) + ")", { :relativeFont => 4 } );
    }


    // Returns the detail view manager for this view
    // If we act as glance (see above) and there is more than
    // one site, there are no detail views and this function
    // will return null.
    public function getDetailViewManager() as DetailViewManager? { return _detailViewManager; }


    // Only with view pre-rendering there is an exception
    // handler at which we have to register exceptions occuring during onShow
    // for it to be displayed in onUpdate.
    private function handleOnShowException( ex as Exception ) as Void {
        getTaskExceptionState().registerException( ex );
    }


    // With every new web response we check if the list of 
    // detail views needs to be updated.
    // For example, the state in storage used during initialization may not
    // yet include a forecast, but it was activated in the meantime and
    // will then be part of the first server response.
    // Also vehicles could be connected or disconnected while the app is running, changing
    // the number of connected vehicle loadpoints, which may or may not require a detail
    // view.

    // ... if view prerendering is enabled, we have to do this earlier,
    // when onStateChange is called, so that the further prerendering
    // of the page and select indicator is already is based on the adapted 
    // detail views.
    function prepareImmediately() as Void {
        // Logger.debug( "WidgetSiteMain: prepareImmediately site=" + getSiteIndex() );
        if( _detailViewManager != null ) {
            _detailViewManager.initOrUpdateDetailViews( false );
        }
        EvccSiteViewBase.prepareImmediately();
    }
    function prepareByTasks() as Void {
        // Logger.debug("WidgetSiteMain: prepareByTasks site=" + getSiteIndex() );
        EvccSiteViewBase.prepareByTasks();
        if( _detailViewManager != null ) {
            TaskQueue.getInstance().addToFront( new InitOrUpdateDetailViewsTask( self ) );
        }
    }


    // Function to generate line for PV, grid, battery and home
    private function renderBasicElement( icon as IconBlock.Icon, text as String?, power as Number, flowIcon as IconBlock.Icon ) as HorizontalBlock {
        var state = getWebRequest().getState();
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
              && icon != IconBlock.ICON_CHARGER
              && icon != IconBlock.ICON_HEATER
              && icon != IconBlock.ICON_DEVICE
            ) 
            || power != 0 
        ) {
            line.addText( " " + WidgetUiHelper.formatPower( power.abs() ) );
        }
        return line;
    }


    // Function to generate the line representing a charger without connected EV
    private function renderDisconnectedLoadpoint( loadpoint as Loadpoint ) as HorizontalBlock {
        var line = new HorizontalBlock( { :truncateSpacing => getContentArea().truncateSpacing } );
        line.addIcon( IconBlock.ICON_CHARGER, {} );
        line.addTextWithOptions( " " + loadpoint.getTitle(), { :isTruncatable => true } );
        return line;
    }


    // Function to generate the main line representing a charger with a connected EV
    private function renderVehicle( loadpoint as Loadpoint ) as HorizontalBlock {
        var vehicle = loadpoint.getVehicle() as Vehicle;

        var line = new HorizontalBlock( { :truncateSpacing => getContentArea().truncateSpacing } );

        line.addTextWithOptions( vehicle.getTitle(), { :isTruncatable => true } );
        
        // For guest vehicles there is no SoC
        if( ! vehicle.isGuest() ) {
            line.addText( " " + WidgetUiHelper.formatSoc( vehicle.getSoc() ) );
        }

        // If the vehicle is charging, show the power.
        // Otherwise, show the charging mode.
        // When charging, the mode is displayed in the separate charging details line.
        if( loadpoint.isCharging() ) {
            addChargePower( line, loadpoint );
        } else {
            addMode( line, loadpoint );
        }

        return line;
    }


    // Function to generate the charging info line below main vehicle line
    private function renderVehicleChargingDetails( loadpoint as Loadpoint, marginLeft as Number ) as HorizontalBlock {
        var lineCharging = new HorizontalBlock( { :relativeFont => 3, :marginLeft => marginLeft } );
        lineCharging.addText( WidgetUiHelper.formatMode( loadpoint ) );
        if( loadpoint.getChargeRemainingDuration() > 0 ) {
            lineCharging.addText( " - " );
            lineCharging.addIcon( IconBlock.ICON_DURATION, {} );
            lineCharging.addText( " " + WidgetUiHelper.formatDuration( loadpoint.getChargeRemainingDuration() ) );
        }
        return lineCharging;
    }


    // Renders a heater or integrated device
    private function renderAuxDevice( loadpoint as Loadpoint ) as HorizontalBlock {

        var isHeater = loadpoint.isHeater();
        var isOnlyInCategory = loadpoint.isOnlyInCategory();

        var line = new HorizontalBlock( 
            ! isOnlyInCategory ? { :truncateSpacing => getContentArea().truncateSpacing } : {} 
        );
        
        if( isOnlyInCategory ) {
            line.addIcon( isHeater ? IconBlock.ICON_HEATER : IconBlock.ICON_DEVICE, {} );
        } else {
            line.addTextWithOptions( loadpoint.getTitle(), { :isTruncatable => true } );
        }

        if( isHeater ) {
            line.addText( " " + WidgetUiHelper.formatTemp( (loadpoint.getHeater() as Heater ).getTemperature() ) );
        }
        
        // If the heater is operating, we show the power
        if( loadpoint.getChargePowerRounded() > 0 ) {
            addChargePower( line, loadpoint );
        }

        addMode( line, loadpoint );

        return line;
    }

}
