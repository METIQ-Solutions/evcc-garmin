// This class extends the basic representation of site content,
// adding capability to split the pre-calculations in tasks and
// add those to the task queue
class SiteContentPreRenderer extends SiteContent {
    var _contentUnderPreparation as VerticalBlock?;
    
    public function initialize( view as EvccSiteViewBase ) {
        SiteContent.initialize( view );
    }

    // Each step needs its own function
    public function taskAssemble() as Void {
        // HelperBase.debug( "SiteContentPreRenderer: taskAssemble" );
        _contentUnderPreparation = assembleInternal( DcStub.getInstance() );
    }
    public function taskPrepare() as Void {
        // HelperBase.debug( "SiteContentPreRenderer: taskPrepare" );
        var ca = _view.getContentArea();
        ( _contentUnderPreparation as VerticalBlock).prepareDrawByTasks( ca.x, ca.y, _view.getTaskExceptionState() );
    }
    public function taskFinalize() as Void {
        // HelperBase.debug( "SiteContentPreRenderer: taskFinalize" );
        _content = _contentUnderPreparation;
        _contentUnderPreparation = null;
    }
    
    // Queue all the steps
    public function queueTasks() as Void {
        var taskQueue = TaskQueue.getInstance();
        taskQueue.add( new PreRenderContentTask( self, :taskAssemble, _view ) );
        taskQueue.add( new PreRenderContentTask( self, :taskPrepare, _view ) );
        taskQueue.add( new PreRenderContentTask( self, :taskFinalize, _view ) );
    }

    // Bypass the queue and prepare everything right away
    public function immediatePrepare() as Void {
        var content = assembleInternal( DcStub.getInstance() );
        var ca = _view.getContentArea();
        content.prepareDraw( ca.x, ca.y );
        _content = content;
    }
}