/// Individual human cognition, social behavior and task execution.

function human_dist_sq(_x1, _y1, _x2, _y2)
{
    return sqr(_x1 - _x2) + sqr(_y1 - _y2);
};

// ============================================================================
// THE BODY
// Anatomy is simulated locally. A wound is a real injury to a real part, not
// a subtraction from a health bar: it bleeds, hurts, clots, can rot, can take
// an organ with it, and leaves a scar when it finally closes.
// ============================================================================

function body_part_defs()
{
    if (!variable_global_exists("body_part_defs_data"))
    {
        global.body_part_defs_data = [
            { key: "head", name: "HEAD", display: "head", coverage: 0.07, bleed: 1.25, pain: 1.20,
              vital: true, organs: ["brain", "left_eye", "right_eye", "left_ear", "right_ear"] },
            { key: "neck", name: "NECK", display: "neck", coverage: 0.03, bleed: 1.55, pain: 1.15,
              vital: true, organs: ["throat", "spine"] },
            { key: "chest", name: "CHEST", display: "chest", coverage: 0.15, bleed: 1.25, pain: 1.00,
              vital: true, organs: ["heart", "left_lung", "right_lung", "spine"] },
            { key: "abdomen", name: "ABDOMEN", display: "abdomen", coverage: 0.12, bleed: 1.15, pain: 1.05,
              vital: true, organs: ["liver", "stomach", "intestines", "left_kidney", "right_kidney", "spine"] },
            { key: "pelvis", name: "PELVIS", display: "pelvis", coverage: 0.09, bleed: 0.95, pain: 1.00,
              vital: true, organs: ["intestines", "spine"] },
            { key: "left_upper_arm", name: "LEFT UPPER ARM", display: "left upper arm", coverage: 0.05, bleed: 0.90, pain: 0.85,
              vital: false, organs: [] },
            { key: "left_forearm", name: "LEFT FOREARM", display: "left forearm", coverage: 0.045, bleed: 0.85, pain: 0.85,
              vital: false, organs: [] },
            { key: "left_hand", name: "LEFT HAND", display: "left hand", coverage: 0.025, bleed: 0.70, pain: 1.20,
              vital: false, organs: [] },
            { key: "right_upper_arm", name: "RIGHT UPPER ARM", display: "right upper arm", coverage: 0.05, bleed: 0.90, pain: 0.85,
              vital: false, organs: [] },
            { key: "right_forearm", name: "RIGHT FOREARM", display: "right forearm", coverage: 0.045, bleed: 0.85, pain: 0.85,
              vital: false, organs: [] },
            { key: "right_hand", name: "RIGHT HAND", display: "right hand", coverage: 0.025, bleed: 0.70, pain: 1.20,
              vital: false, organs: [] },
            { key: "left_thigh", name: "LEFT THIGH", display: "left thigh", coverage: 0.065, bleed: 0.95, pain: 0.90,
              vital: false, organs: [] },
            { key: "left_shin", name: "LEFT SHIN", display: "left shin", coverage: 0.06, bleed: 0.80, pain: 1.00,
              vital: false, organs: [] },
            { key: "left_foot", name: "LEFT FOOT", display: "left foot", coverage: 0.03, bleed: 0.65, pain: 1.10,
              vital: false, organs: [] },
            { key: "right_thigh", name: "RIGHT THIGH", display: "right thigh", coverage: 0.065, bleed: 0.95, pain: 0.90,
              vital: false, organs: [] },
            { key: "right_shin", name: "RIGHT SHIN", display: "right shin", coverage: 0.06, bleed: 0.80, pain: 1.00,
              vital: false, organs: [] },
            { key: "right_foot", name: "RIGHT FOOT", display: "right foot", coverage: 0.03, bleed: 0.65, pain: 1.10,
              vital: false, organs: [] }
        ];
    }
    return global.body_part_defs_data;
};

function body_organ_defs()
{
    if (!variable_global_exists("body_organ_defs_data"))
    {
        global.body_organ_defs_data = [
            { key: "brain", name: "BRAIN", weight: 3.0, age: 0.80, vital: true, pain: 0.35 },
            { key: "heart", name: "HEART", weight: 3.0, age: 1.00, vital: true, pain: 0.90 },
            { key: "left_lung", name: "LEFT LUNG", weight: 2.0, age: 1.00, vital: true, pain: 0.60 },
            { key: "right_lung", name: "RIGHT LUNG", weight: 2.0, age: 1.00, vital: true, pain: 0.60 },
            { key: "liver", name: "LIVER", weight: 1.5, age: 0.85, vital: false, pain: 0.55 },
            { key: "stomach", name: "STOMACH", weight: 1.0, age: 0.60, vital: false, pain: 0.70 },
            { key: "intestines", name: "INTESTINES", weight: 1.2, age: 0.60, vital: false, pain: 0.80 },
            { key: "left_kidney", name: "LEFT KIDNEY", weight: 1.2, age: 0.95, vital: false, pain: 0.70 },
            { key: "right_kidney", name: "RIGHT KIDNEY", weight: 1.2, age: 0.95, vital: false, pain: 0.70 },
            { key: "spine", name: "SPINE", weight: 2.5, age: 0.70, vital: true, pain: 1.10 },
            { key: "throat", name: "THROAT", weight: 2.0, age: 0.40, vital: true, pain: 1.00 },
            { key: "left_eye", name: "LEFT EYE", weight: 0.5, age: 1.25, vital: false, pain: 0.90 },
            { key: "right_eye", name: "RIGHT EYE", weight: 0.5, age: 1.25, vital: false, pain: 0.90 },
            { key: "left_ear", name: "LEFT EAR", weight: 0.3, age: 1.35, vital: false, pain: 0.65 },
            { key: "right_ear", name: "RIGHT EAR", weight: 0.3, age: 1.35, vital: false, pain: 0.65 }
        ];
    }
    return global.body_organ_defs_data;
};

function body_find_part(_body, _key)
{
    for (var _i = 0; _i < array_length(_body.parts); _i++)
    {
        if (_body.parts[_i].key == _key) return _body.parts[_i];
    }
    return noone;
};

function body_find_organ(_body, _key)
{
    if (!variable_struct_exists(_body.organs, _key)) return noone;
    return variable_struct_get(_body.organs, _key);
};

function body_new(_h)
{
    var _body = {
        timer: random_range(0, 0.2),
        parts: [],
        organs: {},
        wounds: [],
        scars: [],
        conditions: [],
        chronic_pain: 0,
        disease: { active: false, name: "", timer: 0, severity: 0, contagious: false },
        blood_volume: 100,
        blood_max: 100,
        blood_pressure_sys: 120,
        blood_pressure_dia: 78,
        pulse: 68,
        respiration: 14,
        oxygen: 0.99,
        temperature: 36.8,
        consciousness: 1,
        shock: 0,
        pain: 0,
        infection_load: 0,
        wound_infection: 0,
        sepsis: 0,
        immune_response: 0,
        clotting: 1,
        bleed_rate: 0,
        care_quality: 0,
        last_doctor: -1,
        last_treatment: -999,
        last_injury: -999,
        death_cause: "",
        sepsis_notified: false,
        shock_notified: false,
        constitution: random_range(0.82, 1.18),
        healing: random_range(0.80, 1.20),
        immune_strength: random_range(0.80, 1.20),
        pain_tolerance: random_range(0.82, 1.18),
        lung_capacity: random_range(0.86, 1.14),
        heart_strength: random_range(0.86, 1.14),
        age_frailty: 0
    };

    if (_h.physical.build == "STURDY" || _h.physical.build == "BROAD") _body.constitution += 0.06;
    if (_h.physical.build == "SLIGHT") _body.constitution -= 0.04;
    if (_h.physical.height == "TALL") _body.lung_capacity += 0.04;
    if (_h.physical.height == "SHORT") _body.lung_capacity -= 0.02;

    var _part_defs = body_part_defs();
    for (var _part_i = 0; _part_i < array_length(_part_defs); _part_i++)
    {
        var _def = _part_defs[_part_i];
        array_push(_body.parts, {
            key: _def.key,
            name: _def.name,
            display: _def.display,
            coverage: _def.coverage,
            bleed_factor: _def.bleed,
            pain_factor: _def.pain,
            vital: _def.vital,
            organs: _def.organs,
            integrity: 1,
            integrity_cap: 1,
            capacity: 1,
            bleeding: 0,
            pain: 0,
            infection: 0,
            swelling: 0,
            numbness: 0,
            fracture: 0,
            burn: 0,
            bandaged: false,
            splinted: false,
            tourniquet: false,
            disabled: false,
            scar: 0,
            permanent_damage: 0,
            chronic_pain: 0
        });
    }

    var _organ_defs = body_organ_defs();
    for (var _organ_i = 0; _organ_i < array_length(_organ_defs); _organ_i++)
    {
        var _organ_def = _organ_defs[_organ_i];
        variable_struct_set(_body.organs, _organ_def.key, {
            key: _organ_def.key,
            name: _organ_def.name,
            weight: _organ_def.weight,
            age_factor: _organ_def.age,
            vital: _organ_def.vital,
            pain_factor: _organ_def.pain,
            integrity: 1,
            integrity_cap: 1,
            capacity: 1,
            bleeding: 0,
            infection: 0,
            pain: 0,
            scar: 0,
            permanent_damage: 0
        });
    }

    // Age is not a number in the corner. It is wear in the heart, the lungs,
    // the kidneys and the senses.
    _body.age_frailty = clamp((_h.age - ELDER_AGE) / 35, 0, 1);
    if (_body.age_frailty > 0)
    {
        for (var _age_organ_i = 0; _age_organ_i < array_length(_organ_defs); _age_organ_i++)
        {
            var _age_organ = body_find_organ(_body, _organ_defs[_age_organ_i].key);
            var _wear = _body.age_frailty * 0.24 * _age_organ.age_factor * random_range(0.7, 1.15);
            _age_organ.integrity = max(0.35, _age_organ.integrity - _wear);
        }
        _body.constitution -= _body.age_frailty * 0.10;
    }

    _h.body = _body;

    if (_h.physical.mark == "A SCAR")
    {
        var _mark_part = body_find_part(_body, "left_forearm");
        if (_mark_part != noone)
        {
            body_add_scar(_h, _mark_part, {
                part: _mark_part.key,
                part_display: _mark_part.display,
                kind: "cut",
                severity: 0.40,
                attacker: -1,
                time: _h.birth_time
            }, 0.32);
            array_push(_h.injuries, { text: "An old scar, cause unrecorded.", time: _h.birth_time });
        }
    }

    body_sync_summary(_h);
    return _body;
};

function body_sync_summary(_h)
{
    var _b = _h.body;
    if (!is_struct(_b)) return;

    var _tissue_sum = 0;
    var _tissue_weight = 0;
    var _chronic_sum = 0;
    for (var _pi = 0; _pi < array_length(_b.parts); _pi++)
    {
        var _part = _b.parts[_pi];
        _tissue_sum += clamp(_part.integrity, 0, 1) * _part.coverage;
        _chronic_sum += clamp(_part.chronic_pain, 0, 1) * _part.coverage;
        _tissue_weight += _part.coverage;
    }
    _b.chronic_pain = _chronic_sum / max(0.001, _tissue_weight);

    var _organ_sum = 0;
    var _organ_weight = 0;
    var _organ_defs = body_organ_defs();
    for (var _oi = 0; _oi < array_length(_organ_defs); _oi++)
    {
        var _organ = body_find_organ(_b, _organ_defs[_oi].key);
        if (_organ == noone) continue;
        var _organ_function = clamp(_organ.capacity, 0, 1) * (1 - clamp(_organ.infection, 0, 1) * 0.35);
        _organ_sum += _organ_function * _organ.weight;
        _organ_weight += _organ.weight;
    }

    var _tissue = _tissue_sum / max(0.001, _tissue_weight);
    var _organ_avg = _organ_sum / max(0.001, _organ_weight);
    var _blood = clamp((_b.blood_volume - 18) / 82, 0, 1);
    var _conscious = clamp(_b.consciousness, 0, 1);
    var _sepsis = clamp(_b.sepsis, 0, 1);
    var _starvation = clamp((_h.hunger - 0.90) / 0.10, 0, 1);

    var _hp = 100 * (0.35 * _blood + 0.35 * _organ_avg + 0.20 * _tissue + 0.10 * _conscious);
    _hp -= _sepsis * 30;
    _hp -= _starvation * 18;

    var _brain = body_find_organ(_b, "brain");
    var _heart = body_find_organ(_b, "heart");
    if ((_brain != noone && _brain.capacity <= 0.03) || (_heart != noone && _heart.capacity <= 0.03)) _hp = 0;

    _h.max_hp = 100;
    _h.hp = clamp(_hp, 0, 100);
    _h.pain = clamp(_b.pain * 100 * clamp(1.15 - _b.pain_tolerance * 0.15, 0.9, 1.15), 0, 100);
    _h.infected = (_b.disease.active || _b.infection_load > 0.28 || _b.sepsis > 0.12);
    _h.infection_timer = _b.disease.active ? _b.disease.timer : 0;

    var _conditions = [];
    if (_b.blood_volume < 72) array_push(_conditions, "BLOOD LOSS");
    if (_b.bleed_rate > 0.06) array_push(_conditions, "BLEEDING");
    if (_b.sepsis > 0.15) array_push(_conditions, "SEPSIS");
    else if (_b.infection_load > 0.28) array_push(_conditions, "WOUND FEVER");
    if (_b.disease.active) array_push(_conditions, "FEVER");
    else if (_b.temperature > 38.2) array_push(_conditions, "FEVER");
    if (_b.temperature < 35.0) array_push(_conditions, "HYPOTHERMIA");
    if (_b.shock > 0.45) array_push(_conditions, "SHOCK");
    if (_b.consciousness < 0.25) array_push(_conditions, "UNCONSCIOUS");
    if (_h.hunger > 0.92) array_push(_conditions, "STARVING");
    if (_h.energy > 0.92) array_push(_conditions, "EXHAUSTED");
    if (_b.chronic_pain > 0.22) array_push(_conditions, "CHRONIC PAIN");

    var _spine = body_find_organ(_b, "spine");
    if (_spine != noone && _spine.capacity < 0.35) array_push(_conditions, "PARALYSED");
    var _left_eye = body_find_organ(_b, "left_eye");
    var _right_eye = body_find_organ(_b, "right_eye");
    if (_left_eye != noone && _right_eye != noone && _left_eye.capacity < 0.20 && _right_eye.capacity < 0.20) array_push(_conditions, "BLIND");
    var _left_ear = body_find_organ(_b, "left_ear");
    var _right_ear = body_find_organ(_b, "right_ear");
    if (_left_ear != noone && _right_ear != noone && _left_ear.capacity < 0.20 && _right_ear.capacity < 0.20) array_push(_conditions, "DEAF");

    var _fractured = false;
    var _limb_broken = false;
    for (var _ci = 0; _ci < array_length(_b.parts); _ci++)
    {
        var _check_part = _b.parts[_ci];
        if (_check_part.fracture > 0.30) _fractured = true;
        if (!_check_part.vital && _check_part.integrity < 0.45) _limb_broken = true;
    }
    if (_fractured) array_push(_conditions, "FRACTURE");
    if (_limb_broken) array_push(_conditions, "LIMB DAMAGE");

    _b.conditions = _conditions;
    _h.conditions = _conditions;
};

function body_part_status(_part)
{
    if (_part == noone) return "UNKNOWN";
    if (_part.integrity <= 0.01) return "RUINED";
    if (_part.fracture > 0.30) return "FRACTURE";
    if (_part.infection > 0.55) return "INFECTED";
    if (_part.bleeding > 0.30) return "BLEEDING";
    if (_part.burn > 0.35) return "BURN";
    if (_part.disabled) return "DISABLED";
    if (_part.integrity < 0.62) return "INJURED";
    if (_part.swelling > 0.25) return "SWOLLEN";
    if (_part.scar > 0.25) return "SCARRED";
    if (_part.chronic_pain > 0.30) return "CHRONIC";
    if (_part.integrity < 0.95) return "BRUISED";
    return "SOUND";
};

function body_organ_status(_organ)
{
    if (_organ == noone) return "UNKNOWN";
    if (_organ.capacity <= 0.05) return "FAILING";
    if (_organ.infection > 0.45) return "INFECTED";
    if (_organ.integrity < 0.55) return "IMPAIRED";
    if (_organ.permanent_damage > 0.10) return "SCARRED";
    if (_organ.capacity < 0.80) return "STRAINED";
    return "SOUND";
};

function body_ailment_text(_h)
{
    if (_h.dead) return "DEAD";
    var _b = _h.body;
    if (_b.sepsis > 0.15) return "SEPSIS";
    if (_b.disease.active) return "FEVER";
    if (_b.infection_load > 0.28) return "WOUND FEVER";
    if (_b.bleed_rate > 0.05) return "BLEEDING";
    for (var _i = 0; _i < array_length(_b.parts); _i++)
    {
        if (_b.parts[_i].fracture > 0.30) return "FRACTURE";
    }
    if (_b.chronic_pain > 0.22) return "CHRONIC PAIN";
    if (_h.pain > 35) return "IN PAIN";
    return "NONE";
};

function body_overall_label(_h)
{
    if (_h.dead) return "DEAD";
    var _b = _h.body;
    if (_b.consciousness < 0.25) return "UNCONSCIOUS";
    if (_h.hp < 25) return "CRITICAL";
    if (_b.blood_volume < 55) return "BLEEDING OUT";
    if (_b.sepsis > 0.15) return "SEPTIC";
    if (_b.disease.active) return "FEVERISH";
    if (_h.pain > 55) return "IN AGONY";
    if (_h.hp < 65) return "WOUNDED";
    return "STABLE";
};

function body_wound_label(_kind)
{
    switch (_kind)
    {
        case "cut": return "CUT";
        case "puncture": return "PUNCTURE";
        case "blunt": return "BLUNT";
        case "bite": return "BITE";
        case "burn": return "BURN";
    }
    return "WOUND";
};

function body_wound_text(_kind, _part_display, _severity)
{
    var _depth = (_severity > 0.75) ? "grievous " : ((_severity > 0.45) ? "deep " : "");
    switch (_kind)
    {
        case "cut": return "A " + _depth + "cut to the " + _part_display + ".";
        case "puncture": return "A " + _depth + "puncture wound in the " + _part_display + ".";
        case "blunt": return "A " + _depth + "blow to the " + _part_display + ".";
        case "bite": return "A " + _depth + "bite on the " + _part_display + ".";
        case "burn": return "A " + _depth + "burn on the " + _part_display + ".";
    }
    return "A wound to the " + _part_display + ".";
};

function body_add_scar(_h, _part, _wound, _strength)
{
    if (!is_struct(_h.body) || _part == noone) return noone;
    var _b = _h.body;
    var _scar_strength = clamp(_strength, 0.05, 1);

    _part.scar = max(_part.scar, _scar_strength);
    _part.permanent_damage = clamp(_part.permanent_damage + _scar_strength * 0.20, 0, 0.75);
    _part.integrity_cap = clamp(1 - _part.permanent_damage, 0.22, 1);
    _part.integrity = min(_part.integrity, _part.integrity_cap);
    _part.chronic_pain = clamp(max(_part.chronic_pain, _scar_strength * 0.40) + _scar_strength * 0.06, 0, 1);

    if (_part.disabled || _part.integrity <= 0.01)
    {
        _part.disabled = true;
        _part.permanent_damage = max(_part.permanent_damage, 0.55);
        _part.integrity_cap = min(_part.integrity_cap, 0.45);
        _part.integrity = min(_part.integrity, _part.integrity_cap);
        _part.chronic_pain = max(_part.chronic_pain, 0.55);
    }

    _part.capacity = clamp(_part.integrity - _part.fracture * 0.55 - _part.numbness * 0.60 - _part.pain * 0.10, 0, 1);
    if (_part.disabled) _part.capacity = 0;

    var _depth = (_scar_strength > 0.70) ? "grievous " : ((_scar_strength > 0.40) ? "deep " : "");
    var _scar = {
        part: _part.key,
        part_display: _part.display,
        kind: _wound.kind,
        severity: _wound.severity,
        strength: _scar_strength,
        time: _wound.time,
        attacker: _wound.attacker,
        text: "A " + _depth + "scar remains on the " + _part.display + "."
    };
    array_push(_b.scars, _scar);
    if (array_length(_b.scars) > 16) array_delete(_b.scars, 0, 1);

    return _scar;
};

function body_add_organ_scar(_organ, _severity)
{
    if (_organ == noone) return;
    _organ.scar = max(_organ.scar, _severity * 0.55);
    _organ.permanent_damage = clamp(_organ.permanent_damage + _severity * 0.18, 0, 0.70);
    _organ.integrity_cap = clamp(1 - _organ.permanent_damage, 0.30, 1);
    _organ.integrity = min(_organ.integrity, _organ.integrity_cap);
};

function body_apply_wound(_h, _kind, _damage, _attacker_id, _part_key)
{
    if (!is_struct(_h.body)) body_new(_h);
    if (_h.dead) return noone;

    var _b = _h.body;
    var _part = noone;
    if (_part_key != -1) _part = body_find_part(_b, _part_key);

    if (_part == noone)
    {
        var _defs = body_part_defs();
        var _roll = random(1);
        var _acc = 0;
        for (var _pick_i = 0; _pick_i < array_length(_defs); _pick_i++)
        {
            _acc += _defs[_pick_i].coverage;
            if (_roll <= _acc)
            {
                _part = body_find_part(_b, _defs[_pick_i].key);
                break;
            }
        }
    }
    if (_part == noone) _part = _b.parts[0];

    var _severity = clamp(_damage / 20, 0.05, 1.25);
    var _bleed_mult = 1;
    var _pain_mult = 1;
    var _penetration = 0.20;
    var _fracture_chance = 0;
    var _contamination = 0.30;

    switch (_kind)
    {
        case "cut":
            _bleed_mult = 1.15;
            _pain_mult = 0.95;
            _penetration = 0.22;
            _contamination = 0.32;
            break;
        case "puncture":
            _bleed_mult = 1.25;
            _pain_mult = 1.00;
            _penetration = 0.58;
            _contamination = 0.48;
            break;
        case "blunt":
            _bleed_mult = 0.30;
            _pain_mult = 1.35;
            _penetration = 0.06;
            _fracture_chance = 0.38;
            _contamination = 0.20;
            break;
        case "bite":
            _bleed_mult = 1.00;
            _pain_mult = 1.15;
            _penetration = 0.32;
            _contamination = 0.88;
            break;
        case "burn":
            _bleed_mult = 0.10;
            _pain_mult = 1.50;
            _penetration = 0.0;
            _contamination = 0.72;
            break;
    }

    _part.integrity = max(0, _part.integrity - _severity * random_range(0.14, 0.28));
    _part.bleeding = min(2, _part.bleeding + _severity * _part.bleed_factor * _bleed_mult * random_range(0.25, 0.45));
    _part.pain = min(1, _part.pain + _severity * _part.pain_factor * _pain_mult * random_range(0.55, 0.85));
    _part.swelling = min(1, _part.swelling + _severity * 0.45);

    if (_kind == "blunt" && random(1) < _fracture_chance + _severity * 0.22)
    {
        _part.fracture = max(_part.fracture, _severity);
    }
    if (_kind == "burn") _part.burn = max(_part.burn, _severity);

    var _wound = {
        part: _part.key,
        part_display: _part.display,
        kind: _kind,
        severity: _severity,
        bleeding: _severity * _part.bleed_factor * _bleed_mult * random_range(0.35, 0.58),
        pain: _severity * _part.pain_factor * _pain_mult * random_range(0.65, 0.95),
        infection: 0,
        contamination: clamp(0.12 + _severity * _contamination, 0, 1),
        clot: 0,
        healing: 0,
        treated: false,
        bandaged: false,
        splinted: false,
        notified: false,
        time: global.sim_time,
        attacker: _attacker_id,
        text: body_wound_text(_kind, _part.display, _severity)
    };
    array_push(_b.wounds, _wound);

    // A penetrating wound can reach whatever lies beneath the flesh.
    if (random(1) < _penetration && array_length(_part.organs) > 0)
    {
        var _organ_key = _part.organs[irandom(array_length(_part.organs) - 1)];
        var _organ = body_find_organ(_b, _organ_key);
        if (_organ != noone)
        {
            _organ.integrity = max(0, _organ.integrity - _severity * random_range(0.10, 0.32));
            _organ.bleeding = min(1, _organ.bleeding + _severity * random_range(0.10, 0.35));
            _organ.infection = min(1, _organ.infection + _wound.contamination * 0.25);
            _organ.pain = min(1, _organ.pain + _severity * _organ.pain_factor * 0.55);
            if (_severity > 0.45) body_add_organ_scar(_organ, _severity);
        }
    }

    // A blow to the head is its own kind of injury.
    if (_kind == "blunt" && _part.key == "head" && _severity > 0.30)
    {
        var _brain = body_find_organ(_b, "brain");
        if (_brain != noone)
        {
            _brain.integrity = max(0, _brain.integrity - _severity * random_range(0.08, 0.22));
            if (_severity > 0.50) body_add_organ_scar(_brain, _severity);
        }
    }

    _b.last_injury = global.sim_time;

    if (_severity > 0.35)
    {
        array_push(_h.injuries, { text: _wound.text, time: global.sim_time });
        if (array_length(_h.injuries) > 12) array_delete(_h.injuries, 0, 1);
        human_add_memory(_h, "WOUND", -0.8, 5, _attacker_id, _wound.text);
        human_add_thought(_h, "The wound in my " + _part.display + " throbs", -0.7, min(1, _severity), 140);
    }

    body_sync_summary(_h);
    return _wound;
};

function body_start_disease(_h, _name, _severity, _contagious)
{
    if (!is_struct(_h.body)) body_new(_h);
    var _b = _h.body;

    if (_b.disease.active)
    {
        _b.disease.severity = max(_b.disease.severity, _severity);
        return;
    }

    _b.disease.active = true;
    _b.disease.name = _name;
    _b.disease.timer = 0;
    _b.disease.severity = clamp(_severity, 0.10, 1);
    _b.disease.contagious = _contagious;
    _b.immune_response = max(_b.immune_response, 0.10);
    human_add_thought(_h, "A fever settles behind my eyes", -0.7, 0.55, 180);
    body_sync_summary(_h);
};

function body_cure_disease(_h)
{
    if (!is_struct(_h.body)) return;
    var _b = _h.body;
    _b.disease.active = false;
    _b.disease.timer = 0;
    _b.disease.severity = 0;
    _b.disease.contagious = false;
    _b.immune_response = 1;
    _h.immunity = 1;
    body_sync_summary(_h);
};

function body_needs_care(_h)
{
    if (_h.dead || !is_struct(_h.body)) return false;
    var _b = _h.body;
    if (_b.disease.active) return true;
    if (_b.bleed_rate > 0.02) return true;
    if (_h.pain > 25 && _b.chronic_pain < 0.30) return true;
    for (var _i = 0; _i < array_length(_b.wounds); _i++)
    {
        var _wound = _b.wounds[_i];
        if (_wound.bleeding > 0.05 || _wound.infection > 0.12 || !_wound.treated) return true;
    }
    return false;
};

function body_triage(_h)
{
    if (_h.dead || !is_struct(_h.body)) return 0;
    var _b = _h.body;
    var _score = (1 - _h.hp / 100) * 0.55
        + clamp(_b.pain, 0, 1) * 0.15
        + clamp(_b.infection_load, 0, 1) * 0.20
        + clamp(_b.sepsis, 0, 1) * 0.50
        + clamp(_b.bleed_rate, 0, 1) * 0.35
        + (1 - clamp(_b.consciousness, 0, 1)) * 0.25
        + (_b.disease.active ? 0.10 : 0);
    return clamp(_score, 0, 1);
};

function body_rest_care(_h, _dt, _quality)
{
    if (_h.dead || !is_struct(_h.body)) return;
    var _b = _h.body;
    var _q = clamp(_quality, 0, 1);
    _b.care_quality = min(1, max(_b.care_quality, _q));

    if (_b.bleed_rate < 0.05)
    {
        _b.blood_volume = min(100, _b.blood_volume + _dt * 0.020 * _q);
    }
    _b.infection_load = max(0, _b.infection_load - _dt * 0.002 * _q);
    _b.sepsis = max(0, _b.sepsis - _dt * 0.0015 * _q);
    _b.pain = max(0, _b.pain - _dt * 0.010 * _q);
    if (_b.disease.active) _b.disease.severity = max(0.05, _b.disease.severity - _dt * 0.002 * _q);
    body_sync_summary(_h);
};

function body_treat_patient(_healer, _patient, _dt, _has_infirmary)
{
    if (_patient.dead || !is_struct(_patient.body)) return;
    var _b = _patient.body;
    var _skill = clamp(_healer.skills.heal, 0, 1);
    var _care = _dt * (0.45 + _skill * 1.30 + (_has_infirmary ? 0.35 : 0));

    _b.care_quality = min(1, _b.care_quality + _care * 0.15);
    _b.pain = max(0, _b.pain - _care * 0.020);

    var _worst = -1;
    var _worst_score = -1;
    for (var _i = 0; _i < array_length(_b.wounds); _i++)
    {
        var _wound = _b.wounds[_i];
        var _score = _wound.bleeding * 1.6 + _wound.infection * 1.3 + _wound.severity * 0.6 - (_wound.treated ? 0.45 : 0);
        if (_score > _worst_score)
        {
            _worst_score = _score;
            _worst = _i;
        }
    }

    if (_worst != -1)
    {
        var _wound = _b.wounds[_worst];
        var _part = body_find_part(_b, _wound.part);

        _wound.bleeding = max(0, _wound.bleeding - _care * 0.22);
        _wound.infection = max(0, _wound.infection - _care * 0.045);
        _wound.contamination = max(0, _wound.contamination - _care * 0.28);
        _wound.pain = max(0, _wound.pain - _care * 0.055);
        _wound.clot = min(1, _wound.clot + _care * 0.09);
        _wound.treated = true;
        if (!_wound.bandaged && _wound.bleeding < 0.50) _wound.bandaged = true;
        _wound.healing = max(_wound.healing, 0.04);

        if (_part != noone)
        {
            _part.bleeding = max(0, _part.bleeding - _care * 0.22);
            _part.infection = max(0, _part.infection - _care * 0.035);
            _part.pain = max(0, _part.pain - _care * 0.045);
            _part.bandaged = _part.bandaged || _wound.bandaged;

            if (_part.fracture > 0.20 && !_part.splinted)
            {
                _part.splinted = true;
                _wound.splinted = true;
                human_add_thought(_patient, "The splint holds my " + _part.display + " steady", 0.35, 0.5, 140);
            }
        }

        _b.last_doctor = _healer.id;
        _b.last_treatment = global.sim_time;
    }

    if (_b.disease.active)
    {
        _b.disease.severity = max(0.05, _b.disease.severity - _care * 0.006);
        _b.immune_response = min(1, _b.immune_response + _care * 0.05);
        _b.last_doctor = _healer.id;
        _b.last_treatment = global.sim_time;
    }

    body_sync_summary(_patient);
};

function body_death_cause(_h)
{
    if (!is_struct(_h.body)) return "wounds";
    var _b = _h.body;
    if (_b.blood_volume <= 25 && _b.bleed_rate > 0.02) return "blood loss";
    if (_b.sepsis > 0.50) return "sepsis";
    if (_b.disease.active) return "fever";

    var _brain = body_find_organ(_b, "brain");
    if (_brain != noone && _brain.capacity <= 0.03) return "a head injury";
    var _heart = body_find_organ(_b, "heart");
    if (_heart != noone && _heart.capacity <= 0.03) return "heart failure";
    var _left_lung = body_find_organ(_b, "left_lung");
    var _right_lung = body_find_organ(_b, "right_lung");
    if (_left_lung != noone && _right_lung != noone
        && (_left_lung.capacity + _right_lung.capacity) * 0.5 <= 0.05) return "suffocation";

    if (_h.hunger > 0.95) return "hunger";
    if (_h.age > ELDER_AGE) return "old age";
    return "wounds";
};

function body_mobility(_h)
{
    if (_h.dead || !is_struct(_h.body)) return 0;
    var _b = _h.body;
    var _mobility = 1;

    _mobility *= clamp(0.30 + 0.70 * _b.consciousness, 0.12, 1);
    var _spine = body_find_organ(_b, "spine");
    if (_spine != noone && _spine.capacity < 0.35) _mobility *= 0.20;

    var _leg_function = 0;
    var _leg_parts = 0;
    var _leg_keys = ["left_thigh", "left_shin", "left_foot", "right_thigh", "right_shin", "right_foot"];
    for (var _i = 0; _i < array_length(_leg_keys); _i++)
    {
        var _leg = body_find_part(_b, _leg_keys[_i]);
        if (_leg == noone) continue;
        _leg_function += clamp(_leg.capacity, 0, 1);
        _leg_parts += 1;
    }
    if (_leg_parts > 0) _mobility *= clamp(0.35 + 0.65 * (_leg_function / _leg_parts), 0.12, 1);

    if (_h.pain > 45) _mobility *= 0.86;
    if (_b.chronic_pain > 0.20) _mobility *= clamp(1 - _b.chronic_pain * 0.28, 0.65, 1);
    if (_b.blood_volume < 60) _mobility *= 0.82;
    if (_b.temperature > 38.8) _mobility *= 0.88;
    if (_b.disease.active) _mobility *= 0.86;

    return clamp(_mobility, 0.10, 1);
};

function body_vision(_h)
{
    if (!is_struct(_h.body)) return 1;
    var _left = body_find_organ(_h.body, "left_eye");
    var _right = body_find_organ(_h.body, "right_eye");
    if (_left == noone || _right == noone) return 1;
    return clamp((_left.capacity + _right.capacity) * 0.5, 0, 1);
};

function body_hearing(_h)
{
    if (!is_struct(_h.body)) return 1;
    var _left = body_find_organ(_h.body, "left_ear");
    var _right = body_find_organ(_h.body, "right_ear");
    if (_left == noone || _right == noone) return 1;
    return clamp((_left.capacity + _right.capacity) * 0.5, 0, 1);
};

function body_dexterity(_h)
{
    if (!is_struct(_h.body)) return 1;
    var _left = body_find_part(_h.body, "left_hand");
    var _right = body_find_part(_h.body, "right_hand");
    if (_left == noone || _right == noone) return 1;
    return clamp((_left.capacity + _right.capacity) * 0.5, 0.15, 1);
};

function body_update(_h, _w, _dt)
{
    if (!is_struct(_h.body)) body_new(_h);
    var _b = _h.body;
    var _part_defs = body_part_defs();
    var _organ_defs = body_organ_defs();
    var _resting = (_h.task == TASK_SLEEP || _h.task == TASK_TREAT) || (_b.consciousness < 0.30);
    var _care = clamp(_b.care_quality, 0, 1);
    _b.care_quality = max(0, _b.care_quality - _dt * 0.18);
    var _rest_quality = clamp((_resting ? 1.0 : 0.35) + _care * 0.55, 0.35, 1.55);
    var _nutrition = clamp(1 - _h.hunger, 0, 1);
    var _frailty = clamp((_h.age - ELDER_AGE) / 35, 0, 1);
    var _immune = clamp(_h.immunity * _b.immune_strength, 0, 1);
    _b.age_frailty = _frailty;

    // Age does not simply subtract hit points. It wears down the organs that
    // keep a person alive.
    if (_frailty > 0)
    {
        for (var _age_i = 0; _age_i < array_length(_organ_defs); _age_i++)
        {
            var _age_organ = body_find_organ(_b, _organ_defs[_age_i].key);
            if (_age_organ == noone) continue;
            _age_organ.integrity = max(0, _age_organ.integrity - _dt * 0.00016 * _frailty * _age_organ.age_factor);
        }
    }

    // Disease runs its course through the immune response, not a hidden timer.
    if (_b.disease.active)
    {
        _b.disease.timer += _dt;
        _b.disease.severity = clamp(
            _b.disease.severity + _dt * (0.013 - _immune * 0.010 - _b.immune_response * 0.004),
            0.05, 1
        );
        _b.immune_response = min(1, _b.immune_response + _dt * (0.040 + _immune * 0.050));
    }
    else
    {
        _b.immune_response = max(0, _b.immune_response - _dt * 0.030);
    }

    // Local parts settle a little every tick; active wounds then write over
    // them. This keeps old swelling and pain from becoming permanent.
    for (var _reset_i = 0; _reset_i < array_length(_b.parts); _reset_i++)
    {
        var _reset_part = _b.parts[_reset_i];
        _reset_part.bleeding = max(0, _reset_part.bleeding - _dt * 0.022);
        _reset_part.pain = max(0, _reset_part.pain - _dt * 0.008);
        _reset_part.infection = max(0, _reset_part.infection - _dt * 0.0012);
        _reset_part.swelling = max(0, _reset_part.swelling - _dt * 0.004);
    }

    var _bleed_total = 0;
    var _pain_total = 0;
    var _wound_infection_total = 0;

    for (var _wi = array_length(_b.wounds) - 1; _wi >= 0; _wi--)
    {
        var _wound = _b.wounds[_wi];
        var _part = body_find_part(_b, _wound.part);
        if (_part == noone)
        {
            array_delete(_b.wounds, _wi, 1);
            continue;
        }

        if (_wound.treated)
        {
            _wound.infection = max(0, _wound.infection - _dt * (0.004 + _b.immune_response * 0.012));
        }
        else
        {
            _wound.infection = min(1, _wound.infection
                + _dt * (0.0022 + _wound.contamination * 0.0060) * (1.25 - _immune * 0.55));
        }

        if (_wound.infection > 0.30 && !_wound.notified)
        {
            _wound.notified = true;
            human_add_memory(_h, "INFECTION", -0.9, 6, -1, "The wound in the " + _wound.part_display + " turned angry.");
            human_add_thought(_h, "The wound in my " + _wound.part_display + " is hot and wrong", -0.8, 0.7, 180);
        }

        _wound.clot = min(1, _wound.clot + _dt * (0.010 + _b.clotting * 0.012) * (1 + (_resting ? 0.35 : 0)));
        var _bleed = _wound.bleeding * (1 - _wound.clot * 0.82);
        if (_wound.bandaged) _bleed *= 0.12;
        if (_part.tourniquet) _bleed = 0;

        _bleed_total += _bleed;
        _pain_total += _wound.pain * (1 + _wound.infection * 0.70);
        _wound_infection_total += _wound.infection * _wound.severity;

        _part.infection = max(_part.infection, _wound.infection * (_wound.treated ? 0.55 : 1));
        _part.pain = max(_part.pain, _wound.pain);
        _part.bleeding = max(_part.bleeding, _bleed);

        if (_wound.infection < 0.30 && _bleed < 0.06 && _wound.clot > 0.45)
        {
            _wound.healing += _dt * (0.0030 + _b.healing * 0.0030) * _rest_quality
                * (0.55 + _nutrition * 0.45) * (1 - _frailty * 0.50);

            if (_wound.healing >= 1)
            {
                var _scar_strength = clamp(_wound.severity * 0.55 + _wound.infection * 0.30
                    + ((_part.fracture > 0.20) ? 0.18 : 0), 0, 1);

                _part.integrity = min(_part.integrity_cap, _part.integrity + _wound.severity * 0.12);
                _part.bleeding = 0;
                _part.pain = max(0, _part.pain - 0.20);

                if (_scar_strength > 0.20 || _wound.severity > 0.35)
                {
                    var _scar = body_add_scar(_h, _part, _wound, _scar_strength);
                    array_push(_h.injuries, { text: _scar.text, time: global.sim_time });
                    if (array_length(_h.injuries) > 12) array_delete(_h.injuries, 0, 1);
                    human_add_memory(_h, "SCAR", (_scar_strength > 0.50) ? -0.35 : -0.10, 5, _wound.attacker, _scar.text);
                    if (_scar_strength > 0.40)
                    {
                        human_add_thought(_h, "The old wound in my " + _part.display + " aches", -0.35, 0.45, 240);
                    }
                }

                array_delete(_b.wounds, _wi, 1);
                continue;
            }
        }
    }

    _b.bleed_rate = _bleed_total;
    if (_b.bleed_rate > 0.001)
    {
        _b.blood_volume = max(0, _b.blood_volume - _b.bleed_rate * _dt * 1.10);
    }
    else
    {
        _b.blood_volume = min(100, _b.blood_volume + _dt * 0.012 * _rest_quality);
    }

    var _wound_count = max(1, array_length(_b.wounds));
    _b.wound_infection = clamp(_wound_infection_total / max(0.8, _wound_count * 0.70), 0, 1);
    _b.infection_load = max(_b.wound_infection, _b.disease.active ? _b.disease.severity : 0);

    var _sepsis_target = max(0, _b.infection_load - 0.55) * (1.70 - _immune * 0.70);
    _b.sepsis += (_sepsis_target - _b.sepsis) * min(1, _dt * 0.14);
    _b.sepsis = clamp(_b.sepsis, 0, 1);

    if (_b.sepsis > 0.15 && !_b.sepsis_notified)
    {
        _b.sepsis_notified = true;
        human_add_memory(_h, "ILLNESS", -1, 8, -1, "Fever and corruption spread through the blood.");
        human_add_thought(_h, "My blood is burning", -0.9, 0.85, 240);
    }
    if (_b.sepsis < 0.08) _b.sepsis_notified = false;

    _b.pain = clamp(_pain_total + _b.infection_load * 0.16 + (_b.disease.active ? 0.08 : 0)
        + _b.chronic_pain * 0.40, 0, 1);

    // Tissue heals under the same pressures as the whole person: food, rest,
    // cleanliness, age, and whether the wound is still open.
    for (var _heal_i = 0; _heal_i < array_length(_b.parts); _heal_i++)
    {
        var _heal_part = _b.parts[_heal_i];
        if (_heal_part.bleeding < 0.05 && _heal_part.infection < 0.20)
        {
            _heal_part.integrity = min(_heal_part.integrity_cap, _heal_part.integrity
                + _dt * 0.0012 * _b.healing * _rest_quality * (0.60 + _nutrition * 0.40));
        }
        if (_heal_part.splinted && _heal_part.fracture > 0)
        {
            _heal_part.fracture = max(0, _heal_part.fracture - _dt * 0.0035 * _b.healing * _rest_quality);
        }
        _heal_part.capacity = clamp(_heal_part.integrity - _heal_part.fracture * 0.55 - _heal_part.numbness * 0.60 - _heal_part.pain * 0.10, 0, 1);
        if (_heal_part.integrity <= 0.002) _heal_part.disabled = true;
        if (_heal_part.disabled) _heal_part.capacity = 0;
    }

    // Organs settle toward their structural capacity. The brain is handled
    // after oxygen, because a brain without blood is not a working brain.
    for (var _oi = 0; _oi < array_length(_organ_defs); _oi++)
    {
        var _organ = body_find_organ(_b, _organ_defs[_oi].key);
        if (_organ == noone) continue;

        if (_b.sepsis > 0.20)
        {
            _organ.infection = min(1, _organ.infection + _dt * 0.0012 * _b.sepsis);
        }
        else
        {
            _organ.infection = max(0, _organ.infection - _dt * 0.0012 * _b.immune_response);
        }
        _organ.bleeding = max(0, _organ.bleeding - _dt * 0.004 * _b.clotting);

        var _organ_capacity = clamp(_organ.integrity, 0, 1) * (1 - clamp(_organ.infection, 0, 1) * 0.55) * (1 - _organ.bleeding * 0.50);
        if (_organ.key == "heart") _organ_capacity *= _b.heart_strength;
        if (_organ.key == "left_lung" || _organ.key == "right_lung") _organ_capacity *= _b.lung_capacity;
        _organ.capacity += (_organ_capacity - _organ.capacity) * min(1, _dt * 0.25);

        if (_organ.infection < 0.20 && _organ.bleeding < 0.10 && _organ.integrity < _organ.integrity_cap)
        {
            _organ.integrity = min(_organ.integrity_cap, _organ.integrity + _dt * 0.0008 * _b.healing * _rest_quality);
        }
    }

    var _blood_fraction = clamp(_b.blood_volume / 100, 0, 1);
    var _left_lung = body_find_organ(_b, "left_lung");
    var _right_lung = body_find_organ(_b, "right_lung");
    var _heart = body_find_organ(_b, "heart");
    var _throat = body_find_organ(_b, "throat");
    var _lung_function = (_left_lung.capacity + _right_lung.capacity) * 0.5;
    var _perfusion = clamp(_blood_fraction * 0.68 + _heart.capacity * 0.32, 0, 1);
    var _oxygen_target = clamp(0.99 * _lung_function * _throat.capacity * (0.50 + 0.50 * _perfusion), 0, 1);
    _b.oxygen += (_oxygen_target - _b.oxygen) * min(1, _dt * 0.40);

    var _brain = body_find_organ(_b, "brain");
    var _brain_capacity = clamp(_brain.integrity, 0, 1) * (1 - clamp(_brain.infection, 0, 1) * 0.55) * (1 - _brain.bleeding * 0.50);
    var _brain_target = _brain_capacity * clamp(0.35 + 0.65 * _b.oxygen, 0, 1);
    _brain.capacity += (_brain_target - _brain.capacity) * min(1, _dt * 0.35);

    var _shock_target = clamp((1 - _blood_fraction) * 1.40 + _b.pain * 0.45 + _b.infection_load * 0.25
        + _b.disease.severity * 0.20, 0, 1);
    _b.shock += (_shock_target - _b.shock) * min(1, _dt * 0.15);

    var _conscious_target = clamp(_brain.capacity * (0.45 + 0.55 * _b.oxygen) - _b.shock * 0.75 - _b.pain * 0.18, 0, 1);
    _b.consciousness += (_conscious_target - _b.consciousness) * min(1, _dt * 0.35);

    var _fever = _b.disease.active ? _b.disease.severity * 2.0 : 0;
    _fever += _b.infection_load * 1.40 + _b.sepsis * 1.50;
    var _target_temperature = 36.8 + _fever;
    if (world_day_night(_w)) _target_temperature -= 0.10;
    if (_w.season == "FROST") _target_temperature -= 0.15;
    _b.temperature += (_target_temperature - _b.temperature) * min(1, _dt * 0.10);

    if (_b.temperature > 40.5)
    {
        _brain.integrity = max(0, _brain.integrity - _dt * 0.0012 * (_b.temperature - 40.5));
    }
    if (_b.temperature < 34.5)
    {
        _b.consciousness = max(0, _b.consciousness - _dt * 0.004);
    }

    _b.blood_pressure_sys = clamp(70 + 50 * _blood_fraction + 10 * _heart.capacity - 15 * _b.shock, 40, 190);
    _b.blood_pressure_dia = clamp(45 + 33 * _blood_fraction - 8 * _b.shock, 25, 120);
    _b.pulse = clamp(58 + (1 - _blood_fraction) * 75 + _b.pain * 20
        + _b.disease.severity * 20 + _b.infection_load * 15 + _h.fear * 12, 35, 190);
    _b.respiration = clamp(12 + _b.pain * 8 + _b.disease.severity * 7
        + (1 - _b.oxygen) * 35 + (1 - _throat.capacity) * 25, 6, 60);
    _b.clotting = clamp(0.72 + _b.organs.liver.capacity * 0.30 - _b.sepsis * 0.20, 0, 1);

    body_sync_summary(_h);
};

function human_new(_id, _civ, _age, _sex, _px, _py, _civ_struct)
{
    var _first_names = global.human_first_names;
    var _last_names = global.human_last_names;
    var _first = _first_names[irandom(array_length(_first_names) - 1)];
    var _last = _last_names[irandom(array_length(_last_names) - 1)];

    var _child = (_age < ADULT_AGE);

    var _heights = ["SHORT", "AVERAGE", "AVERAGE", "TALL"];
    var _builds = ["SLIGHT", "LEAN", "STURDY", "BROAD"];
    var _hairs = ["BLACK", "BROWN", "FAIR", "RUST", "ASH", "WHITE"];
    var _eyes = ["GREY", "GREEN", "BROWN", "BLUE", "AMBER"];
    var _marks = ["NONE", "A SCAR", "FRECKLES", "A BIRTHMARK", "A TATTOO", "A BROKEN NOSE"];
    var _voices = ["LOW", "QUIET", "BRIGHT", "ROUGH", "SMOOTH"];
    var _hands = ["RIGHT-HANDED", "RIGHT-HANDED", "LEFT-HANDED", "BOTH-HANDED"];
    var _foods = ["SMOKED FISH", "BARLEY BREAD", "WILD BERRIES", "ROOT STEW", "HONEY", "MUSHROOMS", "DRIED MEAT"];
    var _materials = ["OAK", "PINE", "GRANITE", "FLINT", "CLAY", "BRONZE", "ASH WOOD"];
    var _creatures = ["WOLVES", "RAVENS", "DEER", "RIVER FISH", "MOTHS", "HORSES"];
    var _dislikes = ["DEEP WATER", "CLOSED SPACES", "THE DARK", "CROWDS", "THUNDER", "SNAKES", "FIRE"];

    var _person = {
        id: _id,
        civ: _civ,
        name: _first + " " + _last,
        sex: _sex,
        age: _age,
        x: _px,
        y: _py,
        home_x: _civ_struct.home_x + random_range(-70, 70),
        home_y: _civ_struct.home_y + random_range(-70, 70),
        heading: random(360),
        move_speed: random_range(40, 48),
        job: _child ? JOB_CHILD : JOB_IDLE,
        goal: GOAL_IDLE,
        goal_score: 0,
        goal_timer: 0,
        task: TASK_IDLE,
        task_timer: 0,
        work_timer: 0,
        think_timer: random(1.2),
        action_cooldown: 0,
        hunger: random_range(0.10, 0.38),
        energy: random_range(0.10, 0.40),
        social: random_range(0.18, 0.55),
        purpose: random_range(0.10, 0.40),
        safety: random_range(0.10, 0.35),
        hp: 100,
        max_hp: 100,
        mood: random_range(52, 72),
        stress: 0,
        fear: 0,
        anger: 0,
        grief: 0,
        comfort: random_range(0.35, 0.68),
        esteem: random_range(0.35, 0.65),
        wonder: random_range(0.25, 0.62),
        hope: random_range(0.35, 0.72),
        pride: random_range(0.08, 0.38),
        shame: random_range(0, 0.14),
        loneliness: random_range(0.10, 0.42),
        pain: 0,
        last_meal: -999,
        last_sleep: -999,
        last_social: -999,
        reflect_timer: random_range(7, 18),
        mental_state: "steady",
        inner_voice: "waking",
        ambition_text: "",
        fear_text: "",
        ambition_progress: 0,
        ambition_met: false,
        epithet: "",
        birth_time: global.sim_time - _age / AGE_RATE,
        origin: (global.sim_time < 1) ? ((_age >= MARRIAGE_AGE) ? "FOUNDING GENERATION" : "EARLY SETTLER") : ("BORN IN " + _civ_struct.name),
        physical: {
            height: _heights[irandom(array_length(_heights) - 1)],
            build: _builds[irandom(array_length(_builds) - 1)],
            hair: _hairs[irandom(array_length(_hairs) - 1)],
            eyes: _eyes[irandom(array_length(_eyes) - 1)],
            mark: _marks[irandom(array_length(_marks) - 1)],
            voice: _voices[irandom(array_length(_voices) - 1)],
            hands: _hands[irandom(array_length(_hands) - 1)],
            favoured_food: _foods[irandom(array_length(_foods) - 1)],
            favoured_material: _materials[irandom(array_length(_materials) - 1)],
            favoured_creature: _creatures[irandom(array_length(_creatures) - 1)],
            dread: _dislikes[irandom(array_length(_dislikes) - 1)]
        },
        values: {
            family: clamp(0.5 + random_range(-0.3, 0.3), 0, 1),
            craft: clamp(0.5 + random_range(-0.3, 0.3), 0, 1),
            martial: clamp(0.5 + random_range(-0.3, 0.3), 0, 1),
            knowledge: clamp(0.5 + random_range(-0.3, 0.3), 0, 1),
            faith: clamp(0.5 + random_range(-0.3, 0.3), 0, 1),
            wealth: clamp(0.5 + random_range(-0.3, 0.3), 0, 1),
            community: clamp(0.5 + random_range(-0.3, 0.3), 0, 1),
            freedom: clamp(0.5 + random_range(-0.3, 0.3), 0, 1),
            honor: clamp(0.5 + random_range(-0.3, 0.3), 0, 1),
            tradition: clamp(0.5 + random_range(-0.3, 0.3), 0, 1)
        },
        facets: {
            patience: clamp(0.5 + random_range(-0.3, 0.3), 0, 1),
            artistic: clamp(0.5 + random_range(-0.3, 0.3), 0, 1),
            competitive: clamp(0.5 + random_range(-0.3, 0.3), 0, 1),
            romantic: clamp(0.5 + random_range(-0.3, 0.3), 0, 1),
            forgiving: clamp(0.5 + random_range(-0.3, 0.3), 0, 1),
            grudge: clamp(0.5 + random_range(-0.3, 0.3), 0, 1),
            wanderlust: clamp(0.5 + random_range(-0.3, 0.3), 0, 1),
            discipline: clamp(0.5 + random_range(-0.3, 0.3), 0, 1),
            humor: clamp(0.5 + random_range(-0.3, 0.3), 0, 1),
            vanity: clamp(0.5 + random_range(-0.3, 0.3), 0, 1),
            secrecy: clamp(0.5 + random_range(-0.3, 0.3), 0, 1),
            altruism: clamp(0.5 + random_range(-0.3, 0.3), 0, 1),
            spirituality: clamp(0.5 + random_range(-0.3, 0.3), 0, 1),
            materialism: clamp(0.5 + random_range(-0.3, 0.3), 0, 1)
        },
        aptitudes: {},
        labor_likes: [],
        labor_dislikes: [],
        thoughts: [],
        children: [],
        injuries: [],
        conditions: [],
        mentor_id: -1,
        student_count: 0,
        masterworks: 0,
        discoveries: 0,
        reflection: "",
        infected: false,
        infection_timer: 0,
        immunity: 0,
        partner_id: -1,
        family_id: -1,
        household_id: -1,
        parent_a: -1,
        parent_b: -1,
        wealth: random_range(0, 8),
        reputation: 50,
        joy: 0,
        faction: "hearth",
        carrying: false,
        carry_type: -1,
        carry_amount: 0,
        target_kind: TARGET_NONE,
        target_ref: -1,
        target_x: _px,
        target_y: _py,
        social_ref: -1,
        threat_ref: -1,
        threat_kind: TARGET_NONE,
        threat_dist: 999,
        near_humans: [],
        near_allies: 0,
        near_enemies: 0,
        near_kin: 0,
        relationships: [],
        memories: [],
        known_sites: [],
        danger_x: -1,
        danger_y: -1,
        danger_time: -999,
        last_gather_ref: -1,
        last_thought: "waking",
        last_event: "",
        kills: 0,
        gathered: 0,
        built: 0,
        taught: 0,
        births: 0,
        raids: 0,
        trade_runs: 0,
        trade_cooldown: 0,
        dead: false,
        traits: {
            bold: clamp(0.5 + random_range(-0.24, 0.24), 0.05, 0.95),
            compassion: clamp(0.5 + random_range(-0.24, 0.24), 0.05, 0.95),
            industry: clamp(0.5 + random_range(-0.24, 0.24), 0.05, 0.95),
            curiosity: clamp(0.5 + random_range(-0.24, 0.24), 0.05, 0.95),
            sociability: clamp(0.5 + random_range(-0.24, 0.24), 0.05, 0.95),
            aggression: clamp(0.5 + random_range(-0.24, 0.24), 0.05, 0.95),
            caution: clamp(0.5 + random_range(-0.24, 0.24), 0.05, 0.95),
            ambition: clamp(0.5 + random_range(-0.24, 0.24), 0.05, 0.95),
            loyalty: clamp(0.5 + random_range(-0.24, 0.24), 0.05, 0.95),
            greed: clamp(0.5 + random_range(-0.24, 0.24), 0.05, 0.95),
            tradition: clamp(0.5 + random_range(-0.24, 0.24), 0.05, 0.95),
            honesty: clamp(0.5 + random_range(-0.24, 0.24), 0.05, 0.95)
        },
        skills: {
            forage: _child ? random_range(0.02, 0.15) : random_range(0.15, 0.65),
            farm: _child ? random_range(0.02, 0.12) : random_range(0.10, 0.60),
            wood: _child ? random_range(0.02, 0.12) : random_range(0.10, 0.60),
            stone: _child ? random_range(0.02, 0.10) : random_range(0.08, 0.55),
            build: _child ? random_range(0.02, 0.10) : random_range(0.08, 0.60),
            combat: _child ? 0.02 : random_range(0.10, 0.65),
            heal: _child ? random_range(0.02, 0.10) : random_range(0.08, 0.60),
            research: _child ? random_range(0.02, 0.10) : random_range(0.08, 0.60),
            trade: _child ? random_range(0.02, 0.10) : random_range(0.08, 0.55),
            lead: _child ? 0.0 : random_range(0.05, 0.55),
            teach: _child ? 0.02 : random_range(0.05, 0.40)
        }
    };

    // Potential is separate from training. A high aptitude learns faster and
    // makes a person more likely to seek that kind of work.
    var _skill_keys = human_skill_keys();
    for (var _apt_i = 0; _apt_i < array_length(_skill_keys); _apt_i++)
    {
        variable_struct_set(_person.aptitudes, _skill_keys[_apt_i], random_range(0.70, 1.30));
    }

    // People have work they gravitate to and work they resent. The best
    // current skill is the strongest pull; a random second trade adds range.
    var _top_skill = "forage";
    var _top_value = -1;
    for (var _skill_i = 0; _skill_i < array_length(_skill_keys); _skill_i++)
    {
        var _skill_key = _skill_keys[_skill_i];
        if (_skill_key == "lead" || _skill_key == "teach") continue;
        var _skill_value = variable_struct_get(_person.skills, _skill_key);
        if (_skill_value > _top_value)
        {
            _top_value = _skill_value;
            _top_skill = _skill_key;
        }
    }

    var _preferred_job = human_job_for_skill(_top_skill);
    array_push(_person.labor_likes, _preferred_job);

    var _job_pool = [JOB_FOOD, JOB_WOOD, JOB_STONE, JOB_FARM, JOB_BUILD, JOB_CRAFT, JOB_HEAL, JOB_SCHOLAR, JOB_TRADER];
    var _second_job = _job_pool[irandom(array_length(_job_pool) - 1)];
    if (_second_job != _preferred_job) array_push(_person.labor_likes, _second_job);

    var _hated_job = _job_pool[irandom(array_length(_job_pool) - 1)];
    if (_hated_job == _preferred_job || _hated_job == _second_job) _hated_job = JOB_STONE;
    if (_hated_job != _preferred_job && _hated_job != _second_job) array_push(_person.labor_dislikes, _hated_job);

    _person.epithet = human_epithet(_person);
    _person.ambition_text = human_ambition_text(human_top_value_key(_person));
    _person.fear_text = human_fear_text(human_top_value_key(_person));

    // A person's public identity is a faction before it is a job.
    if (_person.traits.tradition > 0.62) _person.faction = "hearth";
    else if (_person.traits.industry > 0.64) _person.faction = "forge";
    else if (_person.traits.aggression > 0.64 || _person.traits.bold > 0.68) _person.faction = "wardens";
    else if (_person.traits.curiosity > 0.62) _person.faction = "lore";

    _person.body = body_new(_person);
    return _person;
};

function human_skill_keys()
{
    return ["forage", "farm", "wood", "stone", "build", "combat", "heal", "research", "trade", "lead", "teach"];
};

function human_has(_array, _value)
{
    for (var _i = 0; _i < array_length(_array); _i++)
    {
        if (_array[_i] == _value) return true;
    }
    return false;
};

function human_skill_label(_key)
{
    switch (_key)
    {
        case "forage": return "FORAGING";
        case "farm": return "FARMING";
        case "wood": return "WOODCUTTING";
        case "stone": return "QUARRYING";
        case "build": return "BUILDING";
        case "combat": return "COMBAT";
        case "heal": return "HEALING";
        case "research": return "SCHOLARSHIP";
        case "trade": return "TRADING";
        case "lead": return "LEADERSHIP";
        case "teach": return "TEACHING";
    }
    return "LABOUR";
};

function human_job_for_skill(_key)
{
    switch (_key)
    {
        case "farm": return JOB_FARM;
        case "wood": return JOB_WOOD;
        case "stone": return JOB_STONE;
        case "build": return JOB_BUILD;
        case "combat": return JOB_GUARD;
        case "heal": return JOB_HEAL;
        case "research": return JOB_SCHOLAR;
        case "trade": return JOB_TRADER;
        case "lead": return JOB_LEADER;
        case "teach": return JOB_SCHOLAR;
    }
    return JOB_FOOD;
};

function human_best_skill_key(_h)
{
    var _keys = human_skill_keys();
    var _best = "forage";
    var _best_value = -1;

    for (var _i = 0; _i < array_length(_keys); _i++)
    {
        var _key = _keys[_i];
        if (_key == "lead" || _key == "teach") continue;

        var _value = variable_struct_get(_h.skills, _key);
        if (_value > _best_value)
        {
            _best_value = _value;
            _best = _key;
        }
    }

    return _best;
};

function human_skill_title(_value)
{
    if (_value >= 0.85) return "MASTER";
    if (_value >= 0.65) return "EXPERT";
    if (_value >= 0.45) return "SKILLED";
    if (_value >= 0.25) return "ADEPT";
    return "NOVICE";
};

function human_train_skill(_h, _skill, _amount)
{
    var _aptitude = variable_struct_get(_h.aptitudes, _skill);
    var _before = variable_struct_get(_h.skills, _skill);
    var _after = min(1, _before + _amount * (0.55 + _aptitude * 0.85));
    variable_struct_set(_h.skills, _skill, _after);

    if (floor(_after * 4) > floor(_before * 4))
    {
        human_add_memory(_h, "SKILL", 0.35, 3, -1, "Reached a new level of " + human_skill_label(_skill) + ".");
        human_add_thought(_h, "My " + human_skill_label(_skill) + " is improving", 0.45, 0.45, 100);
    }

    return _after;
};

function human_add_thought(_h, _text, _valence, _strength, _duration)
{
    if (_h.dead) return;

    for (var _i = 0; _i < array_length(_h.thoughts); _i++)
    {
        if (_h.thoughts[_i].text == _text)
        {
            _h.thoughts[_i].valence = clamp(_valence, -1, 1);
            _h.thoughts[_i].strength = clamp(_strength, 0.05, 1);
            _h.thoughts[_i].expires = global.sim_time + _duration;
            return;
        }
    }

    array_push(_h.thoughts, {
        text: _text,
        valence: clamp(_valence, -1, 1),
        strength: clamp(_strength, 0.05, 1),
        expires: global.sim_time + _duration
    });

    if (array_length(_h.thoughts) > 7)
    {
        var _weakest = 0;
        var _weakest_score = 99;
        for (var _i = 0; _i < array_length(_h.thoughts); _i++)
        {
            var _score = _h.thoughts[_i].strength * max(0.2, abs(_h.thoughts[_i].valence));
            if (_score < _weakest_score)
            {
                _weakest_score = _score;
                _weakest = _i;
            }
        }
        array_delete(_h.thoughts, _weakest, 1);
    }
};

function human_strongest_thought(_h)
{
    var _best = noone;
    var _best_score = 0;

    for (var _i = 0; _i < array_length(_h.thoughts); _i++)
    {
        var _thought = _h.thoughts[_i];
        if (_thought.expires <= global.sim_time) continue;

        var _score = _thought.strength * (0.35 + abs(_thought.valence));
        if (_score > _best_score)
        {
            _best_score = _score;
            _best = _thought;
        }
    }

    return _best;
};

function human_thought_valence(_h)
{
    var _sum = 0;
    var _count = 0;

    for (var _i = 0; _i < array_length(_h.thoughts); _i++)
    {
        var _thought = _h.thoughts[_i];
        if (_thought.expires <= global.sim_time) continue;
        _sum += _thought.valence * _thought.strength;
        _count += 1;
    }

    if (_count == 0) return 0;
    return clamp(_sum / _count, -1, 1);
};

function human_mood_label(_h)
{
    if (_h.anger > 0.72) return "FURIOUS";
    if (_h.grief > 0.62) return "GRIEVING";
    if (_h.fear > 0.70) return "TERRIFIED";
    if (_h.mood < 18) return "DESPAIRING";
    if (_h.mood < 32) return "MISERABLE";
    if (_h.mood < 45) return "UNEASY";
    if (_h.mood < 58) return "STEADY";
    if (_h.mood < 72) return "CONTENT";
    if (_h.mood < 85) return "CHEERFUL";
    return "ELATED";
};

function human_mental_label(_h)
{
    if (_h.stress > 0.76) return "ON EDGE";
    if (_h.grief > 0.60) return "GRIEVING";
    if (_h.fear > 0.72) return "HAUNTED";
    if (_h.hope < 0.22) return "DESPAIR";
    if (_h.loneliness > 0.68) return "ISOLATED";
    if (_h.shame > 0.55) return "ASHAMED";
    if (_h.pride > 0.70) return "PROUD";
    return "STEADY";
};

function human_value_keys()
{
    return ["family", "craft", "martial", "knowledge", "faith", "wealth", "community", "freedom", "honor", "tradition"];
};

function human_value_label(_key)
{
    switch (_key)
    {
        case "family": return "FAMILY";
        case "craft": return "CRAFT";
        case "martial": return "MARTIAL PRIDE";
        case "knowledge": return "KNOWLEDGE";
        case "faith": return "FAITH";
        case "wealth": return "WEALTH";
        case "community": return "COMMUNITY";
        case "freedom": return "FREEDOM";
        case "honor": return "HONOUR";
        case "tradition": return "TRADITION";
    }
    return "LIFE";
};

function human_value_short(_key)
{
    switch (_key)
    {
        case "family": return "FAMILY";
        case "craft": return "CRAFT";
        case "martial": return "MARTIAL";
        case "knowledge": return "LORE";
        case "faith": return "FAITH";
        case "wealth": return "WEALTH";
        case "community": return "COMMON";
        case "freedom": return "FREEDOM";
        case "honor": return "HONOUR";
        case "tradition": return "OLD WAYS";
    }
    return "LIFE";
};

function human_facet_keys()
{
    return ["patience", "artistic", "competitive", "romantic", "forgiving", "grudge", "wanderlust", "discipline", "humor", "vanity", "secrecy", "altruism", "spirituality", "materialism"];
};

function human_facet_label(_key)
{
    switch (_key)
    {
        case "patience": return "PATIENT";
        case "artistic": return "ARTISTIC";
        case "competitive": return "COMPETITIVE";
        case "romantic": return "ROMANTIC";
        case "forgiving": return "FORGIVING";
        case "grudge": return "GRUDGE-BEARING";
        case "wanderlust": return "RESTLESS";
        case "discipline": return "DISCIPLINED";
        case "humor": return "WITTY";
        case "vanity": return "VAIN";
        case "secrecy": return "SECRETIVE";
        case "altruism": return "ALTRUISTIC";
        case "spirituality": return "SPIRITUAL";
        case "materialism": return "MATERIALISTIC";
    }
    return "PLAIN";
};

function human_facet_short(_key)
{
    switch (_key)
    {
        case "patience": return "PATIENCE";
        case "artistic": return "ARTISTIC";
        case "competitive": return "COMPETE";
        case "romantic": return "ROMANTIC";
        case "forgiving": return "FORGIVE";
        case "grudge": return "GRUDGE";
        case "wanderlust": return "RESTLESS";
        case "discipline": return "DISCIPLINE";
        case "humor": return "HUMOUR";
        case "vanity": return "VANITY";
        case "secrecy": return "SECRETIVE";
        case "altruism": return "ALTRUISM";
        case "spirituality": return "SPIRITUAL";
        case "materialism": return "MATERIAL";
    }
    return "PLAIN";
};

function human_trait_keys()
{
    return ["bold", "compassion", "industry", "curiosity", "sociability", "aggression", "caution", "ambition", "loyalty", "greed", "tradition", "honesty"];
};

function human_trait_short(_key)
{
    switch (_key)
    {
        case "bold": return "BOLD";
        case "compassion": return "KIND";
        case "industry": return "INDUSTRY";
        case "curiosity": return "CURIOUS";
        case "sociability": return "SOCIABLE";
        case "aggression": return "FIERCE";
        case "caution": return "WARY";
        case "ambition": return "ASPIRING";
        case "loyalty": return "LOYAL";
        case "greed": return "GREEDY";
        case "tradition": return "TRADITION";
        case "honesty": return "HONEST";
    }
    return "PLAIN";
};

function human_trait_label(_key)
{
    switch (_key)
    {
        case "bold": return "BOLD";
        case "compassion": return "COMPASSIONATE";
        case "industry": return "INDUSTRIOUS";
        case "curiosity": return "CURIOUS";
        case "sociability": return "SOCIABLE";
        case "aggression": return "FIERCE";
        case "caution": return "CAUTIOUS";
        case "ambition": return "AMBITIOUS";
        case "loyalty": return "LOYAL";
        case "greed": return "GREEDY";
        case "tradition": return "TRADITIONAL";
        case "honesty": return "HONEST";
    }
    return "PLAIN";
};

function human_job_list_text(_jobs)
{
    var _text = "";
    for (var _i = 0; _i < array_length(_jobs); _i++)
    {
        if (_text != "") _text += ", ";
        _text += human_job_label(_jobs[_i]);
    }
    if (_text == "") return "NONE";
    return string_upper(_text);
};

function human_top_value_key(_h)
{
    var _keys = human_value_keys();
    var _best = _keys[0];
    var _best_value = -1;

    for (var _i = 0; _i < array_length(_keys); _i++)
    {
        var _value = variable_struct_get(_h.values, _keys[_i]);
        if (_value > _best_value)
        {
            _best_value = _value;
            _best = _keys[_i];
        }
    }

    return _best;
};

function human_sorted_keys(_struct, _keys)
{
    var _remaining = [];
    for (var _i = 0; _i < array_length(_keys); _i++)
    {
        array_push(_remaining, _keys[_i]);
    }

    var _result = [];
    while (array_length(_remaining) > 0)
    {
        var _best_i = 0;
        var _best_value = -999;
        for (var _i = 0; _i < array_length(_remaining); _i++)
        {
            var _value = variable_struct_get(_struct, _remaining[_i]);
            if (_value > _best_value)
            {
                _best_value = _value;
                _best_i = _i;
            }
        }
        array_push(_result, _remaining[_best_i]);
        array_delete(_remaining, _best_i, 1);
    }

    return _result;
};

function human_relationship_rank(_h)
{
    var _ranked = [];
    for (var _i = 0; _i < array_length(_h.relationships); _i++)
    {
        array_push(_ranked, _h.relationships[_i]);
    }

    for (var _i = 0; _i < array_length(_ranked); _i++)
    {
        var _best = _i;
        var _best_score = human_relationship_score(_ranked[_i]);

        for (var _j = _i + 1; _j < array_length(_ranked); _j++)
        {
            var _score = human_relationship_score(_ranked[_j]);
            if (_score > _best_score)
            {
                _best_score = _score;
                _best = _j;
            }
        }

        if (_best != _i)
        {
            var _swap = _ranked[_i];
            _ranked[_i] = _ranked[_best];
            _ranked[_best] = _swap;
        }
    }

    return _ranked;
};

function human_relationship_score(_rel)
{
    return _rel.opinion + _rel.respect * 0.5 + _rel.attraction * 0.25
        + _rel.kin * 60 + _rel.friend * 25 - _rel.rival * 40
        + _rel.familiarity * 12 + _rel.love * 0.15;
};

function human_relationship_tag(_rel)
{
    if (_rel.kin && _rel.love > 70) return "BONDED";
    if (_rel.kin) return "KIN";
    if (_rel.rival) return "RIVAL";
    if (_rel.friend) return "FRIEND";
    if (_rel.love > 45 && _rel.attraction > 35) return "SWEETHEART";
    if (_rel.opinion > 28) return "FRIENDLY";
    if (_rel.resentment > 22) return "BITTER";
    return "NEUTRAL";
};

function human_count_tag(_h, _tag)
{
    var _count = 0;
    for (var _i = 0; _i < array_length(_h.relationships); _i++)
    {
        if (human_relationship_tag(_h.relationships[_i]) == _tag) _count += 1;
    }
    return _count;
};

function human_ambition_text(_value_key)
{
    switch (_value_key)
    {
        case "family": return "TO RAISE A GREAT FAMILY";
        case "craft": return "TO MASTER A CRAFT";
        case "martial": return "TO WIN GLORY IN BATTLE";
        case "knowledge": return "TO UNCOVER THE WORLD'S SECRETS";
        case "faith": return "TO HONOUR THE SPIRITS";
        case "wealth": return "TO BUILD A LASTING FORTUNE";
        case "community": return "TO HOLD THE SETTLEMENT TOGETHER";
        case "freedom": return "TO LIVE UNBOUND";
        case "honor": return "TO BE REMEMBERED AS JUST";
        case "tradition": return "TO KEEP THE OLD WAYS ALIVE";
    }
    return "TO MAKE A MARK ON THE WORLD";
};

function human_fear_text(_value_key)
{
    switch (_value_key)
    {
        case "family": return "LOSING THEIR FAMILY";
        case "craft": return "FAILING THEIR LIFE'S WORK";
        case "martial": return "DYING WITHOUT GLORY";
        case "knowledge": return "BEING FORGOTTEN";
        case "faith": return "DYING UNBLESSED";
        case "wealth": return "POVERTY";
        case "community": return "EXILE";
        case "freedom": return "CAPTIVITY";
        case "honor": return "SHAME";
        case "tradition": return "THE OLD WAYS DYING";
    }
    return "THE UNKNOWN";
};

function human_epithet(_h)
{
    var _keys = human_trait_keys();
    var _best = "";
    var _best_value = 0;

    for (var _i = 0; _i < array_length(_keys); _i++)
    {
        var _value = variable_struct_get(_h.traits, _keys[_i]);
        if (_value > _best_value)
        {
            _best_value = _value;
            _best = _keys[_i];
        }
    }

    if (_best_value < 0.58) return "THE UNMARKED";

    switch (_best)
    {
        case "bold": return "THE BOLD";
        case "compassion": return "THE KIND";
        case "industry": return "THE DILIGENT";
        case "curiosity": return "THE CURIOUS";
        case "sociability": return "THE SOCIAL";
        case "aggression": return "THE FIERCE";
        case "caution": return "THE WARY";
        case "ambition": return "THE ASPIRING";
        case "loyalty": return "THE LOYAL";
        case "greed": return "THE ACQUISITIVE";
        case "tradition": return "THE KEEPER";
        case "honesty": return "THE HONEST";
    }
    return "THE QUIET";
};

function human_inner_voice(_h)
{
    if (_h.hunger > 0.72) return "My stomach is an empty hall.";
    if (_h.energy > 0.78) return "My eyelids are heavy as stone.";
    if (_h.pain > 24) return "The wound speaks louder than the day.";
    if (_h.safety > 0.62) return "Every shadow could be teeth.";
    if (_h.grief > 0.42) return "The dead are loud in the quiet.";
    if (_h.loneliness > 0.60) return "I have not heard a friendly voice in too long.";
    if (_h.stress > 0.68) return "The day is a knot I cannot untie.";
    if (_h.anger > 0.55) return "Someone will answer for this.";
    if (_h.purpose > 0.72) return "I should be doing something that matters.";
    if (_h.hope > 0.72) return "There is still a road ahead.";
    return "There is work, and there is daylight.";
};

function human_advance_ambition(_h, _amount)
{
    if (_h.dead || _h.ambition_met) return;

    var _before = _h.ambition_progress;
    _h.ambition_progress = clamp(_h.ambition_progress + _amount, 0, 1);

    if (_before < 0.5 && _h.ambition_progress >= 0.5)
    {
        human_add_thought(_h, "My life's work is taking shape", 0.55, 0.65, 180);
    }

    if (_h.ambition_progress >= 1 && !_h.ambition_met)
    {
        _h.ambition_met = true;
        _h.pride = min(1, _h.pride + 0.3);
        human_add_thought(_h, "I have done what I set out to do", 0.9, 0.9, 300);
        human_add_memory(_h, "AMBITION", 0.9, 9, -1, "Fulfilled a lifelong ambition: " + _h.ambition_text + ".");
    }
};

function human_reflect(_w, _h)
{
    if (_h.dead) return;

    _h.inner_voice = human_inner_voice(_h);
    _h.mental_state = human_mental_label(_h);

    var _strongest = human_strongest_thought(_h);
    if (_strongest != noone && abs(_strongest.valence) > 0.35)
    {
        _h.reflection = "I keep returning to one thing: " + _strongest.text + ".";
    }
    else
    {
        _h.reflection = "I am " + human_mood_label(_h) + ". " + _h.inner_voice;
    }

    // Relationships harden into friendships and rivalries through repeated
    // experience, not because a label was assigned at birth.
    for (var _i = 0; _i < array_length(_h.relationships); _i++)
    {
        var _rel = _h.relationships[_i];
        var _other = world_find_human(_w, _rel.other_id);
        if (_other == noone || _other.dead) continue;

        if (!_rel.friend && _rel.opinion > 52 && _rel.familiarity > 0.38 && !_rel.rival)
        {
            _rel.friend = 1;
            human_add_memory(_h, "FRIEND", 0.7, 6, _other.id, "Came to count " + _other.name + " as a friend.");
            human_add_thought(_h, "I have a true friend in " + _other.name, 0.55, 0.55, 160);
        }
        else if (_rel.friend && _rel.opinion < 18)
        {
            _rel.friend = 0;
        }

        if (!_rel.rival && _rel.resentment > 44)
        {
            _rel.rival = 1;
            human_add_memory(_h, "RIVAL", -0.6, 6, _other.id, "Came to see " + _other.name + " as a rival.");
            human_add_thought(_h, "I will not forget what " + _other.name + " did", -0.6, 0.65, 170);
        }
        else if (_rel.rival && _rel.resentment < 14 && _rel.opinion > -10)
        {
            _rel.rival = 0;
        }
    }

    if (random(1) < 0.22)
    {
        human_add_memory(_h, "REFLECT", 0.12, 2, -1, _h.reflection);
    }
};

function human_add_memory(_h, _kind, _valence, _importance, _subject, _text)
{
    array_push(_h.memories, {
        time: global.sim_time,
        kind: _kind,
        valence: _valence,
        importance: clamp(_importance, 1, 10),
        subject: _subject,
        text: _text,
        last_access: global.sim_time
    });

    if (array_length(_h.memories) > 48)
    {
        array_delete(_h.memories, 0, 1);
    }
};

function human_recall(_h, _kind, _bias)
{
    if (array_length(_h.memories) == 0) return noone;

    var _best = noone;
    var _best_score = -999;
    var _now = global.sim_time;

    for (var _i = 0; _i < array_length(_h.memories); _i++)
    {
        var _memory = _h.memories[_i];
        if (_kind != "" && _memory.kind != _kind) continue;

        var _recency = clamp(1 - (_now - _memory.last_access) / 180, 0, 1);
        var _score = _memory.importance * 0.35 + _recency * 1.4 + _memory.valence * _bias * 1.2;

        if (_score > _best_score)
        {
            _best_score = _score;
            _best = _memory;
        }
    }

    if (_best != noone) _best.last_access = _now;
    return _best;
};

function human_mood_valence(_h)
{
    var _valence = (_h.mood - 50) / 50;
    var _memory = human_recall(_h, "", 0.7);
    if (_memory != noone) _valence += _memory.valence * 0.12;
    return clamp(_valence, -1, 1);
};

function human_remember_site(_h, _node)
{
    for (var _i = 0; _i < array_length(_h.known_sites); _i++)
    {
        var _site = _h.known_sites[_i];
        if (_site.ref == _node)
        {
            _site.amount = _node.amount;
            _site.confidence = 1;
            _site.seen = global.sim_time;
            return;
        }
    }

    if (array_length(_h.known_sites) >= 10) array_delete(_h.known_sites, 0, 1);

    array_push(_h.known_sites, {
        ref: _node,
        kind: _node.kind,
        x: _node.x,
        y: _node.y,
        amount: _node.amount,
        confidence: 0.75,
        seen: global.sim_time
    });
};

function human_known_site(_h, _kind)
{
    var _best = noone;
    var _best_score = 0;
    var _now = global.sim_time;

    for (var _i = 0; _i < array_length(_h.known_sites); _i++)
    {
        var _site = _h.known_sites[_i];
        if (_site.kind != _kind || _site.amount < 2) continue;

        var _age = clamp(1 - (_now - _site.seen) / 150, 0.12, 1);
        var _score = _site.amount * 0.6 + _site.confidence * 8 + _age * 4;

        if (_score > _best_score)
        {
            _best_score = _score;
            _best = _site;
        }
    }

    return _best;
};

function human_forget_site(_h, _node)
{
    for (var _i = array_length(_h.known_sites) - 1; _i >= 0; _i--)
    {
        if (_h.known_sites[_i].ref == _node) array_delete(_h.known_sites, _i, 1);
    }
};

function human_add_emotion(_h, _joy, _fear, _anger, _grief)
{
    _h.mood = clamp(_h.mood + _joy * 4.0 - _fear * 3.0 - _anger * 2.0 - _grief * 3.2, 0, 100);
    _h.joy = clamp(_h.joy + _joy * 0.8 - _grief * 0.25, 0, 1);
    _h.fear = clamp(_h.fear + _fear, 0, 1);
    _h.anger = clamp(_h.anger + _anger, 0, 1);
    _h.grief = clamp(_h.grief + _grief, 0, 1);
    _h.stress = clamp(_h.stress + _fear * 0.4 + _anger * 0.4 + _grief * 0.6, 0, 1);
};

function human_relation(_h, _other_id)
{
    for (var _i = 0; _i < array_length(_h.relationships); _i++)
    {
        if (_h.relationships[_i].other_id == _other_id) return _h.relationships[_i];
    }

    if (array_length(_h.relationships) >= 28)
    {
        var _weakest = 0;
        var _weakest_fam = 2;
        for (var _i = 0; _i < array_length(_h.relationships); _i++)
        {
            if (_h.relationships[_i].familiarity < _weakest_fam)
            {
                _weakest_fam = _h.relationships[_i].familiarity;
                _weakest = _i;
            }
        }
        array_delete(_h.relationships, _weakest, 1);
    }

    var _rel = {
        other_id: _other_id,
        opinion: 0,
        trust: 0.5,
        familiarity: 0,
        kin: 0,
        respect: 0,
        attraction: 0,
        resentment: 0,
        friend: 0,
        rival: 0,
        conversations: 0,
        last_talk: -999,
        love: 0
    };
    array_push(_h.relationships, _rel);
    return _rel;
};

function human_find_relation(_h, _other_id)
{
    for (var _i = 0; _i < array_length(_h.relationships); _i++)
    {
        if (_h.relationships[_i].other_id == _other_id) return _h.relationships[_i];
    }
    return noone;
};

function human_social_event(_h, _other, _kind, _delta, _text)
{
    var _rel = human_relation(_h, _other.id);
    _rel.opinion = clamp(_rel.opinion + _delta, -100, 100);
    _rel.trust = clamp(_rel.trust + _delta * 0.006, 0, 1);
    _rel.familiarity = min(1, _rel.familiarity + 0.03);
    _rel.respect = clamp(_rel.respect + _delta * 0.08 + _other.reputation * 0.02, -100, 100);
    _rel.attraction = clamp(_rel.attraction + _delta * 0.04 + _other.traits.sociability * 0.2, -100, 100);
    _rel.conversations += 1;
    _rel.last_talk = global.sim_time;
    if (_delta > 0) _rel.love = min(100, _rel.love + _delta * 0.10 + _other.facets.romantic * 0.08);
    else _rel.love = max(0, _rel.love - abs(_delta) * 0.08);
    if (_delta < 0) _rel.resentment = min(100, _rel.resentment + abs(_delta) * 1.2);
    else _rel.resentment = max(0, _rel.resentment - _delta * 0.25);

    _h.social = max(0, _h.social - 0.18);
    _h.mood = clamp(_h.mood + _delta * 0.12, 0, 100);
    _h.joy = clamp(_h.joy + max(0, _delta) * 0.004, 0, 1);

    // Routine talk should not bury a life's important memories. Only a
    // strong exchange, or occasionally a quiet one, is written down.
    if (_kind != "TALK" || abs(_delta) > 7 || random(1) < 0.14)
    {
        human_add_memory(_h, _kind, _delta / 40, (_kind == "TALK") ? 1.5 : 3, _other.id, _text);
    }
};

function human_guards_near(_w, _person)
{
    var _count = 0;
    for (var _i = 0; _i < array_length(_w.humans); _i++)
    {
        var _other = _w.humans[_i];
        if (_other.dead || _other == _person || _other.civ != _person.civ || _other.job != JOB_GUARD) continue;
        if (point_distance(_person.x, _person.y, _other.x, _other.y) < 180) _count += 1;
    }
    return _count;
};

function human_move_to(_h, _tx, _ty, _dt, _speed_mult)
{
    var _dist = point_distance(_h.x, _h.y, _tx, _ty);
    if (_dist < 4) return 0;

    var _angle = point_direction(_h.x, _h.y, _tx, _ty);
    _h.heading += angle_difference(_angle, _h.heading) * min(1, _dt * 4.5);

    // Small local separation so work parties do not collapse into single pixels.
    var _push_x = 0;
    var _push_y = 0;
    for (var _i = 0; _i < array_length(_h.near_humans); _i++)
    {
        var _other = _h.near_humans[_i];
        if (_other == _h || _other.dead) continue;

        var _d = point_distance(_h.x, _h.y, _other.x, _other.y);
        if (_d > 1 && _d < 13)
        {
            _push_x += (_h.x - _other.x) / _d * (13 - _d) * 0.8;
            _push_y += (_h.y - _other.y) / _d * (13 - _d) * 0.8;
        }
    }

    var _speed = _h.move_speed * _speed_mult;
    if (_h.age < ADULT_AGE) _speed *= 0.72;
    if (_h.age > ELDER_AGE) _speed *= 0.78;
    if (_h.carrying) _speed *= 0.86;
    _speed *= body_mobility(_h);

    _h.x += lengthdir_x(_speed, _h.heading) * _dt + _push_x * _dt;
    _h.y += lengthdir_y(_speed, _h.heading) * _dt + _push_y * _dt;

    _h.x = clamp(_h.x, 14, room_width - 14);
    _h.y = clamp(_h.y, 14, room_height - 14);

    return point_distance(_h.x, _h.y, _tx, _ty);
};

function human_perceive(_w, _h)
{
    _h.near_humans = [];
    _h.near_allies = 0;
    _h.near_enemies = 0;
    _h.near_kin = 0;
    _h.threat_ref = -1;
    _h.threat_kind = TARGET_NONE;
    _h.threat_dist = 999;
    _h.social_ref = -1;

    var _best_social = 9999;
    var _danger_pressure = 0;
    var _sight = body_vision(_h);
    var _hearing = body_hearing(_h);
    var _human_range = 175 * (0.35 + 0.65 * _sight);
    var _wolf_range = 150 * (0.30 + 0.45 * _sight + 0.25 * _hearing);

    for (var _i = 0; _i < array_length(_w.humans); _i++)
    {
        var _other = _w.humans[_i];
        if (_other == _h || _other.dead) continue;

        var _dist = point_distance(_h.x, _h.y, _other.x, _other.y);
        if (_dist < _human_range)
        {
            if (array_length(_h.near_humans) < 12) array_push(_h.near_humans, _other);

            if (_other.civ == _h.civ)
            {
                _h.near_allies += 1;

                if (_other.age >= ADULT_AGE)
                {
                    // Perception does not create a relationship. Acquaintance
                    // begins with an actual exchange, not with proximity.
                    var _rel = human_find_relation(_h, _other.id);
                    var _rel_opinion = 0;
                    var _rel_kin = 0;
                    var _rel_resentment = 0;
                    if (_rel != noone)
                    {
                        _rel_opinion = _rel.opinion;
                        _rel_kin = _rel.kin;
                        _rel_resentment = _rel.resentment;
                    }
                    if (_rel_kin > 0) _h.near_kin += 1;
                    var _social_score = _dist - _rel_opinion * 0.45 - (_rel_kin * 38) + _other.reputation * 0.08 + _rel_resentment * 0.55;

                    if (_social_score < _best_social)
                    {
                        _best_social = _social_score;
                        _h.social_ref = _other;
                    }
                }
            }
            else
            {
                // A stranger at the Common is not a predator. Fear only
                // arrives with a hostile peace or an open war; otherwise the
                // meeting is wary, and a caravan can finish its road.
                var _hostile = _w.at_war || _w.relation <= -15;

                if (_hostile)
                {
                    _h.near_enemies += 1;
                    var _foreign_pressure = (1 - _dist / _human_range) * (_w.at_war ? 1.4 : 0.42);
                    _danger_pressure += _foreign_pressure;

                    if (_dist < _h.threat_dist)
                    {
                        _h.threat_dist = _dist;
                        _h.threat_ref = _other;
                        _h.threat_kind = TARGET_HUMAN;
                    }
                }
                else
                {
                    _danger_pressure += (1 - _dist / _human_range) * 0.018;
                }
            }
        }
    }

    for (var _i = 0; _i < array_length(_w.wolves); _i++)
    {
        var _wolf = _w.wolves[_i];
        if (_wolf.dead) continue;

        var _dist = point_distance(_h.x, _h.y, _wolf.x, _wolf.y);
        if (_dist < _wolf_range)
        {
            _danger_pressure += (1 - _dist / _wolf_range) * 1.6;

            if (_dist < _h.threat_dist)
            {
                _h.threat_dist = _dist;
                _h.threat_ref = _wolf;
                _h.threat_kind = TARGET_WOLF;
            }
        }
    }

    var _guard_cover = human_guards_near(_w, _h);
    _h.safety = clamp(_danger_pressure * 0.8 + _h.fear * 0.35 - _guard_cover * 0.08 - _h.near_allies * 0.012, 0, 1);

    if (_h.threat_ref != -1)
    {
        _h.fear = min(1, _h.fear + 0.014 + _danger_pressure * 0.008);
    }
};

function human_goal_label(_goal)
{
    switch (_goal)
    {
        case GOAL_EAT: return "eat";
        case GOAL_SLEEP: return "sleep";
        case GOAL_WORK: return "work";
        case GOAL_SOCIAL: return "social";
        case GOAL_FLEE: return "flee";
        case GOAL_HEAL: return "heal";
        case GOAL_FIGHT: return "fight";
        case GOAL_LEAD: return "lead";
        case GOAL_FAITH: return "faith";
        case GOAL_LEISURE: return "leisure";
    }
    return "idle";
};

function human_task_label(_task)
{
    switch (_task)
    {
        case TASK_GATHER: return "gather";
        case TASK_DEPOSIT: return "haul";
        case TASK_FARM: return "farm";
        case TASK_BUILD: return "build";
        case TASK_EAT: return "eat";
        case TASK_SLEEP: return "sleep";
        case TASK_SOCIAL: return "talk";
        case TASK_PATROL: return "patrol";
        case TASK_FIGHT: return "fight";
        case TASK_FLEE: return "flee";
        case TASK_TREAT: return "treat";
        case TASK_RESEARCH: return "study";
        case TASK_TRADE: return "trade";
        case TASK_LEAD: return "lead";
        case TASK_CRAFT: return "craft";
        case TASK_PRAY: return "pray";
        case TASK_WANDER: return "wander";
    }
    return "idle";
};

function human_job_label(_job)
{
    switch (_job)
    {
        case JOB_FOOD: return "forager";
        case JOB_WOOD: return "woodcutter";
        case JOB_STONE: return "quarrier";
        case JOB_FARM: return "farmer";
        case JOB_BUILD: return "builder";
        case JOB_GUARD: return "guard";
        case JOB_HEAL: return "healer";
        case JOB_SCHOLAR: return "scholar";
        case JOB_TRADER: return "trader";
        case JOB_LEADER: return "leader";
        case JOB_CHILD: return "child";
        case JOB_CRAFT: return "craftsman";
    }
    return "idle";
};

function human_goal_combine(_a, _b)
{
    return sqrt(max(0, clamp(_a, 0, 1) * clamp(_b, 0, 1)));
};

function human_goal_combine3(_a, _b, _c)
{
    return power(max(0, clamp(_a, 0, 1) * clamp(_b, 0, 1) * clamp(_c, 0, 1)), 1 / 3);
};

function human_think(_w, _h)
{
    if (_h.dead) return;

    human_perceive(_w, _h);
    _h.inner_voice = human_inner_voice(_h);
    _h.mental_state = human_mental_label(_h);

    var _night = world_day_night(_w);
    var _civ = _w.civs[_h.civ];
    var _danger = _h.safety;
    var _food_available = (_civ.food > 0.5) ? 1 : 0.12;
    var _shrine = (world_civ_building_count(_w, _h.civ, BLD_SHRINE) > 0) ? 1 : 0;
    var _infirmary = (world_civ_building_count(_w, _h.civ, BLD_INFIRMARY) > 0) ? 1 : 0;
    var _grief_pressure = clamp(_h.grief * 1.3 + _h.stress * 0.45, 0, 1);
    var _near_ally_factor = clamp(0.45 + _h.near_allies * 0.18, 0, 1);
    var _age_factor = (_h.age > ELDER_AGE) ? 0.78 : 1;
    var _thought_valence = human_thought_valence(_h);
    var _mental_factor = (_h.mental_state == "ON THE EDGE" || _h.mental_state == "DESPAIRING") ? 0.86 : 1;
    var _likes_work = human_has(_h.labor_likes, _h.job);
    var _dislikes_work = human_has(_h.labor_dislikes, _h.job);
    var _best_skill = human_best_skill_key(_h);
    var _job_aptitude = variable_struct_get(_h.aptitudes, _best_skill);

    if (_h.job == JOB_CHILD) _age_factor *= 0.55;

    // Utility AI: each goal is a small product of considerations, then a
    // geometric mean so adding a consideration does not silently veto it.
    var _eat = human_goal_combine(power(_h.hunger, 1.8), _food_available);
    var _sleep = human_goal_combine(power(_h.energy, 1.7), _night ? 1.15 : 0.74);
    var _social = human_goal_combine3(
        power(_h.social, 1.35) * (0.82 + _h.loneliness * 0.45),
        0.55 + _h.traits.sociability * 0.75 + _h.values.family * 0.12,
        _near_ally_factor * (0.92 + _h.near_kin * 0.10)
    );
    var _heal = human_goal_combine3(
        body_triage(_h) * 1.70 + clamp(1 - _h.hp / _h.max_hp, 0, 1) * 0.25,
        0.65 + _h.traits.caution * 0.35 + _h.values.family * 0.08,
        _infirmary ? 1 : 0.45
    );
    var _work_base = 0.36 + _h.purpose * 0.42 + _h.traits.industry * 0.25
        + _h.values.craft * 0.09 + _h.facets.discipline * 0.10 + _thought_valence * 0.04;
    if (_likes_work) _work_base += 0.11;
    if (_dislikes_work) _work_base -= 0.13;
    if (_job_aptitude > 1.08) _work_base += 0.04;
    if (_h.job == JOB_FOOD || _h.job == JOB_FARM) _work_base += (_civ.food < 70) ? 0.16 : 0;
    if (_h.job == JOB_BUILD && _civ.project != -1) _work_base += 0.12;
    if (_h.job == JOB_CRAFT) _work_base += 0.1;
    if (_h.job == JOB_FARM || _h.job == JOB_FOOD) _work_base += _h.values.community * 0.04;
    if (_h.faction == "forge") _work_base += 0.04;
    _work_base = max(0.08, _work_base - clamp(_h.pain * 0.0012, 0, 0.12));
    _work_base *= 0.65 + 0.35 * body_dexterity(_h);
    var _work = human_goal_combine3(
        _work_base * _age_factor,
        _night ? 0.72 : 1,
        1 - _h.safety * 0.55
    );
    _work *= (1 - _civ.unrest * 0.35) * (0.88 + _h.hope * 0.22) * _mental_factor;
    var _flee = human_goal_combine3(
        power(_danger, 1.25),
        1.2 - _h.traits.bold * 0.7,
        0.8 + _h.fear * 0.5
    );
    var _fight = human_goal_combine3(
        power(_danger, 1.1),
        0.35 + _h.traits.bold * 0.8 + _h.traits.aggression * 0.45
            + _h.values.martial * 0.22 + _h.values.honor * 0.12
            + ((_h.job == JOB_GUARD) ? 0.55 : 0),
        (_h.near_allies > 0) ? 1.15 : 0.62
    );

    if (_h.faction == "wardens") _fight *= 1.15;
    if (_h.age < ADULT_AGE) _fight *= 0.35;

    var _lead = human_goal_combine3(
        (_h.job == JOB_LEADER) ? 1 : 0.06,
        0.35 + _h.traits.ambition * 0.9 + _h.values.community * 0.12,
        0.45 + _civ.legitimacy / 180 + _h.values.honor * 0.08
    );
    var _faith = human_goal_combine3(
        power(_grief_pressure, 1.15),
        0.32 + _h.traits.tradition * 0.85 + _h.values.faith * 0.35 + _h.facets.spirituality * 0.28,
        _shrine ? 1 : 0.38
    );
    var _leisure = human_goal_combine3(
        power(clamp(_h.stress + (1 - _h.joy) * 0.35 + _h.loneliness * 0.15, 0, 1), 0.9),
        0.38 + _h.traits.curiosity * 0.48 + _h.facets.artistic * 0.18
            + _h.facets.wanderlust * 0.16 + _h.wonder * 0.12 + ((_h.job == JOB_CHILD) ? 0.5 : 0),
        _night ? 0.55 : 1
    );

    // Work is the default pressure, not a null action.
    var _scores = array_create(GOAL_COUNT, 0);
    _scores[GOAL_EAT] = _eat;
    _scores[GOAL_SLEEP] = _sleep;
    _scores[GOAL_SOCIAL] = _social;
    _scores[GOAL_WORK] = _work;
    _scores[GOAL_FLEE] = _flee;
    _scores[GOAL_HEAL] = _heal;
    _scores[GOAL_FIGHT] = _fight;
    _scores[GOAL_LEAD] = _lead;
    _scores[GOAL_FAITH] = _faith;
    _scores[GOAL_LEISURE] = _leisure;

    // Small, coherent variation: people are not argmax machines.
    for (var _score_i = 0; _score_i < GOAL_COUNT; _score_i++)
    {
        _scores[_score_i] *= random_range(0.94, 1.06);
    }

    var _best_goal = GOAL_WORK;
    var _best = _scores[GOAL_WORK];

    for (var _goal_i = 0; _goal_i < GOAL_COUNT; _goal_i++)
    {
        if (_scores[_goal_i] > _best)
        {
            _best = _scores[_goal_i];
            _best_goal = _goal_i;
        }
    }

    // Emergencies override deliberation; otherwise commitment prevents dithering.
    var _emergency = false;
    if (_h.hp < _h.max_hp * 0.28 || _h.body.consciousness < 0.30
        || _h.body.blood_volume < 58 || _h.body.sepsis > 0.25)
    {
        _best_goal = GOAL_HEAL; _best = 1; _emergency = true;
    }
    else if (_h.hunger > 0.95) { _best_goal = GOAL_EAT; _best = 1; _emergency = true; }
    else if (_danger > 0.72 && _h.job != JOB_GUARD) { _best_goal = GOAL_FLEE; _best = 1; _emergency = true; }

    if (!_emergency && _h.job == JOB_GUARD && _danger > 0.12 && _h.threat_ref != -1)
    {
        _best_goal = GOAL_FIGHT;
        _best = 1;
        _emergency = true;
    }

    // A caravan is a promise to the other settlement. Only an emergency
    // justifies turning it around before it reaches the far halls.
    if (!_emergency && _h.task == TASK_TRADE && _h.task_timer < 80) return;

    var _switch = false;
    if (_best_goal != _h.goal)
    {
        if (_emergency || _best > _h.goal_score * 1.14 + 0.035 || _h.goal_timer > 2.1 || _h.task == TASK_IDLE)
        {
            _switch = true;
        }
    }

    if (_switch || _h.task == TASK_IDLE)
    {
        _h.goal = _best_goal;
        _h.goal_score = _best;
        _h.goal_timer = 0;
        _h.last_thought = human_goal_label(_best_goal);
        human_plan_goal(_w, _h);
    }
};

function human_find_resource(_w, _h, _kind)
{
    var _best = noone;
    var _best_score = 99999;

    for (var _i = 0; _i < array_length(_w.resources); _i++)
    {
        var _r = _w.resources[_i];
        if (_r.kind != _kind || _r.amount < 3) continue;

        var _dist = point_distance(_h.x, _h.y, _r.x, _r.y);
        var _score = _dist - _r.amount * 0.55;

        if (_h.danger_time > global.sim_time - 70
            && point_distance(_r.x, _r.y, _h.danger_x, _h.danger_y) < 105)
        {
            _score += 130;
        }

        // A remembered, productive site is worth a detour; a depleted one is not.
        for (var _site_i = 0; _site_i < array_length(_h.known_sites); _site_i++)
        {
            var _site = _h.known_sites[_site_i];
            if (_site.ref != _r) continue;

            var _age = clamp(1 - (global.sim_time - _site.seen) / 150, 0.1, 1);
            _score -= _site.confidence * 46 * _age;
            break;
        }

        if (_score < _best_score)
        {
            _best_score = _score;
            _best = _r;
        }
    }

    return _best;
};

function human_find_building(_w, _h, _type)
{
    var _best = noone;
    var _best_dist = 99999;

    for (var _i = 0; _i < array_length(_w.buildings); _i++)
    {
        var _b = _w.buildings[_i];
        if (_b.civ != _h.civ || !_b.complete || _b.type != _type) continue;

        var _dist = human_dist_sq(_h.x, _h.y, _b.x, _b.y);
        if (_dist < _best_dist)
        {
            _best_dist = _dist;
            _best = _b;
        }
    }

    return _best;
};

function human_find_enemy(_w, _h)
{
    if (!_w.at_war) return noone;

    var _best = noone;
    var _best_dist = 99999;

    for (var _i = 0; _i < array_length(_w.humans); _i++)
    {
        var _other = _w.humans[_i];
        if (_other.dead || _other.civ == _h.civ) continue;

        var _dist = human_dist_sq(_h.x, _h.y, _other.x, _other.y);
        if (_dist < _best_dist && _dist < 900 * 900)
        {
            _best_dist = _dist;
            _best = _other;
        }
    }

    return _best;
};

function human_pick_task(_h, _task, _kind, _ref, _tx, _ty)
{
    _h.task = _task;
    _h.task_timer = 0;
    _h.work_timer = 0;
    _h.target_kind = _kind;
    _h.target_ref = _ref;
    _h.target_x = _tx;
    _h.target_y = _ty;
};

function human_plan_goal(_w, _h)
{
    if (_h.dead) return;

    if (_h.goal == GOAL_FLEE)
    {
        human_pick_task(_h, TASK_FLEE, TARGET_POINT, -1, _h.home_x, _h.home_y);
        return;
    }

    if (_h.goal == GOAL_EAT)
    {
        if (_w.civs[_h.civ].food <= 0)
        {
            _h.goal = GOAL_WORK;
            human_plan_work(_w, _h);
            return;
        }

        var _granary = human_find_building(_w, _h, BLD_GRANARY);
        if (_granary != noone)
        {
            human_pick_task(_h, TASK_EAT, TARGET_BUILDING, _granary, _granary.x, _granary.y);
        }
        else
        {
            human_pick_task(_h, TASK_EAT, TARGET_POINT, -1, _h.home_x, _h.home_y);
        }
        return;
    }

    if (_h.goal == GOAL_SLEEP)
    {
        human_pick_task(_h, TASK_SLEEP, TARGET_POINT, -1, _h.home_x, _h.home_y);
        return;
    }

    if (_h.goal == GOAL_HEAL)
    {
        var _infirmary = human_find_building(_w, _h, BLD_INFIRMARY);
        if (_infirmary != noone) human_pick_task(_h, TASK_TREAT, TARGET_BUILDING, _infirmary, _infirmary.x, _infirmary.y);
        else human_pick_task(_h, TASK_TREAT, TARGET_POINT, -1, _h.home_x, _h.home_y);
        return;
    }

    if (_h.goal == GOAL_SOCIAL)
    {
        var _social_target = _h.social_ref;

        if (_social_target == -1 && _h.partner_id != -1)
        {
            var _partner = world_find_human(_w, _h.partner_id);
            if (_partner != noone && !_partner.dead) _social_target = _partner;
        }

        if (_social_target != -1)
        {
            human_pick_task(_h, TASK_SOCIAL, TARGET_HUMAN, _social_target, _social_target.x, _social_target.y);
        }
        else
        {
            human_pick_task(_h, TASK_WANDER, TARGET_POINT, -1, _h.home_x + random_range(-90, 90), _h.home_y + random_range(-70, 70));
        }
        return;
    }

    if (_h.goal == GOAL_FIGHT)
    {
        if (_h.threat_ref != -1)
        {
            human_pick_task(_h, TASK_FIGHT, _h.threat_kind, _h.threat_ref, _h.threat_ref.x, _h.threat_ref.y);
        }
        else if (_w.at_war)
        {
            var _enemy = human_find_enemy(_w, _h);
            if (_enemy != noone) human_pick_task(_h, TASK_FIGHT, TARGET_HUMAN, _enemy, _enemy.x, _enemy.y);
            else human_pick_task(_h, TASK_PATROL, TARGET_POINT, -1, _w.common_x, _w.common_y);
        }
        else
        {
            human_pick_task(_h, TASK_PATROL, TARGET_POINT, -1, _h.home_x, _h.home_y);
        }
        return;
    }

    if (_h.goal == GOAL_FAITH)
    {
        var _shrine = human_find_building(_w, _h, BLD_SHRINE);
        if (_shrine != noone)
        {
            human_pick_task(_h, TASK_PRAY, TARGET_BUILDING, _shrine, _shrine.x, _shrine.y);
        }
        else
        {
            human_pick_task(_h, TASK_PRAY, TARGET_POINT, -1, _h.home_x, _h.home_y);
        }
        return;
    }

    if (_h.goal == GOAL_LEISURE)
    {
        var _leisure_x = _h.home_x + random_range(-110, 110);
        var _leisure_y = _h.home_y + random_range(-80, 80);

        if (_h.job == JOB_CHILD && random(1) < 0.5)
        {
            _leisure_x = _w.common_x + random_range(-100, 100);
            _leisure_y = _w.common_y + random_range(-80, 80);
        }

        human_pick_task(_h, TASK_WANDER, TARGET_POINT, -1, _leisure_x, _leisure_y);
        return;
    }

    if (_h.goal == GOAL_LEAD)
    {
        human_pick_task(_h, TASK_LEAD, TARGET_POINT, -1, _w.civs[_h.civ].home_x, _w.civs[_h.civ].home_y);
        return;
    }

    human_plan_work(_w, _h);
};

function human_plan_work(_w, _h)
{
    if (_h.dead) return;

    if (_h.job == JOB_CHILD || _h.job == JOB_IDLE)
    {
        human_pick_task(_h, TASK_WANDER, TARGET_POINT, -1, _h.home_x + random_range(-100, 100), _h.home_y + random_range(-70, 70));
        return;
    }

    if (_h.job == JOB_FOOD || _h.job == JOB_WOOD || _h.job == JOB_STONE)
    {
        if (_h.carrying)
        {
            human_pick_task(_h, TASK_DEPOSIT, TARGET_POINT, -1, _h.home_x, _h.home_y);
            return;
        }

        var _kind = RES_FOOD;
        if (_h.job == JOB_WOOD) _kind = RES_WOOD;
        else if (_h.job == JOB_STONE) _kind = RES_STONE;

        var _node = human_find_resource(_w, _h, _kind);
        if (_node != noone)
        {
            human_remember_site(_h, _node);
            human_pick_task(_h, TASK_GATHER, TARGET_RESOURCE, _node, _node.x, _node.y);
        }
        else
        {
            // No remembered site: scout the Common and the far field.
            var _scout_x = (_h.job == JOB_WOOD) ? random_range(120, room_width - 120) : _w.common_x + random_range(-260, 260);
            var _scout_y = random_range(120, room_height - 120);
            human_pick_task(_h, TASK_WANDER, TARGET_POINT, -1, _scout_x, _scout_y);
        }
        return;
    }

    if (_h.job == JOB_FARM)
    {
        var _farm = human_find_building(_w, _h, BLD_FARM);
        if (_farm != noone)
        {
            human_pick_task(_h, TASK_FARM, TARGET_BUILDING, _farm, _farm.x, _farm.y);
        }
        else
        {
            var _wild = human_find_resource(_w, _h, RES_FOOD);
            if (_wild != noone) human_pick_task(_h, TASK_GATHER, TARGET_RESOURCE, _wild, _wild.x, _wild.y);
            else human_pick_task(_h, TASK_WANDER, TARGET_POINT, -1, _w.common_x, _w.common_y);
        }
        return;
    }

    if (_h.job == JOB_BUILD)
    {
        var _project = _w.civs[_h.civ].project;
        if (_project != -1 && !_project.complete)
        {
            human_pick_task(_h, TASK_BUILD, TARGET_BUILDING, _project, _project.x, _project.y);
        }
        else
        {
            human_pick_task(_h, TASK_SOCIAL, TARGET_POINT, -1, _h.home_x, _h.home_y);
        }
        return;
    }

    if (_h.job == JOB_CRAFT)
    {
        var _workshop = human_find_building(_w, _h, BLD_WORKSHOP);
        if (_workshop != noone)
        {
            human_pick_task(_h, TASK_CRAFT, TARGET_BUILDING, _workshop, _workshop.x, _workshop.y);
        }
        else
        {
            human_pick_task(_h, TASK_SOCIAL, TARGET_POINT, -1, _h.home_x, _h.home_y);
        }
        return;
    }

    if (_h.job == JOB_GUARD)
    {
        if (_h.threat_ref != -1)
        {
            human_pick_task(_h, TASK_FIGHT, _h.threat_kind, _h.threat_ref, _h.threat_ref.x, _h.threat_ref.y);
        }
        else if (_w.at_war)
        {
            var _enemy = human_find_enemy(_w, _h);
            if (_enemy != noone) human_pick_task(_h, TASK_FIGHT, TARGET_HUMAN, _enemy, _enemy.x, _enemy.y);
            else human_pick_task(_h, TASK_PATROL, TARGET_POINT, -1, _w.common_x, _w.common_y);
        }
        else
        {
            var _patrol_x = _w.civs[_h.civ].home_x + random_range(-130, 130);
            var _patrol_y = _w.civs[_h.civ].home_y + random_range(-90, 90);
            human_pick_task(_h, TASK_PATROL, TARGET_POINT, -1, _patrol_x, _patrol_y);
        }
        return;
    }

    if (_h.job == JOB_HEAL)
    {
        var _patient = noone;
        var _patient_score = 0;

        for (var _i = 0; _i < array_length(_w.humans); _i++)
        {
            var _other = _w.humans[_i];
            if (_other.dead || _other == _h || _other.civ != _h.civ) continue;
            if (!body_needs_care(_other)) continue;

            var _need = body_triage(_other) * 120;
            var _dist = point_distance(_h.x, _h.y, _other.x, _other.y);
            var _score = _need - _dist * 0.08;

            if (_score > _patient_score)
            {
                _patient_score = _score;
                _patient = _other;
            }
        }

        if (_patient != noone && _patient_score > 8)
        {
            human_pick_task(_h, TASK_TREAT, TARGET_HUMAN, _patient, _patient.x, _patient.y);
        }
        else
        {
            var _infirmary = human_find_building(_w, _h, BLD_INFIRMARY);
            if (_infirmary != noone) human_pick_task(_h, TASK_TREAT, TARGET_BUILDING, _infirmary, _infirmary.x, _infirmary.y);
            else human_pick_task(_h, TASK_SOCIAL, TARGET_POINT, -1, _h.home_x, _h.home_y);
        }
        return;
    }

    if (_h.job == JOB_SCHOLAR)
    {
        var _study = human_find_building(_w, _h, BLD_WORKSHOP);
        if (_study == noone) _study = human_find_building(_w, _h, BLD_SHRINE);
        if (_study != noone) human_pick_task(_h, TASK_RESEARCH, TARGET_BUILDING, _study, _study.x, _study.y);
        else human_pick_task(_h, TASK_RESEARCH, TARGET_POINT, -1, _h.home_x, _h.home_y);
        return;
    }

    if (_h.job == JOB_TRADER)
    {
        if (_w.at_war || _w.relation < -25)
        {
            human_pick_task(_h, TASK_SOCIAL, TARGET_POINT, -1, _h.home_x, _h.home_y);
            return;
        }

        // A caravan is a round trip, not a stall at the far gate.
        if (_h.trade_cooldown > 0)
        {
            human_pick_task(_h, TASK_WANDER, TARGET_POINT, -1, _h.home_x, _h.home_y);
            return;
        }

        var _other_civ = _w.civs[1 - _h.civ];
        human_pick_task(_h, TASK_TRADE, TARGET_POINT, -1, _other_civ.home_x, _other_civ.home_y);
        return;
    }

    if (_h.job == JOB_LEADER)
    {
        human_pick_task(_h, TASK_LEAD, TARGET_POINT, -1, _w.civs[_h.civ].home_x, _w.civs[_h.civ].home_y);
        return;
    }

    human_pick_task(_h, TASK_SOCIAL, TARGET_POINT, -1, _h.home_x, _h.home_y);
};

function human_attack(_w, _h, _target, _kind)
{
    if (_h.action_cooldown > 0 || _h.dead || _target.dead) return;
    _h.action_cooldown = 1.0;

    if (_kind == TARGET_WOLF)
    {
        var _wolf_pack = 1 + min(0.45, _h.near_allies * 0.06);
        _target.hp -= (4.0 + _h.skills.combat * 7.0) * _wolf_pack * (0.55 + 0.45 * body_dexterity(_h));
        _h.fear = max(0, _h.fear - 0.2);
        human_train_skill(_h, "combat", 0.006);
        _h.reputation = min(100, _h.reputation + 0.08);

        if (_target.hp <= 0 && !_target.dead)
        {
            _target.dead = true;
            _h.kills += 1;
            _h.mood = clamp(_h.mood + 4, 0, 100);
            human_add_memory(_h, "KILL", 0.3, 6, _target.id, "Killed a wolf threatening the settlement.");
            human_add_thought(_h, "I put a wolf down before it reached the children", 0.5, 0.6, 180);
            human_advance_ambition(_h, 0.008);
            world_event(_w, _h.name + " KILLS A WOLF.", _w.ui_good, 4, _h.civ);
        }
    }
    else
    {
        var _pack = 1 + min(0.6, _h.near_allies * 0.065);
        var _damage = (5 + _h.skills.combat * 9 + _h.traits.aggression * 3) * _pack;
        _damage *= 0.55 + 0.45 * body_dexterity(_h);
        _damage *= 1 + min(0.3, _w.civs[_h.civ].tools * 0.012);

        var _weapon_kind = "blunt";
        if (_w.civs[_h.civ].tools > 2) _weapon_kind = "cut";
        if (_w.civs[_h.civ].tools > 8 && random(1) < 0.24) _weapon_kind = "puncture";
        body_apply_wound(_target, _weapon_kind, _damage, _h.id, -1);

        _target.fear = min(1, _target.fear + 0.3);
        _target.anger = min(1, _target.anger + 0.2);
        human_train_skill(_h, "combat", 0.008);
        _h.anger = max(0, _h.anger - 0.1);
        _h.reputation = min(100, _h.reputation + 0.15);

        if (random(1) < 0.24)
        {
            human_add_memory(_h, "FIGHT", -0.6, 5, _target.id, "Fought " + _target.name + " at the border.");
            human_add_memory(_target, "FIGHT", -0.8, 6, _h.id, "Was attacked by " + _h.name + ".");
        }
        human_add_emotion(_target, 0, 0.25, 0.3, 0);

        if (_target.hp <= 0)
        {
            _h.kills += 1;
            _w.grievance[_target.civ] += 2;
            _w.relation = max(-100, _w.relation - 3);

            if (_w.at_war)
            {
                _w.war_score[_h.civ] += 3;
                _w.war_exhaustion[_target.civ] += 0.8;
                _w.war_exhaustion[_h.civ] += 0.16;
            }

            human_add_thought(_h, "I killed " + _target.name, -0.35, 0.8, 220);
            human_advance_ambition(_h, 0.01);
            human_die(_w, _target, "wounds from " + _h.name);
            world_event(_w, _h.name + " KILLS " + _target.name + ".", _w.ui_alert, 8, _h.civ);
        }
    }
};

function human_die(_w, _h, _cause)
{
    if (_h.dead) return;
    _h.dead = true;
    _h.hp = 0;
    if (is_struct(_h.body))
    {
        _h.body.consciousness = 0;
        _h.body.pulse = 0;
        _h.body.respiration = 0;
        _h.body.oxygen = 0;
        _h.body.blood_pressure_sys = 0;
        _h.body.blood_pressure_dia = 0;
        _h.body.conditions = ["DEAD"];
        _h.conditions = _h.body.conditions;
    }
    _w.civs[_h.civ].deaths += 1;
    _w.lost[_h.civ] += 1;
    human_add_emotion(_h, 0, 1, 0, 1);

    if (_h.carrying && _h.carry_amount > 0)
    {
        _h.carrying = false;
        _h.carry_type = -1;
        _h.carry_amount = 0;
    }

    // Grief and fear propagate through the people who knew them.
    for (var _i = 0; _i < array_length(_w.humans); _i++)
    {
        var _other = _w.humans[_i];
        if (_other.dead || _other == _h) continue;

        var _dist = point_distance(_h.x, _h.y, _other.x, _other.y);
        if (_dist < 150)
        {
            human_add_emotion(_other, 0, 0.18, 0.05, 0.22);
            human_add_memory(_other, "DEATH", -0.8, 7, _h.id, "Saw " + _h.name + " die.");
            human_add_thought(_other, "I saw " + _h.name + " die", -0.75, 0.7, 190);
        }

        if (_other.partner_id == _h.id)
        {
            _other.partner_id = -1;
            human_add_emotion(_other, 0, 0.1, 0.1, 0.65);
            human_add_memory(_other, "GRIEF", -1, 10, _h.id, "Lost " + _h.name + ".");
            human_add_thought(_other, "The house is too quiet without " + _h.name, -0.9, 0.95, 420);
            _other.hope = max(0, _other.hope - 0.25);
            _other.loneliness = min(1, _other.loneliness + 0.30);
            _other.mood = max(0, _other.mood - 22);
        }
    }

    var _house = world_find_household(_w, _h.household_id);
    if (_house != noone)
    {
        world_household_remove(_w, _house.id, _h.id);

        if (_house.head_id == _h.id)
        {
            _house.head_id = world_household_heir(_w, _house);
            if (_house.head_id != -1)
            {
                var _heir = world_find_human(_w, _house.head_id);
                if (_heir != noone)
                {
                    _heir.wealth += _h.wealth * 0.55;
                    _house.wealth += _h.wealth * 0.25;
                    _heir.reputation = min(100, _heir.reputation + 4);
                    world_event(_w, _heir.name + " INHERITS " + _house.name + ".", _w.civs[_h.civ].colour, 4, _h.civ);
                }
            }
        }
    }

    var _partner = world_find_human(_w, _h.partner_id);
    if (_partner != noone && !_partner.dead)
    {
        _partner.wealth += _h.wealth * 0.35;
    }

    for (var _child_i = 0; _child_i < array_length(_w.humans); _child_i++)
    {
        var _child = _w.humans[_child_i];
        if (_child.dead || _child.id == _h.id) continue;
        if (_child.parent_a != _h.id && _child.parent_b != _h.id) continue;

        _child.wealth += _h.wealth * 0.12;
        human_add_memory(_child, "INHERIT", 0.2, 5, _h.id, "Inherited part of " + _h.name + "'s estate.");
        human_add_memory(_child, "GRIEF", -0.9, 9, _h.id, "Lost their parent, " + _h.name + ".");
        human_add_emotion(_child, 0, 0.12, 0.04, 0.55);
        human_add_thought(_child, "My parent, " + _h.name + ", is gone", -0.9, 0.9, 380);
        _child.hope = max(0, _child.hope - 0.18);
    }

    for (var _friend_i = 0; _friend_i < array_length(_w.humans); _friend_i++)
    {
        var _friend = _w.humans[_friend_i];
        if (_friend.dead || _friend.id == _h.id) continue;
        if (_friend.civ != _h.civ) continue;

        var _friend_rel = human_find_relation(_friend, _h.id);
        if (_friend_rel != noone && _friend_rel.friend)
        {
            human_add_memory(_friend, "GRIEF", -0.7, 7, _h.id, "Lost a friend, " + _h.name + ".");
            human_add_thought(_friend, "I keep expecting " + _h.name + " to walk in", -0.8, 0.75, 260);
            human_add_emotion(_friend, 0, 0.08, 0.03, 0.38);
        }
    }

    if (_w.civs[_h.civ].leader_id == _h.id)
    {
        _w.civs[_h.civ].legitimacy = max(0, _w.civs[_h.civ].legitimacy - 18);
        world_event(_w, _w.civs[_h.civ].name + " MOURNS ITS LEADER.", _w.ui_alert, 8, _h.civ);
    }

    show_debug_message("DEATH: " + _h.name + " (" + _w.civs[_h.civ].name + ") by " + _cause + " at t=" + string(floor(_w.time)));
};

function human_interact(_w, _h, _other)
{
    if (_other == noone || _other.dead || _h.dead) return;

    // Compatibility is not a single dice roll. Temperament, values and the
    // small facets of character all decide whether two people can stand
    // each other long enough to become friends.
    var _trait_compat = 1 - (abs(_h.traits.sociability - _other.traits.sociability)
        + abs(_h.traits.compassion - _other.traits.compassion)
        + abs(_h.traits.industry - _other.traits.industry)) / 3;
    var _value_compat = 1 - (abs(_h.values.family - _other.values.family)
        + abs(_h.values.community - _other.values.community)
        + abs(_h.values.honor - _other.values.honor)
        + abs(_h.values.tradition - _other.values.tradition)) / 4;
    var _facet_compat = 1 - (abs(_h.facets.humor - _other.facets.humor)
        + abs(_h.facets.patience - _other.facets.patience)
        + abs(_h.facets.altruism - _other.facets.altruism)
        + abs(_h.facets.discipline - _other.facets.discipline)) / 4;
    var _compat = clamp(_trait_compat * 0.45 + _value_compat * 0.30 + _facet_compat * 0.25, 0, 1);

    // People bring their current preoccupation into a conversation. A
    // grieving person talks about grief; a proud crafter talks about work.
    var _topic = "TALK";
    var _topic_text = "Shared a conversation with " + _other.name + ".";
    if (_h.grief > 0.35)
    {
        _topic = "GRIEF";
        _topic_text = "Shared a grief with " + _other.name + ".";
        _compat += _other.traits.compassion * 0.18 - 0.05;
    }
    else if (_h.anger > 0.42)
    {
        _topic = "COMPLAINT";
        _topic_text = "Complained about the day to " + _other.name + ".";
        _compat += _other.facets.patience * 0.14 - 0.04;
    }
    else if (_h.facets.humor > 0.62)
    {
        _topic = "JEST";
        _topic_text = "Shared a joke with " + _other.name + ".";
        _compat += (_h.facets.humor + _other.facets.humor) * 0.06;
    }
    else if (_h.values.knowledge > 0.62 && _other.values.knowledge > 0.45)
    {
        _topic = "LORE";
        _topic_text = "Traded lore with " + _other.name + ".";
        _compat += (_h.values.knowledge + _other.values.knowledge) * 0.05;
    }
    else if (_h.values.family > 0.62 && _other.values.family > 0.42)
    {
        _topic = "FAMILY";
        _topic_text = "Talked of family with " + _other.name + ".";
        _compat += (_h.values.family + _other.values.family) * 0.05;
    }

    var _delta = 3 + clamp(_compat, 0, 1) * 10 + _h.traits.sociability * 2 - _h.fear * 2;
    if (_topic == "COMPLAINT") _delta -= 1.5;
    if (_topic == "GRIEF") _delta += 1;

    human_social_event(_h, _other, _topic, _delta, _topic_text);
    human_social_event(_other, _h, _topic, _delta * 0.8, _topic_text);

    _h.social = max(0, _h.social - 0.24);
    _other.social = max(0, _other.social - 0.24);
    _h.purpose = max(0, _h.purpose - 0.05);
    _other.purpose = max(0, _other.purpose - 0.04);
    _h.loneliness = max(0, _h.loneliness - 0.12);
    _other.loneliness = max(0, _other.loneliness - 0.12);
    _h.comfort = min(1, _h.comfort + 0.04);
    _other.comfort = min(1, _other.comfort + 0.04);
    _h.last_social = global.sim_time;
    _other.last_social = global.sim_time;
    _h.mood = clamp(_h.mood + 1.0, 0, 100);
    _other.mood = clamp(_other.mood + 1.0, 0, 100);

    if (_delta > 4)
    {
        human_add_thought(_h, "Good company in " + _other.name, 0.42, 0.4, 80);
        human_add_thought(_other, "Good company in " + _h.name, 0.42, 0.4, 80);
    }
    else if (_delta < -2)
    {
        human_add_thought(_h, _other.name + " was short with me", -0.42, 0.5, 90);
    }

    // Experienced people teach what they actually know best. Apprentices
    // remember who trained them; mastery is transmitted, not invented.
    if (_h.age >= ADULT_AGE && _other.age >= 8 && random(1) < 0.11)
    {
        var _skill = human_best_skill_key(_h);
        var _teacher_skill = variable_struct_get(_h.skills, _skill);
        var _student_skill = variable_struct_get(_other.skills, _skill);

        if (_teacher_skill > _student_skill + 0.05)
        {
            var _transfer = 0.002 + _teacher_skill * 0.011 + _h.skills.teach * 0.006;
            variable_struct_set(_other.skills, _skill, min(1, _student_skill + _transfer));
            _h.skills.teach = min(1, _h.skills.teach + 0.004);
            _h.taught += 1;

            if (_other.mentor_id == -1 && _teacher_skill > _student_skill + 0.16)
            {
                _other.mentor_id = _h.id;
                _h.student_count += 1;
                human_add_memory(_other, "TEACH", 0.45, 4, _h.id, "Became " + _h.name + "'s apprentice in " + human_skill_label(_skill) + ".");
                human_add_memory(_h, "TEACH", 0.45, 4, _other.id, "Took " + _other.name + " as an apprentice.");
                human_add_thought(_other, "I am learning " + human_skill_label(_skill) + " from " + _h.name, 0.5, 0.5, 180);
            }

            if (random(1) < 0.08)
            {
                human_add_memory(_other, "TEACH", 0.4, 2, _h.id, "Learned " + human_skill_label(_skill) + " from " + _h.name + ".");
                human_add_thought(_other, "A lesson in " + human_skill_label(_skill), 0.35, 0.3, 70);
            }

            if (random(1) < 0.05)
            {
                human_add_thought(_h, "Teaching " + _other.name + " well", 0.45, 0.35, 80);
                human_advance_ambition(_h, 0.012);
            }
        }
    }

    // Gossip carries important memories: reputation is a social product.
    if (array_length(_h.memories) > 0 && random(1) < 0.05)
    {
        var _memory = _h.memories[irandom(array_length(_h.memories) - 1)];
        if (_memory.importance >= 5 && _memory.subject != -1)
        {
            human_add_memory(_other, "GOSSIP", _memory.valence * 0.6, _memory.importance * 0.45, _memory.subject, "Heard about: " + _memory.text);
            var _heard = human_relation(_other, _memory.subject);
            _heard.opinion = clamp(_heard.opinion + _memory.valence * 2, -100, 100);

            if (_memory.valence < -0.4) _heard.resentment = min(100, _heard.resentment + 3);
            else if (_memory.valence > 0.4) _heard.trust = min(1, _heard.trust + 0.015);
        }
    }

    // Political identity travels through trusted conversation.
    if (human_relation(_h, _other.id).trust > 0.58 && _h.faction != _other.faction && random(1) < 0.012)
    {
        _other.faction = _h.faction;
        _other.purpose = min(1, _other.purpose + 0.04);
        human_add_memory(_other, "POLITICS", 0.15, 4, _h.id, "Was persuaded toward the " + _h.faction + " cause.");
    }

    // A quarrel is a social event too; repeated friction becomes resentment.
    var _rel_to_other = human_relation(_h, _other.id);
    if ((_rel_to_other.resentment > 24 || _rel_to_other.opinion < -18) && random(1) < 0.055)
    {
        var _insult = 4 + _h.traits.aggression * 7;
        human_social_event(_h, _other, "QUARREL", -_insult, "Quarrelled with " + _other.name + ".");
        human_social_event(_other, _h, "QUARREL", -_insult * 0.8, "Quarrelled with " + _h.name + ".");
        human_add_emotion(_h, 0, 0.04, 0.18, 0);
        human_add_emotion(_other, 0, 0.08, 0.1, 0);
        world_event(_w, _h.name + " AND " + _other.name + " QUARREL.", _w.ui_alert, 3, _h.civ);
    }

    // Compassion is a real service: comfort the grieving and the frightened.
    if (_other.grief > 0.28 && _h.traits.compassion > 0.48)
    {
        _other.grief = max(0, _other.grief - 0.07);
        _other.mood = min(100, _other.mood + 3.5);
        _other.fear = max(0, _other.fear - 0.05);
        _h.joy = min(1, _h.joy + 0.03);
        human_add_memory(_other, "COMFORT", 0.6, 5, _h.id, "Was comforted by " + _h.name + ".");
    }

    // Partnerships form through repeated positive contact, not a global matchmaker.
    if (_h.partner_id == -1 && _other.partner_id == -1
        && _h.age >= 18 && _other.age >= 18
        && _h.age < 44 && _other.age < 44
        && _h.sex != _other.sex
        && _h.family_id != _other.family_id
        && _compat > 0.36
        && human_relation(_h, _other.id).opinion > 30
        && random(1) < (0.018 + _h.traits.sociability * 0.012 + _h.facets.romantic * 0.008))
    {
        _h.partner_id = _other.id;
        _other.partner_id = _h.id;
        _h.family_id = _w.civs[_h.civ].next_family_id;
        _other.family_id = _h.family_id;
        _w.civs[_h.civ].next_family_id += 1;

        if (_h.household_id != -1) world_household_remove(_w, _h.household_id, _h.id);
        if (_other.household_id != -1) world_household_remove(_w, _other.household_id, _other.id);

        var _new_house = world_household_new(_w, _h.civ, _h, _other);
        _h.household_id = _new_house.id;
        _other.household_id = _new_house.id;
        _new_house.wealth += _h.wealth * 0.4 + _other.wealth * 0.4;

        world_event(_w, _h.name + " AND " + _other.name + " BIND THEIR HOUSEHOLDS.", _w.civs[_h.civ].colour, 6, _h.civ);
        human_add_memory(_h, "UNION", 0.8, 8, _other.id, "Chose " + _other.name + " as a partner.");
        human_add_memory(_other, "UNION", 0.8, 8, _h.id, "Chose " + _h.name + " as a partner.");
        human_add_emotion(_h, 0.6, 0, 0, 0);
        human_add_emotion(_other, 0.6, 0, 0, 0);

        var _rel_union = human_relation(_h, _other.id);
        _rel_union.kin = 1;
        _rel_union.friend = 1;
        _rel_union.love = 100;
        _rel_union.trust = min(1, _rel_union.trust + 0.15);
        human_add_thought(_h, "A new life with " + _other.name, 0.8, 0.8, 240);
        human_add_thought(_other, "A new life with " + _h.name, 0.8, 0.8, 240);
        human_advance_ambition(_h, 0.10);
        human_advance_ambition(_other, 0.10);
        _w.relation = min(100, _w.relation + 2);
    }
};

function human_execute_task(_w, _h, _dt)
{
    var _arrived = false;

    // An unconscious person does not finish the job. They lie where they fell
    // until the body or a healer brings them back.
    if (_h.body.consciousness < 0.22)
    {
        _h.task = TASK_IDLE;
        _h.goal = GOAL_HEAL;
        _h.target_ref = -1;
        return;
    }

    if (_h.task == TASK_IDLE)
    {
        return;
    }

    if (_h.task == TASK_GATHER)
    {
        var _node = _h.target_ref;
        if (_node == -1 || _node.amount <= 0)
        {
            if (_node != -1) human_forget_site(_h, _node);
            _h.task = TASK_IDLE;
            human_plan_work(_w, _h);
            return;
        }

        _arrived = human_move_to(_h, _node.x, _node.y, _dt, 1.0) < 20;
        if (_arrived)
        {
            _h.work_timer += _dt;
            if (_h.work_timer > 2.2)
            {
                var _skill = _h.skills.forage;
                if (_node.kind == RES_WOOD) _skill = _h.skills.wood;
                else if (_node.kind == RES_STONE) _skill = _h.skills.stone;

                var _tool_bonus = 1 + min(0.55, _w.civs[_h.civ].tools * 0.025);
                _h.carry_amount = min(_node.amount, (3 + _skill * 4 + _h.traits.industry * 1.2) * _tool_bonus);
                if (_node.kind == RES_WOOD) _h.carry_amount = min(_node.amount, _h.carry_amount * 1.35);
                else if (_node.kind == RES_STONE) _h.carry_amount = min(_node.amount, _h.carry_amount * 1.15);
                _node.amount -= _h.carry_amount;
                _h.carrying = true;
                _h.carry_type = _node.kind;
                _h.work_timer = 0;
                _h.task = TASK_DEPOSIT;
                _h.target_kind = TARGET_POINT;
                _h.target_ref = -1;
                _h.target_x = _h.home_x;
                _h.target_y = _h.home_y;
                _h.last_gather_ref = _node;
                human_remember_site(_h, _node);

                var _gather_skill = (_node.kind == RES_FOOD) ? "forage" : ((_node.kind == RES_WOOD) ? "wood" : "stone");
                human_train_skill(_h, _gather_skill, 0.008);
                _h.purpose = max(0, _h.purpose - 0.08);
                _h.reputation = min(100, _h.reputation + 0.03);
            }
        }
        return;
    }

    if (_h.task == TASK_DEPOSIT)
    {
        _arrived = human_move_to(_h, _h.target_x, _h.target_y, _dt, 1.0) < 26;
        if (_arrived)
        {
            var _civ = _w.civs[_h.civ];
            if (_h.carry_type == RES_FOOD)
            {
                _civ.food = min(world_civ_food_capacity(_w, _h.civ), _civ.food + _h.carry_amount);
                _civ.gathered += _h.carry_amount;
            }
            else if (_h.carry_type == RES_WOOD)
            {
                _civ.wood = min(400, _civ.wood + _h.carry_amount);
                _civ.gathered += _h.carry_amount * 0.7;
            }
            else if (_h.carry_type == RES_STONE)
            {
                _civ.stone = min(300, _civ.stone + _h.carry_amount);
                _civ.gathered += _h.carry_amount * 0.5;
            }

            _h.gathered += _h.carry_amount;
            var _haul = _h.carry_amount;

            var _wage = _h.carry_amount * 0.055;
            _h.wealth += _wage;
            _civ.treasury += _wage * 0.28;
            _h.reputation = min(100, _h.reputation + 0.025);

            var _house = world_find_household(_w, _h.household_id);
            if (_house != noone) _house.wealth += _wage * 0.72;

            _h.carrying = false;
            _h.carry_type = -1;
            _h.carry_amount = 0;
            _h.task = TASK_IDLE;
            _h.purpose = min(1, _h.purpose + 0.05);
            _h.mood = clamp(_h.mood + 0.4, 0, 100);

            if (_haul >= 6 && random(1) < 0.16)
            {
                human_add_thought(_h, "A good haul for the stores", 0.45, 0.35, 80);
            }

            human_advance_ambition(_h, 0.004);
        }
        return;
    }

    if (_h.task == TASK_FARM)
    {
        var _farm = _h.target_ref;
        if (_farm == -1 || !_farm.complete)
        {
            _h.task = TASK_IDLE;
            human_plan_work(_w, _h);
            return;
        }

        _arrived = human_move_to(_h, _farm.x, _farm.y, _dt, 0.9) < 28;
        if (_arrived)
        {
            _h.work_timer += _dt;
            if (_h.work_timer > 3.2)
            {
                var _civ = _w.civs[_h.civ];
                var _yield = 2.0 + _h.skills.farm * 3.0 + _civ.know.farm * 0.55;
                _yield *= 1 + min(0.45, _civ.tools * 0.02);
                _yield *= _w.season_food_mult;
                _civ.food = min(world_civ_food_capacity(_w, _h.civ), _civ.food + _yield);
                _civ.gathered += _yield;
                _h.gathered += _yield;
                human_train_skill(_h, "farm", 0.01);
                _h.work_timer = 0;
                _h.purpose = max(0, _h.purpose - 0.04);
                _h.wealth += _yield * 0.04;
                var _house = world_find_household(_w, _h.household_id);
                if (_house != noone) _house.wealth += _yield * 0.04;
            }
        }
        return;
    }

    if (_h.task == TASK_BUILD)
    {
        var _project = _h.target_ref;
        if (_project == -1 || _project.complete)
        {
            _h.task = TASK_IDLE;
            human_plan_work(_w, _h);
            return;
        }

        _arrived = human_move_to(_h, _project.x, _project.y, _dt, 0.85) < 30;
        if (_arrived)
        {
            var _build_skill = _h.skills.build + _w.civs[_h.civ].know.craft * 0.06;
            _project.progress = min(1, _project.progress + _dt * (0.012 + _build_skill * 0.022) * (1 + min(0.35, _w.civs[_h.civ].tools * 0.015)));
            human_train_skill(_h, "build", 0.006);
            _h.work_timer += _dt;
            _h.purpose = max(0, _h.purpose - 0.03);
            _h.reputation = min(100, _h.reputation + _dt * 0.02);

            if (_project.progress >= 1)
            {
                _project.complete = true;
                _project.progress = 1;
                _h.built += 1;
                human_add_memory(_h, "BUILD", 0.5, 5, _project.id, "Helped finish " + building_label(_project.type) + ".");
                human_add_thought(_h, "We raised " + building_label(_project.type) + " from the ground", 0.6, 0.6, 180);
                human_advance_ambition(_h, 0.012);
                world_event(_w, _w.civs[_h.civ].name + " COMPLETES " + building_label(_project.type) + ".", _w.civs[_h.civ].colour, 5, _h.civ);
                _h.task = TASK_IDLE;
                civil_project_finished(_w, _h.civ, _project);
            }
        }
        return;
    }

    if (_h.task == TASK_EAT)
    {
        _arrived = human_move_to(_h, _h.target_x, _h.target_y, _dt, 1.0) < 24;
        if (_arrived)
        {
            var _civ = _w.civs[_h.civ];
            if (_civ.food >= 1)
            {
                _civ.food -= 1;
                _h.hunger = max(0, _h.hunger - 0.42);
                _h.mood = clamp(_h.mood + 2.5, 0, 100);
                _h.purpose = min(1, _h.purpose + 0.02);
                _h.last_meal = global.sim_time;
                _h.comfort = min(1, _h.comfort + 0.06);
                human_add_thought(_h, "A meal of " + _h.physical.favoured_food, 0.45, 0.45, 90);
            }
            else
            {
                _h.hunger = min(1, _h.hunger + 0.04);
                _h.mood = max(0, _h.mood - 2);
                _h.job = JOB_FOOD;
                _h.task = TASK_IDLE;
                human_plan_work(_w, _h);
                return;
            }

            _h.task = TASK_IDLE;
        }
        return;
    }

    if (_h.task == TASK_SLEEP)
    {
        _arrived = human_move_to(_h, _h.target_x, _h.target_y, _dt, 0.8) < 20;
        if (_arrived)
        {
            _h.energy = min(1, _h.energy + _dt * 0.06);
            body_rest_care(_h, _dt, 1.0);
            _h.task_timer += _dt;

            if (_h.energy > 0.82 || _h.task_timer > 24)
            {
                _h.task = TASK_IDLE;
                _h.last_sleep = global.sim_time;
                human_add_thought(_h, "Rested, and ready for the day", 0.4, 0.4, 80);
            }
        }
        return;
    }

    if (_h.task == TASK_SOCIAL)
    {
        if (_h.target_kind == TARGET_HUMAN)
        {
            var _other = _h.target_ref;
            if (_other == -1 || _other.dead)
            {
                _h.task = TASK_IDLE;
                return;
            }

            _arrived = human_move_to(_h, _other.x, _other.y, _dt, 0.9) < 24;
            if (_arrived)
            {
                human_interact(_w, _h, _other);
                _h.task_timer += _dt;

                if (_h.task_timer > 2.2 || _h.social < 0.25)
                {
                    _h.task = TASK_IDLE;
                }
            }
        }
        else
        {
            _arrived = human_move_to(_h, _h.target_x, _h.target_y, _dt, 0.65) < 20;
            if (_arrived) _h.task = TASK_IDLE;
        }
        return;
    }

    if (_h.task == TASK_PATROL)
    {
        _arrived = human_move_to(_h, _h.target_x, _h.target_y, _dt, 0.75) < 30;
        if (_arrived)
        {
            _h.task_timer += _dt;
            if (_h.task_timer > 1.4)
            {
                _h.target_x = _w.civs[_h.civ].home_x + random_range(-160, 160);
                _h.target_y = _w.civs[_h.civ].home_y + random_range(-120, 120);
                _h.task_timer = 0;
            }
        }

        if (_h.threat_ref != -1 && _h.threat_dist < 130)
        {
            _h.goal = GOAL_FIGHT;
            _h.target_kind = _h.threat_kind;
            _h.target_ref = _h.threat_ref;
            _h.task = TASK_FIGHT;
        }
        return;
    }

    if (_h.task == TASK_FIGHT)
    {
        var _target = _h.target_ref;
        if (_target == -1 || _target.dead)
        {
            _h.task = TASK_IDLE;
            _h.goal = GOAL_WORK;
            return;
        }

        _arrived = human_move_to(_h, _target.x, _target.y, _dt, 1.0) < 22;
        if (_arrived)
        {
            human_attack(_w, _h, _target, _h.target_kind);
        }
        return;
    }

    if (_h.task == TASK_FLEE)
    {
        _arrived = human_move_to(_h, _h.target_x, _h.target_y, _dt, 1.2) < 28;
        if (_arrived || _h.threat_ref == -1 || _h.threat_dist > 160)
        {
            _h.task = TASK_IDLE;
            _h.goal = GOAL_IDLE;
        }
        return;
    }

    if (_h.task == TASK_TREAT)
    {
        if (_h.target_kind == TARGET_HUMAN)
        {
            var _patient = _h.target_ref;
            if (_patient == -1 || _patient.dead)
            {
                _h.task = TASK_IDLE;
                return;
            }

            _arrived = human_move_to(_h, _patient.x, _patient.y, _dt, 0.9) < 24;
            if (_arrived)
            {
                var _infirmary = human_find_building(_w, _h, BLD_INFIRMARY);
                var _has_infirmary = (_infirmary != noone
                    && point_distance(_patient.x, _patient.y, _infirmary.x, _infirmary.y) < 90);

                body_treat_patient(_h, _patient, _dt, _has_infirmary);
                _patient.fear = max(0, _patient.fear - _dt * 0.2);
                human_train_skill(_h, "heal", 0.005);
                _h.work_timer += _dt;

                if (_h.work_timer > 4.5 || !body_needs_care(_patient))
                {
                    _h.task = TASK_IDLE;
                    human_add_memory(_patient, "HEAL", 0.55, 4, _h.id, "Was tended by " + _h.name + ".");
                    human_add_thought(_patient, "Tended by " + _h.name, 0.5, 0.45, 100);
                    human_add_thought(_h, "I eased " + _patient.name + "'s pain", 0.45, 0.4, 80);
                    human_advance_ambition(_h, 0.008);
                }
            }
        }
        else
        {
            _arrived = human_move_to(_h, _h.target_x, _h.target_y, _dt, 0.85) < 24;
            if (_arrived)
            {
                body_rest_care(_h, _dt, 0.80);
                _h.energy = max(0, _h.energy - _dt * 0.01);
                _h.task_timer += _dt;

                if (_h.hp > 85 || _h.task_timer > 18) _h.task = TASK_IDLE;
            }
        }
        return;
    }

    if (_h.task == TASK_RESEARCH)
    {
        _arrived = human_move_to(_h, _h.target_x, _h.target_y, _dt, 0.7) < 30;
        if (_arrived)
        {
            var _civ = _w.civs[_h.civ];
            var _gain = _dt * (0.20 + _h.skills.research * 0.55 + _civ.faction.lore * 0.18);
            civ_add_research(_w, _civ, _civ.research_focus, _gain);
            _civ.tech_points += _gain;
            human_train_skill(_h, "research", 0.004);
            _h.purpose = max(0, _h.purpose - 0.02);
            _h.reputation = min(100, _h.reputation + _dt * 0.02);
            _h.work_timer += _dt;

            if (_h.work_timer > 12)
            {
                _h.task = TASK_IDLE;
                _h.discoveries += 1;
                human_add_memory(_h, "STUDY", 0.4, 4, -1, "Followed a line of inquiry into " + _civ.research_focus + ".");
                human_add_thought(_h, "A question I cannot put down", 0.4, 0.5, 110);
                human_advance_ambition(_h, 0.006);
            }
        }
        return;
    }

    if (_h.task == TASK_TRADE)
    {
        if (_w.at_war || _w.relation < -25)
        {
            _h.task = TASK_IDLE;
            _h.goal = GOAL_WORK;
            return;
        }

        _h.task_timer += _dt;
        _arrived = human_move_to(_h, _h.target_x, _h.target_y, _dt, 0.8) < 40;
        if (_arrived)
        {
            var _other_civ = _w.civs[1 - _h.civ];
            var _home_civ = _w.civs[_h.civ];

            // Only surplus leaves; a caravan cannot strip its own settlement.
            var _food = min(max(0, _home_civ.food - 70), max(0, 150 - _other_civ.food), 12);
            var _wood = min(max(0, _home_civ.wood - 45), max(0, 180 - _other_civ.wood), 9);
            var _stone = min(max(0, _home_civ.stone - 35), max(0, 160 - _other_civ.stone), 7);

            if (_food + _wood + _stone < 1)
            {
                _h.task = TASK_IDLE;
                _h.goal = GOAL_WORK;
                return;
            }

            var _scarcity = clamp(1 + (_other_civ.food - _home_civ.food) / 260, 0.7, 1.25);
            _home_civ.food -= _food;
            _home_civ.wood -= _wood;
            _home_civ.stone -= _stone;
            _other_civ.food = min(world_civ_food_capacity(_w, 1 - _h.civ), _other_civ.food + _food * (0.82 + _scarcity * 0.12));
            _other_civ.wood = min(400, _other_civ.wood + _wood * (0.82 + _scarcity * 0.12));
            _other_civ.stone = min(300, _other_civ.stone + _stone * (0.82 + _scarcity * 0.12));

            var _profit = (_food + _wood * 0.7 + _stone * 0.5) * (1.2 + _h.skills.trade * 2.2);
            _h.wealth += _profit;
            _home_civ.treasury += _profit * 0.18;

            // Trade carries techniques as well as goods.
            var _trade_domains = ["farm", "craft", "war", "medicine", "culture", "trade"];
            for (var _trade_i = 0; _trade_i < array_length(_trade_domains); _trade_i++)
            {
                var _domain = _trade_domains[_trade_i];
                var _gap = variable_struct_get(_home_civ.know, _domain) - variable_struct_get(_other_civ.know, _domain);

                if (_gap > 8 && random(1) < 0.16 + _h.skills.trade * 0.12)
                {
                    variable_struct_set(_other_civ.know, _domain, min(200, variable_struct_get(_other_civ.know, _domain) + _gap * 0.045));
                }
            }

            _w.relation = min(100, _w.relation + 3 + _h.skills.trade * 5 + _scarcity);
            _w.trust = min(1, _w.trust + 0.015 + _h.skills.trade * 0.02);
            _home_civ.trade_runs += 1;
            _h.trade_runs += 1;
            _h.trade_cooldown = 42;
            human_train_skill(_h, "trade", 0.012);
            _h.reputation = min(100, _h.reputation + 0.4);
            human_add_memory(_h, "TRADE", 0.5, 5, -1, "Carried goods to " + _other_civ.name + ".");
            world_event(_w, _home_civ.name + " AND " + _other_civ.name + " TRADE.", _w.ui_good, 4, -1);

            _h.task = TASK_IDLE;
            _h.goal = GOAL_WORK;
        }
        return;
    }

    if (_h.task == TASK_CRAFT)
    {
        var _workshop = _h.target_ref;
        if (_workshop == -1 || !_workshop.complete)
        {
            _h.task = TASK_IDLE;
            human_plan_work(_w, _h);
            return;
        }

        _arrived = human_move_to(_h, _workshop.x, _workshop.y, _dt, 0.82) < 30;
        if (_arrived)
        {
            _h.work_timer += _dt;
            _h.purpose = max(0, _h.purpose - _dt * 0.02);

            if (_h.work_timer > 3.4)
            {
                _h.work_timer = 0;
                var _civ = _w.civs[_h.civ];

                if (_civ.wood < 1.2 || _civ.stone < 0.6)
                {
                    _h.task = TASK_IDLE;
                    return;
                }

                _civ.wood -= 1.2;
                _civ.stone -= 0.6;

                var _output = 0.28 + _h.skills.build * 0.45 + _civ.know.craft * 0.22 + _h.traits.industry * 0.16;
                var _before = floor(_civ.tools);
                _civ.tools = min(80, _civ.tools + _output);
                human_train_skill(_h, "build", 0.007);
                _h.wealth += _output * 0.12;

                if (random(1) < 0.008 + _h.skills.build * 0.025)
                {
                    _h.masterworks += 1;
                    human_add_memory(_h, "CRAFT", 0.65, 6, -1, "Finished a masterwork in the workshop.");
                    human_add_thought(_h, "A piece of work worth keeping", 0.6, 0.6, 150);
                    human_advance_ambition(_h, 0.02);
                }
                _h.reputation = min(100, _h.reputation + 0.03);

                var _house = world_find_household(_w, _h.household_id);
                if (_house != noone) _house.wealth += _output * 0.08;

                if (floor(_civ.tools / 20) > floor(_before / 20))
                {
                    world_event(_w, _civ.name + " REACHES " + string(floor(_civ.tools / 20) * 20) + " TOOLS.", _civ.colour, 4, _civ.id);
                }
            }
        }
        return;
    }

    if (_h.task == TASK_PRAY)
    {
        _arrived = human_move_to(_h, _h.target_x, _h.target_y, _dt, 0.62) < 26;
        if (_arrived)
        {
            _h.grief = max(0, _h.grief - _dt * 0.045);
            _h.stress = max(0, _h.stress - _dt * 0.055);
            _h.fear = max(0, _h.fear - _dt * 0.03);
            _h.mood = min(100, _h.mood + _dt * 0.9);
            _h.joy = min(1, _h.joy + _dt * 0.02);
            _h.purpose = min(1, _h.purpose + _dt * 0.008);
            _h.wonder = min(1, _h.wonder + _dt * 0.01);
            _h.task_timer += _dt;

            if (_h.task_timer > 7 || _h.grief < 0.12)
            {
                _h.task = TASK_IDLE;
            }
        }
        return;
    }

    if (_h.task == TASK_WANDER)
    {
        _arrived = human_move_to(_h, _h.target_x, _h.target_y, _dt, 0.62) < 22;
        if (_arrived)
        {
            _h.stress = max(0, _h.stress - _dt * 0.04);
            _h.joy = min(1, _h.joy + _dt * 0.035);
            _h.social = max(0, _h.social - _dt * 0.012);
            _h.wonder = min(1, _h.wonder + _dt * 0.018);
            _h.comfort = min(1, _h.comfort + _dt * 0.006);

            if (_h.job == JOB_CHILD && _h.near_allies > 0 && _h.action_cooldown <= 0)
            {
                _h.action_cooldown = 2.4;
                for (var _play_i = 0; _play_i < array_length(_h.near_humans); _play_i++)
                {
                    var _playmate = _h.near_humans[_play_i];
                    if (_playmate.dead || _playmate.civ != _h.civ || _playmate.age >= ADULT_AGE) continue;
                    human_interact(_w, _h, _playmate);
                    break;
                }
            }

            _h.task = TASK_IDLE;
        }
        return;
    }

    if (_h.task == TASK_LEAD)
    {
        _arrived = human_move_to(_h, _h.target_x, _h.target_y, _dt, 0.65) < 36;
        if (_arrived)
        {
            _h.task_timer += _dt;

            for (var _i = 0; _i < array_length(_w.humans); _i++)
            {
                var _other = _w.humans[_i];
                if (_other.dead || _other.civ != _h.civ) continue;
                if (point_distance(_h.x, _h.y, _other.x, _other.y) < 80)
                {
                    _other.mood = min(100, _other.mood + _dt * 0.12);
                    _other.purpose = min(1, _other.purpose + _dt * 0.008);
                    _other.reputation = min(100, _other.reputation + _dt * 0.004);
                }
            }

            _w.civs[_h.civ].legitimacy = min(100, _w.civs[_h.civ].legitimacy + _dt * 0.018);
            _h.reputation = min(100, _h.reputation + _dt * 0.02);
            human_advance_ambition(_h, _dt * 0.006);

            if (_h.task_timer > 8)
            {
                _h.task = TASK_IDLE;
                _h.target_x = _w.civs[_h.civ].home_x + random_range(-60, 60);
                _h.target_y = _w.civs[_h.civ].home_y + random_range(-40, 40);
            }
        }
        return;
    }
};

function human_contagion(_w, _h)
{
    for (var _i = 0; _i < array_length(_h.near_humans); _i++)
    {
        var _other = _h.near_humans[_i];
        if (_other == _h || _other.dead) continue;

        var _dist = point_distance(_h.x, _h.y, _other.x, _other.y);
        if (_dist > 175) continue;

        var _rel = human_find_relation(_h, _other.id);
        var _familiarity = (_rel == noone) ? 0 : _rel.familiarity;
        var _weight = (1 - _dist / 175) * (0.4 + _familiarity * 0.6) * (0.5 + _other.traits.sociability * 0.5);

        _h.fear += (_other.fear - _h.fear) * 0.035 * _weight;
        _h.anger += (_other.anger - _h.anger) * 0.028 * _weight;
        _h.joy += (_other.joy - _h.joy) * 0.03 * _weight;
        _h.mood += (_other.mood - _h.mood) * 0.012 * _weight;

        if (_other.grief > 0.35)
        {
            _h.grief = min(1, _h.grief + _other.grief * 0.004 * _weight);
        }
    }

    _h.fear = clamp(_h.fear, 0, 1);
    _h.anger = clamp(_h.anger, 0, 1);
    _h.joy = clamp(_h.joy, 0, 1);
    _h.grief = clamp(_h.grief, 0, 1);
};

function human_update(_w, _h, _dt)
{
    if (_h.dead) return;

    _h.age += _dt * AGE_RATE;
    _h.goal_timer += _dt;
    _h.action_cooldown = max(0, _h.action_cooldown - _dt);
    _h.trade_cooldown = max(0, _h.trade_cooldown - _dt);
    _h.fear = max(0, _h.fear - _dt * 0.035);
    _h.anger = max(0, _h.anger - _dt * 0.028);
    _h.grief = max(0, _h.grief - _dt * 0.012);
    _h.stress = max(0, _h.stress - _dt * 0.018);
    _h.joy = max(0, _h.joy - _dt * 0.004);

    // Physiology runs on a slower clock than movement and decisions, but it
    // is the source of health, pain, consciousness and death.
    if (!is_struct(_h.body)) body_new(_h);
    _h.body.timer += _dt;
    if (_h.body.timer >= 0.20)
    {
        var _body_dt = _h.body.timer;
        _h.body.timer = 0;
        body_update(_h, _w, _body_dt);
    }

    if (_h.hp <= 0)
    {
        human_die(_w, _h, body_death_cause(_h));
        return;
    }

    // Thoughts are transient. Important ones last, trivial ones fade.
    for (var _thought_i = array_length(_h.thoughts) - 1; _thought_i >= 0; _thought_i--)
    {
        if (_h.thoughts[_thought_i].expires <= global.sim_time)
        {
            array_delete(_h.thoughts, _thought_i, 1);
        }
    }

    if (_h.job == JOB_CHILD && _h.age >= ADULT_AGE)
    {
        _h.job = JOB_IDLE;
        _h.task = TASK_IDLE;
        _h.goal = GOAL_WORK;
        world_event(_w, _h.name + " COMES OF AGE.", _w.civs[_h.civ].colour, 3, _h.civ);
    }

    if (_h.task != TASK_SLEEP)
    {
        _h.hunger = min(1, _h.hunger + _dt * 0.0062);
        _h.energy = min(1, _h.energy + _dt * 0.0048);
        _h.social = min(1, _h.social + _dt * 0.0036);
        _h.purpose = min(1, _h.purpose + _dt * 0.0024);
    }
    else
    {
        _h.hunger = min(1, _h.hunger + _dt * 0.0028);
    }


    // Secondary needs are derived from the day's conditions: a full belly,
    // a dry bed, the regard of neighbours, and a little room for wonder.
    var _comfort_target = clamp(0.72 - _h.hunger * 0.30 - (1 - _h.energy) * 0.24 - _h.pain * 0.004, 0, 1);
    _h.comfort += (_comfort_target - _h.comfort) * min(1, _dt * 0.05);

    var _esteem_target = clamp(0.42 + _h.reputation / 220 + _h.pride * 0.18 - _h.shame * 0.22, 0, 1);
    _h.esteem += (_esteem_target - _h.esteem) * min(1, _dt * 0.04);

    var _loneliness_target = clamp(0.58 - (1 - _h.social) * 0.28 - _h.near_kin * 0.05
        - ((global.sim_time - _h.last_social < 40) ? 0.12 : 0), 0, 1);
    _h.loneliness += (_loneliness_target - _h.loneliness) * min(1, _dt * 0.035);

    var _hope_target = clamp(0.30 + _h.joy * 0.34 + _h.purpose * 0.20
        + _h.ambition_progress * 0.14 - _h.grief * 0.30 - _h.fear * 0.20 - _h.stress * 0.16, 0, 1);
    _h.hope += (_hope_target - _h.hope) * min(1, _dt * 0.03);

    var _pride_target = clamp(0.20 + _h.reputation / 180 + _h.ambition_progress * 0.25, 0, 1);
    _h.pride += (_pride_target - _h.pride) * min(1, _dt * 0.025);
    _h.shame += (clamp(_h.loneliness * 0.16 - _h.reputation / 500, 0, 1) - _h.shame) * min(1, _dt * 0.02);

    var _thought_mood = human_thought_valence(_h);
    var _mood_target = 52
        - _h.hunger * 24
        - _h.energy * 15
        - _h.safety * 8
        + (1 - _h.social) * 5
        + _h.joy * 9
        + _h.purpose * 3
        + (_h.hp - 70) * 0.13
        - _h.body.infection_load * 9
        - _h.body.sepsis * 24
        + _h.reputation * 0.025
        + _h.comfort * 5
        + _thought_mood * 8
        + _h.hope * 6
        + _h.pride * 3
        - _h.shame * 7
        - _h.loneliness * 6
        - _h.grief * 22
        - _h.fear * 12
        - _h.stress * 8;
    _h.mood += (_mood_target - _h.mood) * min(1, _dt * 0.085);
    _h.mood = clamp(_h.mood, 0, 100);

    _h.reflect_timer -= _dt;
    if (_h.reflect_timer <= 0)
    {
        _h.reflect_timer = random_range(11, 21);
        human_reflect(_w, _h);
    }

    // A visible threat interrupts a plan; it does not wait for the next thought.
    if (_h.threat_ref != -1 && _h.threat_dist < 46 && _h.job != JOB_GUARD
        && _h.goal != GOAL_FLEE && _h.goal != GOAL_FIGHT)
    {
        var _stands_ground = (_h.traits.bold > 0.62 && _h.hp > 45
            && (_h.near_allies > 0 || _h.threat_kind == TARGET_WOLF || _w.at_war));

        if (_stands_ground)
        {
            _h.goal = GOAL_FIGHT;
            _h.task = TASK_FIGHT;
            _h.target_kind = _h.threat_kind;
            _h.target_ref = _h.threat_ref;
        }
        else
        {
            _h.goal = GOAL_FLEE;
            _h.task = TASK_FLEE;
            _h.target_x = _h.home_x;
            _h.target_y = _h.home_y;
            _h.target_ref = -1;
            _h.target_kind = TARGET_POINT;
        }
    }

    _h.think_timer -= _dt;
    if (_h.think_timer <= 0)
    {
        _h.think_timer = random_range(0.8, 1.35);
        human_think(_w, _h);
        human_contagion(_w, _h);
    }

    if (!_h.dead) human_execute_task(_w, _h, _dt);
};
