import("stdfaust.lib");


rate  = hslider("Rate[unit:Hz]", 0.8, 0.05, 5, 0.001);
depth = hslider("Depth[unit:ms]", 5.5, 0.5, 10, 0.01);
volume = hslider("Volume", 1.0, 0.0, 2.0, 0.01);


gate_threshold = 0.006;
noise_gate(x) = x * smoothed_open(x)
with {
    env(x)           = abs(x) : si.smooth(ba.tau2pole(0.005));
    smoothed_open(x) =
        ba.if(env(x) > gate_threshold,       1.0,
        ba.if(env(x) > gate_threshold * 0.3,
              (env(x) - gate_threshold*0.3) / (gate_threshold*0.7),
              0.0));
};

mix = 0.5;

baseDelay = 10; // ms


lfo = os.osc(rate);

drift = no.noise : si.smooth(ba.tau2pole(0.5)) * 0.02;

modDelay = baseDelay + depth * (lfo * 0.5) + drift;

delaySamples = modDelay/1000 * ma.SR;


chorus(x) = x
            : de.delay(44100, delaySamples)
            : fi.lowpass(1, 6000);   


process = _ : noise_gate : chorus : *(volume) <: _,_;