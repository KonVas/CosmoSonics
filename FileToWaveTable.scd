(
f = File("FileReadTestNum.sc", "w");
(1..10).do{|n| f.write(n.asString ++ " ") };
f.close;
)

x = FileReader.readInterpret("FileReadTestNum.sc");
a = x.flat.normalize(-1, 1).resamp1(512, 'sine');

x.collect{|i| a = i.asFloat.normalize(-1, 1).resamp1(512, 'linear') }; // or this way too

b = Buffer.alloc(s, 1024);
b.loadCollection(Signal.newFrom(a).asWavetable);
b.plot;

x = {Osc.ar(b, 80)}.play; //test is playing
