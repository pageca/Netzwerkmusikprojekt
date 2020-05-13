

n = NetAddr("127.0.0.1", 57140);
n.sendMsg("/test", 113);

p = NetAddr("127.0.0.1", 12000);
p.sendMsg("/test", 840);

//p.sendMsg("/mouse", MouseX.kr(0,1).postln);

OSCFunc({arg msg; msg.postln;}, 'test');



(
SynthDef("clock",{
	var sig = Impulse.kr(60);
	SendTrig.kr(sig,1,MouseX.kr);
	SendTrig.kr(sig,2,MouseY.kr);
	SendTrig.kr(sig,0,0);
}).add;

~values=[0,0];
o = OSCFunc({ arg msg;
	//msg.postln;
	switch(msg[2],
		1, {~values[0]=msg[3]},
		2, {~values[1]=msg[3]},
		0, {p.sendMsg("/mouse", ~values[0],~values[1])} );

},'/tr', s.addr);



Synth("clock");
)





(
{
	inf.do({

		p.sendMsg("/mouse", MouseX.kr, MouseY.kr);
		0.1.wait;
	})


}.fork;
)

