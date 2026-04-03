import Toybox.Lang;

class EvccWidgetBaseLoadPointView extends EvccWidgetBaseSiteView {

    protected function initialize( views as ArrayOfSiteViews, parentView as EvccWidgetBaseSiteView?, siteIndex as Number ) {
        EvccWidgetBaseSiteView.initialize( views, parentView, siteIndex );
    }

    // Add a single loadpoint to the given block
    (:exclForMemoryLow)
    protected function addLoadpoint( block as EvccVerticalBlock, loadpoint as EvccLoadPoint ) as Boolean {
        if( loadpoint.isHeater() ) {
            block.addBlock( renderHeater( loadpoint ) );
            return true;
        } else if( loadpoint.isVehicle() ) {
            var loadpointLine = renderVehicle( loadpoint, true );
            block.addBlock( loadpointLine );
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

    // Helper function to add the charge power of a loadpoint to a line
    private function addChargePower( line as EvccHorizontalBlock, loadpoint as EvccLoadPoint ) as Void {
        line.addText( " " );
        line.addIcon( EvccIconBlock.ICON_ACTIVE_PHASES, { :charging => true, :activePhases => loadpoint.getActivePhases() } );
        line.addText( " " + EvccHelperWidget.formatPower( loadpoint.getChargePowerRounded() ) );
    }

    // Helper function to add the charging mode of a loadpoint to a line
    private function addMode( line as EvccHorizontalBlock, loadpoint as EvccLoadPoint ) as Void {
        line.addTextWithOptions( " (" + formatMode( loadpoint ) + ")", { :relativeFont => 4 } );
    }

    // Helper function to add the title of the controllable device (vehicle, heater or integreated device)
    private function addTitle( line as EvccHorizontalBlock, controllable as EvccControllable ) as Void {
        line.addTextWithOptions( controllable.getTitle(), { :isTruncatable => true } as DbOptions );
    }

    // Function to generate main loadpoint lines
    protected function renderVehicle( loadpoint as EvccLoadPoint, showChargingDetails as Boolean ) as EvccHorizontalBlock {
        var vehicle = loadpoint.getVehicle() as EvccConnectedVehicle;

        var line = new EvccHorizontalBlock( { :truncateSpacing => getContentArea().truncateSpacing } );
        
        addTitle( line, vehicle );
        
        // For guest vehicles there is no SoC
        if( ! vehicle.isGuest() ) {
            line.addText( " " + EvccHelperUI.formatSoc( vehicle.getSoc() ) );
        }

        // If the vehicle is charging, we show the power
        if( loadpoint.isCharging() ) {
            addChargePower( line, loadpoint );
            if( ! showChargingDetails ) {
                line.addTextWithOptions( " (" + formatMode( loadpoint ) + ")", { :relativeFont => 4 } );
            }
        }

        if( ! loadpoint.isCharging() || ! showChargingDetails ) {
            addMode( line, loadpoint );
        }

        return line;
    }

    // Function to generate charging info below main loadpoint line
    protected function renderVehicleChargingDetails( loadpoint as EvccLoadPoint, marginLeft as Number ) as EvccHorizontalBlock {
        var lineCharging = new EvccHorizontalBlock( { :relativeFont => 3, :marginLeft => marginLeft } );
        lineCharging.addText( formatMode( loadpoint ) );
        if( loadpoint.getChargeRemainingDuration() > 0 ) {
            lineCharging.addText( " - " );
            lineCharging.addIcon( EvccIconBlock.ICON_DURATION, {} as DbOptions );
            lineCharging.addText( " " + EvccHelperWidget.formatDuration( loadpoint.getChargeRemainingDuration() ) );
        }
        return lineCharging;
    }


    // Function to generate the line for heater loadpoints
    (:exclForMemoryLow)
    private function renderHeater( loadpoint as EvccLoadPoint ) as EvccHorizontalBlock {
        var heater = loadpoint.getHeater() as EvccHeater;
        var line = new EvccHorizontalBlock( { :truncateSpacing => getContentArea().truncateSpacing } );
        
        addTitle( line, heater );

        line.addText( " " + EvccHelperWidget.formatTemp( heater.getTemperature() ) );
        
        // If the heater is operating, we show the power
        if( loadpoint.getChargePowerRounded() > 0 ) {
            addChargePower( line, loadpoint );
        }

        addMode( line, loadpoint );
        
        return line;
    }

    // Function to generate the line for integrated device loadpoints
    (:exclForMemoryLow)
    private function renderIntegratedDevice( loadpoint as EvccLoadPoint ) as EvccHorizontalBlock {
        var integratedDevice = loadpoint.getIntegratedDevice() as EvccIntegratedDevice;
        var line = new EvccHorizontalBlock( { :truncateSpacing => getContentArea().truncateSpacing } );
        
        addTitle( line, integratedDevice );
        
        // If the integrated device is operating, we show the power
        if( loadpoint.getChargePowerRounded() > 0 ) {
            addChargePower( line, loadpoint );
        }

        addMode( line, loadpoint );
        
        return line;
    }

    // Return the text to be displayed for the mode
    private function formatMode( loadpoint as EvccLoadPoint ) as String { 
        var mode = loadpoint.getMode();
        if( mode.equals( "pv" ) ) { return "Solar"; }
        else if( mode.equals( "minpv" ) ) { return "Min+Solar"; }
        else if( mode.equals( "now" ) ) { return "Fast"; }
        else if( mode.equals( "off" ) ) { return "Off"; }
        else { return mode; }
    }
}
