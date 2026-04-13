// (Abstract) parent class of all tasks
(:exclForViewPreRenderingDisabled)
class Task {
    function invoke() as Void;
    
    // Exception handler for this task
    private var _exceptionHandler as TaskExceptionState?;
    
    // Either handlers can be passed in directly, or any class that fullfils the
    // EvccHasTaskExceptionState interface (see below this class).
    // The interface is used to support a EvccSiteViewBase to be passed in and
    // its exception handler to be used
    public function initialize( handler as EvccHasTaskExceptionState or TaskExceptionState ) {
        if( handler instanceof TaskExceptionState ) {
            _exceptionHandler = ( handler as TaskExceptionState );
        } else {
            _exceptionHandler = ( handler as EvccHasTaskExceptionState ).getTaskExceptionState();
        }
    }

    // Return the exception handler
    public function getTaskExceptionState() as TaskExceptionState {
        return _exceptionHandler as TaskExceptionState;
    }
}

// Interface for any class that manages its own exception handler
(:exclForViewPreRenderingDisabled)
typedef EvccHasTaskExceptionState as interface {
    function getTaskExceptionState() as TaskExceptionState;
};
