OscRecv recv;
9000 => recv.port;
recv.listen();

OscSend xmit;
xmit.setHost("localhost", 9001);

OscSend xmit2;
xmit2.setHost("localhost", 9002);

public class Mindwave {
    static float meditation;
    static float attention;
    static float signal;
    //static float EEG[8];
}

Envelope signal => blackhole;
Envelope meditation[8] => blackhole;
Envelope attention[8] => blackhole;
Envelope EEG[8] => blackhole;

for(0 => int i; i < 8; ++i) 
    EEG[i] => blackhole;

for(0 => int i; i < meditation.cap(); ++i) 
    meditation[i] => blackhole;

for(0 => int i; i < attention.cap(); ++i) 
    attention[i] => blackhole;

1.0::second => dur EnvRamp;
EnvRamp => signal.duration;

for(0 => int i; i < attention.cap(); ++i) 
	i*EnvRamp => attention[i].duration;
for(0 => int i; i < meditation.cap(); ++i) 
	i*EnvRamp => meditation[i].duration;

for(0 => int i; i < 8; ++i) 
    EnvRamp => EEG[i].duration;

fun void osc_signal()
{
	recv.event("/mindwave/1/signal,f") @=> OscEvent e; 
	while( true ) {
		e => now;
		while ( e.nextMsg() != 0 ) {
			e.getFloat() => signal.target;
		}
	}
}

fun void osc_meditation()
{
	recv.event("/mindwave/1/meditation,f") @=> OscEvent e; 
	float f;

	while( true ) {
		e => now;
		while ( e.nextMsg() != 0 ) {
			e.getFloat() => f;
			for(0 => int i; i < meditation.cap(); ++i) 
				f => meditation[i].target;
			re_med(f);
		}
	}
}

fun void osc_attention()
{
	recv.event("/mindwave/1/attention,f") @=> OscEvent e; 
	float f;

	while( true ) {
		e => now;
		while ( e.nextMsg() != 0 ) {
			e.getFloat() => f;
			for(0 => int i; i < attention.cap(); ++i) 
				f  => attention[i].target;
			re_att(f);
		}
	}
}

fun void osc_EEG()
{
	recv.event("/mindwave/1/eeg, i, i, i, i, i, i, i, i") @=> OscEvent e; 

	while( true ) {
		e => now;
        int val[8];
		while ( e.nextMsg() != 0 ) {
            0.0 => float sum;
            for(0 => int i; i < 8; ++i) {
                e.getInt() => val[i];
                val[i] +=> sum;
            }
            for(0 => int i; i < 8; ++i) {
                val[i] / sum => EEG[i].target;
            }
		}
	}
}

fun void re_med(float f)
{
	xmit.startMsg("/mindwave/1/meditation, f");
	f => xmit.addFloat;
	xmit2.startMsg("/mindwave/1/meditation, f");
	f => xmit2.addFloat;
}

fun void re_att(float f)
{
	xmit.startMsg("/mindwave/1/attention, f");
	f => xmit.addFloat;
	xmit2.startMsg("/mindwave/1/attention, f");
	f => xmit2.addFloat;
	
}

/*
fun void osc_meditation_smooth()
{
	while( true ) {
		xmit.startMsg("/mindwave/1/meditation_smooth, f,f,f,f,f,f,f,f");
        for(0 => int i; i < meditation.cap(); ++i) 
			meditation[i].value() => xmit.addFloat;

		0.1::second => now;
	}
}

fun void osc_attention_smooth()
{
	while( true ) {
		xmit.startMsg("/mindwave/1/attention_smooth, f,f,f,f,f,f,f,f");
        for(0 => int i; i < attention.cap(); ++i) 
			attention[i].value() => xmit.addFloat;

		0.1::second => now;
	}
}
*/

spork ~ osc_signal();
spork ~ osc_meditation();
spork ~ osc_attention();
//spork ~ osc_meditation_smooth();
//spork ~ osc_attention_smooth();
//spork ~ osc_EEG();
me.yield();

Mindwave mindwave;

while(true) {
    //<<< mindwave.meditation, mindwave.attention >>>;
    //for(0 => int i; i < 8; ++i)
    //    <<< EEG[i].value() >>>;
	//0.1::second => now;

    1::samp => now;
    //for(0 => int i; i < 8; ++i) {
    //    EEG[i].value() => mindwave.EEG[i];
    //}
    meditation[1].value()=> mindwave.meditation;
    attention[1].value()=> mindwave.attention;
    signal.value()=> mindwave.signal;
}
