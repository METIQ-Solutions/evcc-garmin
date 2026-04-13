import Toybox.Lang;
import Toybox.WatchUi;

/*
 * The `ViewStack` must be used throughout the app for switching views
 * or pushing and popping them from the stack.
 *
 * It maintains its own view stack, independent of the system API stack.
 * This allows the app to track how many views are currently active so that,
 * in case of an update or an error, all views can be removed and replaced
 * with the home view or an error view.
 *
 * The initial implementation only tracked the number of active views.
 * Due to bugs in the WatchUi.getCurrentView() implementation on some
 * newer Garmin devices, this was replaced with a fully managed
 * parallel view stack.
 *
 * For details about the underlying issue, see:
 * https://github.com/openhab/openhab-garmin/issues/215
 */
(:exclForMemoryLow)
 class ViewStack {
    
    // Tuple used to store each view/delegate layer in the view stack
    typedef ViewInputPair as [ WatchUi.Views?, WatchUi.InputDelegates? ];

    // The view stack
    private static var _viewStack as Array<ViewInputPair> = [];

    // Returns the current view and delegate, replacing WatchUi.getCurrentView().
    // Replacing that API was the primary reason for introducing our own view stack. 
    // See the class-level comment above for details.
    public static function getCurrentView() as [ WatchUi.Views?, WatchUi.InputDelegates? ] {
        EvccHelperBase.debug( "ViewStack.getCurrentView" );
        return _viewStack.size() > 0 
               ? _viewStack[_viewStack.size()-1]
               : [null, null];
    }
    
    // Pops a view from the stack, replacing WatchUi.popView().
    public static function popView( transition as SlideType ) as Void {
        EvccHelperBase.debug( "ViewStack.popView" );
        WatchUi.popView( transition );
        _viewStack = _viewStack.slice( 0, _viewStack.size() - 1 );
    }

    // Pushes a view onto the stack, replacing WatchUi.pushView().
    public static function pushView( view as Views, delegate as InputDelegates?, transition as SlideType ) as Void {
        EvccHelperBase.debug( "ViewStack.pushView" );
        WatchUi.pushView( view, delegate, transition );
        _viewStack.add( [ view, delegate ] );
    }

    // This function must be called in OHApp.getInitialView() to store the initial view.
    // The initial view only needs to be stored, since the API automatically
    // pushes it onto the stack when it is returned from getInitialView().
    public static function registerInitialView( view as Views, delegate as InputDelegates? ) as Void {
        EvccHelperBase.debug( "ViewStack.registerInitialView" );
        _viewStack.add( [ view, delegate ] );
    }

    // Switches the view on the top of the view stack, replaces ViewStack.switchToView()
    public static function switchToView( view as Views, delegate as InputDelegates?, transition as SlideType ) as Void {
        EvccHelperBase.debug( "ViewStack.switchToView" );
        WatchUi.switchToView( view, delegate, transition );
        _viewStack[_viewStack.size()-1] = [view, delegate];
    }

}
