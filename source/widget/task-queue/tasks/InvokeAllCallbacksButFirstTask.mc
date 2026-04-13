
import Toybox.Lang;

// Task for calling the invokeAllCallbacksButFirst function of an EvccStateRequest

// This class will instantiate its own exception handlers
// Thus, an exception will only be logged, but does not affect any further processing

(:exclForViewPreRenderingDisabled)
class InvokeAllCallbacksButFirstTask extends Task {
    private var _stateRequest as EvccStateRequest;

    public function initialize( stateRequest as EvccStateRequest ) {
        Task.initialize( new TaskExceptionState() );
        _stateRequest = stateRequest;
    }
    public function invoke() as Void {
        _stateRequest.invokeAllCallbacksButFirst();
    }
}