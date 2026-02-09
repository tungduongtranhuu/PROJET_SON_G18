import("stdfaust.lib");

osc(f) = os.sawtooth(f) * 0.1; 

// Définition des accords
chord(0) = osc(110) + osc(130.81) + osc(164.81); // Am
chord(1) = osc(87.31) + osc(130.81) + osc(174.61); // F
chord(2) = osc(130.81) + osc(164.81) + osc(196.00); // C
chord(3) = osc(98.00) + osc(146.83) + osc(196.00); // G

// --- CONTRÔLEUR DE CHANGEMENT D'ACCORD ---
// ma.SR est la fréquence d'échantillonnage (généralement 44100)
// Chaque (2 * ma.SR) échantillons équivaut à 2 secondes
speed = 1 * ma.SR; 
timer = ba.period(speed); // Génère une impulsion toutes les 2 secondes
index = ba.count(timer) % 3; // Compte 0, 1, 2, 3 puis recommence

// Sélectionne l'accord en fonction de l'index
progression = chord(int(index)); 
// =================================
// PARAMETERS (KNOBS)
// =================================
drive = hslider("Drive", 10, 1, 100, 0.1) : si.smoo;
tone  = hslider("Tone", 0.5, 0, 1, 0.01) : si.smoo;
level = hslider("Level", 0.8, 0, 1.5, 0.01) : si.smoo;
mix   = hslider("Mix", 1.0, 0, 1.0, 0.01) : si.smoo;

// =================================
// 1. PRE-FILTER
// =================================
gate_thr = hslider("Noise Gate", -60, -90, -20, 0.1) : ba.db2linear : si.smoo;
// Seuil de porte de bruit (Noise Gate)
noise_gate(x) = x * (abs(x) > gate_thr : si.smoo);
pre_filter = fi.highpass(2, 150) : fi.lowpass(2, 6000);


// =================================
// 2. DISTORTION CORE
// =================================
dist_core(x) = x * drive : ma.tanh; 

// =================================
// 3. TONE CONTROL (Tilt Style)
// =================================
tone_stack(x) = (x : low_path) + (x : high_path)
with {
    low_path  = fi.lowpass(2, 800) * (1 - tone);
    high_path = fi.highpass(2, 1200) * tone;
};

// =================================
// 4. CABINET SIM
// =================================
cab_sim = fi.lowpass(4, 5000);

// =================================
// 5. FULL EFFECT CHAIN (WET SIGNAL)
// =================================
full_effect = noise_gate : pre_filter : dist_core : tone_stack : cab_sim;

// =================================
// MAIN PROCESS (Dry/Wet Mix & Final Level)
// =================================
// Étape 1 : Sépare le signal original en deux chemins (_ <:)
// Étape 2 : Le premier chemin traverse l'effet et est multiplié par Mix
// Étape 3 : Le second chemin reste en Dry et est multiplié par (1 - Mix)
// Étape 4 : Additionne les deux chemins (:> +) puis applique le niveau final

process = progression <: (full_effect * mix), (_ * (1 - mix)) :> + : *(level);


// Drive (10 - 100) : Détermine le caractère agressif du son. Cette commande amplifie le signal avant la saturation : plus la valeur est élevée, plus le son devient saturé et riche en harmoniques.

// Tone (0.0 - 1.0) : Permet de sculpter la couleur sonore.

// Réglé sur 0 : Son chaud, sombre, avec beaucoup de basses (proche des sonorités jazz).
// Réglé sur 1 : Son clair, incisif, avec beaucoup d'aigus (proche des sonorités rock/metal).

// Mix (0.0 - 1.0) : Pourcentage entre le signal clean et le signal traité.


// Level (0.0 - 1.5): Volume totale de la sortie. Les signaux de distorsion sont généralement très forts ; utilisez ce bouton pour les réduire à un niveau sûr.

// Noise Gate (-90dB đến -20dB): Seuil du filtre de souffle. Lorsqu'on ne joue pas, le circuit de distorsion génère un bruit parasite très gênant ; ce bouton permet de couper ce son lorsque le signal est trop faible.