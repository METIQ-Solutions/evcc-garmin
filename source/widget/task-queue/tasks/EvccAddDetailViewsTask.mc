import Toybox.Lang;

// Task for calling the initOrUpdateDetailViews function of an EvccWidgetMainView

(:exclForViewPreRenderingDisabled)
class EvccinitOrUpdateDetailViewsTask extends EvccTask {
    private var _view as EvccWidgetMainView;
    public function initialize( view as EvccWidgetMainView ) {
        EvccTask.initialize( view );
        _view = view;
    }
    public function invoke() as Void {
        _view.initOrUpdateDetailViews( false );
    }
}