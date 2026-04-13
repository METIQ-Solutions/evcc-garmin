import Toybox.Graphics;
import Toybox.Lang;
using Toybox.Time.Gregorian;

// View showing statistics data
(:exclForMemoryLow)
class StatisticsView extends EvccSiteViewBase {
    private var LABELS as Array<String> = [ "30 days", 
                                            "this year", 
                                            "365 days", 
                                            "all time" ];

    function initialize( options as EvccSiteViewBase.Options ) {
        EvccSiteViewBase.initialize( options );
    }

    // Set icon and title for this page
    function getPageTitle() as TextBlock? {
        return new TextBlock( "solar energy", {} as DbOptions );
    }
    function getPageIcon() as IconBlock? {
        return new IconBlock( IconBlock.ICON_STATISTICS, {} as DbOptions );
    }

    // Add the content
    function addContent( block as VerticalBlock, calcDc as EvccDcInterface ) {

        var stateRequest = getStateRequest();
        var dcHeight = calcDc.getHeight();

        if( stateRequest.hasCurrentState() ) {
            var state = stateRequest.getState();
            if( state.hasStatistics() ) {
                var statisticsPeriods = state.getStatistics().getStatisticsPeriods();

                var row = new HorizontalBlock( {} as DbOptions );
                var column1 = new VerticalBlock( {} as DbOptions );
                var column2 = new VerticalBlock( {} as DbOptions );

                for( var i = 0; i < statisticsPeriods.size(); i++ ) {
                    // Add the label
                    column1.addTextWithOptions( LABELS[i] + ":", { :relativeFont => 2, :verticalJustifyToBaseFont => true, :justify => Graphics.TEXT_JUSTIFY_RIGHT } as DbOptions );

                    // Add the value as one right-justified horizontal block,
                    // with value and unit in different sizes
                    var value = new HorizontalBlock( { :justify => Graphics.TEXT_JUSTIFY_RIGHT } as DbOptions );
                    var solarPercent = statisticsPeriods[i].getSolarPercent();
                    if( solarPercent != null ) {
                        value.addText( " " + solarPercent.format("%.0f") ); // format with no digits after the decimal point
                        value.addTextWithOptions( "%", { :relativeFont => 2, :verticalJustifyToBaseFont => true } );
                    } else {
                        value.addText( " " );
                        value.addTextWithOptions( "n/a", { :relativeFont => 2, :verticalJustifyToBaseFont => true } );
                    }

                    column2.addBlock( value );
                }
                row.addBlock( column1 );
                row.addBlock( column2 );
                block.addBlock( row );
            } else {
                addLoading( block, calcDc );
            }
        } else {
            addLoading( block, calcDc );
        }

        // Add a small margin to the bottom. While the content is centered vertically between title and logo,
        // the spacing in the fonts make it seem a bit off, and this is to compensate for that.
        block.setOption( :marginBottom, dcHeight * 0.0375 );
    }

    // Statistics is limited by width not the default height
    function limitHeight() as Boolean { return false; }
    function limitWidth() as Boolean { return true; }
}
