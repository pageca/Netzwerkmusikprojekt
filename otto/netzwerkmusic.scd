

n = NetAddr("127.0.0.1", 57140); // OSCJunction
n.sendMsg("/test", 113);

p = NetAddr("127.0.0.1", 12000); // Processing
p.sendMsg("/test", 840);

OSCFunc({arg msg; msg.postln;}, 'test');


// hab vorher SendTrig benutzt, aber SendReply ist besser
(
SynthDef("clock",{

	var sig = Impulse.kr(60);
	SendReply.kr(sig,"/mouse", [MouseX.kr, MouseY.kr]);

}).add;

o = OSCFunc({ arg msg;
	msg.postln;
	p.sendMsg("/mouse", msg[3],msg[4])

},'/mouse', s.addr);

Synth("clock");
)




