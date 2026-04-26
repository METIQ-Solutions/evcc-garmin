import Toybox.Graphics;
import Toybox.Lang;
using Toybox.Time.Gregorian;

// View showing solar forecast data
class SolarForecastView extends EvccSiteViewBase {
    private var _label as Array<String>;
    private var _indicator as Array<String?>;

    function initialize( options as EvccSiteViewBase.Options ) {
        EvccSiteViewBase.initialize( options );

        // Define the labels for the rows
        // Third label is the three-character short code for the weekday
        _label = [ "tday", "tmrw" ];
        var dat = Gregorian.info(Time.now().add( Gregorian.duration({:days => 2})), Time.FORMAT_MEDIUM);
        _label.add( dat.day_of_week.toString().toLower() );
        
        // Define indicators to be shown in small font at the end of each line
        _indicator = [ "rem.", null, "ptly" ];
    }

    // Show the forecast icon as page title
    // Set icon and title for this page
    function getPageTitle() as TextBlock? {
        return new TextBlock( "forecast", { :color => Graphics.COLOR_LT_GRAY } );
    }
    function getPageIcon() as IconBlock? {
        return new IconBlock( IconBlock.ICON_FORECAST, {} );
    }

    // Add the content
    function addContent( block as VerticalBlock, calcDc as EvccDcInterface ) {

        var state = getWebRequest().getState();
        var dcHeight = calcDc.getHeight();

        if( state != null && state.hasSolarForecast() ) {

            var forecast = state.getSolarForecast();

            if( forecast != null ) {
                // Check if scale is available and configured to be applied
                // Otherwise set scale=1
                var applyScale = new SiteConfig( getSiteIndex() ).scaleForecast() && forecast.getScale() != null;
                var scale = applyScale ? forecast.getScale() : 1.0;

                var energy = forecast.getEnergy();

                // The actual forecast is added in a separate function, since
                // there are two versions used for different devices
                addForecast( block, energy, scale );

                if( applyScale ) {
                    block.addTextWithOptions( 
                        "adj. w\\ real data", 
                        { :relativeFont => 4, 
                          :marginTop => dcHeight * 0.007,
                          :color => Graphics.COLOR_LT_GRAY } 
                    );
                }

            }
        } else {
            block.addText( "No forecast" );
        }

        // Add a small margin to the bottom. While the content is centered vertically between title and logo,
        // the spacing in the fonts make it seem a bit off, and this is to compensate for that.
        block.setOption( :marginBottom, dcHeight * 0.02 );
    }

    
    // Assemble one row of the table
    function addForecast( block as VerticalBlock, energy as Array<Float>, scale as Float ) as Void {

        var row = new HorizontalBlock( {} as DbOptions );
        var column1 = new VerticalBlock( {} as DbOptions );
        var column3 = new VerticalBlock( {} as DbOptions );
        var column2 = new VerticalBlock( {} as DbOptions );

        for( var i = 0; i < energy.size(); i++ ) {
            // Start with the label
            column1.addTextWithOptions( 
                _label[i] + ":", 
                { :relativeFont => 2, 
                  :verticalJustifyToBaseFont => true, 
                  :justify => Graphics.TEXT_JUSTIFY_RIGHT,
                  :color => Graphics.COLOR_LT_GRAY } 
            );
            
            // Then add the value
            column2.addTextWithOptions( " " + formatEnergy( energy[i] * scale ) + " ", { :justify => Graphics.TEXT_JUSTIFY_RIGHT } );

            // And finally the unit with the optional indicator
            var unit = new HorizontalBlock( { :justify => Graphics.TEXT_JUSTIFY_LEFT} );
            unit.addTextWithOptions( "kWh", { :relativeFont => 2, :verticalJustifyToBaseFont => true } );
            if( _indicator[i] != null ) {
                unit.addTextWithOptions( 
                    " " + _indicator[i], 
                    { :relativeFont => 4, 
                      :verticalJustifyToBaseFont => true,
                      :color => Graphics.COLOR_LT_GRAY } 
                );
            }
            column3.addBlock( unit );
        }

        row.addBlock( column1 );
        row.addBlock( column2 );
        row.addBlock( column3 );
        
        block.addBlock( row );
    }

    // Forecast is limited by width not the default height
    function limitHeight() as Boolean { return false; }
    function limitWidth() as Boolean { return true; }

    // Function to format energy values for the forecast view
    // Digits is the number of digits to be displayed before the
    // decimal point - if there are less it will be filled with
    // zeros
    private function formatEnergy( energy as Float ) as String {
        return ( Math.round( energy / 100.0 ) / 10 ).format( "%.1f" );    
    }
}
