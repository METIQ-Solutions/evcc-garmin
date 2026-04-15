import Toybox.Lang;
import Toybox.Math;

/*
 * Provides additional mathematical functions not available in the API's Math class.
 */
 (:glance) 
class ExtendedMath {

    // Returns the larger of two given values
    public static function max( a as Numeric, b as Numeric ) as Numeric { 
        return a > b ? a : b; 
    }

    // Returns the largest of a list of values
    // Currently not needed
    /*
    public static function maxn( n as Array<Numeric> ) as Numeric { 
        var max = 0;
        for( var i = 0; i < n.size(); i++ ) {
            max = ExtendedMath.max( max, n[i] );
        }
        return max;
    }
    */

    // Returns the smaller of two given values
    public static function min( a as Numeric, b as Numeric ) as Numeric { 
        return a < b ? a : b; 
    }


    // Rounds a power value to the nearest 100 Watt number
    static function roundPower( power as Number? ) as Number {
        if( power == null ) { power = 0; }
        return Math.round( power / 100.0 ).toNumber() * 100;
    }

}