// =====================================================================
// SuperCollider Workspace
// =====================================================================

/* A dictionary that represents time, x, y and z axis of the data, and also representing single elements as array e.g [time, x, y, z] */
(
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

[~time, ~x_axis, ~y_axis, ~z_axis].do{|items| items.plot };
)

p = Pxrand(~time, inf).asStream;
p.next; // Stream works pattern style

// proof of concept

(
~dur = 0.01;

SynthDef("sineTones", { arg out, freq, sustain= 0.3, amp=1, pan;
 var env, u=1;
 env = EnvGen.kr(Env.perc(0.01, sustain), 1, doneAction:2);
 5.do { var d; d = exprand(0.01, 1); u = SinOsc.ar(d * 300, u, rrand(0.1,1.2) * d, 1) };
 Out.ar(out, SinOsc.ar([u, u + 1] * freq, 0, amp * env));
}).add;


Pdef(\Chronos, Pbind(\instrument, \sineTones, \amp, 0.01, \dur, ~dur, \scale, Scale.minor, \freq, Pxrand(~time, inf).linlin(0, 1, 100, 1200.0))).play;
Pdef(\X_Axis, Pbind(\instrument, \sineTones, \amp, 0.02, \dur, ~dur,  \scale, Scale.lydian, \freq, Pxrand(~x_axis, inf).linlin(0, 1, 100, 220.0))).play;
Pdef(\Y_Axis, Pbind(\instrument, \sineTones, \amp, 0.3, \dur, ~dur,  \scale, Scale.mixolydian, \freq, Pxrand(~y_axis, inf).linlin(0, 1, 100, 660.0))).play;
Pdef(\Z_Axis, Pbind(\instrument, \sineTones, \amp, 0.4, \dur, ~dur,  \scale, Scale.phrygian, \freq, Pxrand(~z_axis, inf).linlin(0, 1, 100, 1220.0))).play;
PdefAllGui(16, nil, 300@300);
Pdef.all.do{_.quant = 0};
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