

n = NetAddr("127.0.0.1", 57140); // OSCJunction
n.sendMsg("/test", 113);

p = NetAddr("127.0.0.1", 12000); // Processing
p.sendMsg("/test", 840);

//p.sendMsg("/mouse", MouseX.kr(0,1).postln);



OSCFunc({arg msg; msg.postln;}, 'test');



(
SynthDef("clock",{

	var sig = Impulse.kr(60);
	//SendTrig.kr(sig,1,MouseX.kr);
	//SendTrig.kr(sig,2,MouseY.kr);
	//SendTrig.kr(sig,0,0);
	SendReply.kr(sig,"/mouse", [MouseX.kr, MouseY.kr]);

}).add;

o = OSCFunc({ arg msg;
	msg.postln;
	p.sendMsg("/mouse", msg[3],msg[4])

},'/mouse', s.addr);

Synth("clock");
)




