// This class extends the basic representation of site content,
// adding capability to split the pre-calculations in tasks and
// add those to the task queue
class SiteShellPreRenderer extends SiteShell {
    
    public function initialize( view as EvccSiteViewBase ) {
        SiteShell.initialize( view );
    }

    // Only one task here
    public function taskPrepare() as Void {
        // Logger.debug( "SiteShellPreRenderer: taskPrepare" );
        prepare( DcStub.getInstance() );
    }

    // Queue the task
    public function queueTasks() as Void {
        var taskQueue = TaskQueue.getInstance();
        taskQueue.add( new PreRenderShellTask( self, _view.getTaskExceptionState() ) );
    }

    // Bypass the queue and prepare everything right away
    public function immediatePrepare() as Void {
        prepare( DcStub.getInstance() );
    }
}
