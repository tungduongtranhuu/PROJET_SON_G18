import("stdfaust.lib");

duration    = hslider("[1] Duration (s)[unit:s]", 0.3, 0.01, 1.0, 0.001) : si.smooth(0.9999);
feedback    = hslider("[2] Feedback Coef",         0.4, 0.0,  0.95, 0.01)  : si.smooth(0.999);
volume      = hslider("[3] Volume",                0.8, 0.0,  1.0,  0.01)  : si.smooth(0.999);

// Filtre passe-bas dans la boucle de feedback —
// atténue progressivement les hautes fréquences à chaque répétition
// → couleur analogique plus chaude
lpf_cutoff  = 3500.0;

// Saturation douce : tanh limite l’amplitude
// au lieu d’un hard clip numérique
// drive=1.5 → saturation légère lorsque le feedback est élevé
soft_sat(x) = ma.tanh(x * 1.5) / 1.5;

// ======================================================
// LIGNE DE RETARD AVEC BOUCLE DE FEEDBACK
// ======================================================

max_delay_samp = 192000;
delay_samp = duration * float(ma.SR);

// Boucle : entrée + (feedback → LPF → saturation → × coefficient)
// Ordre de traitement :
// LPF d’abord, saturation ensuite
// → les aigus sont filtrés AVANT la compression
echo_engine(x) = loop ~ _
with {
    loop(fb_signal) =
        de.fdelay(max_delay_samp, delay_samp,
                  x + (fb_signal 
                       : fi.lowpass(2, lpf_cutoff)
                       : soft_sat
                       : *(feedback)));
};

// ======================================================
// FLUX DU SIGNAL : Dry + Wet → Volume général
// ======================================================

// wet_mix fixe à 0.7 — équilibre interne dry/wet
// Le paramètre Volume contrôle le niveau global en sortie
wet_mix = 0.7;

echo_process(x) = (x + echo_engine(x) * wet_mix) * volume;

// ======================================================
// PROCESS
// ======================================================

process = _ : echo_process <: _,_;
