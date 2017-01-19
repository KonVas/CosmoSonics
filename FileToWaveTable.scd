//Initial tests using a file with floats

//(
//f = File("~/Downloads/20100603MSTK_f.txt.sc", "w"); //create a file in the computer
//(1..10).do{|n| f.write(n.asString ++ " ") }; //fill the file with data
//f.close;
//)

s.reboot
(
x = FileReader.read("Data/20100603MSTK_f.txt".resolveRelative, true, true); // read the content of the file

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
})
)

d[\t] = ~waveTableFunc.value(\t)
d[\x] = ~waveTableFunc.value(\x)
d[\y] = ~waveTableFunc.value(\y)
d[\z] = ~waveTableFunc.value(\z)

d[\t]

~time = d[\t].flat.normalize(-1, 1).resamp1(512, 'sine');
~x = d[\x].flat.normalize(-1, 1).resamp1(512, 'sine');
~y = d[\y].flat.normalize(-1, 1).resamp1(512, 'sine');
~z = d[\z].flat.normalize(-1, 1).resamp1(512, 'sine');

b = Buffer.alloc(s, 1024);
c = Buffer.alloc(s, 1024);
d = Buffer.alloc(s, 1024);
e = Buffer.alloc(s, 1024);

b.loadCollection(Signal.newFrom(~time).asWavetable);
c.loadCollection(Signal.newFrom(~x).asWavetable);
d.loadCollection(Signal.newFrom(~y).asWavetable);
e.loadCollection(Signal.newFrom(~z).asWavetable);


Ndef(\wavetable, {Osc.ar([b, c, d, e], [\freq.kr(8, 0.1), \freq.kr + 1]) * 0.8 }).play; //test is playing

Ndef(\wavetable)[1] = \xset -> Pbind(\dur, Prand(~time * 2, inf).max(0.2), \scale, Scale.mixolydian, \buf, Pxrand([b, c, d, e], inf), \freq, Prand(~z * 20, inf).max(8));

Ndef(\wavetable).fadeTime = 0.2

Ndef.clear;

e.plot

Ndef(\wavetable).edit

s.scope