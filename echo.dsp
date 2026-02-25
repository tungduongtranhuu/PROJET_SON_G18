import("stdfaust.lib");

duration    = hslider("[1] Duration (s)[unit:s]", 0.3, 0.01, 1.0, 0.001) : si.smooth(0.9999);
feedback    = hslider("[2] Feedback Coef",         0.4, 0.0,  0.95, 0.01)  : si.smooth(0.999);
volume      = hslider("[3] Volume",                0.8, 0.0,  1.0,  0.01)  : si.smooth(0.999);

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

lpf_cutoff  = 3500.0;

soft_sat(x) = ma.tanh(x * 0.5) / 0.5;

max_delay_samp = 44100;
delay_samp = duration * float(ma.SR);


echo_engine(x) = loop ~ _
with {
    loop(fb_signal) =
        de.fdelay(max_delay_samp, delay_samp,
                  x + (fb_signal 
                       : fi.lowpass(1, lpf_cutoff)
                       : *(feedback)));
};


wet_mix = 0.7;

echo_process(x) = (x + echo_engine(x) * wet_mix) 
                  : soft_sat
                  : *(volume);

process = _ : noise_gate : echo_process <: _,_;
