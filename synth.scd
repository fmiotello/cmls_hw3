MIDIClient.init;
MIDIIn.connectAll;

(
SynthDef(\risset, {
	arg out, pan, freq, amp= 0.1, dur= 2, t_trig=1;
	var amps= [1, 0.67, 1, 1.8, 2.67, 1.67, 1.46, 1.33, 1.33, 1, 1.33];
	var durs= [1, 0.9, 0.65, 0.55, 0.325, 0.35, 0.25, 0.2, 0.15, 0.1, 0.075];

	var frqs= [0.56, 0.56, 0.92, 0.92, 1.19, 1.7, 2, 2.74, 3, 3.76, 4.07];
	var dets= [0, 1, 0, 1.7, 0, 0, 0, 0, 0, 0, 0];    // Detune
	// MIx.fill(n,function) n= size of array to create, function: array filling function
	var src= Mix.fill(11, {|i|
		var env = EnvGen.ar(Env.perc(0.005, dur*durs[i], amps[i], -4.5), t_trig);
		SinOsc.ar(freq*frqs[i]+dets[i], 0, amp*env);
	});
	Out.ar(out, Pan2.ar(src, pan));
}).add;
)

NetAddr("127.0.0.1",57120);

(var synth;

synth = Synth(\risset, [\out, 0, \pan, 0, \freq, 400, \amp, 0.1, \dur, 2]);

OSCdef('OSCreceiver',{
	arg msg;
	x = msg[1];
	y = msg[2];
	z = msg[3];

	[x, y, z].postln;

	synth.set(\out,x, \pan, y, \freq, z);
},
"/pos");
)

)

(
var keys;
keys = Array.newClear(128);
~noteOnFunc = {
	arg src, chan, num, vel;
	var node;
	node = keys.at(num);

	if(node.notNil, {
		node.release;
		keys.put(num, nil);
	});

	node = Synth.tail(nil, \risset, [\freq, num.midicps, \amp, vel/127]);

	keys.put(num, node);
	[chan, num, vel/127].postln;
};

MIDIIn.addFuncTo(\noteOn, ~noteOnFunc);

~noteOffFunc = {
	arg src, chan, num, vel;
	var node;
	node = keys.at(num);

	if(node.notNil, {
		node.set(\gate, 0);
		node.release;
		keys.put(num, nil);
	});
};

MIDIIn.addFuncTo(\noteOff, ~noteOffFunc);
)