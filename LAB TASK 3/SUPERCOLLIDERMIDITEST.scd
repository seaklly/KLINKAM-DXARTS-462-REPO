MIDIIn.connectAll;
s.options_(ServerOptions.new.memSize_(2**21));
(
~synth = CtkSynthDef(\default, { |out = 0, freq = 440, amp = 0.05, pan = 0, cutoff = 2000|
    var snd, env, lpf, comb, ring;
	snd = Saw.ar(freq);
	env = EnvGen.kr(Env.perc(0.01, 0.2), doneAction: 2);
	lpf = LPF.ar(snd * env, cutoff * env + 880);
	comb = CombAZN.ar(snd * env, 20, 1720 * env + 220, -60, 'add');
	ring = FreeVerb2.ar(comb, comb, 0.3, 0.5, 0.6);

    Out.ar(ring, Pan2.ar(ring, pan));
});

~harmonies = [5, 12, 7, 19, 24, 3, -5, -7, -12, -14, -19, 0];
~midiadd = 65;
~time = 0.5;
)

// CONTROLS
~playTask = MIDIFunc.cc({ |val, num, chan, src|
    ~task.play;
	~task.reset;
}, ccNum: 32);

~endTask = MIDIFunc.cc({ |val, num, chan, src|
    ~task.stop;
	~task.reset;
}, ccNum: 48);

~pitch = MIDIFunc.cc({ |val, num, chan, src|
    ~midiadd = val;
}, ccNum: 0);


~timeknob = MIDIFunc.cc({ |val, num, chan, src|
	~time = (val / 127);
}, ccNum: 16);
// Using Task so you can pause the sequence
(
~task = Task({
    loop({     // loop the whole thing
		~synth.note.freq_((~midiadd + ~harmonies.choose).midicps).play;
		~synth.note.freq_((~midiadd + ~harmonies.choose).midicps).play;
		~synth.note.freq_((~midiadd + ~harmonies.choose).midicps).play;
		~synth.note.freq_((~midiadd + ~harmonies.choose).midicps).play;
		(~time + 0.03).wait;
    });
});
)
~task.play;
~task.resume;
~task.stop;
~task.reset;



MIDIFunc.trace;