
public class Launchpad extends LEDController
{
    MidiIn min;
    MidiOut mout;
    
    IntIntProcedure grid;
    
    fun int led_mode( int R, int G, int Flash )
    {
        return 16*G + R + 4*Flash + 8;
    }

    fun void setLED( int X, int Y, int Mode )
    {
        MidiMsg msg;
       
        if( Y < 8 ) {
            144 => msg.data1;
            16*(7-Y)+X => msg.data2;
        } else {
            176 => msg.data1;
            104+X => msg.data2;
        }
       
        Mode => msg.data3;
       
        mout.send(msg);
    }

    fun void setGRID( int v[][] )
    {
        MidiMsg msg;
        for( 0 => int y; y < 8; y+1 => y )
        for( 0 => int x; x < 8; x+2 => x )
        {
            146 => msg.data1;
            v[x][7-y] => msg.data2;
            v[x+1][7-y] => msg.data3;
            mout.send(msg);
            //setLED(x,y,v[x][y]);
            //setLED(x+1,y,v[x+1][y]);
        }

        // restore side
        for( 0 => int y; y < 8; y+2 => y )
        {
            146 => msg.data1;
            v[8][7-y] => msg.data2;
            v[8][7-(y+1)] => msg.data3;
            mout.send(msg);
        }
    }

    fun void enableFlashing()
    {
        MidiMsg msg;
        176 => msg.data1;
        0 => msg.data2;
        40 => msg.data3;
        mout.send(msg);           
    }

    fun void disableFlashing()
    {
        // ???
    }

    fun void reset()
    {
        MidiMsg msg;
        176 => msg.data1;
        0 => msg.data2 => msg.data3;
        mout.send(msg);           
    }

    fun int open(int device)
    {
        min.open(device);
        mout.open(device);
        reset();
        enableFlashing();
        spork ~ handle();
    }

    fun void handle()
    {
        MidiMsg msg;
        while (true)
        {
            min => now;
            while (min.recv(msg))
            {
                msg.data1 => int control;
                msg.data2 => int note;
                msg.data3 => int velocity;
               
                if( velocity == 0 )
                    continue;
                   
                //<<< control, note, velocity >>>;
               
                if( control == 144 ) // Note hit
                {
                    note%16 => int X;
                    note/16 => int Y;
                    if( X < 9 )
                        spork ~ grid.run(X,7-Y);
                }
                if( control == 176 ) // Top note hit
                {
                    note-104 => int X;
                    if( X >= 0 && X <= 7)
                        spork ~ grid.run(X, 8);
                }
            }
        }
    }
   
   
}
