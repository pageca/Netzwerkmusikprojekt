~fxBus = Bus.audio(s, 1);

(
SynthDef(\gong, {|gate = 1, freq, decayscale = 1,attack = 0.01,decaytime = 0.3, sustain = 0.6, release = 1,lfreq = 0.0, mul = 1 bpf = 400, rq = 0.3, pan = 0, amp, decay|
	var freqs = freq;
	var amps =  Array.fill(8, {|i| 1 - (i/10)});
	var rings = Array.fill(8, {4 + 1.0.rand}) * decayscale;
	var env = EnvGen.ar(Env.adsr(0.1, decaytime, sustain, release), gate, doneAction:2);
	//var env = EnvGen.ar(Env.perc(attack, release, 1),gate,doneAction:2);
	var lfo = SinOsc.ar(lfreq, 0.0, 1, 0.1);
	var exciter = PinkNoise.ar(0.01);
	var klank = Klank.ar(`[freqs, amps, rings], exciter, decayscale) * env;
	Out.ar(~fxBus, klank);
}).add;

~fx = {|ffreq|
	var in = In.ar(~fxBus, 1);
	in = BPF.ar(in, MouseX.kr(20, 1000), MouseY.kr(0.1, 1));








	Out.ar(0, in);
}.play;
)


MIDIClient.init

MIDIIn.connectAll
(
~freqs = Array.fill(127, nil);

MIDIdef.noteOn(\pn, {|vel, nn, chan|
	nn.postln;
	~freqs[nn] = Synth(\gong, [\freq, Array.fill(8, {|i|nn.midicps * (i+1) + 1.0.rand.midicps}), \gate, 1, \freqoffset, nn.midicps, \lfreq, ~mod]  );

});

MIDIdef.noteOff(\off, {|vel, nn, chan|
	nn.postln;

	~freqs[nn].set(\gate, 0);

});
)
MIDIdef.cc(\mod, {|mod|
	~mod = mod;
	for(0, 127, {|i|
		if(~freqs[i] != nil, {
			~freqs[i].set(\lfreq, ~mod.linlin(0, 10))
		})
	});
});
)
(
MIDIdef.cc(\allc, {|a,b,c,d|
	[a,b,c,d].postln;
})
)

