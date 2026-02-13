import("stdfaust.lib");

// ============================================
// GUITAR DISTORTION - FOR REAL GUITAR INPUT
// ============================================

// ===== CONTROLS =====
drive = hslider("Drive", 15, 1, 50, 0.1);
tone = hslider("Tone", 4000, 1500, 8000, 10);
volume = hslider("Volume", 0.7, 0, 1, 0.01);
d = hslider("duration", 0.1, 0.0, 0.25, 0.01) : si.smooth(0.999);
f = hslider("feedback coef", 0.4, 0.0, 1.0, 0.01) : si.smooth(0.999);

// ===== INPUT STAGE =====
input_stage = 
    fi.dcblocker :
    fi.highpass(1, 75);

// ===== TUBE-STYLE CLIPPING =====
soft_clip(x) = x / (1 + abs(x)^1.5);

hard_clip(x) = 
    ba.if(x > 0,
        x / (1 + abs(x)^2.1),
        x / (1 + abs(x)^2.8))
    * 1.1;

fuzz_clip(x) = ma.tanh(x * 2.8) * 0.9;

// ===== GAIN STAGES =====
stage1_gain = drive * 0.25 + 0.35;
stage1(x) = x * stage1_gain : soft_clip : *(0.95);

stage2_gain = drive * 0.28;
stage2(x) = x * stage2_gain : hard_clip : *(0.9);

stage3_gain = ba.if(drive * 0.12 > 0.9, drive * 0.12, 0.9);
stage3(x) = x * stage3_gain : fuzz_clip : *(0.85);

// ===== DYNAMIC TONE STACK =====
bass_preserve = fi.low_shelf(3, 150);

mid_amount_calc = -7 * (drive / 50);
mid_amount = ba.if(mid_amount_calc > -2.5, mid_amount_calc, -2.5);
mid_control = fi.peak_eq(mid_amount, 680, 1.0);

treble_min = 1800;
treble_freq = ba.if(tone > treble_min, tone, treble_min);
treble_shape = fi.lowpass(2, treble_freq);

tone_stack = 
    bass_preserve :
    mid_control :
    treble_shape;

// ===== CABINET SIMULATION =====
speaker_response = 
    fi.lowpass(2, 4800) :
    fi.highpass(1, 80);

// ===== HIGH-FREQUENCY NOISE FILTER =====
hf_noise_filter = 
    fi.lowpass(2, 6000) :
    fi.high_shelf(-2, 4500);

// ===== SIMPLIFIED NOISE GATE =====
gate_threshold = 0.01;
simple_gate(x) = ba.if(abs(x) > gate_threshold, x, x * 0.1);

// ===== COMPRESSOR =====
glue_comp = co.compressor_mono(-11, 3.0, 0.003, 0.07);

// ===== COMPLETE CHAIN =====
distortion_chain = 
    input_stage
    : glue_comp
    : stage1
    : stage2
    : stage3
    : co.compressor_mono(-12, 2.0, 0.005, 0.1)
    : tone_stack
    : speaker_response
    : hf_noise_filter
    : simple_gate
    : *(volume * 1.2)
    : fi.dcblocker;



// ===== PROCESS =====
// Input từ guitar thật → Distortion → Stereo output
process = _ : distortion_chain  : ef.echo(0.25, d, f) : aa.hardclip <: _,_;