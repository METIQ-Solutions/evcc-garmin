import Toybox.Lang;
import Toybox.Math;

(:exclForMemoryLow)
class LoadpointView extends EvccSiteViewBase {


    /******** TYPES ********/


    // Options for constructor
    typedef Options as {
        :views as ArrayOfSiteViews, 
        :parentView as EvccSiteViewBase?, 
        :siteIndex as Number,
        :pageIndex as Number,
        :category as Number,
        :categoryPageIndex as Number
    };


    /******** STATIC ********/


    public static function getLoadPointsPerPage( category as Number ) as Number {
        return [2,3,3][category];
    }

    /**
    * Returns the start and end indices of loadpoints to display on a page.
    *
    * While DetailViewManager already defines the number of pages,
    * this function ensures that loadpoints are distributed evenly across them.
    * For example, if the maximum per page is three and there are four loadpoints,
    * both pages will display two.
    *
    * @param totalLoadpoints   Total number of loadpoints in the category
    * @param pageIndex         Index of the current page (0-based)
    * @param maxPerPage        Maximum number of loadpoints per page
    *
    * @return [start, end]     Tuple with inclusive start and end indices
    */
    private static function getLoadpointRange( 
        totalLoadpoints as Number, 
        pageIndex as Number, 
        maxPerPage as Number
    ) as [Number, Number] {

        if (totalLoadpoints <= 0 || maxPerPage <= 0) {
            return [ -1, -1 ];
        }

        // Calculate number of pages needed
        var pageCount = (totalLoadpoints + maxPerPage - 1) / maxPerPage;
        pageCount = Math.floor( pageCount.toNumber() );

        // Clamp pageIndex
        if (pageIndex < 0) {
            pageIndex = 0;
        } else if (pageIndex >= pageCount) {
            pageIndex = pageCount - 1;
        }

        // Base number of items per page
        var baseSize = totalLoadpoints / pageCount;
        baseSize = Math.floor( baseSize.toNumber() );

        // Remaining items to distribute
        var remainder = totalLoadpoints - (baseSize * pageCount);

        // Pages with one extra item come first
        var start = 0;

        for (var i = 0; i < pageIndex; i += 1) {
            if (i < remainder) {
                start += baseSize + 1;
            } else {
                start += baseSize;
            }
        }

        var pageSize;
        if (pageIndex < remainder) {
            pageSize = baseSize + 1;
        } else {
            pageSize = baseSize;
        }

        var end = start + pageSize - 1;

        return [ start.toNumber(), end.toNumber() ];
    }


    /******** INSTANCE ********/


    // The index of the category in the array returned by EvccState.getAllLoadPointsCategories
    // E.g. 0 = car, 1 = heater
    private var _category as Number;
    // The page index within the category
    // E.g. 0 = the first page of the category
    private var _categoryPageIndex as Number;
    // The icon representing the category
    private var _icon as IconBlock.Icon;

    // Constructor
    function initialize( options as Options ) {
        EvccSiteViewBase.initialize( options );
        _category = options[:category] as Number;
        _categoryPageIndex = options[:categoryPageIndex] as Number;
        _icon = getStateRequest().getState().getLoadPointCategory( _category )[0];
    }

    // Renders the content and adds it to the block
    // passed in by the base class
    public function addContent( block as VerticalBlock, calcDc as EvccDcInterface ) {
        
        // Get the loadpoints for the category
        var loadPoints = getStateRequest().getState().getLoadPointCategory( _category )[1].getLoadPoints();

        if( loadPoints.size() > 0 ) {

            // Define the range of loadpoints displayed on this
            // page. getLoadPointRange() ensures an even distribution
            // of loadpoints across pages
            var loadPointRange = getLoadpointRange( 
                loadPoints.size(), 
                _categoryPageIndex,
                getLoadPointsPerPage( _category ) 
            );

            // Determine if any loadpoint is charging
            // If any is charging, the spacing for showing the phase indicator arrows 
            // will be applied to all loadpoints, even if they are not charging        
            var isAnyLoadpointCharging = false;
            for( var i = loadPointRange[0]; i <= loadPointRange[1]; i++ ) {
                isAnyLoadpointCharging = isAnyLoadpointCharging || loadPoints[i].getChargePowerRounded() > 0;
            }

            // Iterate and render all loadpoints
            var first = true;
            for( var i = loadPointRange[0]; i <= loadPointRange[1]; i++ ) {
                // From the 2nd loadpoint onwards, a spacing will be
                // applied before the loadpoint
                if( first ) {
                    first = false;
                } else {
                    // The spacing is relative to font height AND less, if there
                    // are more loadpoints
                    block.addBlock(
                        new SpacerBlock( {
                            :relativeToFontHeight => 0.8 / ( loadPointRange[1] - loadPointRange[0] + 1 )
                        } )
                    );
                }
                // Render and add the loadpoint
                addLoadpoint( block, loadPoints[i], isAnyLoadpointCharging );
            }
        } else {
            block.addText( "No loadpoints" );
        }

        // Add a small margin to the bottom. While the content is centered vertically between title and logo,
        // the spacing in the fonts make it seem a bit off, and this is to compensate for that.
        block.setOption( :marginBottom, calcDc.getHeight() * 0.01 );
    }

    private function addLoadpoint( 
        block as VerticalBlock, 
        loadpoint as Loadpoint, 
        isAnyLoadpointCharging as Boolean 
    ) as Void {
        var controllable = loadpoint.getControllable();
        if( controllable == null ) {
            throw new OperationNotAllowedException("LoadpointView.addIntegratedDevice: loadpoint does not have controllable" );
        }

        var titleLine = new HorizontalBlock( { :truncateSpacing => getContentArea().truncateSpacing } );
        titleLine.addTextWithOptions( 
            controllable.getTitle(), 
            { :isTruncatable => true,
              :useEllipsis => true } as DbOptions 
        );
        block.addBlock( titleLine );

        if( controllable instanceof ConnectedVehicle ) {
            titleLine.addText( ": " + HelperUI.formatSoc( controllable.getSoc() ) );
        } else if( controllable instanceof Heater ) {
            titleLine.addText( ": " + HelperWidget.formatTemp( controllable.getTemperature() ) );
        } 
        
        var stateLine = new HorizontalBlock( { :relativeFont => 3 } );

        if( isAnyLoadpointCharging ) {
            stateLine.addIcon( 
                IconBlock.ICON_ACTIVE_PHASES, 
                { :charging => true, 
                :activePhases => loadpoint.getActivePhases(),
                :suppressDrawing => loadpoint.getChargePowerRounded() <= 0 } 
            );
            
            stateLine.addText( " " );
        }

        stateLine.addText( 
            HelperWidget.formatPower( loadpoint.getChargePowerRounded() )
            + " (" + HelperWidget.formatMode( loadpoint ) + ")"
        );

        block.addBlock( stateLine );

        if( controllable instanceof ConnectedVehicle && loadpoint.getChargeRemainingDuration() > 0 ) {
            var timeLine = new HorizontalBlock( { :relativeFont => 3 } );
            timeLine.addIcon( IconBlock.ICON_DURATION, {} as DbOptions );
            timeLine.addText( " " + HelperWidget.formatDuration( loadpoint.getChargeRemainingDuration() ) );
            block.addBlock( timeLine );
        }
    }

    // Show the category icon as page title
    public function getPageIcon() as IconBlock? {
        return new IconBlock( _icon, {} as DbOptions );
    }

}
