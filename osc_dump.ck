OscIn oin;
if(me.args()) me.arg(0) => Std.atoi => oin.port;
else 9001 => oin.port;
oin.listenAll();

OscMsg msg;

while(true)
{
    oin => now;
    
    while(oin.recv(msg))
    {
        chout <= "[" <= oin.port() <= "] " <= msg.address <= " " <= msg.typetag;
        chout <= IO.nl();
    }
}