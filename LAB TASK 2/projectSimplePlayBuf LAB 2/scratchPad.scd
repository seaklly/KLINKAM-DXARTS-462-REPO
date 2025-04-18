/*
Project Title: projectSimplePlayBuf
Date: Wed Jan 29 13:48:27 2025

DXARTS 46x: Sound Series Tutorial
Authors: Joseph Anderson, Wei Yang, et al.
Affiliation: DXARTS, University of Washington (https://dxarts.washington.edu/)
License: GPLv3 (https://www.gnu.org/licenses/gpl-3.0.en.html)
*/

/*
scratch here
*/

/*
For examples see:

HelpBrowser.openLink("link::Tutorials/Getting Practice/ProjectSHARCWTsWPs::");
HelpBrowser.openLink("link::Tutorials/Getting Practice/ProjectRissetsBells::");
*/


/*
_scratchPad_ is the place to write test / scratch code, testing out ideas and
working on code that we'll later formally include in the project.

*/

/////////////// explore interaction with sclang & interpreter ///////////////

// -------------------------
// load functions

/*
First off, we'll load the functions found in the file named _functions_.
*/

(Document.current.dir +/+ "functions.scd").load;

currentEnvironment.keys;


// -------------------------
// load data

/*
We'll usually place various data in the file named _data_.
*/

(Document.current.dir +/+ "data.scd").load;

currentEnvironment.keys;


// inspect data
// ...


/////////////// explore interaction with scsynth & interpreter ///////////////


// -------------------------
// load synthDefs (& ctkProtoNotes)

/*
Let's load the synthDefs found in the file named _synthDefs_
*/

(Document.current.dir +/+ "synthDefs.scd").load;


// check... what's been loaded
currentEnvironment.keys;


// -------------------------
// list project synthDefs


// -------------------------
// play w/ synthDef(s)

// boot (realtime) server
s.boot;


// -------------------------
// prepare wavetable(s) and wave packet(s) for synthesis



// -------------------------
// synthesize some sounds (via -note)

// let's first start up some scopes
FreqScope.new;
Stethoscope.new;



// instantiate some notes


// let's try playing...


// when we're all finished, we should "clean up" and free up the space buffers use on the server

// free... when finished...