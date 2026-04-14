import Toybox.Lang;

// Task for calling one of the three pre-rendering functions of the SiteContentPreRenderer

(:exclForViewPreRenderingDisabled)
class PreRenderContentTask extends Task {
    private var _preRenderer as SiteContentPreRenderer;
    private var _method as Symbol;
    public function initialize( preRenderer as SiteContentPreRenderer, method as Symbol, hasExHandler as EvccHasTaskExceptionState ) {
        Task.initialize( hasExHandler );
        _preRenderer = preRenderer;
        _method = method;
    }
    public function invoke() as Void {
        // HelperBase.debug( "PrepareDrawTask: executing prepareDraw" );
        if( _method == :taskAssemble ) {
            _preRenderer.taskAssemble();
        } else if ( _method == :taskPrepare ) {
            _preRenderer.taskPrepare();
        } else if ( _method == :taskFinalize ) {
            _preRenderer.taskFinalize();
        } else {
            throw new InvalidOptionsException( "MTHDUN");
        }

    }
}
