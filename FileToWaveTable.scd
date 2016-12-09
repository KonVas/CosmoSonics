//Initial tests using a file with floats

(
f = File("FileReadTestNum.sc", "w"); //create a file in computer
(1..10).do{|n| f.write(n.asString ++ " ") }; //fill the file with data
f.close;
)

x = FileReader.readInterpret("FileReadTestNum.sc"); // read the content of the file
a = x.flat.normalize(-1, 1).resamp1(512, 'sine'); // resample

x.collect{|i| a = i.asFloat.normalize(-1, 1).resamp1(512, 'linear') }; // or this way too

b = Buffer.alloc(s, 1024);
b.loadCollection(Signal.newFrom(a).asWavetable);
b.plot;

x = {Osc.ar(b, 80)}.play; //test is playing
