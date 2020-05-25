//Additive synthesis implemented by summing multiple sinusoids.
//The sound changes according to the parameters
//MIDI Connection established
//The local GUI is for now here only to understand the system behaviour better.

//TO DO:
//Connect with Processing by OSC messages.
//Control more parameters of the Synth

s.waitForBoot({

	//GUI vars
	var win, subwin, multiSlider,singleNoteButton, singleNoteButton1;
	//synth vars
	var spectrum, numharm, partialFreq, partialAmpl, percussiveOut, att = 0.01, rel = 2, keys;

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
	partialFreq = Array.newClear(numharm);
	partialFreq.do({
		arg item, count;
		partialFreq[count] = rrand(0.45,0.55).round(0.01).linlin(0, 1, -0.2, 0.2).round(0.01) + count + 1;
	});
	postln("Relative frequencies of partials:");
	postln(partialFreq);

	partialAmpl = Array.newClear(numharm);
	partialAmpl.do({
		arg item, count;
		partialAmpl[count] = 0.05;
	});
	postln("Amplitudes of partials: ");
	postln(partialAmpl); postln("**********************************************");


	keys = Array.newClear(128);

	//****************** SYNTH DEF **************************
	//to do: add general volume as a parameter (velocity of a key)

	SynthDef("add-synth", {
		arg out = 0, pan = 0, fundamental = 120, partial = 1, amp = 0.1, att = 0.01, rel = 2;
		var snd = SinOsc.ar(fundamental * partial, 0, Lag.kr(amp, 3));
		var env = EnvGen.kr(Env.perc(att, rel), doneAction: 2);
		Out.ar(out, Pan2.ar(snd*env*0.5, pan));
	}).add;

	//****************** OSC PART **************************

	NetAddr("127.0.0.1",57120);

	{
	OSCdef('OSCreceiver',{
		arg msg;
		x = msg[1];
		y = msg[2];
		z = msg[3];

		[x, y, z].postln;
		//postln(partialAmpl);
		//each knob corresponds to one harmonic
		//partialAmpl.do({arg value, count;
			//partialAmpl[count] = msg[count+1]*0.1;
		//});

		//setting attack and release parameters
	},
	"/pos");
	};

	//****************** MIDI **************************

	~noteOnFunc = {
		arg src, chan, num, vel;
		var node;
		node = keys.at(num);

		if(node.notNil, {
			node.release;
			keys.put(num, nil);
		});

		spectrum = Array.fill(numharm, {arg i; Synth("add-synth", [\fundamental, num.midicps, \partial, partialFreq[i], \amp, partialAmpl[i]], addAction: \addToTail)});

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
			{arg value, count; partialAmpl[count]=value*0.1;}
		);
	};

	subwin = CompositeView(win, 620@100);
	subwin.background = Color.grey(0.6, 0);

	// *************BUTTONS FOR PLAYING TWO DIFF NOTES WITH FREQ = 150 AND 200**********

	singleNoteButton = Button(subwin, Rect(10, 10, 70, 80));
	singleNoteButton.states = [["Note"+150]];
	singleNoteButton.action = {
		//spectrum = Synth.tail(nil, "additive-synth", [\fundamental, 150]); //, \amp, vel/127]);
		spectrum = Array.fill(numharm, {arg i; Synth("add-synth", [\fundamental, 150, \partial, partialFreq[i], \amp, partialAmpl[i], \att, att, \rel, rel], addAction: \addToTail);});
		"bang!".postln;
		postln(partialAmpl);
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
