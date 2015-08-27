public class LaunchpadSwitch extends Launchpad
{
    Bundle bundles[8];
    0 => int current;
    
    {

    }
    
    fun void handle()
    {
        MidiMsg msg;
        
        setLED(current, 8, G3);
        bundles[current].forground();

        while (true)
        {
            min => now;
            while (min.recv(msg))
            {
                msg.data1 => int control;
                msg.data2 => int note;
                msg.data3 => int velocity;
               
                1 => int on;
                if( velocity == 0 )
                    0 => on;
                
                if( control == 144 ) // Note hit
                {
                    note%16 => int X;
                    note/16 => int Y;
                    
                    if( X < 9 )
                    {
                        spork ~ bundles[current].notify(this,X,7-Y,on);
                    }
                }
                if( control == 176 ) // Top note hit
                {
                    note-104 => int X;
                    if( X >= 0 && X <= 7)
                    {
                        setLED(0, 8, OFF);
                        setLED(1, 8, OFF);
                        setLED(2, 8, OFF);
                        setLED(3, 8, OFF);
                        setLED(4, 8, OFF);
                        setLED(5, 8, OFF);
                        setLED(6, 8, OFF);
                        setLED(7, 8, OFF);
                        bundles[current].background();
                        
                        X => current;
                        setLED(current, 8, G3);
                        bundles[current].restore(this);
                        bundles[current].forground();
                        // switch to X
                    }
                }
            }
        }
    }    
}