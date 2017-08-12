// =====================================================================
// SuperCollider Workspace
// =====================================================================

// Sonification of the Magnetic Solar data.
f = FileReader.read("/Users/Home_KV//Downloads/magnetic_storm_14-20:06:2016/20120714MSTK.F01.txt", true, true); //read the content of the large file
//Or this
f = FileReader.read("/Users/Home_KV/Dev/CosmoSonics/Data/20100603MSTK_f.txt", true, true); // wait until data is loaded

b = Buffer.read(s, Platform.resourceDir ++ "/sounds/a11wlk01-44_1.aiff");
b.free
(
Tdef(\streamer, {
	var fileSize, raw, point;
	point = 0;
	fileSize = f.size;
	p = Pseq(f, inf).asFloat.asStream;
	fileSize.do{
		(3 + 0.5.rand).wait;
		raw = point = point + 1 % fileSize;
		d = f[raw].drop(1).asFloat; //representing time, x, y, and z axis of the solar magnetic fields.
		d = (x:d[0], y:d[1], z:d[2]).values.flat;
		//d = (d.values.flat.sum + d[\x] + d[\y] + d[\z] / 1000).asStream;
		Ndef(\gendy).set(\freq, (d.choose / d.sum).postln );
	};
	});
Tdef(\streamer).play;
)

(
Ndef(\gendy,{|freq = 0.1| Mix.fill(4,{
	var sig;
	Pan2.ar(
		BufRd.ar(b.numChannels, b, Gendy3.ar(6.rand,
		6.rand,SinOsc.kr(0.1,0,0.49,0.51),SinOsc.kr(0.13,0,0.49,0.51), freq,
		SinOsc.kr(0.17, 0, 0.0049,0.0051), SinOsc.kr(0.19,0,0.0049,0.0051))
		) ,0, 0.1)});
}).play;
)

d.choose * 0.1

Ndef(\gendy).fadeTime = 0.1;

Tdef(\streamer).pause;
Tdef(\streamer).resume;
Tdef(\streamer).stop;
Tdef(\streamer).reset