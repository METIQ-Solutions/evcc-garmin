import Toybox.Lang;

// Task for calling the taskPrepare function of an SiteShellPreRenderer

(:exclForViewPreRenderingDisabled)
class PreRenderShellTask extends Task {
    private var _preRenderer as SiteShellPreRenderer;
    public function initialize( preRenderer as SiteShellPreRenderer, exHandler as TaskExceptionState ) {
        Task.initialize( exHandler );
        _preRenderer = preRenderer;
    }
    public function invoke() as Void {
        _preRenderer.taskPrepare();
    }
}