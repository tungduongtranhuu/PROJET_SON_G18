import("stdfaust.lib");

drive = hslider("Drive", 15, 1, 50, 0.1);
tone  = hslider("Tone",  4000, 1500, 8000, 10);
volume = hslider("Volume", 0.7, 0, 1, 0.01);

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

input_stage = fi.highpass(1, 75);

soft_clip(x) = x / (1 + abs(x)^1.5);
hard_clip(x) = ba.if(x > 0,
    x / (1 + abs(x)^2.1),
    x / (1 + abs(x)^2.8)) * 1.1;
fuzz_clip(x) = ma.tanh(x * 2.8) * 0.9;

stage1_gain = drive * 0.25 + 0.35;
stage2_gain = drive * 0.28;
stage3_gain = max(0.9, drive * 0.12);

// ===== DRIVE MAKEUP GAIN =====
// Khi drive tăng, signal bị clip nhiều hơn → RMS gần như không đổi
// nhưng peak gain vẫn leo, dùng log để bù mượt
drive_makeup = 1.0 / (0.4 + (drive / 50.0) * 1.8);

stage1(x) = x * stage1_gain : soft_clip : *(0.95);
stage2(x) = x * stage2_gain : hard_clip : *(0.9);
stage3(x) = x * stage3_gain : fuzz_clip : *(0.85);

bass_preserve = fi.low_shelf(3, 150);

mid_amount_calc = -7 * (drive / 50);
mid_amount = max(-2.5, mid_amount_calc);
mid_control = fi.peak_eq(mid_amount, 680, 1.0);

treble_freq = max(1800.0, tone);
treble_shape = fi.lowpass(2, treble_freq);

// ===== TONE MAKEUP GAIN =====
// Tone thấp → lowpass cắt nhiều tần số → energy giảm → bù lên
// Tone cao → ít bị cắt → không cần bù nhiều
tone_makeup = 1.0 + (8000.0 - tone) / 8000.0 * 0.6;

tone_stack =
    bass_preserve :
    mid_control :
    treble_shape :
    *(tone_makeup);  // bù ngay sau khi filter cắt tần số

speaker_response =
    fi.lowpass(2, 4800) :
    fi.highpass(1, 80);

hf_noise_filter =
    fi.lowpass(2, 6000) :
    fi.high_shelf(-2, 4500);

glue_comp = co.compressor_mono(-11, 3.0, 0.003, 0.07);

distortion_chain =
    input_stage
    : glue_comp 
    : noise_gate 
    : stage1
    : stage2
    : stage3
    : *(drive_makeup)  // bù volume sau 3 stage distortion
    : co.compressor_mono(-12, 2.0, 0.005, 0.1)
    : tone_stack       // đã có tone_makeup bên trong
    : speaker_response
    : hf_noise_filter
    : *(volume)
    : fi.dcblocker;

process = _ : distortion_chain <: _,_;