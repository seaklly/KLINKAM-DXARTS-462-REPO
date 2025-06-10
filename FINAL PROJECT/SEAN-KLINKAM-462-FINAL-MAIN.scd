// DXARTS 462 FINAL - SEAN KLINKAM
(
MIDIIn.connectAll;
s.options_(ServerOptions.new.memSize_(2**21));
)
(
~synth = CtkSynthDef(\default, { |out = 0, freq = 440, amp = 0.2, pan = 0, cutoff = 20000, attack = 0.01,
	reverbmix = 0.4|
    var snd, env, lpf, comb, ring;
	snd = Saw.ar(freq);
	env = EnvGen.kr(Env.perc(attack, 0.3), doneAction: 2);
	lpf = LPF.ar(snd * env * amp, env.range(cutoff * 0.1, cutoff));
	comb = CombAZN.ar(lpf, 20, 1720 * env + 220, -60, 'add');

    Out.ar(comb, Pan2.ar(comb, pan));
});

~buffers = PathName(Document.current.dir +/+ "sounds/").files.collect{ |pathName, increment|
	CtkBuffer(pathName.fullPath).load
};

~playbuff = CtkSynthDef(\playbuf, {|buffer, out = 0, rate = 1, dur, pitch = 1, window = 0.2|
	var warp, env;
	warp = Warp1.ar(2, buffer, Line.kr(0, 1, dur), pitch, window, -1, 8);
	Out.ar(out, warp);

~warp = CtkSynthDef (
		\dxarts46x_stereoWarp1Shuffle,  // name - as Symbol

		{ |dur = 1.0, gain = 0.0, riseTime = 0.01, decayTime = 0.01,
			minWinDur = 1.0, maxWinDur = 1.0,
			minSkipTime = 0.0, maxSkipTime = 0.0,
			minRate = 1, maxRate = 1,
			minDensity = 1, maxDensity = 4,
			winRand = 0.0,
			interp = 4,
			panAngle = 0,
			bufnum = 0,
			outBus = 0|  // UGen graph function

			// vars for UGens
			var ampEnvSig;
			var shuffleSig;
			var panSig;
			var outSig;

			// vars for control
			var numChannels = 2; // <-- stereo buffer - must be set in the UGen graph function!
			var amp = gain.dbamp;
			var pos = panAngle.neg / 45;
			var bufferDurReciprocal = BufDur.kr(bufnum).reciprocal;
			var minPoint = minSkipTime * bufferDurReciprocal;
			var maxPoint = maxSkipTime * bufferDurReciprocal;
			var pointerSig, winDurSig, densitySig, rateSig;

			// ----
			// synthesis

			// shuffler control
			pointerSig = WhiteNoise.kr.range(minPoint, maxPoint);
			winDurSig = WhiteNoise.kr.range(minWinDur, maxWinDur);
			densitySig = WhiteNoise.kr.range(minDensity, maxDensity);
			rateSig = WhiteNoise.kr.range(minRate, maxRate);


			// amplitude envelope
			ampEnvSig = EnvGen.kr(
				Env.linen(riseTime, dur - (riseTime + decayTime), decayTime),  // Env: *linen
				levelScale: amp,
				doneAction: Done.freeSelf
			);  // EnvGen (control rate)


			// sample shuffle playback
			shuffleSig = Warp1.ar(
				numChannels: numChannels,
				bufnum: bufnum,
				pointer: pointerSig,
				freqScale: rateSig,
				windowSize: winDurSig,
				overlaps: densitySig,
				windowRandRatio: winRand,
				interp: interp,
			);

			// apply -linen envelope
			// ... reuse playBufSig var
			// NOTE: we could have just passed ampEnvSig to the level arg of Balance2
			shuffleSig = shuffleSig * ampEnvSig;

			// stereo imager
			panSig = Balance2.ar(shuffleSig[0], shuffleSig[1], pos);  // Balance2 (audio rate)

			// assign to out
			outSig = panSig;

			Out.ar(
				outBus,  // out bus - set as an argument
				outSig
			)  // Out (audio rate)
		}
	);

});


~harmonies = [5, 12, 7, 19, 24, 3, -5, -7, -12, -14, -19, 0];
~midiadd = 61;
~time = 0.5;
~cutoff = 2000;
~pans = [-30, -20, -10, 0, 10, 20, 30];
~attackvalue = 0.05;
~buffpitch = 1;
~curr = ~buffers[0];
)

// CONTROLS (FOR MIDI)
/* ~playTask = MIDIFunc.cc({ |val, num, chan, src|
    ~task.play;
	~task.reset;
}, ccNum: 32);

~playTask2 = MIDIFunc.cc({ |val, num, chan, src|
    ~task2.play;
	~task2.reset;
}, ccNum: 33);

~playTask3 = MIDIFunc.cc({ |val, num, chan, src|
    ~task3.play;
	~task3.reset;
}, ccNum: 34);

~endTask = MIDIFunc.cc({ |val, num, chan, src|
    ~task.stop;
	~task.reset;
}, ccNum: 48);

~endTask2 = MIDIFunc.cc({ |val, num, chan, src|
    ~task2.stop;
	~task2.reset;
}, ccNum: 49);

~endTask3 = MIDIFunc.cc({ |val, num, chan, src|
    ~task3.stop;
	~task3.reset;
}, ccNum: 50);

~buffpad = MIDIFunc.cc({ |val, num, chan, src|
	(val == 127).if({~playbuffnote = ~playbuff.note.buffer_(~buffers.choose).dur_(2 * 2).pitch_(~buffpitch).play});
	(val == 0).if({~playbuffnote.free});
}, ccNum: 35);

~playbuffrate = MIDIFunc.cc({ |val, num, chan, src|
	~buffpitch = val.linexp(0, 127, 0.25, 4);
	~playbuffnote.pitch_(~buffpitch);
}, ccNum: 3);

~pitch = MIDIFunc.cc({ |val, num, chan, src|
    ~midiadd = val;
}, ccNum: 0);


~timeknob = MIDIFunc.cc({ |val, num, chan, src|
	~time = (val / 127);
}, ccNum: 16);

// respond to the first fader on page 1
    ~buffosc = OSCFunc({ |msg, time, addr, recPort|
        ~playbuff.note.buffer_(~buffers.choose).dur_(2 * 2).pitch_(~buffpitch).play;
    }, '/1/fader2', ~iPhone);
 */

//TASKS
(

~task = Task({
    loop({     // loop the whole thing
		~currpan = ~pans.choose;
		~synth.note.freq_((~harmonies.choose + 60).midicps).cutoff_(~cutoff).pan_(~currpan)
		.attack_(~attackvalue).play;
		~synth.note.freq_((~harmonies.choose + 60).midicps).cutoff_(~cutoff).pan_(~currpan)
		.attack_(~attackvalue).play;
		~synth.note.freq_((~harmonies.choose + 60).midicps).cutoff_(~cutoff).pan_(~currpan)
		.attack_(~attackvalue).play;
		~synth.note.freq_((~harmonies.choose + 60).midicps).cutoff_(~cutoff).pan_(~currpan)
		.attack_(~attackvalue).play;
		(~time).wait;

    });
});

)

~task.play;
~task.resume;
~task.stop;
~task.reset;

MIDIFunc.trace;
OSCFunc.trace(false);
