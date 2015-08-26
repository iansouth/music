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

fun void randomScale()
{
    false => int blah;
    0 => int sum;
    /*
    [1,0,0,0, 0,0,0,0, 0,0,0,0] @=> int notes[];
    do {
        false => blah;
        1 => sum;
        for(1 => int i; i < 12; ++i)
        {
            Math.random2(0,1) => notes[i];
            if(notes[i] == 0)
                if(notes[i-1] == 0)
                    if(notes[i-2] == 0)
                        true => blah;
            notes[i] +=> sum;
        }
    } while (blah || (sum < 5) || (sum > 7));
    */

    int notes[];
    Math.random2(1,3) => int s;
    if(s==1)
        [1,0,1,1, 0,1,0,1, 1,0,1,0] @=> notes;
    if(s==2)
        [1,0,1,0, 1,1,0,1, 0,1,0,1] @=> notes;
    if(s==3)
        [1,0,1,1, 0,1,0,1, 1,0,0,1] @=> notes;

    //if(s==4)
    //    [1,0,0,1, 0,1,0,1, 0,0,1,0] @=> notes;

    for(0 => int i; i < 12; ++i)
    {
        notes[i] +=> sum;
    }

    Math.random2(40,52) => int root;
    sum => scale.size;
    0=>int j;
    <<<scale.cap()>>>;
    chout <= "Scale: [";
    for(0 => int i; i < 12; ++i)
    {
        if(notes[i] == 1) {
            root+i => scale[j];
            chout <= scale[j] <= ", ";
            j+1 => j;
        }
    }
    chout <= "]";
    chout <= IO.newline();
}

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

chordIN.left  => /*Echo e0 => r[0] =>*/ chordOUT.left  => d[0] => d[1] => ducker[0] => out.left;
chordIN.right => /*Echo e1 => r[1] =>*/ chordOUT.right => d[1] => d[0] => ducker[1] => out.right;

Pan2 pan; // Panning for the chords

SinOsc   subBass[6];
BeeThree     inst[4];
NRev   inst_rev;
Drone droneMetal;
1.0 => droneMetal.pre.gain;

inst_rev => droneMetal => chordIN;
inst_rev => droneMetal => chordIN;
inst_rev => droneMetal => chordIN;
inst_rev => droneMetal => chordIN;

for( 0 => int i; i < inst.cap(); ++i) {
    inst[i] => inst_rev; 
    0.9 => inst_rev.gain;
    0.2 => inst_rev.mix;
    /*
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

Dyno finalD[2];
Pan2 finalP => dac;

//d0 => finalD[0];
//d0 => finalD[1];

out.left  => finalD[0] => finalP.left;
out.right => finalD[1] => finalP.right;
finalD[0].limit();
finalD[1].limit();

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
        mw.meditation * inst.cap() => float mix;
        mix $ int => int num;
        mix-num => mix;
        
        for( 0 => int i; i < inst.cap(); ++i)
        {
            if( i < num )
                1.0 => inst[i].gain;
            else if( i == num )
                mix => inst[i].gain;
            else
                0.0 => inst[i].gain;
        }
        1::samp => now;
    }
}


fun void scaleChanger() {
    0.1::second => now;
    while(true) {
        if( mw.signal == 0.0 && mw.meditation == 0.0 && mw.attention == 0.0 )
        {

            randomScale();
            subBassOn( 0 );
            chordOn( 1, inst.cap() );
        }
        
        1::second => now;
    }
}


// Main
randomScale();

[ 0, 3, 0, 4 ] @=> int chordProg[];

subBassOn( 0 );
chordOn( 0, inst.cap() );

spork ~ scaleChanger();

1 => int i;
while(true) {

    advanceTime(60*quarter);
    //chordOff();
    //subBassOff();
    //advanceTime(4*quarter);
    //(i+1)%chordProg.cap() => i;
    //chordOn(chordProg[i], inst.cap());
}
