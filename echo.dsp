import("stdfaust.lib");

aa = library("aanl.lib");
ef = library("misceffects.lib");
ba = library("basics.lib");
os = library("oscillators.lib");

// Interface commande
d = hslider("duration", 0.1, 0.0, 0.25, 0.01) : si.smooth(0.999);
f = hslider("feedback coef", 0.4, 0.0, 1.0, 0.01) : si.smooth(0.999);
g = hslider("gain", 1.0, 0.0, 7.0, 0.01) : si.smooth(0.999);

// Son
process = _ : *(g) : ef.echo(0.25, d, f) : aa.hardclip;