// =====================================================================
// SuperCollider Workspace
// =====================================================================

f = FileReader.read("/Users/Home_KV//Downloads/magnetic_storm_14-20:06:2016/20120714MSTK.F01.txt", true, true); // read the content of the file

//f = FileReader.read("/Users/Home_KV/Dev/CosmoSonics/Data/20100603MSTK_f.txt", true, true);

(
~dataFunc = {|day = 0|
	~dayData = f[day].asFloat
}
)

(
Ndef(\daySonifier, {
	var sig;
	sig = Mix.ar([SinOsc.ar(\freq.kr(180))]);
	sig = sig.dup * 0.8;
	Pan2.ar(sig.sum);
}).play;
)

(
~counter = 0;
Tdef(\setDayVal, {
	f.size.do{
		~counter =  ~counter + 1 % f.size;
		~dayValues = ~dataFunc.value(day: ~counter).postln;
		{
			Splay.ar(
				SinOsc.ar(~dayValues.drop(1))
			)
			* EnvGen.kr(Env.perc(0.01, 0.01), doneAction:2)
		}.play;
			0.08.wait;
			}
	}).play
)

Tdef(\setDayVal).pause;
MKtl.find


j = MKtl('hid_1_logite', "logitech-extreme-3d-pro");
j.postElements
j.gui

j.elAt(\bt, \1).action_({|bt| })

(
~counter = 0;
Spec.add(\day, [0, f.size -1, \lin]);
j.elAt(\bt, \1).action_({|but|
	if(but.value == 1){
		{
			~counter = ~counter + 1 % f.size; 
			~dayValues = ~dataFunc.value(day: ~counter);
			Splay.ar(
				SinOsc.ar(
					~dayValues.drop(1) / 2, mul:0.3
				) * EnvGen.kr(Env.perc(0.01, 0.1), doneAction:2)
			)
		}.play;
		~dayValues.postln
	}
})
)

j.gui



