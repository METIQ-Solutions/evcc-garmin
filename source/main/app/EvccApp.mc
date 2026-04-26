import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Math;

// Main class of the app, responsible for initializing
// views and other components
(:glance) class EvccApp extends Application.AppBase {
    
    private static var _glanceView as EvccGlanceView?;
    public static var isGlance as Boolean = false;
    
    function initialize() {
        try {
            // Logger.debug( "EvccApp: initialize" );
            AppBase.initialize();
        } catch ( ex ) {
            Logger.debugException( ex );
        }
    }

    // Called if the app runs in glance mode
    (:typecheck(disableBackgroundCheck)) 
    function getGlanceView() as [ GlanceView ] or [ GlanceView, GlanceViewDelegate ] or Null {
        isGlance = true;
        var glanceView = GetGlanceView.getGlanceView() as [ GlanceView ];
        if( glanceView[0] instanceof EvccGlanceView ) {
            _glanceView = glanceView[0] as EvccGlanceView; 
        }
        return glanceView;
    }

    // For standard devices, a custom ViewStack is used,
    // and the initial view has to be registered with it
    (:typecheck([disableGlanceCheck]))
    function getInitialView() as [Views] or [Views, InputDelegates] {
        var view = GetInitialView.getInitialView();
        ViewStack.registerInitialView( view[0], view[1] );
        return view;
    }

    // If a new version of the app is installed,
    // we clear the storage, just in case the new
    // version is using a new structure for storing
    // data
    (:release) 
    public function onAppUpdate() as Void {
        try {
            // Logger.debug( "EvccApp: onAppUpdate" );
            Storage.clearValues();
        } catch ( ex ) {
            Logger.debugException( ex );
       }
    }

    // Clear the storage if the settings where changed
    public function onSettingsChanged() as Void {
        // Logger.debug( "EvccApp.onSettingsChanged" );
        Storage.clearValues();
    }

    // Called when the app is stopped
    // The onHide() function of the views takes care
    // of required clean-ups. For glances, onHide() is
    // not called automatically, so we do this here
    (:typecheck([disableGlanceCheck]))
    public function onStop( state as Lang.Dictionary or Null ) as Void {
        try {
            // Logger.debug( "EvccApp: onStop" );
            hideGlance();
            if( ! isGlance ) {
                WebRequestRegistry.stop();
            }
        } catch ( ex ) {
            Logger.debugException( ex );
       }
    }

    (:typecheck([disableGlanceCheck]))
    private function hideGlance() as Void {
        if( _glanceView != null ) {
            // Logger.debug( "EvccApp: onStop: glance mode, calling onHide" );
            _glanceView.onHide();
        }
    }
}