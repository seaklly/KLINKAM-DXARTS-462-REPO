// OSC CONTROLS (USE WITH TOUCH DESIGNER MEDIAPIPE)
(
~server = Server.default;

~server.waitForBoot({

	~oscfreq = 0;
    ~server.sync;

    ~td = NetAddr("127.0.0.1", 65535);

    // respond to the first fader on page 1
    ~timeOSC = OSCFunc({ |msg, time, addr, recPort|
		~time = msg[1] + 0.02;
	}, '/h1:pinch_midpoint:distance', ~td);


	~attackOSC = OSCFunc({ |msg, time, addr, recPort|
		~attackvalue = msg[1] + 0.0001;
	}, '/h2:pinch_midpoint:distance', ~td);


	~cutoffOSC = OSCFunc({ |msg, time, addr, recPort|
		~cutoff = msg[1].linexp(0, 0.6, 440, 20000)
	}, '/h2:index_finger_tip:y', ~td);

	~bufferTrigOSC = OSCFunc({ |msg, time, addr, recPort|
		if ( msg[1] < 0.05, {
			~warp.note.dur_(4).bufnum_(~buffers[0]).minRate_(~time).maxRate_(4 * ~time).maxSkipTime_(17.0).gain_(10).maxWinDur_(~attackvalue + 1.0)
			.decayTime_(1).winRand_(5).play;
		})
	}, '/h2:pinch_midpoint:distance', ~td);


})
)
OSCFunc.trace(false)
OSCFunc.trace
~current = true;
