// =====================================================================
// SuperCollider Workspace
// =====================================================================

/* A dictionary that represents time, x, y and z axis of the data, and also representing single elements as array e.g [time, x, y, z] */
(
//f = FileReader.read("/Users/Home_KV//Downloads/magnetic_storm_14-20:06:2016/20120714MSTK.F01.txt", true, true); // read the content of the large file

f = FileReader.read("Data/20100603MSTK_f.txt".resolveRelative, true, true); // wait until data is loaded

~dataFunc = ({|i| // function to select elements from the file
	a = f.collect({|data| data[i].asFloat });
	a.normalize;
});

~data = (); // dictionary to stash data;

~data.put(\t, ~dataFunc.value(0));
~data.put(\x, ~dataFunc.value(1));
~data.put(\y, ~dataFunc.value(2));
~data.put(\z, ~dataFunc.value(3));

~time = ~data[\t];
~x_axis = ~data[\x];
~y_axis = ~data[\y];
~z_axis = ~data[\z];

[~time, ~x_axis, ~y_axis, ~z_axis].do{| items | items.plot };
)

p = Pxrand(~time, inf).asStream;
p.next; // Stream works pattern style

// proof of concept

(
~dur = 0.05;

SynthDef("sineTones", { arg out, freq=120.0, sustain=0.3, amp=0.8, pan;
 var env, sig;
 env = EnvGen.kr(Env.sine(sustain), 1, doneAction:2);
 5.do { sig = SinOsc.ar(freq + Rand(1.0, 2.01), 0, amp)};
 Out.ar(out, sig * env * amp);
}).add;

Pdef(\Chronos, Pbind(\instrument, \sineTones, \dur, Pfunc{~dur}, \freq, Pxrand(~time, inf).linlin(-1, 1, 100, 220.0)));

Pdef(\X_Axis, Pbind(\instrument, \sineTones, \dur, Pfunc{~dur}, \freq, Pxrand(~x_axis, inf).linlin(-1, 1, 100, 220.0)));

Pdef(\Y_Axis, Pbind(\instrument, \sineTones, \dur, Pfunc{~dur}, \freq, Pxrand(~y_axis, inf).linlin(-1, 1, 100, 220.0)));

Pdef(\Z_Axis, Pbind(\instrument, \sineTones, \dur, Pfunc{~dur}, \freq, Pxrand(~z_axis, inf).linlin(-1, 1, 100, 220.0)));


Ndef(\chronos)[0] = Pdef(\Chronos);
Ndef(\x_axis)[0] = Pdef(\X_Axis);
Ndef(\y_axis)[0] = Pdef(\Y_Axis);
Ndef(\z_axis)[0] = Pdef(\Z_Axis);
)

Pdef.clear;

(
~timeInterval = 1;

var point, dataSize;
point = 0;
dataSize = f.size;

Tdef(\streamer,{
	dataSize.do{
		if(a.notNil){
				~currentElement = f[point = point + 1 % dataSize].postln;
			//~currentSingleElement = ~time[point = point + 1 % dataSize].postln;
		};
		~timeInterval.wait;
	}
});

w = Window.new("ControlPanel", bounds:Rect(100, 500, 400, 120)).layout_(
	VLayout(
		HLayout(
			Button(parent:w)
			.states_([
				["stream OFF"],
				["stream ON"]
			])
			.action_({|butt|
				if(butt.value == 1){
					Ndef(\noise).play
				}{
					Ndef(\noise).pause
				};
			}),
			~slider = Slider(parent:nil)
			.action_({|sl|
				~timeInterval = sl.value.round(0.01).max(0.01);
				~numBox.value = sl.value.round(0.01).max(0.01);
			})
			.value_(1.0)
			.orientation_(\horizontal),
			~numBox = NumberBox(w)
		)
	)
).front;
w.onClose_({Tdef(\streamer).stop;});
)

NdefMixer(s)