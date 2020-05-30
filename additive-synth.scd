//Additive synthesis implemented by summing multiple sinusoids.
//The sound changes according to the parameters
//MIDI and OSC Connection established

s.waitForBoot({

	//GUI vars
	var win, subwin, multiSlider,singleNoteButton, singleNoteButton1;
	//synth vars
	var spectrum, numharm, partialFreq, partialAmpl, percussiveOut, att = 0.01, rel = 2, keys, masterVolume, vibrato, pan;

	//****************** INITIALIZATION **************************

	MIDIClient.init;
	MIDIIn.connectAll;

	postln("Welcome to Additive Synthesis");
	postln("**************INITIAL PARAMETERS***************");

	//Number of harmonics (including fund)
	numharm = 5;
	postln("Number of harmonics: " + numharm);

	// Initialize array of partial relative frequencies with rnd values.
	//For now we dont have the detuning as an external parameter.
	partialFreq = List.newClear(numharm);
	partialFreq.do({
		arg item, count;
		partialFreq[count] = rrand(0.45,0.55).round(0.01).linlin(0, 1, -0.2, 0.2).round(0.01) + count + 1;
	});
	postln("Relative frequencies of partials:");
	postln(partialFreq);

	partialAmpl = List.newClear(numharm);
	partialAmpl.do({
		arg item, count;
		partialAmpl[count] = 0.5;
	});
	postln("Amplitudes of partials: ");
	postln(partialAmpl); postln("**********************************************");

	masterVolume = 1;
	keys = Array.newClear(128);

	//****************** SYNTH DEF **************************
	//to do: add general volume as a parameter (velocity of a key)

	SynthDef("add-synth", {
		arg out = 0, pan = 0, fundamental = 120, partial = 1, amp = 0.5, att = 0.01, rel = 2, vel = 1, vibrato = 10, numharmonic = 5;
		var sig = SinOsc.ar(fundamental * partial + SinOsc.kr(vibrato, mul: vibrato/2), 0, Lag.kr(vel*amp/numharmonic, 3));
		var env = EnvGen.kr(Env.perc(att, rel), doneAction: 2);
		sig = sig*env*0.8;
		Out.ar(out, Pan2.ar(sig, pan));
	}).add;

	//****************** OSC PART **************************

	NetAddr("127.0.0.1",57120);

	OSCdef('OSCHarmonic',{
		arg msg;

		postln("harm");

		try{
			if(msg.size > 2) {
				partialAmpl[msg[1]] = msg[2];
			}  {postln("Error: Empty msg")};

		} {partialAmpl.add(msg[2]); partialFreq.add(partialFreq.size+1); numharm = partialAmpl.size}

	},"/harmonic");

	OSCdef('OSCKnob',{
		arg msg;
		postln("knob");

		if(msg.size > 2) {
			masterVolume = msg[1];
			vibrato = msg[2];
			att = msg[3];
			rel = msg[4];
		}  {postln("Error: Empty msg")};
	},"/knob");


	OSCdef('OSCPan',{
		arg msg;
		postln("pan");

		if(msg.size > 1) {
			pan = msg[1];
		}  {postln("Error: Empty msg")};
	},"/pan");


	//****************** MIDI **************************

	~noteOnFunc = {
		arg src, chan, num, vel;
		var node;
		node = keys.at(num);

		if(node.notNil, {
			node.release;
			keys.put(num, nil);
		});

		spectrum = Array.fill(numharm, {arg i; Synth("add-synth", [\fundamental, num.midicps, \partial, partialFreq[i], \amp, partialAmpl[i], \att, att, \rel, rel, \vel, vel/127, \vibrato, vibrato, \pan, pan, \numharmonic, numharm], addAction: \addToTail)});


		keys.put(num, node);

		postln("Relative frequencies of partials: " + partialFreq);
		postln("Amplitudes of partials: " + partialAmpl);
		postln("MIDI message (channel, num, velocity): " + [chan, num, vel/127]);
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

	//TO DELETE WHEN WE FULLY CONNECT WITH PROCESSING

	//************* GUI PART **********************************

	// Main window
	Window.closeAll;
	win = Window.new("Additive Synthesis", Rect(400, 30, 660, 400));
	win.view.decorator = FlowLayout(win.view.bounds, 20@20, 10@10);
	win.front;
	//IMPORTANT: HERE WE ALSO DISPOSE noteOn FUNCTION, OTHERWISE THEY STACK ON EACH OTHER
	win.onClose = {s.freeAll;
		MIDIIn.removeFuncFrom(\noteOn, ~noteOnFunc); MIDIClient.disposeClient;
		"********CLOSING AND REMOVING MIDI FUNCTIONS**********".postln; "".postln;
	};
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
		//spectrum = Synth.tail(nil, "additive-synth", [\fundamental, 150]); //, \amp, vel/127]);
		postln(numharm);
		spectrum = Array.fill(numharm, {arg i; Synth("add-synth", [\fundamental, 150, \partial, partialFreq[i], \amp, partialAmpl[i], \att, att, \rel, rel, \vibrato, vibrato, \pan, pan, \numharmonic, numharm], addAction: \addToTail);});
		"bang!".postln;
		postln(partialAmpl);
		postln(partialFreq);
	};

	singleNoteButton1 = Button(subwin, Rect(100,10,70,80));
	singleNoteButton1.states = [["Note"+200]];
	singleNoteButton1.action = {
		//spectrum = Synth.tail(nil, "additive-synth", [\fundamental, 200]);
		spectrum = Array.fill(numharm, {arg i; Synth("add-synth", [\fundamental, 200, \partial, partialFreq[i], \amp, partialAmpl[i], \att, att, \rel, rel], addAction: \addToTail)});
		"bang!".postln;
		postln(partialAmpl);
	};
});

