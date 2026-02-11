import("stdfaust.lib");

ef = library("misceffects.lib");
ba = library("basics.lib");
os = library("oscillators.lib");

// 1 trigger par seconde
trig = ba.beat(60);

// Compteur de notes
noteIdx = ba.counter(trig);

// Conversion en hauteur (gamme chromatique)
midi = 60 + (noteIdx % 12); // boucle sur 1 octave
freq = ba.midikey2hz(midi);

// Petite enveloppe
env = ba.spulse(ba.tempo(60)/4, trig);

// Son
process = os.osc(freq) * env * 0.3 : ef.echo(0.5, 0.25, 0.4); // echo(max echo duration in s, echo duration in s, feedback coefficient)