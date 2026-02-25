import("stdfaust.lib");

//Parameters
duration    = hslider("Duration", 0.3, 0.01, 1.0, 0.001) : si.smooth(0.9999);
feedback    = hslider("Feedback Coef",0.4, 0.0,  0.95, 0.01)  : si.smooth(0.999);
volume      = hslider("Volume",0.8, 0.0,  1.0,  0.01)  : si.smooth(0.999);
drive = hslider("Drive", 15, 1, 50, 0.1) : si.smooth(0.999);
tone  = hslider("Tone",  4000, 1500, 8000, 10) : si.smooth(0.999);


//Noise gate
gate_threshold = 0.008;
noise_gate(x) = x * smoothed_open(x)
with {
    env(x)           = abs(x) : si.smooth(ba.tau2pole(0.005));
    smoothed_open(x) =
        ba.if(env(x) > gate_threshold,       1.0,
        ba.if(env(x) > gate_threshold * 0.3,
              (env(x) - gate_threshold*0.3) / (gate_threshold*0.7),
              0.0));
};

//Echo process
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

echo_chain(x) = (x + echo_engine(x) * wet_mix) 
                  : soft_sat
                  : *(volume);



//Distortion process
input_stage = fi.highpass(1, 80);

soft_clip(x) = x / (1 + abs(x)^1.5);
hard_clip(x) = ba.if(x > 0,
    x / (1 + abs(x)^2.1),
    x / (1 + abs(x)^2.8)) * 1.1;
fuzz_clip(x) = ma.tanh(x * 2.8) * 0.9;

drive_norm = drive / 50.0;
drive_curve = pow(drive_norm, 0.6);   

stage1_gain = 0.5 + drive_curve * 4.0;
stage2_gain = 0.5 + drive_curve * 5.0;
stage3_gain = 0.8 + drive_curve * 2.0;


drive_makeup = 1.0 / (1.0 + drive_curve * 2.5);

stage1(x) = x * stage1_gain : soft_clip : *(0.95);
stage2(x) = x * stage2_gain : hard_clip : *(0.9);
stage3(x) = x * stage3_gain : fuzz_clip : *(0.85);

pick_attack =
    fi.peak_eq(4.0, 3500, 1.2);   


ts_hp      = fi.highpass(1, 720);       
ts_mid     = fi.peak_eq(3.0, 800, 0.9); 
ts_level(x)= x * 1.2;                   

ts_boost = ts_hp : ts_mid : ts_level;

bass_preserve = fi.low_shelf(3, 150);

mid_amount_calc = -3.0 * (drive / 50);
mid_amount = max(-3.0, mid_amount_calc);
mid_control = fi.peak_eq(mid_amount, 600, 1.0);

treble_freq = max(2000.0, tone);
treble_shape = fi.lowpass(2, treble_freq);

thrash_bite =
    fi.peak_eq(3.5, 2500, 1.0);


tone_makeup = 1.0 + (8000.0 - tone) / 8000.0 * 0.6;

tone_stack =
    bass_preserve :
    mid_control :
    treble_shape :
    *(tone_makeup);  

speaker_response =
    fi.lowpass(2, 4800) :
    fi.highpass(1, 50);

presence_boost =
    fi.peak_eq(2.8, 5200, 0.8);   

hf_noise_filter =
    fi.lowpass(2, 7000) :
    fi.high_shelf(-2, 4500);

glue_comp = co.compressor_mono(-11, 3.0, 0.003, 0.07);

distortion_chain =
    input_stage
    : glue_comp 
    : ts_boost 
    : pick_attack
    : stage1
    : stage2
    : stage3
    : *(drive_makeup)  
    : co.compressor_mono(-12, 2.0, 0.005, 0.1)
    : tone_stack      
    : thrash_bite
    : speaker_response
    : presence_boost
    : hf_noise_filter
    : co.compressor_mono(-6, 8.0, 0.001, 0.08)
    : *(volume)
    : fi.dcblocker;

process = _ : noise_gate : distortion_chain : echo_chain <: _,_;