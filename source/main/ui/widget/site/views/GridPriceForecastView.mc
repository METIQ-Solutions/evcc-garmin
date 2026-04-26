import Toybox.Graphics;
import Toybox.Lang;
using Toybox.Time.Gregorian;

// View showing grid price forecast data
class GridPriceForecastView extends EvccSiteViewBase {
    private const LABELS = [ "now", "+1h", "+2h", "tday", "tmrw" ];

    function initialize( options as EvccSiteViewBase.Options ) {
        EvccSiteViewBase.initialize( options );
    }

    // Show the forecast icon as page title
    // Set icon and title for this page
    function getPageTitle() as TextBlock? {
        return new TextBlock( "grid price", {} as DbOptions );
    }
    function getPageIcon() as IconBlock? {
        return new IconBlock( IconBlock.ICON_FORECAST, {} as DbOptions );
    }

    // Add the content
    function addContent( block as VerticalBlock, calcDc as EvccDcInterface ) {

        var state = getWebRequest().getState();
        var dcHeight = calcDc.getHeight();

        if( state != null && state.hasGridPriceForecast() ) {
            var prices = new Array<Float>[0];
            var currentPrice = state.getGridTariff();
            if( currentPrice != null ) {
                prices.add( currentPrice );
            } else {
                throw new InvalidValueException( "Current price is missing." );
            }
            var forecast = state.getGridPriceForecast();
            if( forecast != null ) {
                prices.addAll( forecast.getAveragePrices() );
                addAverages( block, prices );
            }
        } else {
            block.addText( "No grid prices" );
        }

        // Add a small margin to the bottom. While the content is centered vertically between title and logo,
        // the spacing in the fonts make it seem a bit off, and this is to compensate for that.
        block.setOption( :marginBottom, dcHeight * 0.02 );
    }

    
    // Assemble one row of the table
    function addAverages( block as VerticalBlock, price as Array<Float> ) as Void {

        var row = new HorizontalBlock( {} as DbOptions );
        var column1 = new VerticalBlock( {} as DbOptions );
        var column2 = new VerticalBlock( {} as DbOptions );
        var column3 = new VerticalBlock( {} as DbOptions );

        for( var i = 0; i < price.size(); i++ ) {
            // Start with the label
            column1.addTextWithOptions( LABELS[i] + ":", { :relativeFont => 2, :verticalJustifyToBaseFont => true, :justify => Graphics.TEXT_JUSTIFY_RIGHT} );
            
            // Then add the value
            column2.addTextWithOptions( " " + formatPrice( price[i] ) + " ", { :justify => Graphics.TEXT_JUSTIFY_RIGHT } );

            // And finally the unit with the optional indicator
            var unit = new HorizontalBlock( { :justify => Graphics.TEXT_JUSTIFY_LEFT} );
            unit.addTextWithOptions( "ct", { :relativeFont => 2, :verticalJustifyToBaseFont => true } );
            column3.addBlock( unit );
        }

        row.addBlock( column1 );
        row.addBlock( column2 );
        row.addBlock( column3 );
        
        block.addBlock( row );
    }

    // Function to prices for the forecast view
    private function formatPrice( price as Float ) as String {
        return Math.round( price * 100.0 ).format( "%.1f" );    
    }
}
