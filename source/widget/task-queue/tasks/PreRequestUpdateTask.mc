import Toybox.Lang;

// Task for calling the requestUpdate function of the WatchUi

(:exclForViewPreRenderingDisabled)
class RequestUpdateTask extends Task {
    public function initialize( hasExHandler as EvccHasTaskExceptionState ) {
        Task.initialize( hasExHandler );
    }
    public function invoke() as Void {
        WatchUi.requestUpdate();
    }
}