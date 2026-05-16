import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Application;
import Toybox.Lang;
import Toybox.System;

// Simple view for showing version of the app and some other device settings
class SystemInfoView extends WatchUi.View {
    private var _spacing as Number = 0;

    function initialize() {
        View.initialize();
        _spacing = EvccResources.getFontHeight( WidgetResourceSet.FONT_XTINY ) / 2;
    }

    // Draw the content
    function onUpdate( dc as Dc ) as Void {
            WidgetUiHelper.clearDc( dc );
            var block = new HorizontalBlock( { :font => WidgetResourceSet.FONT_XTINY } );
            var column1 = new VerticalBlock( {} );
            var column2 = new VerticalBlock( {} );

            addLine( column1, column2, "APP", TextProvider.getVersion(), true );
            addLine( column1, column2, "CIQ", "v" + Lang.format("$1$.$2$.$3$", System.getDeviceSettings().monkeyVersion ), false );
            addLine( column1, column2, "PART", "#" + System.getDeviceSettings().partNumber, false );

            block.addBlock( column1 );
            block.addBlock( column2 );

            // Show font mode and if icons are the correct size
            checkFonts( column1, column2, dc );
            
            block.draw( dc, dc.getWidth() / 2, dc.getHeight() / 2 );
    }

    // Adds one line to the output
    private function addLine( column1 as VerticalBlock, column2 as VerticalBlock, label as String, content as String, first as Boolean ) as Void {
        var spacing = first ? 0 : _spacing;
        column1.addTextWithOptions( 
            label + ":", 
            { :relativeFont => 1, 
              :color => EvccColors.ACCENT, 
              :justify => Graphics.TEXT_JUSTIFY_RIGHT,
              :verticalJustifyToBaseFont => true,
              :marginTop => spacing } 
        );
        column2.addTextWithOptions(
            " " + content,
            { :color => EvccColors.CONTENT,
              :justify => Graphics.TEXT_JUSTIFY_LEFT,
              :marginTop => spacing } 
        );
    } 

    // The checkFonts functions checks if the icon sizes match the
    // font sizes choosen by the app, and in any case outputs the 
    // correct icon sizes on the debug console
    
    // in :release scope, checkFonts is only a dummy
    (:release) private function checkFonts( column1 as VerticalBlock, column2 as VerticalBlock, dc as Dc ) as Void {}

    (:debug) private var _debugDone as Boolean = false;
    // For full-glance devices we also check the glance icons
    (:debug) private function checkFonts( column1 as VerticalBlock, column2 as VerticalBlock, dc as Dc ) as Void {
        if( ! _debugDone ) { Logger.info( "Icon sizes:" ); }
        addLine( column1, column2, "FONTS", fontMode(), false );
        checkIcons( new WidgetResourceSet(), column1, column2, dc );
        checkIcons( new GlanceResourceSet(), column1, column2, dc );
        _debugDone = true;
    }

    // Checking the icons for a given UI lib (glance or widget)
    // We don't use the standard type ResourceSet, because we
    // for tiny glances we create our own debug resource set, which
    // is not included in that type
    (:debug) private function checkIcons( uiLib as WidgetResourceSet or GlanceResourceSet, column1 as VerticalBlock, column2 as VerticalBlock, dc as Dc ) as Void {
        var fonts = uiLib.fonts as ArrayOfGarminFonts;
        var icons = uiLib.icons as EvccIcons;
        var fontSizeNames = new Array<String>[0];
        var label = "";
        var state = "OK";

        // Define font names and prefix for debug output for
        // widget and glance
        if( uiLib instanceof WidgetResourceSet ) {
            fontSizeNames = [ "medium", "small", "tiny", "xtiny", "micro" ];
            label = "WG ICONS";
            // For widget, we also derive a recommendation for the logo size from the xtiny font size
            if( ! _debugDone ) { 
                Logger.info( "logo_evcc=" + Math.round( dc.getFontHeight( fonts[3]) * 0.60 ).toNumber() + " (recommendation only)" );
            }
        } else {
            fontSizeNames = [ "glance" ];
            label = "GL ICONS";
        }

        // Cycle through all font sizes and compare them with
        // an icon of that size
        for( var i = 0; i < fonts.size(); i++ ) {
            var fontHeight = dc.getFontHeight( fonts[i]);
            var debug = "icon_" + fontSizeNames[i] + "=" + fontHeight;
            
            var bitmap = null;
            for( var j = 0; j < icons.size(); j++ ) {
                if( icons[j][i] != null ) {
                    bitmap = WatchUi.loadResource( icons[j][i] as ResourceId ) as DbBitmap;
                }
            }
        
            if( bitmap != null ) {
                var bmHeight = bitmap.getHeight();
                if( bmHeight != fontHeight ) {
                    debug += " (mismatch! icon size=" + bmHeight + ")";
                    state = "MISMATCH";
                }
            } else {
                state = "MISSING";
            }
            if( ! _debugDone ) { Logger.info( debug ); }
        } 
        addLine( column1, column2, label, state, true );
    }

    (:debug :exclForFontsStatic :exclForFontsStaticOptimized) function fontMode() as String { return "VECTOR"; }
    (:debug :exclForFontsVector :exclForFontsStatic) function fontMode() as String { return "STATIC-OPT"; }
    (:debug :exclForFontsVector :exclForFontsStaticOptimized) function fontMode() as String { return "STATIC"; }

}