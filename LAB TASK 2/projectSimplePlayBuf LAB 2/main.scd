OSCFunc.trace
OSCFunc.trace(false)

// listen from the SuperCollider language
n = NetAddr.localAddr;

// receive from the local address
o = OSCFunc({arg msg, time, addr, recvPort; msg.asArray.postln;}, 'hello/world', n);

// send a message
n.sendMsg('/hello/world', "This is the language sending you a message!");

(

MIDIIn.connectAll;
MIDIFunc.trace();
(Document.current.dir +/+ "functions.scd").load;
(Document.current.dir +/+ "synthDefs.scd").load;

~server = Server.default;
~server.options_(ServerOptions.new.numOutputBusChannels_(16).memSize_(2**21));

~server.waitForBoot({


	~buffers = PathName(Document.current.dir +/+ "sounds/").files.collect{ |pathName, increment|
		CtkBuffer(pathName.fullPath).load
	};

	~audioBuss = CtkAudio.play(2, server: ~server);

	~rateSpec = ControlSpec(0.25, 4, 'exp');
	~panSpec = ControlSpec(-45, 45, 'lin');

	~buffer = ~buffers.choose;
	~start = 0.0;
	~note = ~myPlayBufPNotes[\dxarts46x_stereoPlayBuf].note(
		starttime: ~start,
	)
	.dur_(~buffer.duration)
	.bufnum_(~buffer)
	.outBus_(~audioBuss)
	.loop_(1)
	.play;

	~reverbNote = ~myPlayBufPNotes['reverb'].note(addAction: 'tail')
	.in_(~audioBuss).play;

	~midiRate = MIDIFunc.cc({ |val, num, chan, src|
		~note.rate_(~rateSpec.map(val.linlin(0, 127, 0, 1)));
	}, ccNum: 0);

	~midiPan = MIDIFunc.cc({ |val, num, chan, src|
		~note.panAngle_(~panSpec.map(val.linlin(0, 127, 0, 1)));
	}, ccNum: 1);

})

)