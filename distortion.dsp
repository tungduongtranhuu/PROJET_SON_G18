import("stdfaust.lib");
import("compressors.lib");


// ===== PARAMETERS =====
drive = hslider("Drive", 12, 1, 40, 0.1);
tone  = hslider("Tone", 3000, 800, 6000, 1);

// ===== FIXED INTERNAL SETTINGS =====
n         = 2.;      // diode shape cố định
offset    = 0.05;     // asymmetry nhẹ
cubicMix  = 0.3;      // làm mềm nhẹ
threshold = 0.;     // gate cố định

// ===== NONLINEARITY =====
diode(x) = x / pow((1 + abs(x)^n), 1/n);
cubic(x) = x - x*x*x/3;
softshape(x) = x*(1-cubicMix) + cubic(x)*cubicMix;

// ===== FILTERS =====
dcblock = fi.dcblocker;
preHPF  = fi.highpass(1, 200);
postHPF = fi.highpass(1, 120);
lpf     = fi.lowpass(1, tone);
cab     = fi.lowpass(2,3800 );
mid =  _ <: _, (fi.resonbp(750, 0.8, 1) : *(0.4)) :> +;

// ===== NOISE GATE =====
gate(x) = x * (abs(x) > threshold);

// ===== COMPRESSOR =====
comp = co.compressor_mono(-18, 2.5, 0.002, 0.08);

distCore(x) = (x + offset) : comp : *(drive) : diode : softshape;

// ===== PROCESS (INPUT REAL) =====
process =
    _ :
    dcblock :
    preHPF :
    mid :
    distCore:
    postHPF :
    lpf :
    cab :
    gate;
