import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Time;

// View showing grid price forecast data
class GridPriceForecastView extends EvccSiteViewBase {
    private const LABELS = [ "+1H", "+2H", "TDAY", "TMRW" ];
    private const UNIT = " ct";
    private const NA = "--";
    
    function initialize( options as EvccSiteViewBase.Options ) {
        EvccSiteViewBase.initialize( options );
    }

    // Show the forecast icon as page title
    // Set icon and title for this page
    public function getPageTitle() as TextBlock? {
        return new TextBlock( "GRID PRICE", { :color => EvccColors.HEADER } );
    }
    public function getPageIcon() as IconBlock? {
        return new IconBlock( IconBlock.ICON_PRICE, {} );
    }
    // Forecast is limited by width not the default height
    function limitHeight() as Boolean { return false; }
    function limitWidth() as Boolean { return true; }

    // Add the content
    public function addContent( block as VerticalBlock, calcDc as EvccDcInterface ) {

        var state = getWebRequest().getState();
        var dcHeight = calcDc.getHeight();

        var now = state.getGridTariff();
        addSingle( block, "NOW", now );
        block.addBlock( new SpacerBlock( { :relativeToFontHeight => 0.20 } ) );

        if( state != null && state.hasGridPriceForecast() ) {
            var forecast = state.getGridPriceForecast();
            if( forecast != null ) {
                addAverages( block, forecast.getAveragePrices() );
                block.addBlock( new SpacerBlock( { :relativeToFontHeight => 0.20 } ) );
                var cheapestHour = forecast.getCheapestPeriod();
                if( cheapestHour != null ) {
                    addSingle( block, "MIN", cheapestHour.getCheapestPeriodAverage() );
                    addCheapestPeriod( block, cheapestHour.getCheapestPeriodStart(), cheapestHour.getCheapestPeriodEnd() );
                } else {
                    addSingle( block, "MIN", null );
                }
            }
        }

        // Add a small margin to the bottom. While the content is centered vertically between title and logo,
        // the spacing in the fonts make it seem a bit off, and this is to compensate for that.
        block.setOption( :marginBottom, dcHeight * 0.02 );
    }

    
    // Assemble one row of the table
    private function addCheapestPeriod( block as VerticalBlock, start as Moment, end as Moment ) as Void {
        var startInfo = Gregorian.info( start, Time.FORMAT_MEDIUM );
        var endInfo = Gregorian.info( end, Time.FORMAT_MEDIUM );
        block.addTextWithOptions( 
                startInfo.day_of_week.toString().toUpper() + " " 
                + StringFormatter.pad2( startInfo.hour ) + ":"
                + StringFormatter.pad2( startInfo.min ) + "-"
                + ( endInfo.day == startInfo.day ? "" : endInfo.day_of_week.toString().toUpper() + " " )
                + StringFormatter.pad2( endInfo.hour ) + ":" 
                + StringFormatter.pad2( endInfo.min ), 
            { :relativeFont => 4 } 
        );
    }


    // Assemble one row of the table
    private function addSingle( block as VerticalBlock, label as String, price as Float? ) as Void {
        var row = new HorizontalBlock( {} as DbOptions );
        row.addTextWithOptions( 
            label + ":", 
            { :relativeFont => 2, 
              :verticalJustifyToBaseFont => true,
              :color => EvccColors.ACCENT } 
        );
        row.addTextWithOptions( " " + formatPrice( price ), { :relativeFont => 0, :verticalJustifyToBaseFont => true } );
        row.addTextWithOptions( UNIT, { :relativeFont => 2, :verticalJustifyToBaseFont => true } );
        block.addBlock( row );
    }


    // Assemble one row of the table
    private function addAverages( block as VerticalBlock, prices as Array<Float?> ) as Void {

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

        for( var pi = 0; pi < prices.size(); pi++ ) {
            // Start with the label
            columns[ci][0].addTextWithOptions( 
                ( ci == 1 ? "      " : "" ) + LABELS[pi] + ":", 
                { 
                    :relativeFont => 2, 
                    :verticalJustifyToBaseFont => true, 
                    :justify => Graphics.TEXT_JUSTIFY_RIGHT,
                    :color => EvccColors.ACCENT
                } 
            );
            

            var price = prices[pi];

            // Then add the value
            columns[ci][1].addTextWithOptions( 
                " " + formatPrice( price ), 
                { :justify => Graphics.TEXT_JUSTIFY_RIGHT } 
            );

            // And finally the unit with the optional indicator
            columns[ci][2].addTextWithOptions( 
                UNIT, 
                { :relativeFont => 2,
                  :justify => Graphics.TEXT_JUSTIFY_LEFT,
                  :verticalJustifyToBaseFont => true } 
            );

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
    private function formatPrice( price as Float? ) as String {
        return 
            price != null 
                ? Math.round( price * 100.0 ).format( "%d" )
                : NA;
    }
}
