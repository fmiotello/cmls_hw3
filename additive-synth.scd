//Additive synthesis implemented by summing multiple sinusoids.
//The sound changes according to the parameters
//MIDI and OSC Connection established

//TO DO:
//change number of harmonics dynamically - send all harmonics in one OSC message
//think about harmonics normalization and clipping (0.8 parameters is now removed, due to masterVolume)
(
s.waitForBoot({

	//GUI vars
	var win, subwin, multiSlider,singleNoteButton, singleNoteButton1;
	//synth vars
	var sound, numharm, partialFreq, partialAmpl, attack, release, keys, masterVolume, vibrato, pan,oscObject;

	//****************** INITIALIZATION **************************

	"**************ADDITIVE SYNTHESIS****************".postln; "".postln;

	MIDIIn.removeFuncFrom(\noteOn, ~noteOnFunc); MIDIClient.disposeClient;
	"*********Removing old MIDI functions**********".postln;
	"********Establishing MIDI connections**********".postln; "".postln;
	MIDIClient.init;
	MIDIIn.connectAll;

	"".postln; postln("**************INITIAL PARAMETERS***************");

	//Number of harmonics (including the fundamental)
	numharm = 10;
	postln("* Number of harmonics: " + numharm);

	// Initialize array of partial relative frequencies with rnd values.
	partialFreq = List.newClear(numharm);
	partialFreq.do({
		arg item, count;
		partialFreq[count] = count + 1;
	});
	postln("* Relative frequencies of partials:");
	postln(partialFreq);

	partialAmpl = List.newClear(numharm);
	partialAmpl.do({
		arg item, count;
		partialAmpl[count] = 0.5;
	});
	postln("* Amplitudes of partials: ");
	postln(partialAmpl);

	masterVolume = 1;
	keys = Array.newClear(128);
	vibrato = 5;
	attack = 0.01;
	release = 2;

	postln("* MasterVolume: " + masterVolume);
	postln("* Vibrato: " + vibrato);
	postln("* Attack: " + attack);
	postln("* Release: " + release);
	postln("**********************************************");


	//****************** SYNTH DEF **************************

	SynthDef("add-synth", {
		arg out = 0, pan = 0, fundamental = 120, partial = 1, amp = 0.5, att = 0.01, rel = 2, vel = 1, vibrato = 1, numharmonic = 5, masterVolume = 1;
		var sig = SinOsc.ar(fundamental * partial + SinOsc.kr(vibrato, mul: vibrato/2), 0, Lag.kr(vel*amp/numharmonic, 3));
		var env = EnvGen.kr(Env.perc(att, rel), doneAction: 2);
		sig = sig*env*masterVolume;
		Out.ar(out, Pan2.ar(sig, pan));
	}).add;

	//****************** OSC **************************

	oscObject = NetAddr("127.0.0.1",12000);
	oscObject.sendMsg("/sendMeAllValues", "there");

	OSCdef('OSCHarmonic',{
		arg msg;

		postln("harm" + msg);

		try{
			if(msg.size > 2) {
				partialAmpl[msg[1]] = msg[2];
			}  {postln("Error: Empty msg")};

		} {partialAmpl.add(msg[2]); partialFreq.add(partialFreq.size+1); numharm = partialAmpl.size; postln(numharm); postln(partialFreq); postln(partialAmpl);}

	},"/harmonic");

	OSCdef('OSCKnob',{
		arg msg;
		postln("knob" + msg);

		if(msg.size > 2) {
			masterVolume = msg[1];
			vibrato = msg[2]*15;
			attack = msg[3];
			release = msg[4]*4;
		}  {postln("Error: Empty msg")};
	},"/knob");


	OSCdef('OSCPan',{
		arg msg;
		postln("pan" + msg);

		if(msg.size > 1) {
			pan = msg[1];
		}  {postln("Error: Empty msg")};
	},"/pan");

	OSCdef('OSCNumharm',{
		arg msg;
		postln("num harm" + msg);

		if(msg.size > 1) {
			numharm = msg[1];
		}  {postln("Error: Empty msg")};
	},"/harmonicsNumber");


	//****************** MIDI **************************

	~noteOnFunc = {
		arg src, chan, num, vel;
		var node;
		node = keys.at(num);

		if(node.notNil, {
			node.release;
			keys.put(num, nil);
		});

		sound = Array.fill(numharm, {arg i; Synth("add-synth", [\fundamental, num.midicps, \partial, partialFreq[i], \amp, partialAmpl[i], \att, attack, \rel, release, \vel, vel/127, \vibrato, vibrato, \pan, pan, \numharmonic, numharm, \masterVolume, masterVolume], addAction: \addToTail)});


		keys.put(num, node);

		postln("MIDI message (num, vel: " + [num, vel/127]);
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

	//GUI: TO DELETE WHEN WE FULLY CONNECT WITH PROCESSING

	// Main window
	Window.closeAll;
	win = Window.new("Additive Synthesis", Rect(400, 30, 660, 400));
	win.view.decorator = FlowLayout(win.view.bounds, 20@20, 10@10);
	win.front;
	win.onClose = {s.freeAll;};
	CmdPeriod.doOnce({win.close});

	// Multislider - changing values of partial amplitudes
	multiSlider = MultiSliderView(win, Rect(0, 0, 620, 250));
	multiSlider.value = Array.fill(numharm, {0.5});
	multiSlider.isFilled = true;
	multiSlider.indexThumbSize = 29.0;
	multiSlider.gap = 9;
	multiSlider.action = {
		multiSlider.value.do(
			{arg value, count; partialAmpl[count]=value;}
		);
	};

	subwin = CompositeView(win, 620@100);
	subwin.background = Color.grey(0.6, 0);

	// *************BUTTONS FOR PLAYING TWO DIFF NOTES WITH FREQ = 150 AND 200**********

	singleNoteButton = Button(subwin, Rect(10, 10, 70, 80));
	singleNoteButton.states = [["Note"+150]];
	singleNoteButton.action = {
		postln(numharm);
		sound = Array.fill(numharm, {arg i; Synth("add-synth", [\fundamental, 150, \partial, partialFreq[i], \amp, partialAmpl[i], \att, attack, \rel, release, \vibrato, vibrato, \pan, pan, \numharmonic, numharm, \masterVolume, masterVolume], addAction: \addToTail);});
		"bang!".postln;
		postln(partialAmpl);
	};

	singleNoteButton1 = Button(subwin, Rect(100,10,70,80));
	singleNoteButton1.states = [["Note"+200]];
	singleNoteButton1.action = {
		sound = Array.fill(numharm, {arg i; Synth("add-synth", [\fundamental, 200, \partial, partialFreq[i], \amp, partialAmpl[i], \att, attack, \rel, release, \vibrato, vibrato, \pan, pan, \numharmonic, numharm, \masterVolume, masterVolume], addAction: \addToTail)});
		"bang!".postln;
		postln(partialAmpl);
	};
	s.meter;
});
)
