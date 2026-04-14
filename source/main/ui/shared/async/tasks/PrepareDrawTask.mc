import Toybox.Lang;

// Task for calling the prepareDraw function of an DrawingBlockBase

(:exclForViewPreRenderingDisabled :typecheck(disableGlanceCheck))
class PrepareDrawTask extends Task {
    private var _element as DrawingBlockBase;
    private var _x as Number;
    private var _y as Number;
    public function initialize( element as DrawingBlockBase, x as Number, y as Number, exHandler as TaskExceptionState ) {
        Task.initialize( exHandler );
        _element = element; _x = x; _y = y;
    }
    public function invoke() as Void {
        // HelperBase.debug( "PrepareDrawTask: executing prepareDraw" );
        _element.prepareDraw( _x, _y );
    }
}