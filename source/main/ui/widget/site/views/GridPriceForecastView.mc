import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Time;

// View showing grid price forecast data
class GridPriceForecastView extends EvccSiteViewBase {
    private const LABELS = [ "+1h", "+2h", "tday", "tmrw" ];
    private const UNIT = " ct";
    
    function initialize( options as EvccSiteViewBase.Options ) {
        EvccSiteViewBase.initialize( options );
    }

    // Show the forecast icon as page title
    // Set icon and title for this page
    public function getPageTitle() as TextBlock? {
        return new TextBlock( "grid price", { :color => Graphics.COLOR_LT_GRAY } );
    }
    public function getPageIcon() as IconBlock? {
        return new IconBlock( IconBlock.ICON_PRICE, {} );
    }
    // Forecast is limited by width not the default height
    function limitHeight() as Boolean { return true; }
    function limitWidth() as Boolean { return false; }

    // Add the content
    public function addContent( block as VerticalBlock, calcDc as EvccDcInterface ) {

        var state = getWebRequest().getState();
        var dcHeight = calcDc.getHeight();

        var now = state.getGridTariff();
        if( now != null ) {
            addSingle( block, "now", now );
            block.addBlock( new SpacerBlock( { :relativeToFontHeight => 0.20 } ) );
        }
        if( state != null && state.hasGridPriceForecast() ) {
            var forecast = state.getGridPriceForecast();
            if( forecast != null ) {
                addAverages( block, forecast.getAveragePrices() );
                block.addBlock( new SpacerBlock( { :relativeToFontHeight => 0.20 } ) );
                addSingle( block, "min", forecast.getCheapestHourAverage() );
                addCheapestHour( block, forecast.getCheapestHourStart(), forecast.getCheapestHourEnd() );
            }
        }

        // Add a small margin to the bottom. While the content is centered vertically between title and logo,
        // the spacing in the fonts make it seem a bit off, and this is to compensate for that.
        block.setOption( :marginBottom, dcHeight * 0.02 );
    }

    
    // Assemble one row of the table
    private function addCheapestHour( block as VerticalBlock, start as Moment, end as Moment ) as Void {
        var startInfo = Gregorian.info( start, Time.FORMAT_MEDIUM );
        var endInfo = Gregorian.info( end, Time.FORMAT_MEDIUM );
        block.addTextWithOptions( 
            startInfo.day_of_week
                + " " + StringFormatter.pad2( startInfo.hour ) 
                + ":" + StringFormatter.pad2( startInfo.min )
                + "-" + StringFormatter.pad2( endInfo.hour ) 
                + ":" + StringFormatter.pad2( endInfo.min ), 
            { :relativeFont => 4 } 
        );
    }


    // Assemble one row of the table
    private function addSingle( block as VerticalBlock, label as String, price as Float ) as Void {
        var row = new HorizontalBlock( {} as DbOptions );
        row.addTextWithOptions( 
            label + ":", 
            { :relativeFont => 2, 
              :verticalJustifyToBaseFont => true,
              :color => Graphics.COLOR_LT_GRAY } 
        );
        row.addTextWithOptions( " " + formatPrice( price ), { :relativeFont => 0, :verticalJustifyToBaseFont => true } );
        row.addTextWithOptions( UNIT, { :relativeFont => 2, :verticalJustifyToBaseFont => true } );
        block.addBlock( row );
    }


    // Assemble one row of the table
    private function addAverages( block as VerticalBlock, price as Array<Float> ) as Void {

        var row = new HorizontalBlock( {} as DbOptions );
        var columns = [ [
            new VerticalBlock( {} as DbOptions ),
            new VerticalBlock( {} as DbOptions ),
            new VerticalBlock( {} as DbOptions )
        ], [
            new VerticalBlock( {} as DbOptions ),
            new VerticalBlock( {} as DbOptions ),
            new VerticalBlock( {} as DbOptions )
        ] ];

        var ci = 0;

        for( var pi = 0; pi < price.size(); pi++ ) {
            // Start with the label
            columns[ci][0].addTextWithOptions( 
                ( ci == 1 ? "      " : "" ) + LABELS[pi] + ":", 
                { 
                    :relativeFont => 2, 
                    :verticalJustifyToBaseFont => true, 
                    :justify => Graphics.TEXT_JUSTIFY_RIGHT,
                    :color => Graphics.COLOR_LT_GRAY
                } 
            );
            
            // Then add the value
            columns[ci][1].addTextWithOptions( " " + formatPrice( price[pi] ), { :justify => Graphics.TEXT_JUSTIFY_RIGHT } );

            // And finally the unit with the optional indicator
            var unit = new HorizontalBlock( { :justify => Graphics.TEXT_JUSTIFY_LEFT} );
            unit.addTextWithOptions( UNIT, { :relativeFont => 2, :verticalJustifyToBaseFont => true } );
            columns[ci][2].addBlock( unit );
        
            ci = 1 - ci;
        }

        for( var i = 0; i < columns.size(); i++ ) {
            for( var j= 0 ; j < columns[i].size(); j++ ) {
                row.addBlock( columns[i][j] );
            }
        }
        
        block.addBlock( row );
    }

    // Function to prices for the forecast view
    private function formatPrice( price as Float ) as String {
        return Math.round( price * 100.0 ).format( "%u" );    
        //return Math.round( price * 100.0 ).format( "%.1f" );    
    }
}
