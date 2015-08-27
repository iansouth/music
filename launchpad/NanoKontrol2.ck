public class NanoKontrol2
{
    MidiIn min;
    MidiOut mout;
    
    IntIntFloatProcedure control;    
    
     0 => int G_slider;
    16 => int G_knob;
    32 => int G_solo;
    48 => int G_mute;
    64 => int G_rec;
    
    // Toggle
    32+10 => int stop;
    32+9  => int play;
    32+13 => int rec;
    
    // Momentary
    32+11 => int rew;
    32+12 => int ff;
    32+14 => int cycle;
    48+10 => int prev_track;
    48+11 => int next_track;
    48+12 => int set_marker;
    48+13 => int prev_marker;
    48+14 => int next_marker;
   
    fun void LED_on( int button )
    {
        MidiMsg msg;
        191    => msg.data1;
        button => msg.data2;
        127    => msg.data3;
        mout.send(msg);
    }

    fun void LED_off( int button )
    {
        MidiMsg msg;
        191    => msg.data1;
        button => msg.data2;
        0      => msg.data3;
        mout.send(msg);
    }

    fun void group_LED_on( int group, int button )
    {
        MidiMsg msg;
        191    => msg.data1;
        button+group => msg.data2;
        127    => msg.data3;
        mout.send(msg);
    }

    fun void group_LED_off( int group, int button )
    {
        MidiMsg msg;
        191    => msg.data1;
        button+group => msg.data2;
        0      => msg.data3;
        mout.send(msg);
    }

    fun void handle()
    {
        MidiMsg msg;
        while (true)
        {
            min => now;
            
            while (min.recv(msg))
            {
                msg.data1 => int c;
                msg.data2 => int b;
                msg.data3 => int v;
                //<<< "msg" >>>;
                // Skip momentary button note-off messages
                if( v == 0 && 
                    ( b == rew || b == ff || b == cycle || (prev_track <= b && b <= next_marker ))
                    )
                    continue;
                                  
                if( c == 176 ) // Note hit
                {
                    b-G_slider => int gl;
                    b-G_knob => int gk;
                    b-G_solo => int gs;
                    b-G_mute => int gm;
                    b-G_rec  => int gr;
                    if( 0 <= gl && gl < 8 )
                        spork ~ control.run(gl, G_slider, v/127.0);
                    else if( 0 <= gk && gk < 8 )
                        spork ~ control.run(gk, G_knob, v/127.0);
                    else if( 0 <= gs && gs < 8 )
                        spork ~ control.run(gs, G_solo, v/127.0);
                    else if( 0 <= gm && gm < 8 )
                        spork ~ control.run(gm, G_mute, v/127.0);
                    else if( 0 <= gr && gr < 8 )
                        spork ~ control.run(gr, G_rec, v/127.0);
                    else
                        spork ~ control.run(-1, b, v/127.0);
                }
                else
                    <<< c, b, v >>>;
            }
        }
        
    }

    fun int open(int device)
    {
        min.open(device);
        mout.open(device);
        spork ~ handle();
        me.yield();
    }
}

/*
NanoKontrol2 nk;

class NKProc extends IntIntFloatProcedure
{
    fun void run(int g, int b, float val )
    {
        <<< g, b, val >>>; 
    }
}

NKProc a @=> nk.control;
nk.open(2);

while( true )
    1::second => now;
*/
