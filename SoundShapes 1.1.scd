// SoundShapes
().play
(
~fxBus = Bus.audio(s, 2);
~klankBus = Bus.audio(s,2);
k = Bus.audio(s,2);

n = Buffer.alloc(s, s.sampleRate * 0.25, 1);
s.sendMsg(\b_alloc, p = s.bufferAllocator.alloc(1), 1024, 1, [\b_setn, p, 0, 1024] ++ Env.sine.asSignal(1024));
)
(
SynthDef(\klank, {|nmul =  0.01, freqscale = 1, freqoffset = 0, decayscale = 0, gate = 1, mul = 1, bpf = 440, freq, ring, amp, pos, attack|
	var snd;
	var freqs = freq!1;

	var amps = amp!1;

	var ringtimes = ring;
	var env = EnvGen.ar(Env.perc(attack, ring*2, 1),gate, doneAction:2);
	var exciter = PinkNoise.ar(Array.fill(3, {0.001 + 0.001.rand}));

	var klank = DynKlank.ar(`[freqs,amps,ringtimes],exciter) * env;
	klank = Pan2.ar(BPF.ar(klank, bpf, 0.2), pos);


	Out.ar(~fxBus, klank);

	//Out.ar(k, LPF.ar(BPF.ar(klank, bpf), 500));
	//Out.ar(~fxBus, LPF.ar(BPF.ar(klank, bpf), 500));
	//Out.ar(0, LPF.ar(BPF.ar(klank, bpf), 500));


}).add;




SynthDef(\recBuf, {|run = 0|
	var in = Mix.ar(In.ar(~fxBus.index));
	var rec = RecordBuf.ar(in, n, 0,0,0, run, loop:1);
	rec;
}).add;


SynthDef(\grainBuf, {|gate = 0,rate = 1, pos|
	var env = EnvGen.ar(Env.asr(0.1, 1, 0.5), gate, doneAction:0);
	var snd = GrainBuf.ar(1, Impulse.ar(500), 0.1, n, 4, Saw.kr(0.01).range(0,1), envbufnum:p );
	Out.ar(0, snd * env);
}).add;



SynthDef(\kickDrum, { |amp = 1|

	var in = Impulse.ar(0.5);
	var snd = Decay2.ar(in, 0.01, 1)  * SinOsc.ar(60).dup ;
	var snd2;
	var env = EnvGen.kr(Env.perc(0.01,2));
	//var env2 = (EnvGen.kr(Env.adsr(0.01,0.1, 0.5, 0.5, 1)));


	snd = LPF.ar(snd ,220);

	Out.ar(k, snd * env * amp);

	//Out.ar(0, snd * env * amp);

}).add;
)
//FX Bus

(
//somevariables
var count = 0;
var sameCount = 0;
var prevSame = false;
var same = false;
var darkCount = 0;
var bright = false;
var dark = false;
var thisV;
var lastV = 0;

var lastR = 0;
var lastG = 0;
var lastB = 0;

var diff;

//RGB OSC
OSCdef(\rgb, {|msg|
	dark = false;
	r = msg[1];
	g = msg[2];
	b = msg[3];

	//Sound 1 on every Step
	if(dark == false, {
		/*Synth(\klank, [
			\freq, msg[1..3].linlin(0,255, 200, 2000).postln,
			\bpf, msg[1..3].linlin(0,255, 200, 2000).postln,
			\ring, Array.fill(3, {0.2+ 0.5.rand}),
			\amp, Array.fill(3, {0.5 + 0.5.rand}),
			\pos, v.linlin(0,255, -0.6,0.6)
		]);*/
		Synth(\klank, [
			\freq, msg[1..3].linlin(0,255, 40, 100).round(0.5).midicps,
			\bpf, msg[1..3].linlin(0,255, 40,100).round(0.5).midicps,
			\ring, Array.fill(3, {0.2+ 0.5.rand}).round,
			\amp, Array.fill(3, {0.5 + 0.5.rand}),
			\pos, v.linlin(0,255, -1,1),
			\attack, 0.1
		]);
	});


	if(count == 0, {

	});

	count = count + 1;
	if(count > 7, {count = 0});


	//if colours similar, hold with grainbuf
	/*diff = (r-lastR).abs + (g - lastG).abs + (b - lastB).abs;
	["diff",diff].postln;
	if(diff < 100, {
		z.set(\run, 0);
		y.set(\gate, 1);
		same = true;
	}, {
		same = false;
		z.set(\run, 1);
		y.set(\gate, 0);

	});
	lastR = r;
	lastG = g;
	lastB = b;
*/

}, "/rgb");

//HSV OSC
OSCdef(\hsv, {|msg|
	h = msg[1];
	f = msg[2];
	v = msg[3];

	//if value is 20% higher than last, play note (high pitch)
	thisV = v;
	if( ((lastV + (lastV*0.75)) < thisV), {
		"lotohi".postln;
		Synth(\klank, [
			\freq, [r,g,b].linlin(0,255, 80, 120).round(0.5).midicps,
			\bpf, [r,g,b].linlin(0,255, 80, 120).round(0.5).midicps,
			\ring, Array.fill(3, {1.5.rand}),
			\amp, Array.fill(3, {1.5.rand}),
			\pos, v.linlin(0,255, -1,1)!3,
			\attack, 0.01,
		])
	});
	//if dark, play deeper note,
	if( /*((lastV - (lastV/2) > thisV) || */ thisV < 40, {

		if(darkCount == 0, {
			Synth(\kickDrum);
			Synth(\klank, [
			\freq, h.linlin(0,255, 20, 50).round.midicps,
			\bpf, h.linlin(0,255, 20, 50).round.midicps,
			\ring, Array.fill(3, {2 + 0.5.rand}),
			\amp, Array.fill(3, {|i| 2 - (4/1)}),
			\pos, v.linlin(0,255, -1,1)!3 ,
			\attack, 0.01
			]);
			});

		dark = true;
		darkCount = darkCount + 1;

	}, {
		dark = false;
		darkCount = 0;
	});

	lastV = thisV;




}, "/hsv");

z = Synth(\recBuf, [\run,1]);

y = Synth(\grainBuf, [\gate, 0]);

x = {| mix = 0.33, room = 0.8, damp = 0.5|
	var kick = In.ar(k.index, 2);
	var wobble;
	var in = In.ar(~fxBus.index, 2);
	var snd = FreeVerb2.ar(in[0], in[1], mix, room, darkCount/10);
	snd = Compander.ar(snd, kick, clampTime:4);


	Out.ar(0, HPF.ar(LPF.ar(snd, 2000), 80));
}.play;
)

