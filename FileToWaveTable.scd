//Initial tests using a file with floats

//(
//f = File("~/Downloads/20100603MSTK_f.txt.sc", "w"); //create a file in the computer
//(1..10).do{|n| f.write(n.asString ++ " ") }; //fill the file with data
//f.close;
//)

s.reboot;

(
x = FileReader.read("/Users/Home_KV//Downloads/magnetic_storm_14-20:06:2016/20120714MSTK.F01.txt", true, true); // read the content of the file
//x = FileReader.read("Data/20100603MSTK_f.txt".resolveRelative, true, true); // read the content of the file

~dataFunc = ({|i| // function to select elements from the file
	a = x.collect({|data| data[i].asFloat });
	//a.normalize(0, 1);
});

d = ();
d.put(\t, ~dataFunc.value(0));
d.put(\x, ~dataFunc.value(1));
d.put(\y, ~dataFunc.value(2));
d.put(\z, ~dataFunc.value(3));

~waveTableFunc = ({|data|
	d[data].normalize(-1, 1);
});

d[\t] = ~waveTableFunc.value(\t);
d[\x] = ~waveTableFunc.value(\x);
d[\y] = ~waveTableFunc.value(\y);
d[\z] = ~waveTableFunc.value(\z);

~time = d[\t].flat.normalize(-1, 1).resamp1(512, 'sine');
~x = d[\x].flat.normalize(-1, 1).resamp1(512, 'sine');
~y = d[\y].flat.normalize(-1, 1).resamp1(512, 'sine');
~z = d[\z].flat.normalize(-1, 1).resamp1(512, 'sine');

b = Buffer.alloc(s, 1024);
c = Buffer.alloc(s, 1024);
d = Buffer.alloc(s, 1024);
e = Buffer.alloc(s, 1024);
)

(
fork{
	loop{0.05.wait;
		//j = ;
		j = d.values.flat.normalize(-1, 1).resamp0(512, 'sine');
		b.loadCollection(Signal.newFrom(j + Array.rand(32,0,1).cubed).asWavetable);
	};
}
)

b.plot;

Ndef(\wavetable, {|buf| Osc.ar(b.bufnum, d[\x] / 10, 0, 0.2) }).play; //test is playing


(
Ndef(\wavetable)[1] = \xset ->
Pbind(
	\dur, Prand(~time * 2, inf).max(0.2),
	\buf, Pxrand([b, c, d, e], inf),
);
)

Ndef(\wavetable).fadeTime = 0.25;

Ndef.clear;

Ndef(\wavetable).edit;
Ndef(\wavetable).play;

s.scope;
s.record;
s.stopRecording;