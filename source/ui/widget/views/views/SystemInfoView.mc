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
    }

    // Draw the content
    function onUpdate( dc as Dc ) as Void {
            HelperWidget.clearDc( dc );
            var block = new VerticalBlock( { :font => WidgetResourceSet.FONT_XTINY } );
            block.addText( "evccg " + HelperUI.getVersion() );

            _spacing = EvccResources.getFontHeight( WidgetResourceSet.FONT_XTINY ) / 2;

            var monkeyVersion = Lang.format("$1$.$2$.$3$", System.getDeviceSettings().monkeyVersion );

            block.addTextWithOptions( "monkey v" + monkeyVersion, { :marginTop => _spacing } );

            block.addTextWithOptions( "part # " + System.getDeviceSettings().partNumber, { :marginTop => _spacing } );

            // Show font mode and if icons are the correct size
            checkFonts( block, dc );
            
            block.draw( dc, dc.getWidth() / 2, dc.getHeight() / 2 );
    }

    // The checkFonts functions checks if the icon sizes match the
    // font sizes choosen by the app, and in any case outputs the 
    // correct icon sizes on the debug console
    
    // in :release scope, checkFonts is only a dummy
    (:release) function checkFonts( block as VerticalBlock, dc as Dc ) as Void {}

    (:debug) private var _debugDone as Boolean = false;
    // For full-glance devices we also check the glance icons
    (:debug) function checkFonts( block as VerticalBlock, dc as Dc ) as Void {
        if( ! _debugDone ) { HelperBase.info( "Icon sizes:" ); }
        block.addTextWithOptions( "fonts: " + fontMode(), { :marginTop => _spacing } );
        checkFontsDeviceSpecific( block, dc );
        _debugDone = true;
    }

    // For glance devices we also check the glance icons
    // Note that GlanceResourceSet does not exist for tiny glance devices
    // Therefore it is added at the end of this class, only for tiny glance and in
    // debug scope
    (:debug) function checkFontsDeviceSpecific( block as VerticalBlock, dc as Dc ) as Void {
        checkIcons( new WidgetResourceSet(), block, dc );
        checkIcons( new GlanceResourceSet(), block, dc );
    }

    // Checking the icons for a given UI lib (glance or widget)
    // We don't use the standard type ResourceSet, because we
    // for tiny glances we create our own debug resource set, which
    // is not included in that type
    (:debug) function checkIcons( uiLib as WidgetResourceSet or GlanceResourceSet, block as VerticalBlock, dc as Dc ) as Void {
        var fonts = uiLib.fonts as ArrayOfGarminFonts;
        var icons = uiLib.icons as EvccIcons;
        var text = "icons: OK";
        var fontSizeNames = new Array<String>[0];
        var prefix = "";

        // Define font names and prefix for debug output for
        // widget and glance
        if( uiLib instanceof WidgetResourceSet ) {
            fontSizeNames = [ "medium", "small", "tiny", "xtiny", "micro" ];
            prefix = "w";
            // For widget, we also derive a recommendation for the logo size from the xtiny font size
            if( ! _debugDone ) { 
                HelperBase.info( "logo_evcc=" + Math.round( dc.getFontHeight( fonts[3]) * 0.60 ).toNumber() + " (recommendation only)" );
            }
        } else {
            fontSizeNames = [ "glance" ];
            prefix = "g";
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
                    text = "icons: mismatch";
                }
            } else {
                text = "icons: icon missing";
            }
            if( ! _debugDone ) { HelperBase.info( debug ); }
        } 
        block.addText( prefix + "-" + text );
    }

    (:debug :exclForFontsStatic :exclForFontsStaticOptimized) function fontMode() as String { return "vector"; }
    (:debug :exclForFontsVector :exclForFontsStatic) function fontMode() as String { return "static-opt"; }
    (:debug :exclForFontsVector :exclForFontsStaticOptimized) function fontMode() as String { return "static"; }

}