/// @description Full-screen character dossier for the selected person.
var _h = world_find_human(self, global.selected_id);
if (_h == noone || _h.dead)
{
    draw_set_colour(c_white);
    draw_set_alpha(1);
    exit;
}

var _civ = civs[_h.civ];
var _page = clamp(global.panel_page, 0, UI_PERSON_PAGES - 1);
var _tab_names = ["SELF", "BODY", "MIND", "SOUL", "WORK", "BONDS", "LIFE"];
var _tab_area = UI_PERSON_W - UI_PERSON_PAD * 2;

// Full-page backing. The map remains underneath only as a dim memory.
draw_set_alpha(1);
draw_set_colour(make_colour_rgb(7, 10, 9));
draw_rectangle(0, 0, UI_PERSON_W, UI_PERSON_H, false);

draw_set_alpha(0.5);
draw_set_colour(ui_border);
draw_rectangle(24, 24, UI_PERSON_W - 24, UI_PERSON_H - 24, true);
draw_set_alpha(1);

draw_set_colour(_civ.colour);
draw_rectangle(0, 0, UI_PERSON_W, 4, false);
draw_rectangle(0, 0, 6, UI_PERSON_H, false);

// Header.
ui_text(UI_PERSON_PAD, 10, "CITIZEN DOSSIER", ui_label, 1);
ui_text(UI_PERSON_PAD, 28, _h.name, _civ.colour, 2);
ui_text(UI_PERSON_PAD, 54, _civ.name + " / " + _h.epithet, ui_value, 1);
ui_text_right(UI_PERSON_W - UI_PERSON_PAD, 54, ((_h.sex == 1) ? "FEMALE" : "MALE") + " / " + string(floor(_h.age)) + " YEARS", ui_value, 1);

var _header_ailment = body_ailment_text(_h);
if (_header_ailment == "NONE") _header_ailment = "NO ACTIVE AILMENT";
ui_text(UI_PERSON_PAD, 66, "CONDITION  " + ui_fit(_header_ailment, 96), (_header_ailment == "NO ACTIVE AILMENT") ? ui_good : ui_alert, 1);

var _close_left = UI_PERSON_W - UI_PERSON_PAD - UI_PERSON_CLOSE_W;
draw_set_alpha(0.18);
draw_set_colour(_civ.colour);
draw_rectangle(_close_left, UI_PERSON_CLOSE_Y, _close_left + UI_PERSON_CLOSE_W, UI_PERSON_CLOSE_Y + UI_PERSON_CLOSE_H, false);
draw_set_alpha(1);
draw_set_colour(ui_border);
draw_rectangle(_close_left, UI_PERSON_CLOSE_Y, _close_left + UI_PERSON_CLOSE_W, UI_PERSON_CLOSE_Y + UI_PERSON_CLOSE_H, true);
ui_text(_close_left + 16, UI_PERSON_CLOSE_Y + 8, "CLOSE [ESC]", ui_value, 2);

// Tab strip.
for (var _tab_i = 0; _tab_i < UI_PERSON_PAGES; _tab_i++)
{
    var _tab_left = UI_PERSON_PAD + floor(_tab_i * _tab_area / UI_PERSON_PAGES);
    var _tab_right = UI_PERSON_PAD + floor((_tab_i + 1) * _tab_area / UI_PERSON_PAGES);

    if (_tab_i == _page)
    {
        draw_set_alpha(0.14);
        draw_set_colour(_civ.colour);
        draw_rectangle(_tab_left + 2, UI_PERSON_TAB_Y, _tab_right - 2, UI_PERSON_TAB_Y + UI_PERSON_TAB_H, false);
        draw_set_alpha(1);
        draw_set_colour(_civ.colour);
        draw_rectangle(_tab_left + 8, UI_PERSON_TAB_Y + UI_PERSON_TAB_H - 3, _tab_right - 8, UI_PERSON_TAB_Y + UI_PERSON_TAB_H - 1, false);
    }

    if (_tab_i > 0)
    {
        draw_set_alpha(0.30);
        draw_set_colour(ui_border);
        draw_line(_tab_left, UI_PERSON_TAB_Y + 6, _tab_left, UI_PERSON_TAB_Y + UI_PERSON_TAB_H - 6);
        draw_set_alpha(1);
    }

    ui_text_centred(floor((_tab_left + _tab_right) / 2), UI_PERSON_TAB_Y + 6, _tab_names[_tab_i], (_tab_i == _page) ? _civ.colour : ui_label, 2);
}

draw_set_alpha(0.55);
draw_set_colour(ui_border);
draw_line(UI_PERSON_PAD, 120, UI_PERSON_W - UI_PERSON_PAD, 120);
draw_set_alpha(1);

// Shared lookups. These are cheap and keep the individual pages declarative.
var _partner_name = "NONE";
var _partner = world_find_human(self, _h.partner_id);
if (_partner != noone && !_partner.dead) _partner_name = _partner.name;

var _house_name = "NONE";
var _house = world_find_household(self, _h.household_id);
if (_house != noone)
{
    var _house_text = _house.name;
    var _suffix = " HOUSE";
    var _suffix_len = string_length(_suffix);
    if (string_length(_house_text) > _suffix_len
        && string_copy(_house_text, string_length(_house_text) - _suffix_len + 1, _suffix_len) == _suffix)
    {
        _house_text = string_copy(_house_text, 1, string_length(_house_text) - _suffix_len);
    }
    _house_name = _house_text;
}

var _mother_name = "NONE";
if (_h.parent_b != -1)
{
    var _mother = world_find_human(self, _h.parent_b);
    _mother_name = (_mother == noone) ? "DECEASED" : _mother.name;
}

var _father_name = "NONE";
if (_h.parent_a != -1)
{
    var _father = world_find_human(self, _h.parent_a);
    _father_name = (_father == noone) ? "DECEASED" : _father.name;
}

var _mentor_name = "NONE";
if (_h.mentor_id != -1)
{
    var _mentor = world_find_human(self, _h.mentor_id);
    _mentor_name = (_mentor == noone) ? "DECEASED" : _mentor.name;
}

var _children_text = "NONE";
if (array_length(_h.children) > 0)
{
    _children_text = "";
    var _child_shown = 0;
    for (var _child_i = 0; _child_i < array_length(_h.children); _child_i++)
    {
        var _child = world_find_human(self, _h.children[_child_i]);
        if (_child == noone || _child.dead) continue;
        if (_children_text != "") _children_text += ", ";
        _children_text += _child.name;
        _child_shown += 1;
    }
    if (_child_shown == 0) _children_text = "NONE LIVING";
}

var _born_text = "BEFORE RECORDS";
if (_h.birth_time >= 0) _born_text = "T-" + ui_clock(max(0, global.sim_time - _h.birth_time)) + " AGO";

var _best_skill = human_best_skill_key(_h);
var _best_skill_value = variable_struct_get(_h.skills, _best_skill);
var _value_rank = human_sorted_keys(_h.values, human_value_keys());
var _facet_rank = human_sorted_keys(_h.facets, human_facet_keys());
var _trait_rank = human_sorted_keys(_h.traits, human_trait_keys());
var _skill_rank = human_sorted_keys(_h.skills, human_skill_keys());
var _aptitude_rank = human_sorted_keys(_h.aptitudes, human_skill_keys());
var _link_rank = human_relationship_rank(_h);
var _memory_count = array_length(_h.memories);

var _col_w = 584;
var _col0 = UI_PERSON_PAD;
var _col1 = 664;
var _col2 = 1288;
var _content_y = 140;
var _cy0 = _content_y;
var _cy1 = _content_y;
var _cy2 = _content_y;

switch (_page)
{
    case 0:
        // ---------------------------------------------------------------
        // SELF
        // ---------------------------------------------------------------
        ui_section(_col0, _cy0, _col_w, "IDENTITY", ui_milestone, ui_border);
        _cy0 += UI_SECTION_H;
        ui_key_value(_col0, _cy0, "AGE / SEX", string(floor(_h.age)) + " / " + ((_h.sex == 1) ? "FEMALE" : "MALE"), ui_label, ui_value, 48); _cy0 += UI_ROW_H;
        ui_key_value(_col0, _cy0, "ORIGIN", _h.origin, ui_label, ui_value, 48); _cy0 += UI_ROW_H;
        ui_key_value(_col0, _cy0, "BIRTH", _born_text, ui_label, ui_value, 48); _cy0 += UI_ROW_H;
        ui_key_value(_col0, _cy0, "FACTION", string_upper(_h.faction), ui_label, ui_value, 48); _cy0 += UI_ROW_H;
        ui_key_value(_col0, _cy0, "HOUSEHOLD", _house_name, ui_label, ui_value, 48); _cy0 += UI_ROW_H;
        ui_key_value(_col0, _cy0, "PARTNER", _partner_name, ui_label, ui_value, 48); _cy0 += UI_ROW_GAP;

        ui_section(_col0, _cy0, _col_w, "APPEARANCE", ui_milestone, ui_border);
        _cy0 += UI_SECTION_H;
        ui_key_value(_col0, _cy0, "BUILD", _h.physical.build, ui_label, ui_value, 48); _cy0 += UI_ROW_H;
        ui_key_value(_col0, _cy0, "HEIGHT", _h.physical.height, ui_label, ui_value, 48); _cy0 += UI_ROW_H;
        ui_key_value(_col0, _cy0, "HAIR", _h.physical.hair, ui_label, ui_value, 48); _cy0 += UI_ROW_H;
        ui_key_value(_col0, _cy0, "EYES", _h.physical.eyes, ui_label, ui_value, 48); _cy0 += UI_ROW_H;
        ui_key_value(_col0, _cy0, "MARK", _h.physical.mark, ui_label, ui_value, 48); _cy0 += UI_ROW_H;
        ui_key_value(_col0, _cy0, "VOICE", _h.physical.voice, ui_label, ui_value, 48); _cy0 += UI_ROW_H;
        ui_key_value(_col0, _cy0, "HANDS", _h.physical.hands, ui_label, ui_value, 48); _cy0 += UI_ROW_H;
        ui_key_value(_col0, _cy0, "FAVOURS", _h.physical.favoured_food, ui_label, ui_value, 48); _cy0 += UI_ROW_H;
        ui_key_value(_col0, _cy0, "DREADS", _h.physical.dread, ui_label, ui_alert, 48); _cy0 += UI_ROW_GAP;

        ui_section(_col0, _cy0, _col_w, "STANDING", ui_milestone, ui_border);
        _cy0 += UI_SECTION_H;
        ui_bar_row(_col0, _cy0, _col_w, "REPUTATION", _h.reputation / 100, (_h.reputation > 60) ? ui_good : ui_milestone, ui_label); _cy0 += UI_ROW_H_BAR;
        ui_key_value(_col0, _cy0, "WEALTH", string(round(_h.wealth)) + " COIN", ui_label, ui_value, 48); _cy0 += UI_ROW_H;
        ui_key_value(_col0, _cy0, "TIES", string(human_count_tag(_h, "FRIEND")) + " FRIENDS / " + string(human_count_tag(_h, "RIVAL")) + " RIVALS", ui_label, ui_value, 48); _cy0 += UI_ROW_H;
        ui_key_value(_col0, _cy0, "MOOD", human_mood_label(_h) + " / " + _h.mental_state, ui_label, ui_value, 48);

        ui_section(_col1, _cy1, _col_w, "CALLING", ui_milestone, ui_border);
        _cy1 += UI_SECTION_H;
        ui_key_value(_col1, _cy1, "JOB", string_upper(human_job_label(_h.job)), ui_label, ui_value, 48); _cy1 += UI_ROW_H;
        ui_key_value(_col1, _cy1, "DUTY", string_upper(human_task_label(_h.task)), ui_label, ui_value, 48); _cy1 += UI_ROW_H;
        ui_key_value(_col1, _cy1, "BEST SKILL", human_skill_label(_best_skill) + " / " + human_skill_title(_best_skill_value), ui_label, ui_value, 48); _cy1 += UI_ROW_H;
        ui_key_value(_col1, _cy1, "DRAWN TO", human_job_list_text(_h.labor_likes), ui_label, ui_good, 48); _cy1 += UI_ROW_H;
        ui_key_value(_col1, _cy1, "RESENTS", human_job_list_text(_h.labor_dislikes), ui_label, ui_alert, 48); _cy1 += UI_ROW_GAP;

        ui_section(_col1, _cy1, _col_w, "AMBITION", ui_milestone, ui_border);
        _cy1 += UI_SECTION_H;
        _cy1 += ui_text_wrapped(_col1, _cy1, _h.ambition_text, ui_milestone, 64, 3, UI_LINE_H) * UI_LINE_H;
        ui_bar_row(_col1, _cy1, _col_w, "PROGRESS", _h.ambition_progress, _civ.colour, ui_label);
        _cy1 += UI_ROW_H_BAR;
        if (_h.ambition_met) ui_text(_col1, _cy1, "FULFILLED", ui_good, 1);
        _cy1 += UI_ROW_GAP;

        ui_section(_col1, _cy1, _col_w, "FEAR", ui_milestone, ui_border);
        _cy1 += UI_SECTION_H;
        _cy1 += ui_text_wrapped(_col1, _cy1, _h.fear_text, ui_alert, 64, 2, UI_LINE_H) * UI_LINE_H;
        _cy1 += UI_GAP_SMALL;

        ui_section(_col1, _cy1, _col_w, "THOUGHTS", ui_milestone, ui_border);
        _cy1 += UI_SECTION_H;
        var _self_thoughts = 0;
        for (var _self_thought_i = array_length(_h.thoughts) - 1; _self_thought_i >= 0 && _self_thoughts < 4; _self_thought_i--)
        {
            var _self_thought = _h.thoughts[_self_thought_i];
            if (_self_thought.expires <= global.sim_time) continue;
            var _self_colour = (_self_thought.valence > 0.18) ? ui_good : ((_self_thought.valence < -0.18) ? ui_alert : ui_value);
            ui_text(_col1, _cy1, "- " + ui_fit(_self_thought.text, 60), _self_colour, 1);
            _cy1 += UI_ROW_H;
            _self_thoughts += 1;
        }
        if (_self_thoughts == 0) ui_text(_col1, _cy1, "NO STRONG THOUGHT", ui_label, 1);
        _cy1 += UI_ROW_GAP;

        ui_section(_col1, _cy1, _col_w, "INNER VOICE", ui_milestone, ui_border);
        _cy1 += UI_SECTION_H;
        _cy1 += ui_text_wrapped(_col1, _cy1, _h.inner_voice, ui_value, 64, 3, UI_LINE_H) * UI_LINE_H;

        ui_section(_col2, _cy2, _col_w, "FAMILY", ui_milestone, ui_border);
        _cy2 += UI_SECTION_H;
        ui_key_value(_col2, _cy2, "PARTNER", _partner_name, ui_label, ui_value, 48); _cy2 += UI_ROW_H;
        ui_key_value(_col2, _cy2, "MOTHER", _mother_name, ui_label, ui_value, 48); _cy2 += UI_ROW_H;
        ui_key_value(_col2, _cy2, "FATHER", _father_name, ui_label, ui_value, 48); _cy2 += UI_ROW_H;
        ui_key_value(_col2, _cy2, "CHILDREN", _children_text, ui_label, ui_value, 48); _cy2 += UI_ROW_H;
        ui_key_value(_col2, _cy2, "MENTOR", _mentor_name, ui_label, ui_value, 48); _cy2 += UI_ROW_H;
        ui_key_value(_col2, _cy2, "APPRENTICES", string(_h.student_count), ui_label, ui_value, 48); _cy2 += UI_ROW_GAP;

        ui_section(_col2, _cy2, _col_w, "TEMPERAMENT", ui_milestone, ui_border);
        _cy2 += UI_SECTION_H;
        for (var _self_trait_i = 0; _self_trait_i < 6; _self_trait_i++)
        {
            var _self_trait_key = _trait_rank[_self_trait_i];
            var _self_trait_value = variable_struct_get(_h.traits, _self_trait_key);
            ui_bar_row(_col2, _cy2, _col_w, human_trait_label(_self_trait_key), _self_trait_value, (_self_trait_value > 0.68) ? ui_good : ui_milestone, ui_label);
            _cy2 += UI_ROW_H_BAR;
        }
        _cy2 += UI_GAP_TINY;

        ui_section(_col2, _cy2, _col_w, "RECENT MEMORY", ui_milestone, ui_border);
        _cy2 += UI_SECTION_H;
        var _self_mem_shown = 0;
        for (var _self_mem_i = _memory_count - 1; _self_mem_i >= 0 && _self_mem_shown < 5; _self_mem_i--)
        {
            var _self_mem = _h.memories[_self_mem_i];
            var _self_mem_colour = (_self_mem.valence < -0.25) ? ui_alert : ((_self_mem.valence > 0.25) ? ui_good : ui_value);
            ui_text(_col2, _cy2, "T-" + ui_clock(max(0, global.sim_time - _self_mem.time)), ui_label, 1);
            ui_text(_col2 + 60, _cy2, ui_fit(_self_mem.text, 62), _self_mem_colour, 1);
            _cy2 += UI_ROW_H;
            _self_mem_shown += 1;
        }
        if (_self_mem_shown == 0) ui_text(_col2, _cy2, "NOTHING RECORDED", ui_label, 1);
        break;

    case 1:
        // ---------------------------------------------------------------
        // BODY
        // ---------------------------------------------------------------
        var _body = _h.body;
        var _body_parts = body_part_defs();
        var _body_organs = body_organ_defs();

        ui_section(_col0, _cy0, _col_w, "VITAL SIGNS", ui_milestone, ui_border);
        _cy0 += UI_SECTION_H;
        ui_bar_row(_col0, _cy0, _col_w, "HEALTH", _h.hp / 100, (_h.hp < 35) ? ui_alert : ((_h.hp < 65) ? ui_milestone : ui_good), ui_label); _cy0 += UI_ROW_H_BAR;
        ui_bar_row(_col0, _cy0, _col_w, "CONSCIOUS", _body.consciousness, (_body.consciousness < 0.30) ? ui_alert : ui_good, ui_label); _cy0 += UI_ROW_H_BAR;
        ui_bar_row(_col0, _cy0, _col_w, "PAIN", _h.pain / 100, (_h.pain > 50) ? ui_alert : ((_h.pain > 25) ? ui_milestone : ui_good), ui_label); _cy0 += UI_ROW_H_BAR;
        ui_bar_row(_col0, _cy0, _col_w, "CHRONIC PAIN", _body.chronic_pain, (_body.chronic_pain > 0.35) ? ui_alert : ui_milestone, ui_label); _cy0 += UI_ROW_H_BAR;
        ui_bar_row(_col0, _cy0, _col_w, "BLOOD", _body.blood_volume / 100, (_body.blood_volume < 55) ? ui_alert : ((_body.blood_volume < 75) ? ui_milestone : ui_good), ui_label); _cy0 += UI_ROW_H_BAR;
        ui_key_value(_col0, _cy0, "PRESSURE", string(round(_body.blood_pressure_sys)) + " / " + string(round(_body.blood_pressure_dia)), ui_label, ui_value, 48); _cy0 += UI_ROW_H;
        ui_key_value(_col0, _cy0, "PULSE", string(round(_body.pulse)) + " BPM", ui_label, ui_value, 48); _cy0 += UI_ROW_H;
        ui_key_value(_col0, _cy0, "BREATHING", string(round(_body.respiration)) + " / MIN", ui_label, ui_value, 48); _cy0 += UI_ROW_H;
        ui_key_value(_col0, _cy0, "OXYGEN", string(round(_body.oxygen * 100)) + "%", ui_label, (_body.oxygen < 0.85) ? ui_alert : ui_value, 48); _cy0 += UI_ROW_H;
        ui_key_value(_col0, _cy0, "TEMPERATURE", string(round(_body.temperature * 10) / 10) + " C", ui_label, (_body.temperature > 38.2 || _body.temperature < 35.0) ? ui_alert : ui_value, 48); _cy0 += UI_ROW_H;
        ui_bar_row(_col0, _cy0, _col_w, "SHOCK", _body.shock, (_body.shock > 0.45) ? ui_alert : ui_milestone, ui_label); _cy0 += UI_ROW_H_BAR;
        ui_bar_row(_col0, _cy0, _col_w, "INFECTION", _body.infection_load, (_body.infection_load > 0.28) ? ui_alert : ui_milestone, ui_label); _cy0 += UI_ROW_H_BAR;
        ui_bar_row(_col0, _cy0, _col_w, "IMMUNITY", _body.immune_response, ui_good, ui_label); _cy0 += UI_ROW_H_BAR;
        ui_bar_row(_col0, _cy0, _col_w, "CLOTTING", _body.clotting, ui_milestone, ui_label); _cy0 += UI_ROW_GAP;

        ui_section(_col0, _cy0, _col_w, "CONDITIONS", ui_milestone, ui_border);
        _cy0 += UI_SECTION_H;
        if (array_length(_body.conditions) == 0)
        {
            ui_text(_col0, _cy0, "STABLE - NO ACTIVE CONDITION", ui_good, 1);
            _cy0 += UI_ROW_H;
        }
        else
        {
            for (var _body_cond_i = 0; _body_cond_i < array_length(_body.conditions) && _body_cond_i < 8; _body_cond_i++)
            {
                var _body_cond = _body.conditions[_body_cond_i];
                var _body_cond_colour = ui_milestone;
                if (_body_cond == "SEPSIS" || _body_cond == "UNCONSCIOUS" || _body_cond == "BLIND"
                    || _body_cond == "PARALYSED" || _body_cond == "BLEEDING" || _body_cond == "BLOOD LOSS")
                {
                    _body_cond_colour = ui_alert;
                }
                ui_text(_col0, _cy0, "- " + _body_cond, _body_cond_colour, 1);
                _cy0 += UI_ROW_H;
            }
        }
        _cy0 += UI_ROW_GAP;

        ui_section(_col0, _cy0, _col_w, "CONSTITUTION", ui_milestone, ui_border);
        _cy0 += UI_SECTION_H;
        ui_key_value(_col0, _cy0, "FRAME", string(round(_body.constitution * 100)), ui_label, ui_value, 48); _cy0 += UI_ROW_H;
        ui_key_value(_col0, _cy0, "HEALING", string(round(_body.healing * 100)), ui_label, ui_value, 48); _cy0 += UI_ROW_H;
        ui_key_value(_col0, _cy0, "PAIN TOL.", string(round(_body.pain_tolerance * 100)), ui_label, ui_value, 48); _cy0 += UI_ROW_H;
        ui_key_value(_col0, _cy0, "IMMUNITY", string(round(_body.immune_strength * 100)), ui_label, ui_value, 48); _cy0 += UI_ROW_H;
        ui_key_value(_col0, _cy0, "LUNGS", string(round(_body.lung_capacity * 100)), ui_label, ui_value, 48); _cy0 += UI_ROW_H;
        ui_key_value(_col0, _cy0, "HEART", string(round(_body.heart_strength * 100)), ui_label, ui_value, 48); _cy0 += UI_ROW_GAP;

        var _body_eye_l = body_find_organ(_body, "left_eye");
        var _body_eye_r = body_find_organ(_body, "right_eye");
        var _body_ear_l = body_find_organ(_body, "left_ear");
        var _body_ear_r = body_find_organ(_body, "right_ear");
        var _body_throat = body_find_organ(_body, "throat");
        var _body_hand_l = body_find_part(_body, "left_hand");
        var _body_hand_r = body_find_part(_body, "right_hand");
        var _body_vision = (_body_eye_l.capacity + _body_eye_r.capacity) * 0.5;
        var _body_hearing = (_body_ear_l.capacity + _body_ear_r.capacity) * 0.5;
        var _body_speech = _body_throat.capacity;
        var _body_touch = (_body_hand_l.integrity + _body_hand_r.integrity) * 0.5;
        var _body_sense_colour = ui_good;

        ui_section(_col0, _cy0, _col_w, "SENSES", ui_milestone, ui_border);
        _cy0 += UI_SECTION_H;
        _body_sense_colour = (_body_vision < 0.50) ? ui_alert : ((_body_vision < 0.80) ? ui_milestone : ui_good);
        ui_bar_row(_col0, _cy0, _col_w, "VISION", _body_vision, _body_sense_colour, ui_label); _cy0 += UI_ROW_H_BAR;
        _body_sense_colour = (_body_hearing < 0.50) ? ui_alert : ((_body_hearing < 0.80) ? ui_milestone : ui_good);
        ui_bar_row(_col0, _cy0, _col_w, "HEARING", _body_hearing, _body_sense_colour, ui_label); _cy0 += UI_ROW_H_BAR;
        _body_sense_colour = (_body_speech < 0.50) ? ui_alert : ((_body_speech < 0.80) ? ui_milestone : ui_good);
        ui_bar_row(_col0, _cy0, _col_w, "SPEECH", _body_speech, _body_sense_colour, ui_label); _cy0 += UI_ROW_H_BAR;
        _body_sense_colour = (_body_touch < 0.50) ? ui_alert : ((_body_touch < 0.80) ? ui_milestone : ui_good);
        ui_bar_row(_col0, _cy0, _col_w, "TOUCH", _body_touch, _body_sense_colour, ui_label); _cy0 += UI_ROW_GAP;

        ui_section(_col0, _cy0, _col_w, "EXPOSURE", ui_milestone, ui_border);
        _cy0 += UI_SECTION_H;
        ui_key_value(_col0, _cy0, "ILLNESS", string_upper(_body.disease.active ? _body.disease.name : "NONE"), ui_label, _body.disease.active ? ui_alert : ui_value, 48); _cy0 += UI_ROW_H;
        ui_key_value(_col0, _cy0, "SEVERITY", string(round(_body.disease.severity * 100)) + "%", ui_label, _body.disease.severity > 0.55 ? ui_alert : ui_value, 48); _cy0 += UI_ROW_H;
        ui_key_value(_col0, _cy0, "CONTAGIOUS", _body.disease.active ? (_body.disease.contagious ? "YES" : "NO") : "NONE", ui_label, _body.disease.contagious ? ui_alert : ui_value, 48); _cy0 += UI_ROW_H;
        ui_key_value(_col0, _cy0, "IMMUNITY", string(round(_h.immunity * 100)) + "%", ui_label, ui_value, 48); _cy0 += UI_ROW_H;
        ui_key_value(_col0, _cy0, "AGE WEAR", string(round(_body.age_frailty * 100)) + "%", ui_label, _body.age_frailty > 0.55 ? ui_alert : ui_value, 48); _cy0 += UI_ROW_H;
        ui_key_value(_col0, _cy0, "LAST INJURY", (_body.last_injury < 0) ? "NEVER" : ("T-" + ui_clock(max(0, global.sim_time - _body.last_injury)) + " AGO"), ui_label, ui_value, 48); _cy0 += UI_ROW_H;
        ui_key_value(_col0, _cy0, "MARKS", _h.physical.mark, ui_label, ui_value, 48);

        ui_section(_col1, _cy1, _col_w, "ANATOMY", ui_milestone, ui_border);
        _cy1 += UI_SECTION_H;
        ui_text(_col1, _cy1, "PART", ui_label, 1);
        ui_text(_col1 + 150, _cy1, "TISSUE", ui_label, 1);
        ui_text(_col1 + 220, _cy1, "USE", ui_label, 1);
        _cy1 += UI_ROW_H;
        for (var _body_part_i = 0; _body_part_i < array_length(_body_parts); _body_part_i++)
        {
            var _body_part = body_find_part(_body, _body_parts[_body_part_i].key);
            var _body_part_status = body_part_status(_body_part);
            var _body_part_colour = ui_good;
            if (_body_part_status == "BLEEDING" || _body_part_status == "INFECTED" || _body_part_status == "RUINED" || _body_part_status == "DISABLED")
            {
                _body_part_colour = ui_alert;
            }
            else if (_body_part_status == "FRACTURE" || _body_part_status == "INJURED" || _body_part_status == "BURN"
                || _body_part_status == "SCARRED" || _body_part_status == "CHRONIC")
            {
                _body_part_colour = ui_milestone;
            }
            else if (_body_part_status == "SWOLLEN" || _body_part_status == "BRUISED")
            {
                _body_part_colour = ui_label;
            }
            var _body_part_use_colour = (_body_part.capacity < 0.50) ? ui_alert : ((_body_part.capacity < 0.80) ? ui_milestone : ui_good);

            ui_text(_col1, _cy1, _body_part.name, ui_value, 1);
            ui_text(_col1 + 150, _cy1, string(round(_body_part.integrity * 100)) + "%", _body_part_colour, 1);
            ui_text(_col1 + 220, _cy1, string(round(_body_part.capacity * 100)) + "%", _body_part_use_colour, 1);
            ui_text_right(_col1 + _col_w, _cy1, _body_part_status, _body_part_colour, 1);
            _cy1 += UI_ROW_H;
        }
        _cy1 += UI_ROW_GAP;

        ui_section(_col1, _cy1, _col_w, "ORGANS", ui_milestone, ui_border);
        _cy1 += UI_SECTION_H;
        ui_text(_col1, _cy1, "ORGAN", ui_label, 1);
        ui_text(_col1 + 184, _cy1, "CAPACITY", ui_label, 1);
        _cy1 += UI_ROW_H;
        for (var _body_organ_i = 0; _body_organ_i < array_length(_body_organs); _body_organ_i++)
        {
            var _body_organ = body_find_organ(_body, _body_organs[_body_organ_i].key);
            var _body_organ_status = body_organ_status(_body_organ);
            var _body_organ_colour = ui_good;
            if (_body_organ_status == "FAILING" || _body_organ_status == "INFECTED")
            {
                _body_organ_colour = ui_alert;
            }
            else if (_body_organ_status == "IMPAIRED" || _body_organ_status == "SCARRED")
            {
                _body_organ_colour = ui_milestone;
            }
            else if (_body_organ_status == "STRAINED")
            {
                _body_organ_colour = ui_label;
            }

            ui_text(_col1, _cy1, _body_organ.name, ui_value, 1);
            ui_text(_col1 + 184, _cy1, string(round(_body_organ.capacity * 100)) + "%", _body_organ_colour, 1);
            ui_text_right(_col1 + _col_w, _cy1, _body_organ_status, _body_organ_colour, 1);
            _cy1 += UI_ROW_H;
        }
        _cy1 += UI_ROW_GAP;

        ui_section(_col1, _cy1, _col_w, "SCARS & IMPAIRMENTS", ui_milestone, ui_border);
        _cy1 += UI_SECTION_H;
        if (array_length(_body.scars) == 0)
        {
            ui_text(_col1, _cy1, "NO PERMANENT SCARS", ui_good, 1);
            _cy1 += UI_ROW_H;
        }
        else
        {
            var _body_scar_shown = 0;
            for (var _body_scar_i = array_length(_body.scars) - 1; _body_scar_i >= 0 && _body_scar_shown < 5; _body_scar_i--)
            {
                var _body_scar = _body.scars[_body_scar_i];
                var _body_scar_part = body_find_part(_body, _body_scar.part);
                if (_body_scar_part == noone) continue;

                var _body_scar_use = clamp(_body_scar_part.capacity, 0, 1);
                var _body_scar_colour = (_body_scar_use < 0.55 || _body_scar.strength > 0.60) ? ui_alert : ui_milestone;
                ui_text(_col1, _cy1, "T-" + ui_clock(max(0, global.sim_time - _body_scar.time)) + "  " + _body_scar.part_display + "  " + body_wound_label(_body_scar.kind), ui_label, 1);
                ui_text_right(_col1 + _col_w, _cy1, "SCAR " + string(round(_body_scar.strength * 100)) + "%", _body_scar_colour, 1);
                _cy1 += UI_ROW_H;
                ui_text(_col1, _cy1, ui_fit(_body_scar.text, 64), ui_value, 1);
                _cy1 += UI_ROW_H;
                ui_text(_col1, _cy1, "USE " + string(round(_body_scar_use * 100)) + "%   PAIN " + string(round(_body_scar_part.chronic_pain * 100)) + "%", _body_scar_colour, 1);
                _cy1 += UI_ROW_H + UI_GAP_TINY;
                _body_scar_shown += 1;
            }
            if (array_length(_body.scars) > _body_scar_shown)
            {
                ui_text(_col1, _cy1, "+ " + string(array_length(_body.scars) - _body_scar_shown) + " MORE", ui_label, 1);
                _cy1 += UI_ROW_H;
            }
        }

        ui_section(_col2, _cy2, _col_w, "OPEN WOUNDS", ui_milestone, ui_border);
        _cy2 += UI_SECTION_H;
        if (array_length(_body.wounds) == 0)
        {
            ui_text(_col2, _cy2, "NO OPEN WOUNDS", ui_good, 1);
            _cy2 += UI_ROW_H;
        }
        else
        {
            for (var _body_wound_i = 0; _body_wound_i < array_length(_body.wounds) && _body_wound_i < 8; _body_wound_i++)
            {
                var _body_wound = _body.wounds[_body_wound_i];
                var _body_wound_colour = (_body_wound.infection > 0.30 || _body_wound.bleeding > 0.30) ? ui_alert : ui_value;
                var _body_wound_treat = _body_wound.treated ? "TREATED" : "UNTREATED";

                ui_text(_col2, _cy2, "T-" + ui_clock(max(0, global.sim_time - _body_wound.time)) + "  " + body_wound_label(_body_wound.kind), ui_label, 1);
                ui_text_right(_col2 + _col_w, _cy2, _body_wound_treat, _body_wound_colour, 1);
                _cy2 += UI_ROW_H;
                ui_text(_col2, _cy2, ui_fit(_body_wound.text, 64), _body_wound_colour, 1);
                _cy2 += UI_ROW_H;
                ui_text(_col2, _cy2, "SEVERITY " + string(round(_body_wound.severity * 100))
                    + "   BLEED " + string(round(_body_wound.bleeding * 100))
                    + "   INFECTION " + string(round(_body_wound.infection * 100)), ui_label, 1);
                _cy2 += UI_ROW_H;
                _cy2 += UI_GAP_TINY;
            }
            if (array_length(_body.wounds) > 8)
            {
                ui_text(_col2, _cy2, "+ " + string(array_length(_body.wounds) - 8) + " MORE", ui_label, 1);
                _cy2 += UI_ROW_H;
            }
        }
        _cy2 += UI_ROW_GAP;

        ui_section(_col2, _cy2, _col_w, "TREATMENT", ui_milestone, ui_border);
        _cy2 += UI_SECTION_H;
        var _body_doctor_name = "NONE";
        if (_body.last_doctor != -1)
        {
            var _body_doctor = world_find_human(self, _body.last_doctor);
            _body_doctor_name = (_body_doctor == noone) ? "DECEASED" : _body_doctor.name;
        }
        var _body_bandaged = 0;
        var _body_splinted = 0;
        for (var _body_care_i = 0; _body_care_i < array_length(_body.wounds); _body_care_i++)
        {
            if (_body.wounds[_body_care_i].bandaged) _body_bandaged += 1;
            if (_body.wounds[_body_care_i].splinted) _body_splinted += 1;
        }

        ui_key_value(_col2, _cy2, "CARER", _body_doctor_name, ui_label, ui_value, 48); _cy2 += UI_ROW_H;
        ui_key_value(_col2, _cy2, "LAST CARE", (_body.last_treatment < 0) ? "NEVER" : ("T-" + ui_clock(max(0, global.sim_time - _body.last_treatment)) + " AGO"), ui_label, ui_value, 48); _cy2 += UI_ROW_H;
        ui_key_value(_col2, _cy2, "BANDAGED", string(_body_bandaged) + " / " + string(array_length(_body.wounds)), ui_label, ui_value, 48); _cy2 += UI_ROW_H;
        ui_key_value(_col2, _cy2, "SPLINTED", string(_body_splinted) + " LIMBS", ui_label, ui_value, 48); _cy2 += UI_ROW_H;
        ui_key_value(_col2, _cy2, "CARE", string(round(_body.care_quality * 100)) + "%", ui_label, ui_value, 48); _cy2 += UI_ROW_H;
        ui_key_value(_col2, _cy2, "SEPSIS", string(round(_body.sepsis * 100)) + "%", ui_label, (_body.sepsis > 0.15) ? ui_alert : ui_value, 48); _cy2 += UI_ROW_H;
        ui_key_value(_col2, _cy2, "FEVER", string(round(_body.wound_infection * 100)) + "%", ui_label, (_body.wound_infection > 0.28) ? ui_alert : ui_value, 48); _cy2 += UI_ROW_GAP;

        ui_section(_col2, _cy2, _col_w, "MEDICAL HISTORY", ui_milestone, ui_border);
        _cy2 += UI_SECTION_H;
        if (array_length(_h.injuries) == 0)
        {
            ui_text(_col2, _cy2, "NOTHING RECORDED", ui_label, 1);
            _cy2 += UI_ROW_H;
        }
        else
        {
            for (var _body_hist_i = array_length(_h.injuries) - 1; _body_hist_i >= 0 && _body_hist_i >= array_length(_h.injuries) - 8; _body_hist_i--)
            {
                var _body_hist = _h.injuries[_body_hist_i];
                ui_text(_col2, _cy2, "T-" + ui_clock(max(0, global.sim_time - _body_hist.time)), ui_label, 1);
                ui_text(_col2 + 60, _cy2, ui_fit(_body_hist.text, 62), ui_value, 1);
                _cy2 += UI_ROW_H;
            }
        }
        break;

    case 2:
        // ---------------------------------------------------------------
        // MIND
        // ---------------------------------------------------------------
        ui_section(_col0, _cy0, _col_w, "CONDITION", ui_milestone, ui_border);
        _cy0 += UI_SECTION_H;
        ui_text(_col0, _cy0, "MOOD", ui_label, 1);
        ui_text_right(_col0 + _col_w, _cy0, human_mood_label(_h), ui_value, 1); _cy0 += UI_ROW_H;
        ui_text(_col0, _cy0, "MIND", ui_label, 1);
        ui_text_right(_col0 + _col_w, _cy0, _h.mental_state, ui_value, 1); _cy0 += UI_ROW_H_BAR;
        ui_bar_row(_col0, _cy0, _col_w, "HOPE", _h.hope, (_h.hope < 0.30) ? ui_alert : ui_good, ui_label); _cy0 += UI_ROW_H_BAR;
        ui_bar_row(_col0, _cy0, _col_w, "LONELINESS", _h.loneliness, (_h.loneliness > 0.55) ? ui_alert : ui_milestone, ui_label); _cy0 += UI_ROW_H_BAR;
        ui_bar_row(_col0, _cy0, _col_w, "COMFORT", _h.comfort, (_h.comfort < 0.30) ? ui_alert : ui_good, ui_label); _cy0 += UI_ROW_H_BAR;
        ui_bar_row(_col0, _cy0, _col_w, "ESTEEM", _h.esteem, (_h.esteem < 0.30) ? ui_alert : ui_good, ui_label); _cy0 += UI_ROW_GAP;

        ui_section(_col0, _cy0, _col_w, "FEELINGS", ui_milestone, ui_border);
        _cy0 += UI_SECTION_H;
        ui_bar_row(_col0, _cy0, _col_w, "JOY", _h.joy, (_h.joy < 0.20) ? ui_alert : ui_good, ui_label); _cy0 += UI_ROW_H_BAR;
        ui_bar_row(_col0, _cy0, _col_w, "FEAR", _h.fear, (_h.fear > 0.45) ? ui_alert : ui_milestone, ui_label); _cy0 += UI_ROW_H_BAR;
        ui_bar_row(_col0, _cy0, _col_w, "ANGER", _h.anger, (_h.anger > 0.45) ? ui_alert : ui_milestone, ui_label); _cy0 += UI_ROW_H_BAR;
        ui_bar_row(_col0, _cy0, _col_w, "GRIEF", _h.grief, (_h.grief > 0.40) ? ui_alert : ui_milestone, ui_label); _cy0 += UI_ROW_H_BAR;
        ui_bar_row(_col0, _cy0, _col_w, "STRESS", _h.stress, (_h.stress > 0.55) ? ui_alert : ui_milestone, ui_label); _cy0 += UI_ROW_H_BAR;
        ui_bar_row(_col0, _cy0, _col_w, "PAIN", _h.pain / 100, (_h.pain > 20) ? ui_alert : ui_milestone, ui_label); _cy0 += UI_ROW_GAP;

        ui_section(_col0, _cy0, _col_w, "VITALITY", ui_milestone, ui_border);
        _cy0 += UI_SECTION_H;
        ui_bar_row(_col0, _cy0, _col_w, "HEALTH", _h.hp / _h.max_hp, (_h.hp < 45) ? ui_alert : ui_good, ui_label); _cy0 += UI_ROW_H_BAR;
        ui_bar_row(_col0, _cy0, _col_w, "IMMUNITY", _h.immunity, ui_milestone, ui_label); _cy0 += UI_ROW_H_BAR;
        ui_key_value(_col0, _cy0, "AILMENT", _h.infected ? "FEVER" : "NONE", ui_label, _h.infected ? ui_alert : ui_value, 48);

        ui_section(_col1, _cy1, _col_w, "NEEDS", ui_milestone, ui_border);
        _cy1 += UI_SECTION_H;
        ui_bar_row(_col1, _cy1, _col_w, "HUNGER", _h.hunger, (_h.hunger > 0.55) ? ui_alert : ((_h.hunger > 0.30) ? ui_milestone : ui_good), ui_label); _cy1 += UI_ROW_H_BAR;
        ui_bar_row(_col1, _cy1, _col_w, "FATIGUE", _h.energy, (_h.energy > 0.55) ? ui_alert : ((_h.energy > 0.30) ? ui_milestone : ui_good), ui_label); _cy1 += UI_ROW_H_BAR;
        ui_bar_row(_col1, _cy1, _col_w, "SOCIAL NEED", _h.social, (_h.social > 0.55) ? ui_alert : ((_h.social > 0.30) ? ui_milestone : ui_good), ui_label); _cy1 += UI_ROW_H_BAR;
        ui_bar_row(_col1, _cy1, _col_w, "PURPOSE", _h.purpose, (_h.purpose > 0.55) ? ui_alert : ((_h.purpose > 0.30) ? ui_milestone : ui_good), ui_label); _cy1 += UI_ROW_H_BAR;
        ui_bar_row(_col1, _cy1, _col_w, "UNSAFETY", _h.safety, (_h.safety > 0.45) ? ui_alert : ((_h.safety > 0.20) ? ui_milestone : ui_good), ui_label); _cy1 += UI_ROW_H_BAR;
        ui_bar_row(_col1, _cy1, _col_w, "WONDER", _h.wonder, ui_milestone, ui_label); _cy1 += UI_ROW_GAP;

        ui_section(_col1, _cy1, _col_w, "THOUGHTS", ui_milestone, ui_border);
        _cy1 += UI_SECTION_H;
        var _mind_thoughts = 0;
        for (var _mind_thought_i = array_length(_h.thoughts) - 1; _mind_thought_i >= 0 && _mind_thoughts < 8; _mind_thought_i--)
        {
            var _mind_thought = _h.thoughts[_mind_thought_i];
            if (_mind_thought.expires <= global.sim_time) continue;
            var _mind_colour = (_mind_thought.valence > 0.18) ? ui_good : ((_mind_thought.valence < -0.18) ? ui_alert : ui_value);
            ui_text(_col1, _cy1, "- " + ui_fit(_mind_thought.text, 60), _mind_colour, 1);
            _cy1 += UI_ROW_H;
            _mind_thoughts += 1;
        }
        if (_mind_thoughts == 0) ui_text(_col1, _cy1, "NO STRONG THOUGHT", ui_label, 1);

        ui_section(_col2, _cy2, _col_w, "INNER VOICE", ui_milestone, ui_border);
        _cy2 += UI_SECTION_H;
        _cy2 += ui_text_wrapped(_col2, _cy2, _h.inner_voice, ui_value, 64, 3, UI_LINE_H) * UI_LINE_H;
        _cy2 += UI_GAP_SMALL;

        ui_section(_col2, _cy2, _col_w, "REFLECTION", ui_milestone, ui_border);
        _cy2 += UI_SECTION_H;
        _cy2 += ui_text_wrapped(_col2, _cy2, _h.reflection, ui_label, 64, 4, UI_LINE_H) * UI_LINE_H;
        _cy2 += UI_GAP_SMALL;

        ui_section(_col2, _cy2, _col_w, "ROUTINE", ui_milestone, ui_border);
        _cy2 += UI_SECTION_H;
        ui_key_value(_col2, _cy2, "LAST MEAL", "T-" + ui_clock(max(0, global.sim_time - _h.last_meal)) + " AGO", ui_label, ui_value, 48); _cy2 += UI_ROW_H;
        ui_key_value(_col2, _cy2, "LAST SLEEP", "T-" + ui_clock(max(0, global.sim_time - _h.last_sleep)) + " AGO", ui_label, ui_value, 48); _cy2 += UI_ROW_H;
        ui_key_value(_col2, _cy2, "LAST TALK", "T-" + ui_clock(max(0, global.sim_time - _h.last_social)) + " AGO", ui_label, ui_value, 48); _cy2 += UI_ROW_GAP;

        ui_section(_col2, _cy2, _col_w, "DOMINANT VALUES", ui_milestone, ui_border);
        _cy2 += UI_SECTION_H;
        for (var _mind_value_i = 0; _mind_value_i < 4; _mind_value_i++)
        {
            var _mind_value_key = _value_rank[_mind_value_i];
            var _mind_value = variable_struct_get(_h.values, _mind_value_key);
            ui_bar_row(_col2, _cy2, _col_w, human_value_label(_mind_value_key), _mind_value, (_mind_value > 0.65) ? ui_good : ui_milestone, ui_label);
            _cy2 += UI_ROW_H_BAR;
        }
        break;

    case 3:
        // ---------------------------------------------------------------
        // SOUL
        // ---------------------------------------------------------------
        ui_section(_col0, _cy0, _col_w, "VALUES", ui_milestone, ui_border);
        _cy0 += UI_SECTION_H;
        for (var _soul_value_i = 0; _soul_value_i < 10; _soul_value_i++)
        {
            var _soul_value_key = _value_rank[_soul_value_i];
            var _soul_value = variable_struct_get(_h.values, _soul_value_key);
            ui_bar_row(_col0, _cy0, _col_w, human_value_label(_soul_value_key), _soul_value, (_soul_value > 0.65) ? ui_good : ui_milestone, ui_label);
            _cy0 += UI_ROW_H_BAR;
        }
        _cy0 += UI_GAP_TINY;

        ui_section(_col0, _cy0, _col_w, "AMBITION", ui_milestone, ui_border);
        _cy0 += UI_SECTION_H;
        _cy0 += ui_text_wrapped(_col0, _cy0, _h.ambition_text, ui_milestone, 64, 3, UI_LINE_H) * UI_LINE_H;
        ui_bar_row(_col0, _cy0, _col_w, "PROGRESS", _h.ambition_progress, _civ.colour, ui_label); _cy0 += UI_ROW_GAP;

        ui_section(_col0, _cy0, _col_w, "FEAR", ui_milestone, ui_border);
        _cy0 += UI_SECTION_H;
        _cy0 += ui_text_wrapped(_col0, _cy0, _h.fear_text, ui_alert, 64, 3, UI_LINE_H) * UI_LINE_H;

        ui_section(_col1, _cy1, _col_w, "CHARACTER", ui_milestone, ui_border);
        _cy1 += UI_SECTION_H;
        for (var _soul_facet_i = 0; _soul_facet_i < 14; _soul_facet_i++)
        {
            var _soul_facet_key = _facet_rank[_soul_facet_i];
            var _soul_facet = variable_struct_get(_h.facets, _soul_facet_key);
            ui_bar_row(_col1, _cy1, _col_w, human_facet_label(_soul_facet_key), _soul_facet, (_soul_facet > 0.65) ? ui_good : ui_milestone, ui_label);
            _cy1 += UI_ROW_H_BAR;
        }
        _cy1 += UI_GAP_TINY;

        ui_section(_col1, _cy1, _col_w, "OUTLOOK", ui_milestone, ui_border);
        _cy1 += UI_SECTION_H;
        _cy1 += ui_text_wrapped(_col1, _cy1, _h.reflection, ui_label, 64, 4, UI_LINE_H) * UI_LINE_H;

        ui_section(_col2, _cy2, _col_w, "TEMPERAMENT", ui_milestone, ui_border);
        _cy2 += UI_SECTION_H;
        for (var _soul_trait_i = 0; _soul_trait_i < 12; _soul_trait_i++)
        {
            var _soul_trait_key = _trait_rank[_soul_trait_i];
            var _soul_trait = variable_struct_get(_h.traits, _soul_trait_key);
            ui_bar_row(_col2, _cy2, _col_w, human_trait_label(_soul_trait_key), _soul_trait, (_soul_trait > 0.68) ? ui_good : ui_milestone, ui_label);
            _cy2 += UI_ROW_H_BAR;
        }
        _cy2 += UI_GAP_TINY;

        ui_section(_col2, _cy2, _col_w, "LEGACY", ui_milestone, ui_border);
        _cy2 += UI_SECTION_H;
        ui_bar_row(_col2, _cy2, _col_w, "REPUTATION", _h.reputation / 100, (_h.reputation > 60) ? ui_good : ui_milestone, ui_label); _cy2 += UI_ROW_H_BAR;
        ui_bar_row(_col2, _cy2, _col_w, "PRIDE", _h.pride, ui_good, ui_label); _cy2 += UI_ROW_H_BAR;
        ui_bar_row(_col2, _cy2, _col_w, "SHAME", _h.shame, (_h.shame > 0.4) ? ui_alert : ui_milestone, ui_label); _cy2 += UI_ROW_H_BAR;
        ui_bar_row(_col2, _cy2, _col_w, "HOPE", _h.hope, (_h.hope < 0.25) ? ui_alert : ui_good, ui_label);
        break;

    case 4:
        // ---------------------------------------------------------------
        // WORK
        // ---------------------------------------------------------------
        ui_section(_col0, _cy0, _col_w, "ASSIGNMENT", ui_milestone, ui_border);
        _cy0 += UI_SECTION_H;
        ui_key_value(_col0, _cy0, "JOB", string_upper(human_job_label(_h.job)), ui_label, ui_value, 48); _cy0 += UI_ROW_H;
        ui_key_value(_col0, _cy0, "DUTY", string_upper(human_task_label(_h.task)), ui_label, ui_value, 48); _cy0 += UI_ROW_H;
        ui_key_value(_col0, _cy0, "CALLING", human_skill_label(_best_skill) + " / " + human_skill_title(_best_skill_value), ui_label, ui_value, 48); _cy0 += UI_ROW_GAP;

        ui_section(_col0, _cy0, _col_w, "PREFERENCES", ui_milestone, ui_border);
        _cy0 += UI_SECTION_H;
        ui_key_value(_col0, _cy0, "DRAWN TO", human_job_list_text(_h.labor_likes), ui_label, ui_good, 48); _cy0 += UI_ROW_H;
        ui_key_value(_col0, _cy0, "RESENTS", human_job_list_text(_h.labor_dislikes), ui_label, ui_alert, 48); _cy0 += UI_ROW_H;
        ui_key_value(_col0, _cy0, "DISCIPLINE", string(round(_h.facets.discipline * 100)), ui_label, ui_value, 48); _cy0 += UI_ROW_H;
        ui_key_value(_col0, _cy0, "AMBITION", string(round(_h.ambition_progress * 100)) + "% COMPLETE", ui_label, ui_milestone, 48); _cy0 += UI_ROW_GAP;

        ui_section(_col0, _cy0, _col_w, "APTITUDES", ui_milestone, ui_border);
        _cy0 += UI_SECTION_H;
        for (var _work_apt_i = 0; _work_apt_i < 11; _work_apt_i++)
        {
            var _work_apt_key = _aptitude_rank[_work_apt_i];
            var _work_apt = variable_struct_get(_h.aptitudes, _work_apt_key);
            var _apt_colour = (_work_apt > 1.15) ? ui_good : ((_work_apt < 0.85) ? ui_milestone : ui_value);
            ui_text(_col0, _cy0, human_skill_label(_work_apt_key), ui_label, 1);
            ui_text_right(_col0 + _col_w, _cy0, string(round(_work_apt * 100) / 100), _apt_colour, 1);
            _cy0 += UI_ROW_H;
        }

        ui_section(_col1, _cy1, _col_w, "SKILLS", ui_milestone, ui_border);
        _cy1 += UI_SECTION_H;
        for (var _work_skill_i = 0; _work_skill_i < 11; _work_skill_i++)
        {
            var _work_skill_key = _skill_rank[_work_skill_i];
            var _work_skill = variable_struct_get(_h.skills, _work_skill_key);
            var _work_aptitude = variable_struct_get(_h.aptitudes, _work_skill_key);
            var _work_label = human_skill_label(_work_skill_key) + "  " + human_skill_title(_work_skill);
            if (_work_aptitude > 1.14) _work_label += " *";
            ui_bar_row(_col1, _cy1, _col_w, _work_label, _work_skill, (_work_skill > 0.65) ? ui_good : ui_milestone, ui_label);
            _cy1 += UI_ROW_H_BAR;
        }
        _cy1 += UI_GAP_TINY;

        ui_section(_col1, _cy1, _col_w, "GIFTS", ui_milestone, ui_border);
        _cy1 += UI_SECTION_H;
        for (var _work_gift_i = 0; _work_gift_i < 4; _work_gift_i++)
        {
            var _work_gift_key = _aptitude_rank[_work_gift_i];
            var _work_gift = variable_struct_get(_h.aptitudes, _work_gift_key);
            ui_key_value(_col1, _cy1, human_skill_label(_work_gift_key), string(round(_work_gift * 100) / 100), ui_label, ui_good, 48);
            _cy1 += UI_ROW_H;
        }

        ui_section(_col2, _cy2, _col_w, "DEEDS", ui_milestone, ui_border);
        _cy2 += UI_SECTION_H;
        ui_key_value(_col2, _cy2, "BUILT", string(_h.built), ui_label, ui_value, 48); _cy2 += UI_ROW_H;
        ui_key_value(_col2, _cy2, "TAUGHT", string(_h.taught), ui_label, ui_value, 48); _cy2 += UI_ROW_H;
        ui_key_value(_col2, _cy2, "BIRTHS", string(_h.births), ui_label, ui_value, 48); _cy2 += UI_ROW_H;
        ui_key_value(_col2, _cy2, "KILLS", string(_h.kills), ui_label, ui_value, 48); _cy2 += UI_ROW_H;
        ui_key_value(_col2, _cy2, "TRADES", string(_h.trade_runs), ui_label, ui_value, 48); _cy2 += UI_ROW_H;
        ui_key_value(_col2, _cy2, "CRAFTWORKS", string(_h.masterworks), ui_label, ui_value, 48); _cy2 += UI_ROW_H;
        ui_key_value(_col2, _cy2, "STUDIES", string(_h.discoveries), ui_label, ui_value, 48); _cy2 += UI_ROW_H;
        ui_key_value(_col2, _cy2, "STUDENTS", string(_h.student_count), ui_label, ui_value, 48); _cy2 += UI_ROW_GAP;

        ui_section(_col2, _cy2, _col_w, "AMBITION", ui_milestone, ui_border);
        _cy2 += UI_SECTION_H;
        _cy2 += ui_text_wrapped(_col2, _cy2, _h.ambition_text, ui_milestone, 64, 3, UI_LINE_H) * UI_LINE_H;
        ui_bar_row(_col2, _cy2, _col_w, "PROGRESS", _h.ambition_progress, _civ.colour, ui_label); _cy2 += UI_ROW_GAP;

        ui_section(_col2, _cy2, _col_w, "WORK HISTORY", ui_milestone, ui_border);
        _cy2 += UI_SECTION_H;
        var _work_mem_shown = 0;
        for (var _work_mem_i = _memory_count - 1; _work_mem_i >= 0 && _work_mem_shown < 8; _work_mem_i--)
        {
            var _work_mem = _h.memories[_work_mem_i];
            if (_work_mem.kind != "BUILD" && _work_mem.kind != "CRAFT" && _work_mem.kind != "TRADE"
                && _work_mem.kind != "TEACH" && _work_mem.kind != "SKILL" && _work_mem.kind != "STUDY") continue;
            var _work_mem_colour = (_work_mem.valence < 0) ? ui_alert : ui_value;
            ui_text(_col2, _cy2, ui_fit(_work_mem.text, 64), _work_mem_colour, 1);
            _cy2 += UI_ROW_H;
            _work_mem_shown += 1;
        }
        if (_work_mem_shown == 0) ui_text(_col2, _cy2, "NOTHING RECORDED YET", ui_label, 1);
        break;

    case 5:
        // ---------------------------------------------------------------
        // BONDS
        // ---------------------------------------------------------------
        ui_section(_col0, _cy0, _col_w, "FAMILY", ui_milestone, ui_border);
        _cy0 += UI_SECTION_H;
        ui_key_value(_col0, _cy0, "HOUSEHOLD", _house_name, ui_label, ui_value, 48); _cy0 += UI_ROW_H;
        ui_key_value(_col0, _cy0, "PARTNER", _partner_name, ui_label, ui_value, 48); _cy0 += UI_ROW_H;
        ui_key_value(_col0, _cy0, "MOTHER", _mother_name, ui_label, ui_value, 48); _cy0 += UI_ROW_H;
        ui_key_value(_col0, _cy0, "FATHER", _father_name, ui_label, ui_value, 48); _cy0 += UI_ROW_H;
        ui_key_value(_col0, _cy0, "MENTOR", _mentor_name, ui_label, ui_value, 48); _cy0 += UI_ROW_H;
        ui_key_value(_col0, _cy0, "APPRENTICES", string(_h.student_count), ui_label, ui_value, 48); _cy0 += UI_ROW_GAP;

        ui_section(_col0, _cy0, _col_w, "CHILDREN", ui_milestone, ui_border);
        _cy0 += UI_SECTION_H;
        _cy0 += ui_text_wrapped(_col0, _cy0, _children_text, ui_value, 64, 4, UI_LINE_H) * UI_LINE_H;
        _cy0 += UI_GAP_SMALL;

        ui_section(_col0, _cy0, _col_w, "SOCIAL STANDING", ui_milestone, ui_border);
        _cy0 += UI_SECTION_H;
        ui_key_value(_col0, _cy0, "FRIENDS", string(human_count_tag(_h, "FRIEND")), ui_label, ui_good, 48); _cy0 += UI_ROW_H;
        ui_key_value(_col0, _cy0, "RIVALS", string(human_count_tag(_h, "RIVAL")), ui_label, ui_alert, 48); _cy0 += UI_ROW_H;
        ui_bar_row(_col0, _cy0, _col_w, "REPUTATION", _h.reputation / 100, (_h.reputation > 60) ? ui_good : ui_milestone, ui_label); _cy0 += UI_ROW_H_BAR;
        ui_key_value(_col0, _cy0, "WEALTH", string(round(_h.wealth)) + " COIN", ui_label, ui_value, 48);

        ui_section(_col1, _cy1, _col_w, "CLOSEST TIES", ui_milestone, ui_border);
        _cy1 += UI_SECTION_H;
        var _ties_a = 0;
        var _ties_a_end = 0;
        for (var _tie_a_i = 0; _tie_a_i < array_length(_link_rank) && _ties_a < 14; _tie_a_i++)
        {
            _ties_a_end = _tie_a_i + 1;
            var _link_a = _link_rank[_tie_a_i];
            var _other_a = world_find_human(self, _link_a.other_id);
            if (_other_a == noone || _other_a.dead) continue;

            var _tag_a = human_relationship_tag(_link_a);
            var _tag_a_colour = ui_value;
            if (_tag_a == "RIVAL" || _tag_a == "BITTER") _tag_a_colour = ui_alert;
            else if (_tag_a == "FRIEND" || _tag_a == "BONDED" || _tag_a == "SWEETHEART") _tag_a_colour = ui_good;
            else if (_tag_a == "KIN") _tag_a_colour = ui_milestone;

            var _opinion_a = ((_link_a.opinion >= 0) ? "+" : "") + string(round(_link_a.opinion));
            ui_text(_col1, _cy1, ui_fit(_other_a.name, 24), ui_value, 1);
            ui_text(_col1 + 232, _cy1, _tag_a, _tag_a_colour, 1);
            ui_text_right(_col1 + _col_w, _cy1, _opinion_a, _tag_a_colour, 1);
            _cy1 += UI_ROW_H;
            _ties_a += 1;
        }
        if (_ties_a == 0) ui_text(_col1, _cy1, "NO CLOSE TIES", ui_label, 1);
        _cy1 += UI_GAP_TIES;

        ui_section(_col1, _cy1, _col_w, "FAMILY HISTORY", ui_milestone, ui_border);
        _cy1 += UI_SECTION_H;
        var _kin_mem_shown = 0;
        for (var _kin_mem_i = _memory_count - 1; _kin_mem_i >= 0 && _kin_mem_shown < 8; _kin_mem_i--)
        {
            var _kin_mem = _h.memories[_kin_mem_i];
            if (_kin_mem.kind != "BIRTH" && _kin_mem.kind != "INHERIT" && _kin_mem.kind != "UNION"
                && _kin_mem.kind != "GRIEF" && _kin_mem.kind != "COMFORT") continue;
            var _kin_mem_colour = (_kin_mem.valence < 0) ? ui_alert : ui_value;
            ui_text(_col1, _cy1, ui_fit(_kin_mem.text, 64), _kin_mem_colour, 1);
            _cy1 += UI_ROW_H;
            _kin_mem_shown += 1;
        }
        if (_kin_mem_shown == 0) ui_text(_col1, _cy1, "NOTHING RECORDED YET", ui_label, 1);

        ui_section(_col2, _cy2, _col_w, "WIDER TIES", ui_milestone, ui_border);
        _cy2 += UI_SECTION_H;
        var _ties_b = 0;
        for (var _tie_b_i = _ties_a_end; _tie_b_i < array_length(_link_rank) && _ties_b < 14; _tie_b_i++)
        {
            var _link_b = _link_rank[_tie_b_i];
            var _other_b = world_find_human(self, _link_b.other_id);
            if (_other_b == noone || _other_b.dead) continue;

            var _tag_b = human_relationship_tag(_link_b);
            var _tag_b_colour = ui_value;
            if (_tag_b == "RIVAL" || _tag_b == "BITTER") _tag_b_colour = ui_alert;
            else if (_tag_b == "FRIEND" || _tag_b == "BONDED" || _tag_b == "SWEETHEART") _tag_b_colour = ui_good;
            else if (_tag_b == "KIN") _tag_b_colour = ui_milestone;

            var _opinion_b = ((_link_b.opinion >= 0) ? "+" : "") + string(round(_link_b.opinion));
            ui_text(_col2, _cy2, ui_fit(_other_b.name, 24), ui_value, 1);
            ui_text(_col2 + 232, _cy2, _tag_b, _tag_b_colour, 1);
            ui_text_right(_col2 + _col_w, _cy2, _opinion_b, _tag_b_colour, 1);
            _cy2 += UI_ROW_H;
            _ties_b += 1;
        }
        if (_ties_b == 0) ui_text(_col2, _cy2, "NO FURTHER TIES", ui_label, 1);
        _cy2 += UI_GAP_TIES;

        ui_section(_col2, _cy2, _col_w, "SOCIAL HISTORY", ui_milestone, ui_border);
        _cy2 += UI_SECTION_H;
        var _social_mem_shown = 0;
        for (var _social_mem_i = _memory_count - 1; _social_mem_i >= 0 && _social_mem_shown < 8; _social_mem_i--)
        {
            var _social_mem = _h.memories[_social_mem_i];
            if (_social_mem.kind != "TALK" && _social_mem.kind != "GOSSIP" && _social_mem.kind != "POLITICS"
                && _social_mem.kind != "QUARREL" && _social_mem.kind != "FRIEND" && _social_mem.kind != "RIVAL"
                && _social_mem.kind != "JEST" && _social_mem.kind != "LORE") continue;
            var _social_mem_colour = (_social_mem.valence < 0) ? ui_alert : ui_value;
            ui_text(_col2, _cy2, ui_fit(_social_mem.text, 64), _social_mem_colour, 1);
            _cy2 += UI_ROW_H;
            _social_mem_shown += 1;
        }
        if (_social_mem_shown == 0) ui_text(_col2, _cy2, "NOTHING RECORDED YET", ui_label, 1);
        break;

    case 6:
        // ---------------------------------------------------------------
        // LIFE
        // ---------------------------------------------------------------
        ui_section(_col0, _cy0, _col_w, "IN THEIR WORDS", ui_milestone, ui_border);
        _cy0 += UI_SECTION_H;
        _cy0 += ui_text_wrapped(_col0, _cy0, _h.reflection, ui_value, 64, 4, UI_LINE_H) * UI_LINE_H;
        _cy0 += UI_GAP_SMALL;

        ui_section(_col0, _cy0, _col_w, "A LIFE IN NUMBERS", ui_milestone, ui_border);
        _cy0 += UI_SECTION_H;
        ui_key_value(_col0, _cy0, "YEARS LIVED", string(floor(_h.age)), ui_label, ui_value, 48); _cy0 += UI_ROW_H;
        ui_key_value(_col0, _cy0, "CHILDREN", string(array_length(_h.children)), ui_label, ui_value, 48); _cy0 += UI_ROW_H;
        ui_key_value(_col0, _cy0, "BUILT", string(_h.built), ui_label, ui_value, 48); _cy0 += UI_ROW_H;
        ui_key_value(_col0, _cy0, "TAUGHT", string(_h.taught), ui_label, ui_value, 48); _cy0 += UI_ROW_H;
        ui_key_value(_col0, _cy0, "KILLS", string(_h.kills), ui_label, ui_value, 48); _cy0 += UI_ROW_H;
        ui_key_value(_col0, _cy0, "TRADES", string(_h.trade_runs), ui_label, ui_value, 48); _cy0 += UI_ROW_H;
        ui_key_value(_col0, _cy0, "CRAFTWORKS", string(_h.masterworks), ui_label, ui_value, 48); _cy0 += UI_ROW_H;
        ui_key_value(_col0, _cy0, "STUDIES", string(_h.discoveries), ui_label, ui_value, 48); _cy0 += UI_ROW_GAP;

        ui_section(_col0, _cy0, _col_w, "LASTING MARKS", ui_milestone, ui_border);
        _cy0 += UI_SECTION_H;
        var _life_scars = 0;
        if (_h.infected)
        {
            ui_text(_col0, _cy0, "- FEVER", ui_alert, 1);
            _cy0 += UI_ROW_H;
            _life_scars += 1;
        }
        for (var _life_scar_i = array_length(_h.injuries) - 1; _life_scar_i >= 0 && _life_scars < 3; _life_scar_i--)
        {
            ui_text(_col0, _cy0, "- " + ui_fit(_h.injuries[_life_scar_i].text, 60), ui_alert, 1);
            _cy0 += UI_ROW_H;
            _life_scars += 1;
        }
        if (_life_scars == 0) ui_text(_col0, _cy0, "NONE", ui_label, 1);
        _cy0 += UI_ROW_GAP;

        ui_section(_col0, _cy0, _col_w, "BEGINNINGS", ui_milestone, ui_border);
        _cy0 += UI_SECTION_H;
        ui_key_value(_col0, _cy0, "ORIGIN", _h.origin, ui_label, ui_value, 48); _cy0 += UI_ROW_H;
        ui_key_value(_col0, _cy0, "BIRTH", _born_text, ui_label, ui_value, 48); _cy0 += UI_ROW_H;
        ui_key_value(_col0, _cy0, "FACTION", string_upper(_h.faction), ui_label, ui_value, 48);

        ui_section(_col1, _cy1, _col_w, "CHRONICLE", ui_milestone, ui_border);
        _cy1 += UI_SECTION_H;
        var _life_mem_a = 0;
        for (var _life_mem_i = _memory_count - 1; _life_mem_i >= 0 && _life_mem_a < 24; _life_mem_i--)
        {
            var _life_mem = _h.memories[_life_mem_i];
            var _life_mem_colour = (_life_mem.valence < -0.25) ? ui_alert : ((_life_mem.valence > 0.25) ? ui_good : ui_value);
            ui_text(_col1, _cy1, "T-" + ui_clock(max(0, global.sim_time - _life_mem.time)), ui_label, 1);
            ui_text(_col1 + 60, _cy1, ui_fit(_life_mem.text, 62), _life_mem_colour, 1);
            _cy1 += UI_ROW_H;
            _life_mem_a += 1;
        }
        if (_life_mem_a == 0) ui_text(_col1, _cy1, "NOTHING RECORDED", ui_label, 1);

        ui_section(_col2, _cy2, _col_w, "CHRONICLE II", ui_milestone, ui_border);
        _cy2 += UI_SECTION_H;
        var _life_mem_b = 0;
        for (var _life_mem_j = _memory_count - 1 - _life_mem_a; _life_mem_j >= 0 && _life_mem_b < 24; _life_mem_j--)
        {
            var _life_mem_old = _h.memories[_life_mem_j];
            var _life_old_colour = (_life_mem_old.valence < -0.25) ? ui_alert : ((_life_mem_old.valence > 0.25) ? ui_good : ui_value);
            ui_text(_col2, _cy2, "T-" + ui_clock(max(0, global.sim_time - _life_mem_old.time)), ui_label, 1);
            ui_text(_col2 + 60, _cy2, ui_fit(_life_mem_old.text, 62), _life_old_colour, 1);
            _cy2 += UI_ROW_H;
            _life_mem_b += 1;
        }
        if (_life_mem_b == 0) ui_text(_col2, _cy2, "NO OLDER RECORDS", ui_label, 1);
        break;
}

// Footer.
draw_set_alpha(0.55);
draw_set_colour(ui_border);
draw_line(UI_PERSON_PAD, 1028, UI_PERSON_W - UI_PERSON_PAD, 1028);
draw_set_alpha(1);

ui_text(UI_PERSON_PAD, 1038, "Q / E  PAGE   * NATURAL GIFT", ui_label, 1);
ui_text_right(UI_PERSON_W - UI_PERSON_PAD, 1038, string(_page + 1) + " / " + string(UI_PERSON_PAGES), ui_value, 1);

draw_set_colour(c_white);
draw_set_alpha(1);
