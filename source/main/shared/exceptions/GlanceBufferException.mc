import Toybox.Lang;

// Exception indicating that for a site a user name
// is specified but the password is missing
(:glance) class GlanceBufferException extends EvccBaseException {
    function initialize() {
        EvccBaseException.initialize();
    }
    public function getScreenMessage() as String { 
        return "Glance buffer failed"; 
    }
}
