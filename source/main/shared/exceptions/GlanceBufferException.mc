import Toybox.Lang;

(:glance) class GlanceBufferException extends EvccBaseException {
    function initialize() {
        EvccBaseException.initialize();
    }
    public function getScreenMessage() as String { 
        return "Glance buffer failed"; 
    }
}
