
import Toybox.Lang;

// Task for calling the invokeAllCallbacksButFirst function of an WebRequest

// This class will instantiate its own exception handlers
// Thus, an exception will only be logged, but does not affect any further processing

class InvokeAllCallbacksButFirstTask extends Task {
    private var _stateRequest as WebRequest;

    public function initialize( stateRequest as WebRequest ) {
        Task.initialize( new TaskExceptionState() );
        _stateRequest = stateRequest;
    }
    public function invoke() as Void {
        _stateRequest.invokeAllCallbacksButFirst();
    }
}