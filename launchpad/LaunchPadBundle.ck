public class Bundle
{
    int vals[9][8];
    int mode[9][8];

    0 => int DISABLE; // Ignore
    1 => int INSTANT; // One instantaneous note-on, no note-off sent.

    // Send note-on when hit first time, then note-off next time
    2 => int TOGGLE_ON; 
    3 => int TOGGLE_OFF; // Send note-on when hit first time, then note-off next time

    // Note on when pressed, then note-off when removed
    4 => int HOLD_ON; 
    5 => int HOLD_OFF;
    HOLD_OFF   => int HOLD;
    TOGGLE_OFF => int TOGGLE;
    true => int hidden;

    {
        for( 0 => int x; x < 9; x+1 => x )
        for( 0 => int y; y < 8; y+1 => y )
            12 => vals[x][y];
        
        setModeAll(DISABLE);
    }

    fun void setModeAll( int m )
    {
        <<< m >>>;
        setModeRange(0,0,9,8, m);
    }
    
    fun void setModeRange( int x_min, int y_min, int x_max, int y_max, int m )
    {
        for( x_min => int x; x < x_max; x+1 => x )
        for( y_min => int y; y < y_max; y+1 => y )
            m => mode[x][y];
    }
    
    fun void notify(LEDController led, int x, int y, int on)
    {
        if( mode[x][y] == INSTANT && on )
        {
            if( x == 8 ) 
                side( led, y, 1 );
            else 
                handle( led, x, y, 1 );
            return;
        } 

        if( mode[x][y] == TOGGLE_OFF && on )
        {
            TOGGLE_ON => mode[x][y];
            if( x == 8 ) 
                side( led, y, 1 );
            else 
                handle( led, x, y, 1 );
            return;
        } 

        if( mode[x][y] == TOGGLE_ON && on )
        {
            TOGGLE_OFF => mode[x][y];
            if( x == 8 ) 
                side( led, y, 0 );
            else 
                handle( led, x, y, 0 );
            return;
        } 

        if( mode[x][y] == HOLD_OFF && on )
        {
            HOLD_ON => mode[x][y];
            if( x == 8 ) 
                side( led, y, 1 );
            else 
                handle( led, x, y, 1 );
            return;
        } 

        if( mode[x][y] == HOLD_ON && !on )
        {
            HOLD_OFF => mode[x][y];
            if( x == 8 ) 
                side( led, y, 0 );
            else 
                handle( led, x, y, 0 );
            return;
        }
    }
    
    fun void background()
    {
        true => hidden;
    }

    fun void forground()
    {
        false => hidden;
    }
    
    fun void restore(LEDController led)
    {
        led.setGRID(vals);
    }
    
    fun void set( LEDController led, int x, int y, int c )
    {
        if( !hidden && vals[x][y] != c ) led.setLED(x,y,c);
        c => vals[x][y];
    }
        
    fun void setSide( LEDController led, int y, int c )
    {
        set( led, 8, y, c );
    }

    // Implement this
    fun void handle( LEDController led, int x, int y, int on )
    {
        if( on )
            set(led, x, y, led.R3);
        if( !on )
            set(led, x, y, led.OFF);
    }
    
    // Implement this
    fun void side( LEDController led, int y, int on )
    {
    }
    
}
