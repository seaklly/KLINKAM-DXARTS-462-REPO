
(
MIDIIn.connectAll;
~buffers = PathName(Document.current.dir +/+ "sounds/").files.collect{ |pathName, increment|
		CtkBuffer(pathName.fullPath).load
	};

s.options_(ServerOptions.new.memSize_(2**21));
)
(
~synth = CtkSynthDef(\default, { |out = 0, freq = 440, amp = 0.05, pan = 0, cutoff = 20000, attack = 0.01,
	reverbmix = 0.4|
    var snd, env, lpf, comb, ring;
	snd = Saw.ar(freq);
	env = EnvGen.kr(Env.perc(attack, 0.3), doneAction: 2);
	lpf = LPF.ar(snd * env, env.range(cutoff * 0.1, cutoff));
	comb = CombAZN.ar(lpf, 20, 1720 * env + 220, -60, 'add');
	ring = FreeVerb2.ar(comb, comb, reverbmix, 0.5, 0.6);

    Out.ar(ring, Pan2.ar(ring, pan));
});

~playbuff = CtkSynthDef(\playbuf, {|buffer, out = 0, rate = 1, dur, pitch = 1, window = 0.2|
	var warp, env;
	warp = Warp1.ar(2, buffer, Line.kr(0, 1, dur), pitch, window, -1, 8);
	Out.ar(out, warp);
});


~harmonies = [5, 12, 7, 19, 24, 3, -5, -7, -12, -14, -19, 0];
~midiadd = 61;
~time = 0.5;
~cutoff = CtkControl.lfo(SinOsc, 0.1 , 1500, 20000);
~pans = [-30, -20, -10, 0, 10, 20, 30];
~attackvalue = 0.05;
~buffpitch = 1;
~curr = ~buffers[0];
)
(
// CONTROLS
~playTask = MIDIFunc.cc({ |val, num, chan, src|
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
)

//TASKS
(
~task = Task({
    loop({     // loop the whole thing
		/*~currpan = ~pans.choose;
		~synth.note.freq_((~midiadd + ~harmonies.choose).midicps).cutoff_(~cutoff).pan_(~currpan)
		.attack_(~attackvalue).play;
		~synth.note.freq_((~midiadd + ~harmonies.choose).midicps).cutoff_(~cutoff).pan_(~currpan)
		.attack_(~attackvalue).play;
		~synth.note.freq_((~midiadd + ~harmonies.choose).midicps).cutoff_(~cutoff).pan_(~currpan)
		.attack_(~attackvalue).play;
		~synth.note.freq_((~midiadd + ~harmonies.choose).midicps).cutoff_(~cutoff).pan_(~currpan)
		.attack_(~attackvalue).play;
		(~time).wait;*/

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

~task2 = Task({
    loop({     // loop the whole thing
		~currpan = ~pans.choose;
		~synth.note.freq_((~midiadd + ~harmonies.choose).midicps).cutoff_(1720).pan_(~currpan).attack_(3)
		.reverbmix_(0.9).play;
		(~time * 4).wait;

    });
});

~task3 = Task({
    loop({     // loop the whole thing
		~currpan = ~pans.choose;
		~synth.note.freq_((~midiadd + ~harmonies.choose + 12).midicps).cutoff_(10000).pan_(~currpan).attack_(0.01)
		.reverbmix_(0.9).play;
		(~time / 2).wait;

    });
});

)



~task.play;
~task.resume;
~task.stop;
~task.reset;

~task2.play;
~task2.stop;

~task3.play;
~task3.stop;

MIDIFunc.trace;
OSCFunc.trace(true);
