import Toybox.Lang;

// Task for calling the initOrUpdateDetailViews function of an EvccWidgetMainView

(:exclForViewPreRenderingDisabled)
class EvccInitOrUpdateDetailViewsTask extends EvccTask {
    private var _view as EvccWidgetMainView;
    public function initialize( view as EvccWidgetMainView ) {
        EvccTask.initialize( view );
        _view = view;
    }
    public function invoke() as Void {
        var detailViewManager = _view.getDetailViewManager();
        if( detailViewManager != null ) {
            detailViewManager.initOrUpdateDetailViews( false );
        } else {
            throw new OperationNotAllowedException( "EvccAddDetailViewsTask: invoked on a main view without detail views." );
        }
    }
}