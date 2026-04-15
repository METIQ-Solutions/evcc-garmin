import Toybox.Lang;

// This class is intended to be re-used for all tasks associated
// with the same view (or any other entity that schedules tasks)
// It holds one exception (the latest that occured), and provides
// accessors to check if there is an exception.

class TaskExceptionState {
    
    private var _exception as Exception?;
    
    // Registered exceptions are printed in the debug output
    // and stored
    public function registerException( ex as Exception ) as Void {
        _exception = ex;
        Logger.debugException( ex );
    }
    
    // Returns whether there is an exception
    public function hasException() as Boolean {
        return _exception != null;
    }
    
    // If there is one, throws the exception
    public function checkForException() as Void {
        if( _exception != null ) {
            throw _exception;
        }
    }

    // If there is one, throws the exception
    public function clearException() as Void {
        _exception = null;
    }
}