OscIn oin;
if(me.args()) me.arg(0) => Std.atoi => oin.port;
else 9000 => oin.port;
oin.listenAll();

OscMsg msg;

OscSend xmit[3];
OscSend o1 @=> xmit[0];
OscSend o2 @=> xmit[1];
OscSend o3 @=> xmit[2];

xmit[0].setHost("localhost", 9001);
xmit[1].setHost("localhost", 9002);
xmit[2].setHost("localhost", 9003);

while(true)
{
    oin => now;
    
    while(oin.recv(msg))
    {
        msg.address+", "+msg.typetag => string address;
        
        xmit[0].startMsg(address);
        xmit[1].startMsg(address);
        xmit[2].startMsg(address);
        
        for(int n; n < msg.numArgs(); n++)
        {
            if(msg.typetag.charAt(n) == 'i')
            {
                msg.getInt(n) => xmit[0].addInt;
                msg.getInt(n) => xmit[1].addInt;
                msg.getInt(n) => xmit[2].addInt;
            }
            else if(msg.typetag.charAt(n) == 'f')
            {
                msg.getFloat(n) => xmit[0].addFloat;
                msg.getFloat(n) => xmit[1].addFloat;
                msg.getFloat(n) => xmit[2].addFloat;
            }
            else if(msg.typetag.charAt(n) == 's')
            {
                msg.getString(n) => xmit[0].addString;
                msg.getString(n) => xmit[1].addString;
                msg.getString(n) => xmit[2].addString;
            }
        }
    }
}