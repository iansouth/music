// Assignment 5 - Dynosaur Abuse
// In this piece I really overload the gain/reverb, while abusing the 
// Dyno ugen to keep things under control. The kick drum is also sidechained
// to compress the chord/bass

now / second => float start;

Mindwave mw;

// Db Phrygian
// Db,  D,  E, Gb, Ab,  A,  B
[  49, 50, 52, 54, 56, 57, 59 ] @=> int scale[];

0.75::second => dur quarter;



/////////////////////////////////////////
// Sound network

// Chord effect chain
// Unfortunately Dynamo and NRev do not work on multichannel input
// If they did the chain would look like:
// Pan2 chordIN => NRev r => Pan2 chordOUT => Dyno d => Dyno ducker => Pan2 out;
Pan2 chordIN;
NRev r[2]; // 2 channel reverb!
Pan2 chordOUT;
Dyno d[2];
Dyno ducker[2];
Pan2 out;
Gain subBassIN;

chordIN.left  => Echo e0 => r[0] => chordOUT.left  => d[0] => d[1] => ducker[0] => out.left;
chordIN.right => Echo e1 => r[1] => chordOUT.right => d[1] => d[0] => ducker[1] => out.right;

Pan2 pan; // Panning for the chords

SinOsc   subBass[10];
BeeThree     inst[6];
for( 0 => int i; i < inst.cap(); ++i) {
    inst[i] => pan => chordIN; /*
    i => inst[i].phonemeNum;
    1.0 => inst[i].vibratoFreq;
    0.0 => inst[i].vibratoGain;
    1.0 => inst[i].voiceMix;
    1.0 => inst[i].speak;
    0.0 => inst[i].pitchSweepRate; */
}

for( 0 => int i; i < subBass.cap(); ++i)
    subBass[i] => subBassIN => chordOUT;
1.0 => subBassIN.gain;
0.01 => chordOUT.gain;
1.0 => r[0].mix;
1.0 => r[1].mix;
// d => dac;
/////////////////////////
ducker[0].duck();
ducker[1].duck();

subBassIN => Gain d0;
Gain samples => d0;
samples => chordOUT.left;
samples => chordOUT.right;

Dyno finalD[2];
Pan2 finalP => dac;

//d0 => finalD[0];
//d0 => finalD[1];

out.left  => finalD[0] => finalP.left;
out.right => finalD[1] => finalP.right;

fun void kick()
{
    // Creating a new kick buffer each time removes the click 
    // when the pos gets set to 0 in the middle of playback
    SndBuf kickBuf => samples;
    // Adding the oscillating playback rate makes the kick seems less mechanical
    0.5 => kickBuf.gain;
    playSample(kickBuf, "./kick_01.wav", 0.7, 0.6);
}

/////////////////////////////////////////

// Most of these frequencies are sub-hearing range
// I'd suggest turning the bass up high when listening
// preferably with a great set of headphones
fun void subBassOn( int note )
{
    for( 0 => int i; i < subBass.cap(); ++i)
    {
        // Increasing the bass gain over time starts to get the chord
        // pushed back by the Dynos, but in a wobbly way that I found
        // nice.
        3.0/(1) => subBass[i].gain;
        scaleNoteToFreq(note)/(2*(i+1)) => subBass[i].freq;
    }
}

fun void subBassOff()
{
    for( 0 => int i; i < subBass.cap(); ++i)
    {
        0.0 => subBass[i].gain;
    }
}
subBassOff();
0 => int panCounter;

// I don't know much about music theory, but I noticed
// the notes in a lot of chords consist of alternating 
// notes in the scale, starting with a root note
// This does that for a configurable amount of notes
fun void chordOn( int note, int numNotes )
{
    0.0 => pan.pan;
    
    for( 0 => int i; i < inst.cap(); ++i)
    {
        if( i < numNotes )
        {
            scaleNoteToFreq(note+2*i) => inst[i].freq;
            1 => inst[i].noteOn;
        }
    }
}

fun void chordOff()
{
    for( 0 => int i; i < inst.cap(); ++i)
    {
        1 => inst[i].noteOff;
    }
}

// Convert a scale note to freq
// Wraps the scale array, so negative numbers and large numbers
// will play higher/lower octaves.
fun float scaleNoteToFreq(int note)
{
    note => int n;
    0 => int octave;
    
    while(n < 0)
    {
        scale.cap()-1 +=> n;
        1 -=> octave;
    }

    while(n >= scale.cap())
    {
        scale.cap()-1 -=> n;
        1 +=> octave;
    }
    
    return Std.mtof(scale[n]+octave*12);
}

me.dir()+"/audio/" => string path;
// Play a sample at a certain speed
fun void playSample(SndBuf sample, string file, float gain, float speed)
{
    path+file => sample.read;
    gain => sample.gain;
    
    speed => sample.rate;
    if(speed >= 0) {
        0 => sample.pos;
    } else {
        sample.samples() => sample.pos;
    }
    <<< file >>>;
}

// Play a sample at a speed that forces it to play within a length of time
fun void playSample2(SndBuf sample, string file, float gain, float length)
{
    path+file => sample.read;
    gain => sample.gain;
    
    sample.length() / length::second=> float speed;
    
    <<< speed >>>;
    
    speed => sample.rate;
    if(speed >= 0) {
        0 => sample.pos;
    } else {
        sample.samples() => sample.pos;
    }
    
    <<< file >>>;
}

// I saw this in the ducker example, you need to manually feed 
// in the samples to the side chain compressor, so I replaced all
// instances of (time) => now with advanceTime() so I could always 
// step one sample at a time
fun void advanceTime( dur t ) {
    now + t => time stop;
    while( now < stop ) {
        d0.last() => ducker[0].sideInput;
        d0.last() => ducker[1].sideInput;

        mw.attention => subBassIN.gain;
        mw.meditation * subBass.cap() => float mix;
        mix $ int => int num;
        mix-num => mix;
        
        for( 0 => int i; i < subBass.cap(); ++i)
        {
            if( i < num )
                1.0 => subBass[i].gain;
            else if( i == num )
                mix => subBass[i].gain;
            else
                0.0 => subBass[i].gain;
        }
        1::samp => now;
    }
}

// Main

[ 0, 3, 1, 5 ] @=> int chordProg[];
0 => int patternRoot;

  subBassOn( patternRoot );
   // chordOn( patternRoot+1, inst.cap() );

0 => int i;
while(true) {
    i+1 => i;
    (6*mw.meditation) $ int => int notes;
    //<<< notes >>>;
    //chordOn( patternRoot+chordProg[i%chordProg.cap()], notes );
    
    //kick();

    advanceTime(quarter);
    //chordOff();
    /*
    if( i > 8 && i < 11 )
        kick();

    if( i >= 11 && i % 3 == 0 && i < 22 )
        kick();
    
    */
    advanceTime(quarter);
    //subBassOff();
}

<<< "Sorry this is a little bit longer than 30 seconds" >>>;
<<< "Duration:", now / second - start, "seconds">>>;
