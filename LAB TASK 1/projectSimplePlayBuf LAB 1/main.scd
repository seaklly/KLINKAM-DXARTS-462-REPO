(

(Document.current.dir +/+ "functions.scd").load;
(Document.current.dir +/+ "synthDefs.scd").load;

~server = Server.default;
~server.options_(ServerOptions.new.numOutputBusChannels_(16).memSize_(2**21));

~server.waitForBoot({


	~buffers = PathName(Document.current.dir +/+ "sounds/").files.collect{ |pathName, increment|
		CtkBuffer(pathName.fullPath).load
	};

	~audioBuss = CtkAudio.play(1, server: ~server);
	10.do { |i|

		~buffer = ~buffers.choose;
		~start = 0.0.rrand(10.0);
		~myPlayBufPNotes[\dxarts46x_stereoPlayBuf].note(
			starttime: ~start,
			duration: ~buffer.duration
		)
		.dur_(~buffer.duration)
		.bufnum_(~buffer)
		.outBus_()
		.play;

		~reverbNote = ~myPlayBufPNotes['reverb'].note(addAction: 'tail')
		.in_(~audioBuss).play;
	}
})


)