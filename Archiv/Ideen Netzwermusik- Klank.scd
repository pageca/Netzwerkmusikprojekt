//Ideen Netzwermusik

//klank

(
SynthDef(\klank, {|nmul =  0.01, freqscale = 1, freqoffset = 0, decayscale = 0, gate = 1, mul = 1, bpf = 440, freq, ring|
	var freqs = freq;
	var amps = nil;
	var ringtimes = ring * Array.fill(8, 1);
	var env = EnvGen.ar(Env.perc(0.1, ring * 4, 1),gate, doneAction:2);
	var exciter = PinkNoise.ar(Array.fill(8, {0.001 + 0.001.rand}));
	//var excite2 = Dust2.ar(MouseY.kr(0,50, 0), Array.fill(8, 0.01));
	//var excite2 = Impulse.ar(0.5, 0.0, 0.1);
	var klank = DynKlank.ar(`[freqs,amps,ringtimes],exciter) * env;
	Out.ar(0, BPF.ar(klank, bpf) * 0.5);
}).add;
)
x = Synth(\klank)

(
Pbind(
	\instrument, \klank,
	\freq, Prand(Array.fill(8, {Array.fill(8, {200 + 2000.rand})}),inf),
	\ring, Pwhite(1, 2),
	\dur, Pseq([1,1,2,2,4], inf ),
	\bpf, Pwhite(120, 1000)
).play;
)