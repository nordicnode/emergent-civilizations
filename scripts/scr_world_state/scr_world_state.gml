/// World state, generation, orchestration and rendering for the human simulation.

#macro CIV_COUNT 2
#macro MAX_POPULATION 100
#macro ADULT_AGE 14
#macro MARRIAGE_AGE 18
#macro ELDER_AGE 56
#macro AGE_RATE 0.06
#macro DAY_LENGTH 52
#macro MAX_RESOURCES 96
#macro MAX_BUILDINGS 48
#macro MAX_WOLVES 9

#macro RES_FOOD 0
#macro RES_WOOD 1
#macro RES_STONE 2

#macro JOB_IDLE 0
#macro JOB_FOOD 1
#macro JOB_WOOD 2
#macro JOB_STONE 3
#macro JOB_FARM 4
#macro JOB_BUILD 5
#macro JOB_GUARD 6
#macro JOB_HEAL 7
#macro JOB_SCHOLAR 8
#macro JOB_TRADER 9
#macro JOB_LEADER 10
#macro JOB_CHILD 11
#macro JOB_CRAFT 12
#macro JOB_COUNT 13

#macro GOAL_IDLE 0
#macro GOAL_EAT 1
#macro GOAL_SLEEP 2
#macro GOAL_WORK 3
#macro GOAL_SOCIAL 4
#macro GOAL_FLEE 5
#macro GOAL_HEAL 6
#macro GOAL_FIGHT 7
#macro GOAL_LEAD 8
#macro GOAL_FAITH 9
#macro GOAL_LEISURE 10
#macro GOAL_COUNT 11

#macro TASK_IDLE 0
#macro TASK_GATHER 1
#macro TASK_DEPOSIT 2
#macro TASK_FARM 3
#macro TASK_BUILD 4
#macro TASK_EAT 5
#macro TASK_SLEEP 6
#macro TASK_SOCIAL 7
#macro TASK_PATROL 8
#macro TASK_FIGHT 9
#macro TASK_FLEE 10
#macro TASK_TREAT 11
#macro TASK_RESEARCH 12
#macro TASK_TRADE 13
#macro TASK_LEAD 14
#macro TASK_CRAFT 15
#macro TASK_PRAY 16
#macro TASK_WANDER 17

#macro TARGET_NONE 0
#macro TARGET_RESOURCE 1
#macro TARGET_HUMAN 2
#macro TARGET_BUILDING 3
#macro TARGET_WOLF 4
#macro TARGET_POINT 5

#macro BLD_HUT 0
#macro BLD_GRANARY 1
#macro BLD_FARM 2
#macro BLD_WORKSHOP 3
#macro BLD_SHRINE 4
#macro BLD_INFIRMARY 5
#macro BLD_PALISADE 6
#macro BLD_WATCHTOWER 7
#macro BLD_MARKET 8
#macro BLD_WELL 9
#macro BLD_COUNT 10

// ASCII glyphs used by the map.
#macro GLYPH_HUMAN 64
#macro GLYPH_HUMAN_DARK 64
#macro GLYPH_TREE 84
#macro GLYPH_FOOD 42
#macro GLYPH_STONE 79
#macro GLYPH_WOLF 119
#macro GLYPH_HUT 35
#macro GLYPH_GRANARY 61
#macro GLYPH_FARM 37
#macro GLYPH_WORKSHOP 38
#macro GLYPH_SHRINE 43
#macro GLYPH_INFIRMARY 33
#macro GLYPH_PALISADE 72
#macro GLYPH_WATCHTOWER 94
#macro GLYPH_MARKET 36
#macro GLYPH_WELL 111
#macro GLYPH_COMMON 46

function world_init(_w)
{
    randomize();

    global.human_first_names = [
        "Mira", "Tovan", "Sera", "Bram", "Ilya", "Kael", "Rhea", "Dain",
        "Nessa", "Orin", "Vale", "Tess", "Marek", "Lio", "Anya", "Corin",
        "Elsbeth", "Rook", "Sana", "Pell", "Jori", "Nadia", "Tomas", "Yara",
        "Kest", "Bel", "Arun", "Selene", "Harl", "Ione", "Fen", "Rhea"
    ];
    global.human_last_names = [
        "Vale", "Thorn", "Mere", "Fenn", "Holt", "Ash", "Wren", "Dale",
        "Moss", "Reed", "Stone", "Brook", "Harrow", "Frost", "Lark", "Voss",
        "Kerr", "Briar", "Gale", "Rill", "Alder", "Cairn", "Dun", "Low"
    ];
    global.sim_time = 0;
    global.game_speed = 1;
    global.game_paused = false;
    global.dossier_open = false;
    global.game_paused_before_dossier = false;

    display_set_gui_size(room_width, room_height);
    gpu_set_texfilter(false);
    depth = 10;

    view_enabled = true;
    view_visible[0] = true;
    view_xport[0] = 0;
    view_yport[0] = 0;
    view_wport[0] = room_width;
    view_hport[0] = room_height;
    global.game_camera = camera_create_view(0, 0, room_width, room_height);
    view_set_camera(0, global.game_camera);
    global.game_zoom = 1;
    global.cam_x = 0;
    global.cam_y = 0;
    global.selected_id = -1;
    global.panel_page = 0;
    global.zoom_feedback = 0;
    global.pan_active = false;
    global.pan_anchor_x = 0;
    global.pan_anchor_y = 0;
    global.pan_origin_x = 0;
    global.pan_origin_y = 0;

    _w.ui_border = make_colour_rgb(62, 73, 77);
    _w.ui_label = make_colour_rgb(178, 188, 184);
    _w.ui_value = make_colour_rgb(240, 243, 238);
    _w.ui_alert = make_colour_rgb(210, 90, 74);
    _w.ui_milestone = make_colour_rgb(216, 194, 137);
    _w.ui_good = make_colour_rgb(146, 199, 151);

    var _civ_a = civ_new(0, "AURELIA", c_orange, "WOODLAND", 250, 540);
    var _civ_b = civ_new(1, "VESPER", c_aqua, "HIGHLAND", room_width - 250, 540);
    _w.civs = [_civ_a, _civ_b];

    _w.humans = [];
    _w.resources = [];
    _w.buildings = [];
    _w.wolves = [];
    _w.households = [];
    _w.events = [];
    _w.chronicle = [];
    _w.terrain = [];

    _w.time = 0;
    _w.day_phase = 0;
    _w.day = 1;
    _w.next_human_id = 1;
    _w.next_wolf_id = 1;
    _w.next_building_id = 1;
    _w.next_household_id = 1;
    _w.relation = 12;
    _w.trust = 0.42;
    _w.grievance = [0, 0];
    _w.at_war = false;
    _w.war_time = 0;
    _w.war_cause = "";
    _w.war_goal = "";
    _w.war_score = [0, 0];
    _w.war_exhaustion = [0, 0];
    _w.peace_offer = 0;
    _w.peace_timer = 0;
    _w.common_x = room_width / 2;
    _w.common_y = room_height / 2;

    _w.drought = 0;
    _w.drought_cooldown = 40;
    _w.resource_timer = 0;
    _w.disease_timer = 10;
    _w.wolf_timer = 18;
    _w.birth_timer = 5;
    _w.diplomacy_timer = 4;
    _w.border_event_timer = 0;
    _w.log_timer = 0;
    _w.next_think_phase = 0;
    _w.hud_timer = 0;
    _w.season = "GREEN";
    _w.season_food_mult = 1.0;
    _w.season_consume = 1.0;

    _w.population = [0, 0];
    _w.stores = [0, 0];
    _w.harvested = [0, 0];
    _w.lost = [0, 0];
    _w.morale_hud = [0, 0];
    _w.housing_hud = [0, 0];
    _w.tools_hud = [0, 0];
    _w.food_days_hud = [0, 0];
    _w.households_hud = [0, 0];
    _w.gini_hud = [0, 0];
    _w.tech_hud = ["SETTLE", "SETTLE"];
    _w.infected_hud = 0;

    // A static field of dim punctuation gives the map its ASCII texture.
    var _ground_codes = [44, 46, 46, 39, 34];
    for (var _ground_i = 0; _ground_i < 900; _ground_i++)
    {
        array_push(_w.terrain, {
            x: random(room_width),
            y: random(room_height),
            code: _ground_codes[irandom(array_length(_ground_codes) - 1)],
            shade: random_range(0.10, 0.38)
        });
    }

    // Initial settlements.
    for (var _c = 0; _c < CIV_COUNT; _c++)
    {
        var _civ = _w.civs[_c];
        var _hx = _civ.home_x;
        var _hy = _civ.home_y;

        world_spawn_building(_w, _c, BLD_GRANARY, _hx + 42, _hy - 56, true);
        world_spawn_building(_w, _c, BLD_FARM, _hx - 76, _hy + 44, true);

        for (var _hut_i = 0; _hut_i < 5; _hut_i++)
        {
            var _a = -30 + _hut_i * 68 + random_range(-8, 8);
            world_spawn_building(_w, _c, BLD_HUT, _hx + lengthdir_x(82, _a), _hy + lengthdir_y(64, _a), true);
        }
    }


    // Resource field. Each civilization has a distinct endowment; the common is rich.
    for (var _c = 0; _c < CIV_COUNT; _c++)
    {
        var _side = (_c == 0) ? 1 : -1;
        var _base_x = (_c == 0) ? 70 : room_width - 70;

        // Home fields are small and thin out under pressure. The Common is
        // the only lasting endowment, so distance becomes a decision.
        for (var _food_i = 0; _food_i < 4; _food_i++)
        {
            var _food_node = world_spawn_resource(_w, RES_FOOD, _base_x + _side * random_range(110, 460), random_range(95, 985), random_range(42, 68));
            if (_food_node != noone) _food_node.regen *= 0.28;
        }

        for (var _wood_i = 0; _wood_i < 4; _wood_i++)
        {
            var _wood_node = world_spawn_resource(_w, RES_WOOD, _base_x + _side * random_range(90, 480), random_range(95, 985), random_range(55, 80));
            if (_wood_node != noone) _wood_node.regen *= 0.28;
        }

        for (var _stone_i = 0; _stone_i < 3; _stone_i++)
        {
            var _stone_node = world_spawn_resource(_w, RES_STONE, _base_x + _side * random_range(100, 460), random_range(95, 985), random_range(34, 54));
            if (_stone_node != noone) _stone_node.regen *= 0.28;
        }
    }

    // The Common: food, timber and stone in one contested basin.
    for (var _common_i = 0; _common_i < 12; _common_i++)
    {
        world_spawn_resource(_w, RES_FOOD, _w.common_x + random_range(-170, 170), _w.common_y + random_range(-210, 210), random_range(120, 180));
    }
    for (var _common_i = 0; _common_i < 10; _common_i++)
    {
        world_spawn_resource(_w, RES_WOOD, _w.common_x + random_range(-190, 190), _w.common_y + random_range(-210, 210), random_range(110, 160));
    }
    for (var _common_i = 0; _common_i < 6; _common_i++)
    {
        world_spawn_resource(_w, RES_STONE, _w.common_x + random_range(-190, 190), _w.common_y + random_range(-210, 210), random_range(75, 115));
    }


    // People, families and a first generation.
    for (var _c = 0; _c < CIV_COUNT; _c++)
    {
        var _civ = _w.civs[_c];
        var _adults_male = [];
        var _adults_female = [];

        for (var _person_i = 0; _person_i < 34; _person_i++)
        {
            var _sex = irandom(1);
            var _age = random_range(18, 49);
            var _person = world_spawn_human(_w, _c, _age, _sex, _civ.home_x + random_range(-80, 80), _civ.home_y + random_range(-80, 80));

            if (_person != noone)
            {
                if (_sex == 0) array_push(_adults_male, _person);
                else array_push(_adults_female, _person);
            }
        }

        // Stable couples; children inherit a family identity rather than spawning loose.
        var _couple_count = min(min(array_length(_adults_male), array_length(_adults_female)), 14);
        for (var _couple_i = 0; _couple_i < _couple_count; _couple_i++)
        {
            var _a_person = _adults_male[_couple_i];
            var _b_person = _adults_female[_couple_i];

            _a_person.partner_id = _b_person.id;
            _b_person.partner_id = _a_person.id;
            _a_person.family_id = _c * 100 + _couple_i;
            _b_person.family_id = _a_person.family_id;

            var _household = world_household_new(_w, _c, _a_person, _b_person);
            _a_person.household_id = _household.id;
            _b_person.household_id = _household.id;

            human_relation(_a_person, _b_person.id).opinion = 45;
            human_relation(_a_person, _b_person.id).kin = 1;
            human_relation(_a_person, _b_person.id).trust = 0.78;
            human_relation(_b_person, _a_person.id).opinion = 45;
            human_relation(_b_person, _a_person.id).kin = 1;
            human_relation(_b_person, _a_person.id).trust = 0.78;
        }

        for (var _child_i = 0; _child_i < 8; _child_i++)
        {
            var _male = _adults_male[irandom(array_length(_adults_male) - 1)];
            var _female = _adults_female[irandom(array_length(_adults_female) - 1)];
            var _child = world_spawn_human(_w, _c, random_range(1, 11), irandom(1), _civ.home_x + random_range(-60, 60), _civ.home_y + random_range(-60, 60));

            if (_child != noone)
            {
                _child.job = JOB_CHILD;
                _child.family_id = _male.family_id;
                _child.household_id = _male.household_id;
                _child.parent_a = _male.id;
                _child.parent_b = _female.id;
                _child.home_x = _civ.home_x + random_range(-55, 55);
                _child.home_y = _civ.home_y + random_range(-55, 55);

                world_household_add(_w, _male.household_id, _child.id);
                human_relation(_child, _male.id).kin = 1;
                human_relation(_child, _male.id).trust = 0.8;
                human_relation(_child, _female.id).kin = 1;
                human_relation(_child, _female.id).trust = 0.8;
            }
        }

        // Adults who did not form a couple still cook, sleep and inherit together.
        for (var _single_i = 0; _single_i < array_length(_w.humans); _single_i++)
        {
            var _single = _w.humans[_single_i];
            if (_single.civ != _c || _single.dead || _single.age < ADULT_AGE) continue;
            if (_single.household_id != -1) continue;

            var _single_house = world_household_new(_w, _c, _single, noone);
            _single.household_id = _single_house.id;
        }


        // A leader emerges from skill, boldness and ambition.
        var _leader = noone;
        var _leader_score = -999;
        for (var _leader_i = 0; _leader_i < array_length(_w.humans); _leader_i++)
        {
            var _candidate = _w.humans[_leader_i];
            if (_candidate.civ != _c || _candidate.age < 20 || _candidate.dead) continue;

            var _candidate_score = _candidate.skills.lead * 1.4
                + _candidate.traits.bold * 0.35
                + _candidate.traits.ambition * 0.25
                + _candidate.mood * 0.004;

            if (_candidate_score > _leader_score)
            {
                _leader_score = _candidate_score;
                _leader = _candidate;
            }
        }

        if (_leader != noone)
        {
            _leader.job = JOB_LEADER;
            _civ.leader_id = _leader.id;
            world_event(_w, _civ.name + " FOLLOWS " + _leader.name + ".", _civ.colour, 5, _c);
        }
    }


    // Predators begin at the edges of the world.
    for (var _wolf_i = 0; _wolf_i < 4; _wolf_i++)
    {
        world_spawn_wolf(_w, random_range(0, 1) ? random_range(30, 180) : random_range(room_width - 180, room_width - 30), random_range(80, room_height - 80));
    }

    world_event(_w, "TWO CIVILIZATIONS WAKE.", _w.ui_value, 8, -1);
};

function world_spawn_human(_w, _civ, _age, _sex, _px, _py)
{
    if (array_length(_w.humans) >= MAX_POPULATION * 2) return noone;

    var _person = human_new(_w.next_human_id, _civ, _age, _sex, _px, _py, _w.civs[_civ]);
    _w.next_human_id += 1;
    array_push(_w.humans, _person);
    return _person;
};

function world_spawn_resource(_w, _kind, _px, _py, _amount)
{
    if (array_length(_w.resources) >= MAX_RESOURCES) return noone;

    var _node = {
        id: array_length(_w.resources),
        kind: _kind,
        x: clamp(_px, 30, room_width - 30),
        y: clamp(_py, 30, room_height - 30),
        amount: _amount,
        max_amount: _amount,
        regen: (_kind == RES_FOOD) ? 0.16 : ((_kind == RES_WOOD) ? 0.09 : 0.055),
        claimed_by: -1
    };

    array_push(_w.resources, _node);
    return _node;
};

function world_spawn_building(_w, _civ, _type, _px, _py, _complete)
{
    if (array_length(_w.buildings) >= MAX_BUILDINGS) return noone;

    var _building = {
        id: _w.next_building_id,
        civ: _civ,
        type: _type,
        x: clamp(_px, 45, room_width - 45),
        y: clamp(_py, 45, room_height - 45),
        complete: _complete,
        progress: _complete ? 1 : 0,
        hp: 100,
        workers: 0,
        production_timer: 0
    };

    _w.next_building_id += 1;
    array_push(_w.buildings, _building);
    return _building;
};

function world_household_new(_w, _civ, _head_a, _head_b)
{
    var _has_a = is_struct(_head_a);
    var _has_b = is_struct(_head_b);
    var _members = [];
    if (_has_a) array_push(_members, _head_a.id);
    if (_has_b) array_push(_members, _head_b.id);

    var _house = {
        id: _w.next_household_id,
        civ: _civ,
        name: _has_a ? (_head_a.name + " HOUSE") : "HOUSE",
        head_id: _has_a ? _head_a.id : -1,
        heir_id: -1,
        members: _members,
        wealth: (_has_a ? _head_a.wealth : 0) + (_has_b ? _head_b.wealth : 0),
        prestige: 0,
        home_x: _has_a ? _head_a.home_x : 0,
        home_y: _has_a ? _head_a.home_y : 0,
        founded: _w.time,
        faction: _has_a ? _head_a.faction : "hearth",
        deaths: 0,
        births: 0
    };

    _w.next_household_id += 1;
    array_push(_w.households, _house);
    return _house;
};

function world_find_household(_w, _id)
{
    for (var _i = 0; _i < array_length(_w.households); _i++)
    {
        if (_w.households[_i].id == _id) return _w.households[_i];
    }
    return noone;
};

function world_household_add(_w, _id, _person_id)
{
    var _house = world_find_household(_w, _id);
    if (_house == noone) return;

    for (var _i = 0; _i < array_length(_house.members); _i++)
    {
        if (_house.members[_i] == _person_id) return;
    }
    array_push(_house.members, _person_id);
};

function world_household_remove(_w, _id, _person_id)
{
    var _house = world_find_household(_w, _id);
    if (_house == noone) return;

    for (var _i = array_length(_house.members) - 1; _i >= 0; _i--)
    {
        if (_house.members[_i] == _person_id) array_delete(_house.members, _i, 1);
    }
};

function world_household_member_count(_w, _id)
{
    var _house = world_find_household(_w, _id);
    if (_house == noone) return 0;
    return array_length(_house.members);
};

function world_household_heir(_w, _house)
{
    var _best = -1;
    var _best_score = -999;

    for (var _i = 0; _i < array_length(_house.members); _i++)
    {
        var _person = world_find_human(_w, _house.members[_i]);
        if (_person == noone || _person.dead || _person.id == _house.head_id) continue;

        var _score = _person.age * 0.4 + _person.skills.lead * 8 + _person.reputation * 0.2;
        if (_person.age < ADULT_AGE) _score -= 30;
        if (_person.sex == 0) _score += 1;

        if (_score > _best_score)
        {
            _best_score = _score;
            _best = _person.id;
        }
    }

    return _best;
};

function world_spawn_wolf(_w, _px, _py)
{
    if (array_length(_w.wolves) >= MAX_WOLVES) return noone;

    var _wolf = {
        id: _w.next_wolf_id,
        x: clamp(_px, 20, room_width - 20),
        y: clamp(_py, 20, room_height - 20),
        hp: 18,
        target_ref: -1,
        cooldown: 0,
        hunger: random_range(0.3, 0.8),
        dead: false,
        heading: random(360)
    };

    _w.next_wolf_id += 1;
    array_push(_w.wolves, _wolf);
    return _wolf;
};

function world_event(_w, _text, _colour, _salience, _civ)
{
    array_push(_w.events, {
        time: _w.time,
        text: _text,
        colour: _colour,
        salience: _salience,
        civ: _civ,
        life: 18
    });

    if (array_length(_w.events) > 14) array_delete(_w.events, 0, array_length(_w.events) - 14);
    show_debug_message("HUMANEVENT: " + _text);
};

function world_find_human(_w, _id)
{
    for (var _i = 0; _i < array_length(_w.humans); _i++)
    {
        if (_w.humans[_i].id == _id) return _w.humans[_i];
    }
    return noone;
};

function world_civ_population(_w, _civ)
{
    var _count = 0;
    for (var _i = 0; _i < array_length(_w.humans); _i++)
    {
        if (_w.humans[_i].civ == _civ && !_w.humans[_i].dead) _count += 1;
    }
    return _count;
};

function world_civ_adults(_w, _civ)
{
    var _count = 0;
    for (var _i = 0; _i < array_length(_w.humans); _i++)
    {
        var _h = _w.humans[_i];
        if (_h.civ == _civ && !_h.dead && _h.age >= ADULT_AGE && _h.age < ELDER_AGE) _count += 1;
    }
    return _count;
};

function world_civ_housing(_w, _civ)
{
    var _beds = 0;
    for (var _i = 0; _i < array_length(_w.buildings); _i++)
    {
        var _b = _w.buildings[_i];
        if (_b.civ == _civ && _b.complete)
        {
            if (_b.type == BLD_HUT) _beds += 8;
            else if (_b.type == BLD_GRANARY) _beds += 0;
        }
    }
    return _beds;
};

function world_civ_building_count(_w, _civ, _type)
{
    var _count = 0;
    for (var _i = 0; _i < array_length(_w.buildings); _i++)
    {
        var _b = _w.buildings[_i];
        if (_b.civ == _civ && _b.type == _type && _b.complete) _count += 1;
    }
    return _count;
};

function world_civ_food_capacity(_w, _civ)
{
    return 180 + world_civ_building_count(_w, _civ, BLD_GRANARY) * 180;
};

function world_day_night(_w)
{
    return ((_w.day_phase > 0.78) || (_w.day_phase < 0.18));
};

function world_civ_gini(_w, _civ)
{
    var _values = [];
    var _sum = 0;

    for (var _i = 0; _i < array_length(_w.households); _i++)
    {
        var _house = _w.households[_i];
        if (_house.civ != _civ || array_length(_house.members) <= 0) continue;
        array_push(_values, max(0.1, _house.wealth));
        _sum += max(0.1, _house.wealth);
    }

    var _count = array_length(_values);
    if (_count < 2 || _sum <= 0) return 0;

    array_sort(_values, true);
    var _weighted = 0;
    for (var _i = 0; _i < _count; _i++)
    {
        _weighted += (_i + 1) * _values[_i];
    }

    return clamp((2 * _weighted) / (_count * _sum) - (_count + 1) / _count, 0, 1);
};

function world_tech_label(_civ)
{
    var _best = "SETTLE";
    var _best_value = -1;

    var _domains = ["farm", "craft", "war", "medicine", "culture", "trade"];
    var _labels = ["FIELDS", "CRAFT", "WAR", "HEALING", "RITES", "TRADE"];

    for (var _i = 0; _i < array_length(_domains); _i++)
    {
        var _value = variable_struct_get(_civ.know, _domains[_i]);
        if (_value > _best_value)
        {
            _best_value = _value;
            _best = _labels[_i];
        }
    }

    return _best;
};

function world_civ_food_days(_w, _civ)
{
    var _consume = _civ.adults * 0.0045 + _civ.children * 0.0022;
    return _civ.food / max(0.2, _consume) / 60;
};

function world_update_hud(_w)
{
    _w.infected_hud = world_infected_count(_w);

    for (var _c = 0; _c < CIV_COUNT; _c++)
    {
        var _civ = _w.civs[_c];
        _w.population[_c] = world_civ_population(_w, _c);
        _w.stores[_c] = floor(_civ.food);
        _w.harvested[_c] = floor(_civ.gathered);
        _w.lost[_c] = _civ.deaths;
        _w.morale_hud[_c] = floor(_civ.morale);
        _w.housing_hud[_c] = world_civ_housing(_w, _c);
        _w.tools_hud[_c] = floor(_civ.tools);
        _w.food_days_hud[_c] = world_civ_food_days(_w, _civ);
        _w.households_hud[_c] = 0;
        _w.gini_hud[_c] = world_civ_gini(_w, _c);
        _w.tech_hud[_c] = world_tech_label(_civ);

        for (var _h_i = 0; _h_i < array_length(_w.households); _h_i++)
        {
            var _house = _w.households[_h_i];
            if (_house.civ == _c && array_length(_house.members) > 0) _w.households_hud[_c] += 1;
        }
    }
};

function world_update(_w, _dt)
{
    _w.time += _dt;
    global.sim_time = _w.time;
    _w.day = floor(_w.time / DAY_LENGTH) + 1;
    _w.day_phase = (_w.time / DAY_LENGTH) mod 1;

    var _season_index = floor(_w.time / (DAY_LENGTH * 3)) mod 4;
    if (_season_index == 0) { _w.season = "GREEN"; _w.season_food_mult = 1.0; _w.season_consume = 1.0; }
    else if (_season_index == 1) { _w.season = "DRY"; _w.season_food_mult = 0.58; _w.season_consume = 1.08; }
    else if (_season_index == 2) { _w.season = "HARVEST"; _w.season_food_mult = 1.32; _w.season_consume = 0.94; }
    else { _w.season = "FROST"; _w.season_food_mult = 0.36; _w.season_consume = 1.24; }

    for (var _event_i = array_length(_w.events) - 1; _event_i >= 0; _event_i--)
    {
        _w.events[_event_i].life -= _dt;
        if (_w.events[_event_i].life <= 0) array_delete(_w.events, _event_i, 1);
    }

    for (var _c = 0; _c < CIV_COUNT; _c++)
    {
        civ_update(_w, _w.civs[_c], _dt);
    }

    // Humans are updated back-to-front so dead structs can be removed safely.
    for (var _human_i = array_length(_w.humans) - 1; _human_i >= 0; _human_i--)
    {
        var _person = _w.humans[_human_i];
        human_update(_w, _person, _dt);

        if (_person.dead)
        {
            array_delete(_w.humans, _human_i, 1);
        }
    }

    world_wolves_update(_w, _dt);
    world_disease_update(_w, _dt);
    world_hazards_update(_w, _dt);
    world_resources_update(_w, _dt);
    world_diplomacy_update(_w, _dt);

    world_update_hud(_w);

    _w.log_timer += _dt;
    if (_w.log_timer >= 5)
    {
        _w.log_timer = 0;

        var _job_text = "";
        var _task_gather0 = 0;
        var _task_gather1 = 0;
        var _task_trade0 = 0;
        var _task_trade1 = 0;
        var _common0 = 0;
        var _common1 = 0;
        for (var _probe_i = 0; _probe_i < array_length(_w.humans); _probe_i++)
        {
            var _probe = _w.humans[_probe_i];
            if (_probe.dead) continue;
            if (_probe.task == TASK_GATHER) { if (_probe.civ == 0) _task_gather0 += 1; else _task_gather1 += 1; }
            if (_probe.task == TASK_TRADE) { if (_probe.civ == 0) _task_trade0 += 1; else _task_trade1 += 1; }
            if (point_distance(_probe.x, _probe.y, _w.common_x, _w.common_y) < 240) { if (_probe.civ == 0) _common0 += 1; else _common1 += 1; }
        }

        for (var _job_i = 0; _job_i < JOB_COUNT; _job_i++)
        {
            var _job_count = 0;
            for (var _person_i = 0; _person_i < array_length(_w.humans); _person_i++)
            {
                if (_w.humans[_person_i].civ == 0 && _w.humans[_person_i].job == _job_i && !_w.humans[_person_i].dead) _job_count += 1;
            }
            _job_text += " j" + string(_job_i) + "=" + string(_job_count);
        }

        show_debug_message(
            "HUMANSIM t=" + string(floor(_w.time)) +
            " pop0=" + string(_w.population[0]) +
            " food0=" + string(_w.stores[0]) +
            " morale0=" + string(_w.morale_hud[0]) +
            " wood0=" + string(floor(_w.civs[0].wood)) +
            " stone0=" + string(floor(_w.civs[0].stone)) +
            " tech0=" + string(_w.civs[0].tech) +
            " pop1=" + string(_w.population[1]) +
            " food1=" + string(_w.stores[1]) +
            " morale1=" + string(_w.morale_hud[1]) +
            " wood1=" + string(floor(_w.civs[1].wood)) +
            " stone1=" + string(floor(_w.civs[1].stone)) +
            " tech1=" + string(_w.civs[1].tech) +
            " relation=" + string(round(_w.relation)) +
            " war=" + string(_w.at_war) +
            " wolves=" + string(array_length(_w.wolves)) +
            " infected=" + string(world_infected_count(_w)) +
            " drought=" + string(round(_w.drought)) +
            " season=" + _w.season +
            " hh0=" + string(_w.households_hud[0]) +
            " hh1=" + string(_w.households_hud[1]) +
            " gini0=" + string(round(_w.gini_hud[0] * 100)) +
            " gini1=" + string(round(_w.gini_hud[1] * 100)) +
            " tools0=" + string(_w.tools_hud[0]) +
            " tools1=" + string(_w.tools_hud[1]) +
            " policy0=" + _w.civs[0].policy +
            " policy1=" + _w.civs[1].policy +
            " unrest0=" + string(round(_w.civs[0].unrest * 100)) +
            " unrest1=" + string(round(_w.civs[1].unrest * 100)) +
            " jobs0" + _job_text +
            " gather0=" + string(_task_gather0) +
            " gather1=" + string(_task_gather1) +
            " trade0=" + string(_task_trade0) +
            " trade1=" + string(_task_trade1) +
            " common0=" + string(_common0) +
            " common1=" + string(_common1)
        );
    }
};

function world_infected_count(_w)
{
    var _count = 0;
    for (var _i = 0; _i < array_length(_w.humans); _i++)
    {
        if (_w.humans[_i].infected && !_w.humans[_i].dead) _count += 1;
    }
    return _count;
};

function world_resources_update(_w, _dt)
{
    // The Common keeps producing new patches, drawing both colonies into contact.
    _w.resource_timer += _dt;
    if (_w.resource_timer >= 13)
    {
        _w.resource_timer = 0;

        if (array_length(_w.resources) < MAX_RESOURCES - 6)
        {
            var _bloom_count = 3 + irandom(2);
            for (var _bloom_i = 0; _bloom_i < _bloom_count; _bloom_i++)
            {
                world_spawn_resource(
                    _w,
                    (random(1) < 0.68) ? RES_FOOD : ((random(1) < 0.5) ? RES_WOOD : RES_STONE),
                    _w.common_x + random_range(-170, 170),
                    _w.common_y + random_range(-170, 170),
                    random_range(80, 140)
                );
            }

            if (random(1) < 0.35) world_event(_w, "WILD HARVEST AT THE COMMON.", _w.ui_good, 3, -1);
        }
    }

    for (var _i = 0; _i < array_length(_w.resources); _i++)
    {
        var _r = _w.resources[_i];
        if (_r.amount <= 0) continue;

        var _regen = _r.regen;
        if (_r.kind == RES_FOOD) _regen *= _w.season_food_mult;
        if (_w.drought > 0 && _r.kind == RES_FOOD) _regen *= 0.1;
        _r.amount = min(_r.max_amount, _r.amount + _regen * _dt);
    }
};

function world_wolves_update(_w, _dt)
{
    for (var _wolf_i = array_length(_w.wolves) - 1; _wolf_i >= 0; _wolf_i--)
    {
        var _wolf = _w.wolves[_wolf_i];
        if (_wolf.dead)
        {
            array_delete(_w.wolves, _wolf_i, 1);
            continue;
        }

        _wolf.cooldown = max(0, _wolf.cooldown - _dt);
        _wolf.hunger = min(1, _wolf.hunger + _dt * 0.006);

        var _target = _wolf.target_ref;
        if (!is_struct(_target) || _target.dead) _target = -1;

        if (_target == -1 || point_distance(_wolf.x, _wolf.y, _target.x, _target.y) > 360)
        {
            _target = -1;
            var _best = 999;

            for (var _person_i = 0; _person_i < array_length(_w.humans); _person_i++)
            {
                var _person = _w.humans[_person_i];
                if (_person.dead || _person.age < 4) continue;

                var _dist = point_distance(_wolf.x, _wolf.y, _person.x, _person.y);
                var _exposure = (human_guards_near(_w, _person) > 0) ? 1.8 : 1.0;

                if (_dist < _best * _exposure && _dist < 380)
                {
                    _best = _dist;
                    _target = _person;
                }
            }

            _wolf.target_ref = _target;
        }

        if (_target == -1)
        {
            _wolf.heading += random_range(-25, 25) * _dt;
            _wolf.x += lengthdir_x(24, _wolf.heading) * _dt;
            _wolf.y += lengthdir_y(24, _wolf.heading) * _dt;
        }
        else
        {
            var _angle = point_direction(_wolf.x, _wolf.y, _target.x, _target.y);
            _wolf.heading += angle_difference(_angle, _wolf.heading) * min(1, _dt * 5);
            _wolf.x += lengthdir_x(42, _wolf.heading) * _dt;
            _wolf.y += lengthdir_y(42, _wolf.heading) * _dt;

            if (point_distance(_wolf.x, _wolf.y, _target.x, _target.y) < 20 && _wolf.cooldown <= 0)
            {
                _wolf.cooldown = 1.4;
                body_apply_wound(_target, "bite", 4.6 + random_range(0, 1.8), _wolf.id, -1);
                _target.fear = min(1, _target.fear + 0.45);
                _target.anger = min(1, _target.anger + 0.15);
                _target.danger_x = _wolf.x;
                _target.danger_y = _wolf.y;
                _target.danger_time = global.sim_time;
                human_add_memory(_target, "WOLF", -0.8, 7, _wolf.id, "A wolf attacked " + _target.name + ".");
                human_add_emotion(_target, 0, 0.35, 0.1, 0);

                if (_target.hp <= 0)
                {
                    human_die(_w, _target, "a wolf");
                    world_event(_w, "A WOLF DRAGS DOWN " + _target.name + ".", _w.ui_alert, 7, _target.civ);
                }
            }
        }

        _wolf.x = clamp(_wolf.x, 14, room_width - 14);
        _wolf.y = clamp(_wolf.y, 14, room_height - 14);
    }
};

function world_disease_update(_w, _dt)
{
    _w.disease_timer -= _dt;
    if (_w.disease_timer > 0) return;
    _w.disease_timer = 0.55;

    for (var _i = 0; _i < array_length(_w.humans); _i++)
    {
        var _person = _w.humans[_i];
        if (_person.dead) continue;

        if (_person.body.disease.active)
        {
            var _disease = _person.body.disease;

            if (_disease.timer > 16 && random(1) < 0.012 + _person.immunity * 0.02)
            {
                body_cure_disease(_person);
                human_add_memory(_person, "RECOVERY", 0.5, 5, -1, "Survived the fever.");
                world_event(_w, _person.name + " SURVIVES THE FEVER.", _w.ui_good, 3, _person.civ);
            }

            if (_person.hp <= 0)
            {
                human_die(_w, _person, "fever");
                world_event(_w, _person.name + " DIES OF FEVER.", _w.ui_alert, 5, _person.civ);
            }
            continue;
        }

        _person.immunity = max(0, _person.immunity - 0.0002);

        for (var _other_i = 0; _other_i < array_length(_w.humans); _other_i++)
        {
            var _other = _w.humans[_other_i];
            if (_other == _person || _other.dead) continue;
            if (!_other.body.disease.active || !_other.body.disease.contagious) continue;

            var _dist = point_distance(_person.x, _person.y, _other.x, _other.y);
            if (_dist < 34 && random(1) < 0.0016 * (1 - _person.immunity) * (0.6 + _other.body.disease.severity))
            {
                body_start_disease(_person, "fever", 0.50, true);
                world_event(_w, "FEVER SPREADS TO " + _person.name + ".", _w.ui_alert, 4, _person.civ);
                break;
            }
        }
    }
};

function world_hazards_update(_w, _dt)
{
    if (_w.drought > 0)
    {
        _w.drought = max(0, _w.drought - _dt);
    }
    else
    {
        _w.drought_cooldown -= _dt;
        if (_w.drought_cooldown <= 0)
        {
            _w.drought = random_range(18, 30);
            _w.drought_cooldown = random_range(65, 105);
            world_event(_w, "A DRY SPELL.", _w.ui_alert, 4, -1);
        }
    }

    _w.wolf_timer -= _dt;
    if (_w.wolf_timer <= 0)
    {
        _w.wolf_timer = random_range(16, 30);

        if (array_length(_w.wolves) < 5 + floor(_w.time / 100))
        {
            var _edge = irandom(3);
            var _wx = (_edge == 0) ? random_range(20, 140) : ((_edge == 1) ? random_range(room_width - 140, room_width - 20) : random(room_width));
            var _wy = (_edge == 2) ? random_range(20, 120) : random_range(120, room_height - 120);
            world_spawn_wolf(_w, _wx, _wy);
        }
    }

    // A quiet, healthy valley can still produce a first fever case.
    if (array_length(_w.humans) > 0 && world_infected_count(_w) == 0 && random(1) < _dt * 0.0007)
    {
        var _victim = _w.humans[irandom(array_length(_w.humans) - 1)];
        if (!_victim.dead)
        {
            body_start_disease(_victim, "fever", 0.50, true);
            world_event(_w, "A FEVER CASE IN " + _w.civs[_victim.civ].name + ".", _w.ui_alert, 5, _victim.civ);
        }
    }
};

function world_diplomacy_update(_w, _dt)
{
    _w.diplomacy_timer -= _dt;
    _w.border_event_timer = max(0, _w.border_event_timer - _dt);
    if (_w.diplomacy_timer > 0) return;
    _w.diplomacy_timer = 4;

    // Grievances cool slowly; fear and trade keep the peace from being stable.
    for (var _g = 0; _g < 2; _g++)
    {
        _w.grievance[_g] = max(0, _w.grievance[_g] - 0.12);
    }

    if (_w.at_war)
    {
        _w.war_time += 4;
        _w.war_exhaustion[0] = min(100, _w.war_exhaustion[0] + 0.45);
        _w.war_exhaustion[1] = min(100, _w.war_exhaustion[1] + 0.45);

        var _a_civ = _w.civs[0];
        var _b_civ = _w.civs[1];
        var _a_exhausted = _w.war_exhaustion[0]
            + (1 - _a_civ.food / max(1, _a_civ.population * 18)) * 32
            + (1 - _a_civ.morale / 100) * 26;
        var _b_exhausted = _w.war_exhaustion[1]
            + (1 - _b_civ.food / max(1, _b_civ.population * 18)) * 32
            + (1 - _b_civ.morale / 100) * 26;

        // A peace offer is a leader's calculation, not a timer.
        var _a_leader = world_find_human(_w, _a_civ.leader_id);
        var _b_leader = world_find_human(_w, _b_civ.leader_id);
        var _wants_peace_a = (_a_exhausted > 48) || (_a_civ.population < 12 && _a_leader != noone && _a_leader.traits.caution > 0.55);
        var _wants_peace_b = (_b_exhausted > 48) || (_b_civ.population < 12 && _b_leader != noone && _b_leader.traits.caution > 0.55);

        if (_w.war_time > 58 || (_a_exhausted > 58 && _b_exhausted > 58) || (_wants_peace_a && _wants_peace_b))
        {
            _w.at_war = false;
            _w.war_time = 0;
            _w.relation = max(-20, _w.relation + 22);
            _w.trust = min(1, _w.trust + 0.08);
            _w.grievance[0] = max(0, _w.grievance[0] - 18);
            _w.grievance[1] = max(0, _w.grievance[1] - 18);
            _w.war_exhaustion[0] *= 0.55;
            _w.war_exhaustion[1] *= 0.55;
            _w.war_score[0] = 0;
            _w.war_score[1] = 0;

            var _peace_cause = (_a_exhausted > _b_exhausted) ? _b_civ.name : _a_civ.name;
            world_event(_w, "A HARD-WON PEACE.", _w.ui_good, 9, -1);
            world_event(_w, _peace_cause + " SETS PEACE TERMS.", _w.ui_good, 6, -1);
        }
        else if (_w.war_time > 30 && _w.war_time < 34)
        {
            world_event(_w, "BOTH SIDES COUNT THEIR DEAD.", _w.ui_alert, 5, -1);
        }
        return;
    }

    _w.relation = clamp(_w.relation + (0 - _w.relation) * 0.0035 + random_range(-0.12, 0.12), -100, 100);
    _w.trust = clamp(_w.trust + (0.42 - _w.trust) * 0.001, 0, 1);

    // Border friction at the Common.
    for (var _i = 0; _i < array_length(_w.humans); _i++)
    {
        var _a = _w.humans[_i];
        if (_a.dead || point_distance(_a.x, _a.y, _w.common_x, _w.common_y) > 240) continue;

        for (var _j = _i + 1; _j < array_length(_w.humans); _j++)
        {
            var _b = _w.humans[_j];
            if (_b.dead || _b.civ == _a.civ) continue;
            if (point_distance(_a.x, _a.y, _b.x, _b.y) > 36) continue;

            if (random(1) < 0.018 + _a.traits.aggression * 0.024)
            {
                _w.relation = max(-100, _w.relation - random_range(1.5, 4));
                _w.grievance[_a.civ] += 1;
                human_add_memory(_a, "BORDER", -0.5, 4, _b.id, "A tense meeting with " + _b.name + " at the Common.");
                human_add_memory(_b, "BORDER", -0.5, 4, _a.id, "A tense meeting with " + _a.name + " at the Common.");

                if (_w.border_event_timer <= 0)
                {
                    _w.border_event_timer = 9;
                    world_event(_w, "A BORDER DISPUTE AT THE COMMON.", _w.ui_alert, 4, -1);
                }
                break;
            }
        }
    }

    // War declaration is a decision made by a leader with a coalition behind him.
    var _a_civ = _w.civs[0];
    var _b_civ = _w.civs[1];
    var _a_leader = world_find_human(_w, _a_civ.leader_id);
    var _b_leader = world_find_human(_w, _b_civ.leader_id);

    if (_a_leader != noone && _b_leader != noone && !_a_leader.dead && !_b_leader.dead)
    {
        var _a_ratio = (_a_civ.soldiers + 1) / (_b_civ.soldiers + 1);
        var _b_ratio = (_b_civ.soldiers + 1) / (_a_civ.soldiers + 1);
        var _a_hunger = 1 - clamp(_a_civ.food / 160, 0, 1);
        var _b_hunger = 1 - clamp(_b_civ.food / 160, 0, 1);
        var _a_claim = _w.grievance[0] + _a_civ.faction.wardens * 8 + _a_leader.traits.aggression * 5;
        var _b_claim = _w.grievance[1] + _b_civ.faction.wardens * 8 + _b_leader.traits.aggression * 5;

        if (_w.relation < -30 && _a_claim > 10 && _a_ratio > 1.02 && _a_leader.traits.aggression > 0.55 && _a_civ.food > 45 && _a_civ.morale > 38
            && random(1) < 0.18 + _a_hunger * 0.18)
        {
            _w.at_war = true;
            _w.war_time = 0;
            _w.war_goal = (_b_civ.food > _a_civ.food * 1.2) ? "THE GRAIN ROAD" : "THE COMMON";
            _w.war_cause = _a_civ.name + " CLAIMS " + _w.war_goal;
            _a_civ.priority = "DEFEND";
            _b_civ.priority = "DEFEND";
            _w.war_exhaustion[0] = 8;
            _w.war_exhaustion[1] = 8;
            world_event(_w, _a_civ.name + " DECLARES WAR.", _w.ui_alert, 9, 0);
        }
        else if (_w.relation < -30 && _b_claim > 10 && _b_ratio > 1.02 && _b_leader.traits.aggression > 0.55 && _b_civ.food > 45 && _b_civ.morale > 38
            && random(1) < 0.18 + _b_hunger * 0.18)
        {
            _w.at_war = true;
            _w.war_time = 0;
            _w.war_goal = (_a_civ.food > _b_civ.food * 1.2) ? "THE GRAIN ROAD" : "THE COMMON";
            _w.war_cause = _b_civ.name + " CLAIMS " + _w.war_goal;
            _a_civ.priority = "DEFEND";
            _b_civ.priority = "DEFEND";
            _w.war_exhaustion[0] = 8;
            _w.war_exhaustion[1] = 8;
            world_event(_w, _b_civ.name + " DECLARES WAR.", _w.ui_alert, 9, 1);
        }
    }
};

function building_roof_colour(_type)
{
    switch (_type)
    {
        case BLD_HUT: return make_colour_rgb(195, 108, 76);
        case BLD_GRANARY: return make_colour_rgb(211, 176, 87);
        case BLD_FARM: return make_colour_rgb(108, 163, 84);
        case BLD_WORKSHOP: return make_colour_rgb(124, 152, 188);
        case BLD_SHRINE: return make_colour_rgb(181, 146, 216);
        case BLD_INFIRMARY: return make_colour_rgb(107, 190, 179);
        case BLD_PALISADE: return make_colour_rgb(165, 125, 85);
        case BLD_WATCHTOWER: return make_colour_rgb(205, 99, 89);
        case BLD_MARKET: return make_colour_rgb(220, 153, 74);
        case BLD_WELL: return make_colour_rgb(102, 153, 209);
    }
    return make_colour_rgb(120, 120, 110);
};

function world_draw(_w)
{
    draw_set_alpha(1);
    draw_set_colour(make_colour_rgb(11, 15, 13));
    draw_rectangle(0, 0, room_width, room_height, false);

    // Static punctuation field gives the ground its ASCII texture.
    var _ground_green = make_colour_rgb(44, 71, 46);
    var _ground_grey = make_colour_rgb(52, 56, 46);
    for (var _patch_i = 0; _patch_i < array_length(_w.terrain); _patch_i++)
    {
        var _patch = _w.terrain[_patch_i];
        var _ground_colour = ((_patch.code == 44) || (_patch.code == 34)) ? _ground_green : _ground_grey;
        draw_set_alpha(_patch.shade * 0.8);
        ui_glyph_centred(_patch.x, _patch.y, _patch.code, _ground_colour, 1);
    }
    draw_set_alpha(1);

    // The Common is marked by a sparse ring of terminal dots.
    var _common_colour = make_colour_rgb(86, 112, 80);
    draw_set_alpha(0.32);
    for (var _common_angle = 0; _common_angle < 360; _common_angle += 15)
    {
        ui_glyph_centred(
            _w.common_x + lengthdir_x(205, _common_angle),
            _w.common_y + lengthdir_y(205, _common_angle),
            GLYPH_COMMON,
            _common_colour,
            1
        );
    }
    draw_set_alpha(1);

    // Resources: bushes, trees and rock outcrops as single terminal glyphs.
    for (var _r_i = 0; _r_i < array_length(_w.resources); _r_i++)
    {
        var _r = _w.resources[_r_i];
        var _fill = clamp(_r.amount / _r.max_amount, 0.1, 1);
        var _r_code = GLYPH_FOOD;
        var _r_colour = make_colour_rgb(156, 189, 106);

        if (_r.kind == RES_WOOD)
        {
            _r_code = GLYPH_TREE;
            _r_colour = make_colour_rgb(82, 143, 82);
        }
        else if (_r.kind == RES_STONE)
        {
            _r_code = GLYPH_STONE;
            _r_colour = make_colour_rgb(149, 153, 141);
        }

        draw_set_alpha(0.45 + 0.55 * _fill);
        ui_glyph_centred(_r.x, _r.y, _r_code, _r_colour, 1);
    }
    draw_set_alpha(1);

    // Buildings: one type-coloured glyph per structure.
    for (var _b_i = 0; _b_i < array_length(_w.buildings); _b_i++)
    {
        var _b = _w.buildings[_b_i];
        var _civ = _w.civs[_b.civ];
        var _roof = building_roof_colour(_b.type);
        var _glyph = GLYPH_HUT;

        switch (_b.type)
        {
            case BLD_HUT: _glyph = GLYPH_HUT; break;
            case BLD_GRANARY: _glyph = GLYPH_GRANARY; break;
            case BLD_FARM: _glyph = GLYPH_FARM; break;
            case BLD_WORKSHOP: _glyph = GLYPH_WORKSHOP; break;
            case BLD_SHRINE: _glyph = GLYPH_SHRINE; break;
            case BLD_INFIRMARY: _glyph = GLYPH_INFIRMARY; break;
            case BLD_PALISADE: _glyph = GLYPH_PALISADE; break;
            case BLD_WATCHTOWER: _glyph = GLYPH_WATCHTOWER; break;
            case BLD_MARKET: _glyph = GLYPH_MARKET; break;
            case BLD_WELL: _glyph = GLYPH_WELL; break;
        }

        draw_set_alpha(_b.complete ? 1 : 0.42);
        ui_glyph_centred(_b.x, _b.y, _glyph, _roof, 1);

        // Civilization ownership stays legible as a short coloured underline.
        draw_set_alpha(_b.complete ? 0.85 : 0.35);
        draw_set_colour(_civ.colour);
        draw_rectangle(_b.x - 7, _b.y + 10, _b.x + 7, _b.y + 11, false);

        if (!_b.complete)
        {
            draw_set_alpha(0.9);
            draw_set_colour(_w.ui_milestone);
            draw_rectangle(_b.x - 7, _b.y + 13, _b.x - 7 + 14 * _b.progress, _b.y + 15, false);
        }
    }
    draw_set_alpha(1);

    // Wolves: a lower-case w, as in a roguelike bestiary.
    draw_set_alpha(0.95);
    for (var _wolf_i = 0; _wolf_i < array_length(_w.wolves); _wolf_i++)
    {
        var _wolf = _w.wolves[_wolf_i];
        ui_glyph_centred(_wolf.x, _wolf.y, GLYPH_WOLF, make_colour_rgb(198, 104, 84), 1);
    }
    draw_set_alpha(1);

    // Humans: one ASCII @ per person, coloured by allegiance and role.
    for (var _human_i = 0; _human_i < array_length(_w.humans); _human_i++)
    {
        var _h = _w.humans[_human_i];
        if (_h.dead) continue;

        var _civ = _w.civs[_h.civ];
        var _is_child = (_h.age < ADULT_AGE);
        var _glyph = GLYPH_HUMAN;
        var _colour = _civ.colour;

        if (_h.job == JOB_LEADER)
        {
            _glyph = GLYPH_HUMAN_DARK;
            _colour = _w.ui_milestone;
        }
        else if (_h.job == JOB_GUARD)
        {
            _colour = make_colour_rgb(236, 239, 225);
        }

        if (_h.infected) _colour = make_colour_rgb(142, 188, 120);

        draw_set_alpha(_is_child ? 0.72 : 1);
        ui_glyph_centred(_h.x, _h.y, _glyph, _colour, 1);

        if (_h.carrying)
        {
            var _carry_code = GLYPH_FOOD;
            var _carry_colour = make_colour_rgb(159, 111, 96);
            if (_h.carry_type == RES_WOOD)
            {
                _carry_code = GLYPH_TREE;
                _carry_colour = make_colour_rgb(151, 111, 66);
            }
            else if (_h.carry_type == RES_STONE)
            {
                _carry_code = GLYPH_STONE;
                _carry_colour = make_colour_rgb(153, 156, 147);
            }

            draw_set_alpha(0.9);
            ui_glyph_centred(_h.x + 8, _h.y + 7, _carry_code, _carry_colour, 0.5);
        }

        draw_set_alpha(1);
    }

    // Selection marker: a gold box around the selected person's glyph.
    var _selected = world_find_human(_w, global.selected_id);
    if (_selected != noone && !_selected.dead)
    {
        draw_set_alpha(1);
        draw_set_colour(_w.ui_milestone);
        draw_rectangle(_selected.x - 10, _selected.y - 10, _selected.x + 10, _selected.y + 10, true);
        draw_set_colour(c_white);
    }

    // Night is a pressure and a visual shift, not a separate mode.
    if (world_day_night(_w))
    {
        draw_set_alpha(0.22);
        draw_set_colour(make_colour_rgb(9, 14, 28));
        draw_rectangle(0, 0, room_width, room_height, false);
        draw_set_alpha(1);
    }

    draw_set_colour(c_white);
};
