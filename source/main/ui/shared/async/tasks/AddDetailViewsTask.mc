import Toybox.Lang;

// Task for calling the initOrUpdateDetailViews function of an MainView

(:exclForViewPreRenderingDisabled)
class InitOrUpdateDetailViewsTask extends Task {
    private var _view as MainView;
    public function initialize( view as MainView ) {
        Task.initialize( view );
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