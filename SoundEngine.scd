// =====================================================================
// SuperCollider Workspace
// =====================================================================

//Requires file Streamer.scd

(
Spec.add(\detune, [0.1, 10]);
Spec.add(\diff, [0, 1]);
Spec.add(\damp, [0, 1]);
Spec.add(\modDepth, [0, 50]);
Spec.add(\modFreq, [0, 10]);
Spec.add(\size, [0.5, 3]);
Spec.add(\fb, [0, 1]);
Spec.add(\dtime, [0, 2]);
)

(
Ndef(\pad, {
	var drift = LFNoise2.kr(0.1, \detune.kr(0.2, 0.3));
	var sig = WhiteNoise.ar(0.01);//WhiteNoise.ar(0.01);
	//	sig = sig * EnvGen.kr(Env.perc(0.01, 0.1), Dust.kr(0.3));
	sig = Ringz.ar(sig * 0.1, {ExpRand(120.0, 660.0) + drift}!8, Rand(300, 500) ).distort;
	sig = Splay.ar(sig);
	sig  = LeakDC.ar(sig);
	sig = Greyhole.ar(sig,
		\dtime.kr(0.1),
		\damp.kr(0.1),
		\size.kr(1),
		\diff.kr(0.707),
		\fb.kr(0.1),
		\modDepth.kr(0.01),
		\modFreq.kr(2)
	);
	sig = HPF.ar(sig * 0.8);
	sig = Compander.ar(sig, sig.reverse);
}).play
)

Ndef(\pad).fadeTime = 0.1;

(
~timeInterval = 0.01;
t = Pseq(~time, inf).asStream; // t needs fixing
x = Pseq(~x, inf).asStream;
y = Pseq(~y, inf).asStream;
z = Pseq(~z, inf).asStream;

Ndef(\pad)[1] = \set -> Pbind(
	\dur, Pfunc{ ~timeInterval + rrand(0.1, 0.5)},
	\detune, Pfunc{ \detune.asSpec.map(x.next) },
	 \dtime, Pfunc{ \dtime.asSpec.map(x.next) },
	\damp, Pfunc{ \damp.asSpec.map(x.next) },
	\size, Pfunc{ \size.asSpec.map(y.next) },
	\diff, Pfunc{ \diff.asSpec.map(z.next) },
	\fb, Pfunc{ \fb.asSpec.map(x.next) },
	\modDepth, Pfunc{ \modDepth.asSpec.map(y.next) },
	\modFreq, Pfunc{ \modFreq.asSpec.map(z.next) }
);
)


(
w = Window.new("ControlPanel", bounds:Rect(0, 0, 400, 320)).layout_(
	VLayout(
		HLayout(
			Button(parent:w)
			.states_([
				["stream OFF"],
				["stream ON"]
			])
			.action_({|butt|
				if(butt.value == 1){
				}{
				};
			}),
			~slider = Slider(parent:w)
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
w.onClose_({"n"});

Ndef(\pad).edit(parent:w);
)

Ndef(\pad).clear(8);

Ndef(\pad).edit;