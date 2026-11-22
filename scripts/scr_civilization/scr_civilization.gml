/// Civilization-level economy, labor, projects, technology and diplomacy.

function civ_new(_id, _name, _colour, _trait, _home_x, _home_y)
{
    var _civ = {
        id: _id,
        name: _name,
        colour: _colour,
        trait: _trait,
        home_x: _home_x,
        home_y: _home_y,
        food: 150,
        wood: 110,
        stone: 65,
        tools: 0,
        treasury: 0,
        morale: 62,
        legitimacy: 58,
        stability: 58,
        unrest: 0,
        tech: 0,
        tech_points: 0,
        know: { farm: 0, craft: 0, war: 0, medicine: 0, culture: 0, trade: 0 },
        research_focus: "farm",
        policy: "SHARE",
        priority: "GROW",
        project: -1,
        leader_id: -1,
        heir_id: -1,
        council: [],
        next_family_id: _id * 100 + 20,
        population: 0,
        adults: 0,
        children: 0,
        housing: 0,
        soldiers: 0,
        infected: 0,
        gathered: 0,
        deaths: 0,
        births: 0,
        trade_runs: 0,
        war_chest: 0,
        war_score: 0,
        war_exhaustion: 0,
        last_leader_support: 0,
        challenge_timer: 20,
        faction: { hearth: 0.34, forge: 0.22, wardens: 0.22, lore: 0.22 },
        job_timer: random(2),
        project_timer: random(2),
        birth_timer: random(4),
        pair_timer: random(3),
        tech_timer: 0,
        consumption_timer: 0,
        priority_timer: 0,
        event_timer: 0,
        last_priority: ""
    };
    return _civ;
};

function building_label(_type)
{
    switch (_type)
    {
        case BLD_HUT: return "HUT";
        case BLD_GRANARY: return "GRANARY";
        case BLD_FARM: return "FIELD";
        case BLD_WORKSHOP: return "WORKSHOP";
        case BLD_SHRINE: return "SHRINE";
        case BLD_INFIRMARY: return "INFIRMARY";
        case BLD_PALISADE: return "PALISADE";
        case BLD_WATCHTOWER: return "WATCHTOWER";
        case BLD_MARKET: return "MARKET";
        case BLD_WELL: return "WELL";
    }
    return "BUILDING";
};

function building_cost_wood(_type)
{
    switch (_type)
    {
        case BLD_HUT: return 18;
        case BLD_GRANARY: return 28;
        case BLD_FARM: return 24;
        case BLD_WORKSHOP: return 40;
        case BLD_SHRINE: return 26;
        case BLD_INFIRMARY: return 34;
        case BLD_PALISADE: return 46;
        case BLD_WATCHTOWER: return 34;
        case BLD_MARKET: return 38;
        case BLD_WELL: return 12;
    }
    return 20;
};

function building_cost_stone(_type)
{
    switch (_type)
    {
        case BLD_HUT: return 0;
        case BLD_GRANARY: return 10;
        case BLD_FARM: return 4;
        case BLD_WORKSHOP: return 20;
        case BLD_SHRINE: return 18;
        case BLD_INFIRMARY: return 16;
        case BLD_PALISADE: return 2;
        case BLD_WATCHTOWER: return 12;
        case BLD_MARKET: return 10;
        case BLD_WELL: return 22;
    }
    return 10;
};

function civ_available_building(_civ, _type)
{
    if (_type == BLD_HUT || _type == BLD_GRANARY || _type == BLD_FARM) return true;
    if (_type == BLD_WELL) return civ_domain_level(_civ.know.medicine) >= 1 || civ_domain_level(_civ.know.farm) >= 1;
    if (_type == BLD_WORKSHOP) return civ_domain_level(_civ.know.craft) >= 1;
    if (_type == BLD_SHRINE) return civ_domain_level(_civ.know.culture) >= 1;
    if (_type == BLD_INFIRMARY) return civ_domain_level(_civ.know.medicine) >= 1;
    if (_type == BLD_PALISADE) return civ_domain_level(_civ.know.war) >= 1;
    if (_type == BLD_WATCHTOWER) return civ_domain_level(_civ.know.war) >= 2;
    if (_type == BLD_MARKET) return civ_domain_level(_civ.know.trade) >= 2;
    return false;
};

function civ_job_affinity(_h, _job)
{
    var _s = _h.skills;
    var _t = _h.traits;
    var _score = 0;

    switch (_job)
    {
        case JOB_FOOD:
            _score = _s.forage * 1.2 + _s.farm * 0.4 + _t.industry * 0.5 - _h.age * 0.002;
            break;
        case JOB_WOOD:
            _score = _s.wood * 1.2 + _t.industry * 0.5 + _t.bold * 0.15;
            break;
        case JOB_STONE:
            _score = _s.stone * 1.2 + _t.industry * 0.45 + _t.bold * 0.15;
            break;
        case JOB_FARM:
            _score = _s.farm * 1.35 + _t.industry * 0.45 + _t.caution * 0.1;
            break;
        case JOB_BUILD:
            _score = _s.build * 1.3 + _t.industry * 0.5 + _t.curiosity * 0.15;
            break;
        case JOB_GUARD:
            _score = _s.combat * 1.4 + _t.bold * 0.55 + _t.aggression * 0.25 - _t.caution * 0.15;
            break;
        case JOB_HEAL:
            _score = _s.heal * 1.4 + _t.compassion * 0.6 + _t.caution * 0.1;
            break;
        case JOB_SCHOLAR:
            _score = _s.research * 1.4 + _t.curiosity * 0.65 + _t.ambition * 0.15;
            break;
        case JOB_TRADER:
            _score = _s.trade * 1.35 + _t.sociability * 0.55 + _t.bold * 0.15;
            break;
        case JOB_LEADER:
            _score = _s.lead * 1.5 + _t.ambition * 0.4 + _t.bold * 0.25;
            break;
        case JOB_CRAFT:
            _score = _s.build * 1.05 + _s.research * 0.45 + _t.industry * 0.55 + _t.curiosity * 0.25;
            break;
        default:
            _score = 0.1;
    }

    // Preference is not the same as talent. A willing worker learns faster
    // and keeps at a task; a resentful one drifts toward other work.
    if (human_has(_h.labor_likes, _job)) _score += 0.30 + _h.facets.discipline * 0.08;
    if (human_has(_h.labor_dislikes, _job)) _score -= 0.38;

    var _affinity_skill = "forage";
    if (_job == JOB_FARM) _affinity_skill = "farm";
    else if (_job == JOB_WOOD) _affinity_skill = "wood";
    else if (_job == JOB_STONE) _affinity_skill = "stone";
    else if (_job == JOB_BUILD) _affinity_skill = "build";
    else if (_job == JOB_GUARD) _affinity_skill = "combat";
    else if (_job == JOB_HEAL) _affinity_skill = "heal";
    else if (_job == JOB_SCHOLAR) _affinity_skill = "research";
    else if (_job == JOB_TRADER) _affinity_skill = "trade";
    else if (_job == JOB_LEADER) _affinity_skill = "lead";
    else if (_job == JOB_CRAFT) _affinity_skill = "build";
    _score += (variable_struct_get(_h.aptitudes, _affinity_skill) - 1) * 0.16;

    if (_job == JOB_BUILD || _job == JOB_CRAFT) _score += _h.values.craft * 0.10;
    if (_job == JOB_GUARD) _score += _h.values.martial * 0.16 + _h.values.honor * 0.06;
    if (_job == JOB_HEAL) _score += _h.values.community * 0.10 + _h.facets.altruism * 0.08;
    if (_job == JOB_SCHOLAR) _score += _h.values.knowledge * 0.14;
    if (_job == JOB_TRADER) _score += _h.values.wealth * 0.14;
    if (_job == JOB_FARM) _score += _h.values.community * 0.06 + _h.values.tradition * 0.05;

    return _score;
};

function civ_job_quota(_w, _civ, _job)
{
    var _pop = _civ.adults;
    var _quota = 0;

    switch (_job)
    {
        case JOB_FOOD:
            _quota = max(4, floor(_pop * 0.22));
            if (_civ.food < 60) _quota += max(2, floor(_pop * 0.08));
            else if (_civ.food > world_civ_food_capacity(_w, _civ.id) * 0.88) _quota = max(4, floor(_pop * 0.15));
            break;
        case JOB_WOOD:
            _quota = max(3, floor(_pop * 0.14));
            if (_civ.project != -1 || _civ.priority == "GROW") _quota += 1;
            break;
        case JOB_STONE:
            _quota = max(2, floor(_pop * 0.09));
            if (_civ.project != -1 && _civ.tech >= 1) _quota += 1;
            break;
        case JOB_FARM:
            _quota = min(world_civ_building_count(_w, _civ.id, BLD_FARM) * 2, floor(_pop * 0.24));
            if (_civ.food < 50) _quota += 1;
            else if (_civ.food > world_civ_food_capacity(_w, _civ.id) * 0.88) _quota = max(3, _quota - 2);
            break;
        case JOB_BUILD:
            _quota = (_civ.project != -1) ? max(2, floor(_pop * 0.12)) : 0;
            break;
        case JOB_GUARD:
            _quota = 2 + ((_w.at_war) ? max(3, floor(_pop * 0.18)) : 0);
            if (array_length(_w.wolves) > 2) _quota += 1;
            if (_civ.policy == "MARTIAL") _quota += 1;
            break;
        case JOB_HEAL:
            _quota = max(1, floor(_pop * 0.04)) + ((_civ.infected > 1) ? 1 : 0);
            break;
        case JOB_SCHOLAR:
            _quota = max(1, floor(_pop * 0.05));
            if (_civ.priority == "STUDY") _quota += 1;
            if (_civ.policy == "LEARN") _quota += 1;
            break;
        case JOB_TRADER:
            _quota = (!_w.at_war && _w.relation > -12) ? 1 : 0;
            if (_civ.priority == "TRADE") _quota += 1;
            break;
        case JOB_CRAFT:
            // Once the workshops have equipped the settlement, the smiths
            // return to timber, stone and building rather than draining the
            // stores for tools nobody needs.
            if (_civ.tools >= 80) return 0;
            var _workshops = world_civ_building_count(_w, _civ.id, BLD_WORKSHOP);
            _quota = (_workshops > 0) ? max(1, floor(_pop * 0.06)) : 0;
            if (_workshops > 0 && _civ.tools < 12) _quota += 1;
            if (_workshops > 0 && _civ.priority == "STUDY") _quota += 1;
            if (_workshops > 0 && _civ.policy == "CRAFT") _quota += 1;
            break;
    }

    return max(0, _quota);
};

function civ_assign_jobs(_w, _civ, _dt)
{
    _civ.job_timer -= _dt;
    if (_civ.job_timer > 0) return;
    _civ.job_timer = 3.2;

    var _adults = [];

    for (var _i = 0; _i < array_length(_w.humans); _i++)
    {
        var _h = _w.humans[_i];
        if (_h.dead || _h.civ != _civ.id) continue;
        if (_h.age >= ADULT_AGE && _h.age < ELDER_AGE) array_push(_adults, _h);
    }

    if (array_length(_adults) == 0) return;

    var _quotas = array_create(JOB_COUNT, 0);
    for (var _job_i = JOB_FOOD; _job_i < JOB_COUNT; _job_i++)
    {
        _quotas[_job_i] = civ_job_quota(_w, _civ, _job_i);
    }

    // The leader is a person, not a slot; keep the office filled.
    var _leader = world_find_human(_w, _civ.leader_id);
    if (_leader == noone || _leader.dead || _leader.age < ADULT_AGE)
    {
        civ_choose_leader(_w, _civ);
        _leader = world_find_human(_w, _civ.leader_id);
    }

    // Keep existing roles before filling vacancies. A person who already
    // keeps a trade does not lose it to a marginally better newcomer, and
    // long tasks do not restart every few seconds.
    var _counts = array_create(JOB_COUNT, 0);
    var _kept = array_create(array_length(_adults), false);

    for (var _i = 0; _i < array_length(_adults); _i++)
    {
        var _h = _adults[_i];

        if (_leader != noone && _h.id == _leader.id)
        {
            _h.job = JOB_LEADER;
            _counts[JOB_LEADER] += 1;
            _kept[_i] = true;
            continue;
        }

        var _current = _h.job;
        if (_current >= JOB_FOOD && _current < JOB_COUNT
            && _current != JOB_LEADER && _current != JOB_CHILD
            && _counts[_current] < _quotas[_current])
        {
            _counts[_current] += 1;
            _kept[_i] = true;
        }
    }

    for (var _i = 0; _i < array_length(_adults); _i++)
    {
        if (_kept[_i]) continue;

        var _h = _adults[_i];
        var _previous = _h.job;
        var _best_job = -1;
        var _best = 0;

        for (var _job_i = JOB_FOOD; _job_i < JOB_COUNT; _job_i++)
        {
            if (_job_i == JOB_LEADER || _job_i == JOB_CHILD) continue;
            if (_counts[_job_i] >= _quotas[_job_i]) continue;

            var _score = civ_job_affinity(_h, _job_i);
            if (_job_i == _previous) _score *= 1.18;
            if (_h.age > 47 && (_job_i == JOB_GUARD || _job_i == JOB_STONE)) _score *= 0.6;
            if (_score > _best)
            {
                _best = _score;
                _best_job = _job_i;
            }
        }

        if (_best_job != -1)
        {
            _h.job = _best_job;
            _counts[_best_job] += 1;

            // A genuine trade change is a new plan, not a new identity.
            if (_previous != _best_job
                && _h.task != TASK_EAT && _h.task != TASK_FLEE
                && _h.task != TASK_FIGHT && _h.task != TASK_SLEEP)
            {
                _h.task = TASK_IDLE;
                _h.goal = GOAL_WORK;
            }

            if (_previous != _best_job)
            {
                var _work_valence = human_has(_h.labor_likes, _best_job) ? 0.35 : (human_has(_h.labor_dislikes, _best_job) ? -0.35 : 0.10);
                human_add_thought(_h, "Took up work as a " + human_job_label(_best_job), _work_valence, 0.40, 120);
            }
        }
        else
        {
            // No quota has room: put the surplus where the settlement is
            // actually short, rather than piling more labour onto full stores.
            var _fallback = (_civ.wood < 80) ? JOB_WOOD : JOB_FOOD;
            _h.job = _fallback;
            _counts[_fallback] += 1;

            if (_previous != _fallback
                && _h.task != TASK_EAT && _h.task != TASK_FLEE
                && _h.task != TASK_FIGHT && _h.task != TASK_SLEEP)
            {
                _h.task = TASK_IDLE;
                _h.goal = GOAL_WORK;
            }

            if (_previous != _fallback)
            {
                var _fallback_valence = human_has(_h.labor_likes, _fallback) ? 0.30 : (human_has(_h.labor_dislikes, _fallback) ? -0.30 : 0.05);
                human_add_thought(_h, "Took up work as a " + human_job_label(_fallback), _fallback_valence, 0.35, 110);
            }
        }
    }

    for (var _i = 0; _i < array_length(_adults); _i++)
    {
        var _h = _adults[_i];
        if (_h.job == JOB_IDLE) _h.job = JOB_FOOD;
    }
};

function civ_choose_leader(_w, _civ)
{
    var _best = noone;
    var _best_score = -999;

    for (var _i = 0; _i < array_length(_w.humans); _i++)
    {
        var _h = _w.humans[_i];
        if (_h.dead || _h.civ != _civ.id || _h.age < 20 || _h.age >= ELDER_AGE) continue;

        var _faction_support = variable_struct_get(_civ.faction, _h.faction);
        var _score = _h.skills.lead * 1.5
            + _h.traits.ambition * 0.5
            + _h.traits.bold * 0.3
            + _h.mood * 0.003
            + _h.reputation * 0.012
            + _h.wealth * 0.008
            + _faction_support * 1.4
            + human_relation(_h, _civ.leader_id).opinion * 0.001;

        if (_score > _best_score)
        {
            _best_score = _score;
            _best = _h;
        }
    }

    if (_best != noone)
    {
        var _old_leader = world_find_human(_w, _civ.leader_id);
        if (_old_leader != noone && _old_leader != _best && !_old_leader.dead)
        {
            _old_leader.job = JOB_IDLE;
        }

        _civ.leader_id = _best.id;
        var _leader_house = world_find_household(_w, _best.household_id);
        _civ.heir_id = (_leader_house != noone) ? world_household_heir(_w, _leader_house) : -1;
        _best.job = JOB_LEADER;
        _best.task = TASK_IDLE;
        _best.reputation = min(100, _best.reputation + 8);
        _civ.legitimacy = clamp(_civ.legitimacy - 8, 0, 100);
        _civ.challenge_timer = 24;
        world_event(_w, _civ.name + " RAISES " + _best.name + " AS LEADER.", _civ.colour, 6, _civ.id);
    }
};

function civ_politics(_w, _civ, _dt)
{
    _civ.challenge_timer -= _dt;

    var _leader = world_find_human(_w, _civ.leader_id);
    if (_leader == noone || _leader.dead)
    {
        civ_choose_leader(_w, _civ);
        return;
    }

    // Unrest is a material index, not a random mood: food, shelter, fever, war.
    var _food_gap = clamp(1 - world_civ_food_days(_w, _civ) / 4.0, 0, 1);
    var _housing_gap = clamp((_civ.population - _civ.housing) / max(4, _civ.population), 0, 1);
    var _unrest_target = _food_gap * 0.42 + _housing_gap * 0.25 + clamp(_civ.infected / 12, 0, 1) * 0.18 + (_w.at_war ? 0.18 : 0);
    _civ.unrest += (_unrest_target - _civ.unrest) * min(1, _dt * 0.05);

    if (_civ.challenge_timer > 0) return;
    _civ.challenge_timer = 18;

    var _support = _civ.legitimacy * 0.45
        + _civ.morale * 0.28
        + _civ.stability * 0.18
        + _leader.reputation * 0.22
        + variable_struct_get(_civ.faction, _leader.faction) * 18;

    _civ.last_leader_support = clamp(_support, 0, 100);

    var _rival = noone;
    var _rival_score = -999;

    for (var _i = 0; _i < array_length(_w.humans); _i++)
    {
        var _person = _w.humans[_i];
        if (_person.dead || _person.civ != _civ.id || _person.id == _leader.id) continue;
        if (_person.age < 20 || _person.age >= ELDER_AGE) continue;

        var _score = _person.skills.lead * 1.2
            + _person.traits.ambition * 0.55
            + _person.reputation * 0.014
            + _person.wealth * 0.01
            + variable_struct_get(_civ.faction, _person.faction) * 1.6;

        if (_score > _rival_score)
        {
            _rival_score = _score;
            _rival = _person;
        }
    }

    var _leader_score = _leader.skills.lead * 1.2
        + _leader.traits.ambition * 0.55
        + _leader.reputation * 0.014
        + _leader.wealth * 0.01
        + variable_struct_get(_civ.faction, _leader.faction) * 1.6;

    if (_rival != noone && (_support < 38 || _civ.unrest > 0.58) && _rival_score > _leader_score * 1.05)
    {
        world_event(_w, _rival.name + " CHALLENGES " + _leader.name + " FOR LEADERSHIP OF " + _civ.name + ".", _w.ui_alert, 8, _civ.id);

        if (random(1) < 0.28 + clamp(_civ.unrest, 0, 1) * 0.35)
        {
            civ_choose_leader(_w, _civ);
            return;
        }

        _leader.reputation = max(0, _leader.reputation - 4);
        _civ.legitimacy = max(0, _civ.legitimacy - 3);
    }
    else if (_support > 68)
    {
        _civ.legitimacy = min(100, _civ.legitimacy + 0.7);
    }

    // The leader's faction sets the public policy, and therefore the next pressure.
    var _dominant = "hearth";
    var _dominant_share = -1;
    var _faction_keys = ["hearth", "forge", "wardens", "lore"];

    for (var _i = 0; _i < array_length(_faction_keys); _i++)
    {
        var _share = variable_struct_get(_civ.faction, _faction_keys[_i]);
        if (_share > _dominant_share)
        {
            _dominant_share = _share;
            _dominant = _faction_keys[_i];
        }
    }

    if (_dominant == "forge") _civ.policy = "CRAFT";
    else if (_dominant == "wardens") _civ.policy = "MARTIAL";
    else if (_dominant == "lore") _civ.policy = "LEARN";
    else _civ.policy = "SHARE";
};

function civ_choose_project(_w, _civ, _dt)
{
    _civ.project_timer -= _dt;
    if (_civ.project_timer > 0) return;
    _civ.project_timer = 2.8;

    if (_civ.project != -1 && !_civ.project.complete) return;
    _civ.project = -1;

    var _housing = world_civ_housing(_w, _civ.id);
    var _population = _civ.population;
    var _households = world_civ_building_count(_w, _civ.id, BLD_HUT);
    var _granaries = world_civ_building_count(_w, _civ.id, BLD_GRANARY);
    var _farms = world_civ_building_count(_w, _civ.id, BLD_FARM);
    var _wells = world_civ_building_count(_w, _civ.id, BLD_WELL);
    var _infirmaries = world_civ_building_count(_w, _civ.id, BLD_INFIRMARY);
    var _workshops = world_civ_building_count(_w, _civ.id, BLD_WORKSHOP);
    var _shrines = world_civ_building_count(_w, _civ.id, BLD_SHRINE);
    var _palisades = world_civ_building_count(_w, _civ.id, BLD_PALISADE);
    var _best_type = -1;
    var _best_score = 0;

    for (var _type = 0; _type < BLD_COUNT; _type++)
    {
        if (!civ_available_building(_civ, _type)) continue;

        var _score = 0.2;

        if (_type == BLD_HUT)
        {
            // Keep one spare bed ahead of the next birth, not a second granary
            // on top of seven.
            _score = 0.35 + max(0, _population + 2 - _housing) * 0.65;
        }
        else if (_type == BLD_GRANARY)
        {
            _score = (_granaries >= 2) ? 0.08
                : 0.25 + ((_granaries < 1) ? 1.2 : 0) + ((_civ.food > world_civ_food_capacity(_w, _civ.id) * 0.8) ? 0.7 : 0);
        }
        else if (_type == BLD_FARM)
        {
            _score = (_farms >= 4) ? 0.12
                : 0.45 + max(0, 3 - _farms) * 0.45 + ((_civ.food < 80) ? 0.7 : 0);
        }
        else if (_type == BLD_WELL)
        {
            _score = (_wells >= 2) ? 0.08 : 0.2 + ((_wells < 1) ? 0.6 : 0) + ((_civ.infected > 0) ? 0.4 : 0);
        }
        else if (_type == BLD_WORKSHOP)
        {
            _score = (_workshops >= 2) ? 0.1 : 0.3 + ((_workshops < 1) ? 1.0 : 0) + _civ.faction.lore * 0.6;
        }
        else if (_type == BLD_SHRINE)
        {
            _score = (_shrines >= 1) ? 0.08 : 0.2 + ((_shrines < 1) ? 0.9 : 0) + _civ.faction.hearth * 0.4;
        }
        else if (_type == BLD_INFIRMARY)
        {
            _score = (_infirmaries >= 1) ? 0.08 : 0.2 + ((_infirmaries < 1) ? 0.9 : 0) + _civ.infected * 0.15;
        }
        else if (_type == BLD_PALISADE)
        {
            _score = (_palisades >= 1) ? 0.08 : 0.35 + _civ.faction.wardens * 0.6;
        }
        else if (_type == BLD_WATCHTOWER)
        {
            var _towers = world_civ_building_count(_w, _civ.id, BLD_WATCHTOWER);
            _score = (_towers >= 2) ? 0.08 : 0.3 + _civ.faction.wardens * 0.5;
        }
        else if (_type == BLD_MARKET)
        {
            var _markets = world_civ_building_count(_w, _civ.id, BLD_MARKET);
            _score = (_markets >= 1) ? 0.08 : 0.4 + _civ.faction.forge * 0.5;
        }

        if (_score > _best_score) { _best_score = _score; _best_type = _type; }
    }

    if (_best_type == -1) return;

    var _wood_cost = building_cost_wood(_best_type);
    var _stone_cost = building_cost_stone(_best_type);

    if (_civ.wood < _wood_cost || _civ.stone < _stone_cost) return;

    var _spot = civ_pick_building_site(_w, _civ);
    var _building = world_spawn_building(_w, _civ.id, _best_type, _spot[0], _spot[1], false);

    if (_building == noone) return;

    _civ.wood -= _wood_cost;
    _civ.stone -= _stone_cost;
    _civ.project = _building;
    _building.progress = 0;

    world_event(_w, _civ.name + " BEGINS " + building_label(_best_type) + ".", _civ.colour, 2, _civ.id);
};

function civ_pick_building_site(_w, _civ)
{
    for (var _attempt = 0; _attempt < 18; _attempt++)
    {
        var _angle = random(360);
        var _radius = random_range(95, 190);
        var _x = _civ.home_x + lengthdir_x(_radius, _angle);
        var _y = _civ.home_y + lengthdir_y(_radius, _angle);

        if (_x < 70 || _x > room_width - 70 || _y < 70 || _y > room_height - 70) continue;

        var _clear = true;
        for (var _b_i = 0; _b_i < array_length(_w.buildings); _b_i++)
        {
            var _b = _w.buildings[_b_i];
            if (point_distance(_x, _y, _b.x, _b.y) < 34)
            {
                _clear = false;
                break;
            }
        }

        if (_clear) return [_x, _y];
    }

    return [_civ.home_x + random_range(-140, 140), _civ.home_y + random_range(-100, 100)];
};

function civil_project_finished(_w, _civ_id, _building)
{
    var _civ = _w.civs[_civ_id];
    if (_civ.project == _building)
    {
        _civ.project = -1;
        _civ.project_timer = 0;
    }

    _civ.legitimacy = clamp(_civ.legitimacy + 3, 0, 100);

    if (_building.type == BLD_SHRINE)
    {
        _civ.morale = clamp(_civ.morale + 4, 0, 100);
    }
    else if (_building.type == BLD_GRANARY)
    {
        _civ.food = min(world_civ_food_capacity(_w, _civ_id), _civ.food + 30);
    }
};

function world_is_peaceful(_w)
{
    return !_w.at_war && _w.relation > -5;
};

function civ_form_pairs(_w, _civ, _dt)
{
    _civ.pair_timer -= _dt;
    if (_civ.pair_timer > 0) return;
    _civ.pair_timer = 2.8;

    var _women = [];
    var _men = [];

    for (var _i = 0; _i < array_length(_w.humans); _i++)
    {
        var _person = _w.humans[_i];
        if (_person.dead || _person.civ != _civ.id) continue;
        if (_person.age < MARRIAGE_AGE || _person.partner_id != -1) continue;

        if (_person.sex == 1)
        {
            if (_person.age <= 44) array_push(_women, _person);
        }
        else
        {
            if (_person.age <= 52) array_push(_men, _person);
        }
    }

    if (array_length(_women) == 0 || array_length(_men) == 0) return;

    for (var _w_i = 0; _w_i < array_length(_women); _w_i++)
    {
        var _woman = _women[_w_i];
        if (_woman.partner_id != -1) continue;

        var _best = noone;
        var _best_score = 0.10;

        for (var _m_i = 0; _m_i < array_length(_men); _m_i++)
        {
            var _man = _men[_m_i];
            if (_man.partner_id != -1) continue;

            var _age_gap = abs(_woman.age - _man.age);
            if (_age_gap > 18) continue;

            var _score = 0.34 - _age_gap * 0.012;
            _score += human_relation(_woman, _man.id).opinion * 0.0035;
            _score += (_woman.faction == _man.faction) ? 0.12 : 0;
            _score += (1 - min(1, point_distance(_woman.x, _woman.y, _man.x, _man.y) / 420)) * 0.12;
            _score += (_woman.traits.compassion + _man.traits.compassion - 1) * 0.08;
            _score += (_woman.traits.sociability + _man.traits.sociability - 1) * 0.05;
            _score += random_range(-0.05, 0.05);

            if (_woman.family_id != -1 && _woman.family_id == _man.family_id) _score -= 0.45;
            if (_woman.parent_a == _man.id || _woman.parent_b == _man.id
                || _man.parent_a == _woman.id || _man.parent_b == _woman.id) _score -= 2;

            if (_score > _best_score)
            {
                _best_score = _score;
                _best = _man;
            }
        }

        if (_best == noone) continue;

        var _chosen = _best;
        _woman.partner_id = _chosen.id;
        _chosen.partner_id = _woman.id;
        _woman.family_id = _civ.next_family_id;
        _chosen.family_id = _woman.family_id;
        _civ.next_family_id += 1;

        world_household_remove(_w, _woman.household_id, _woman.id);
        world_household_remove(_w, _chosen.household_id, _chosen.id);

        var _home_x = (_woman.home_x + _chosen.home_x) * 0.5;
        var _home_y = (_woman.home_y + _chosen.home_y) * 0.5;
        _woman.home_x = _home_x;
        _woman.home_y = _home_y;
        _chosen.home_x = _home_x;
        _chosen.home_y = _home_y;

        var _house = world_household_new(_w, _civ.id, _woman, _chosen);
        _woman.household_id = _house.id;
        _chosen.household_id = _house.id;

        var _rel_a = human_relation(_woman, _chosen.id);
        var _rel_b = human_relation(_chosen, _woman.id);
        _rel_a.kin = 1;
        _rel_b.kin = 1;
        _rel_a.trust = max(_rel_a.trust, 0.78);
        _rel_b.trust = max(_rel_b.trust, 0.78);
        _rel_a.opinion = max(_rel_a.opinion, 55);
        _rel_b.opinion = max(_rel_b.opinion, 55);

        human_add_memory(_woman, "MARRIAGE", 0.8, 7, _chosen.id, "Bonded with " + _chosen.name + ".");
        human_add_memory(_chosen, "MARRIAGE", 0.8, 7, _woman.id, "Bonded with " + _woman.name + ".");
        human_add_emotion(_woman, 0.55, 0, 0, 0);
        human_add_emotion(_chosen, 0.55, 0, 0, 0);
    }
};

function civ_births(_w, _civ, _dt)
{
    _civ.birth_timer -= _dt;
    if (_civ.birth_timer > 0) return;
    _civ.birth_timer = 5.5;

    if (_civ.food < 75 || _civ.population >= MAX_POPULATION) return;

    var _housing = world_civ_housing(_w, _civ.id);
    if (_housing <= _civ.population + 1) return;
    if (_civ.morale < 42) return;
    if (world_day_night(_w)) return;

    for (var _i = 0; _i < array_length(_w.humans); _i++)
    {
        var _mother = _w.humans[_i];
        if (_mother.dead || _mother.civ != _civ.id || _mother.sex != 1) continue;
        if (_mother.age < 18 || _mother.age > 44 || _mother.partner_id == -1) continue;

        var _father = world_find_human(_w, _mother.partner_id);
        if (_father == noone || _father.dead || _father.civ != _civ.id) continue;
        if (random(1) > 0.09) continue;

        var _child = world_spawn_human(_w, _civ.id, 0, irandom(1), _mother.x + random_range(-8, 8), _mother.y + random_range(-8, 8));
        if (_child == noone) return;

        _child.job = JOB_CHILD;
        _child.home_x = _mother.home_x;
        _child.home_y = _mother.home_y;
        _child.family_id = _mother.family_id;
        _child.household_id = _mother.household_id;
        _child.parent_a = _father.id;
        _child.parent_b = _mother.id;
        _child.faction = (random(1) < 0.7) ? _mother.faction : _father.faction;

        var _trait_keys = ["bold", "compassion", "industry", "curiosity", "sociability", "aggression", "caution", "ambition", "loyalty", "greed", "tradition", "honesty"];
        for (var _trait_i = 0; _trait_i < array_length(_trait_keys); _trait_i++)
        {
            var _trait = _trait_keys[_trait_i];
            var _parent_value = (variable_struct_get(_mother.traits, _trait) + variable_struct_get(_father.traits, _trait)) * 0.5;
            variable_struct_set(_child.traits, _trait, clamp(_parent_value + random_range(-0.12, 0.12), 0.05, 0.95));
        }

        world_household_add(_w, _mother.household_id, _child.id);

        var _birth_house = world_find_household(_w, _mother.household_id);
        if (_birth_house != noone) _birth_house.births += 1;

        // Values and potential run in families. A child is not a copy of
        // either parent, but the household leaves a deep impression.
        var _value_keys = human_value_keys();
        for (var _value_i = 0; _value_i < array_length(_value_keys); _value_i++)
        {
            var _value_key = _value_keys[_value_i];
            var _inherited_value = (variable_struct_get(_mother.values, _value_key) + variable_struct_get(_father.values, _value_key)) * 0.5;
            variable_struct_set(_child.values, _value_key, clamp(_inherited_value + random_range(-0.09, 0.09), 0, 1));
        }

        var _facet_keys = human_facet_keys();
        for (var _facet_i = 0; _facet_i < array_length(_facet_keys); _facet_i++)
        {
            var _facet_key = _facet_keys[_facet_i];
            var _inherited_facet = (variable_struct_get(_mother.facets, _facet_key) + variable_struct_get(_father.facets, _facet_key)) * 0.5;
            variable_struct_set(_child.facets, _facet_key, clamp(_inherited_facet + random_range(-0.10, 0.10), 0, 1));
        }

        var _aptitude_keys = human_skill_keys();
        for (var _aptitude_i = 0; _aptitude_i < array_length(_aptitude_keys); _aptitude_i++)
        {
            var _aptitude_key = _aptitude_keys[_aptitude_i];
            var _inherited_aptitude = (variable_struct_get(_mother.aptitudes, _aptitude_key) + variable_struct_get(_father.aptitudes, _aptitude_key)) * 0.5;
            variable_struct_set(_child.aptitudes, _aptitude_key, clamp(_inherited_aptitude + random_range(-0.12, 0.12), 0.6, 1.4));
        }

        if (random(1) < 0.65 && array_length(_mother.labor_likes) > 0
            && !human_has(_child.labor_likes, _mother.labor_likes[0]))
        {
            array_push(_child.labor_likes, _mother.labor_likes[0]);
        }

        _child.epithet = human_epithet(_child);
        _child.ambition_text = human_ambition_text(human_top_value_key(_child));
        _child.fear_text = human_fear_text(human_top_value_key(_child));
        _child.origin = "BORN IN " + _civ.name;
        _child.birth_time = global.sim_time;

        human_relation(_child, _mother.id).kin = 1;
        human_relation(_child, _mother.id).trust = 0.8;
        human_relation(_child, _mother.id).love = 100;
        human_relation(_child, _father.id).kin = 1;
        human_relation(_child, _father.id).trust = 0.8;
        human_relation(_child, _father.id).love = 100;
        array_push(_mother.children, _child.id);
        array_push(_father.children, _child.id);
        _civ.food -= 8;
        _civ.births += 1;
        _mother.births += 1;
        _father.births += 1;

        human_add_memory(_mother, "BIRTH", 0.9, 9, _child.id, "Gave birth to " + _child.name + ".");
        human_add_memory(_father, "BIRTH", 0.9, 9, _child.id, "Became a parent to " + _child.name + ".");
        human_add_emotion(_mother, 0.7, 0, 0, 0);
        human_add_emotion(_father, 0.7, 0, 0, 0);
        human_add_thought(_mother, "A child, " + _child.name, 0.9, 0.9, 260);
        human_add_thought(_father, "A child, " + _child.name, 0.9, 0.9, 260);
        human_advance_ambition(_mother, 0.08);
        human_advance_ambition(_father, 0.08);
        world_event(_w, _child.name + " IS BORN.", _civ.colour, 4, _civ.id);
        return;
    }
};

function civ_domain_level(_points)
{
    if (_points >= 160) return 4;
    if (_points >= 100) return 3;
    if (_points >= 55) return 2;
    if (_points >= 20) return 1;
    return 0;
};

function civ_research_domain(_civ, _w)
{
    if (_w.at_war || _civ.priority == "DEFEND") return "war";
    if (_civ.food < 55) return "farm";
    if (_civ.infected > 2) return "medicine";
    if (_civ.project != -1 && _civ.tools < 12) return "craft";
    if (_civ.priority == "TRADE") return "trade";

    var _best = "farm";
    var _best_share = -1;
    var _domains = ["farm", "craft", "war", "medicine", "culture", "trade"];
    var _faction_by_domain = { farm: "hearth", craft: "forge", war: "wardens", medicine: "hearth", culture: "lore", trade: "forge" };

    for (var _i = 0; _i < array_length(_domains); _i++)
    {
        var _domain = _domains[_i];
        var _faction_key = variable_struct_get(_faction_by_domain, _domain);
        var _share = variable_struct_get(_civ.faction, _faction_key) + variable_struct_get(_civ.know, _domain) * -0.0015;
        if (_share > _best_share)
        {
            _best_share = _share;
            _best = _domain;
        }
    }

    return _best;
};

function civ_add_research(_w, _civ, _domain, _amount)
{
    var _before = variable_struct_get(_civ.know, _domain);
    var _after = min(200, _before + _amount);
    variable_struct_set(_civ.know, _domain, _after);

    var _old_level = civ_domain_level(_before);
    var _new_level = civ_domain_level(_after);

    if (_new_level > _old_level)
    {
        var _labels = {
            farm: "CROP ROTATION",
            craft: "FORGE CRAFT",
            war: "WARBAND DRILL",
            medicine: "HERBAL HEALING",
            culture: "RITES OF THE HEARTH",
            trade: "CARAVAN LAW"
        };
        world_event(_w, _civ.name + " MASTERS " + variable_struct_get(_labels, _domain) + ".", _civ.colour, 7, _civ.id);
        _civ.legitimacy = min(100, _civ.legitimacy + 3);
    }

    _civ.tech = max(_civ.tech, civ_domain_level(_after));
};

function civ_update_research(_w, _civ, _dt)
{
    _civ.research_focus = civ_research_domain(_civ, _w);
};

function civ_building_effects(_w, _civ, _dt)
{
    var _shrines = world_civ_building_count(_w, _civ.id, BLD_SHRINE);
    var _infirmaries = world_civ_building_count(_w, _civ.id, BLD_INFIRMARY);
    var _wells = world_civ_building_count(_w, _civ.id, BLD_WELL);
    var _markets = world_civ_building_count(_w, _civ.id, BLD_MARKET);

    if (_shrines > 0)
    {
        _civ.legitimacy = min(100, _civ.legitimacy + _dt * 0.06 * _shrines);
    }

    if (_infirmaries > 0)
    {
        for (var _i = 0; _i < array_length(_w.humans); _i++)
        {
            var _h = _w.humans[_i];
            if (_h.dead || _h.civ != _civ.id) continue;
            if (point_distance(_h.x, _h.y, _civ.home_x, _civ.home_y) < 150)
            {
                body_rest_care(_h, _dt, min(1, 0.35 + _infirmaries * 0.15));
            }
        }
    }

    if (_wells > 0)
    {
        for (var _i = 0; _i < array_length(_w.humans); _i++)
        {
            var _h = _w.humans[_i];
            if (_h.dead || _h.civ != _civ.id) continue;
            if (point_distance(_h.x, _h.y, _civ.home_x, _civ.home_y) < 160)
            {
                _h.immunity = min(1, _h.immunity + _dt * 0.0016 * _wells);
            }
        }
    }

    if (_markets > 0 && world_is_peaceful(_w))
    {
        _w.trust = min(1, _w.trust + _dt * 0.0008 * _markets);
    }
};

function civ_update(_w, _civ, _dt)
{
    _civ.population = world_civ_population(_w, _civ.id);
    _civ.adults = world_civ_adults(_w, _civ.id);
    _civ.children = max(0, _civ.population - _civ.adults);
    _civ.housing = world_civ_housing(_w, _civ.id);
    _civ.infected = 0;
    _civ.soldiers = 0;

    var _mood_sum = 0;
    var _mood_count = 0;

    for (var _i = 0; _i < array_length(_w.humans); _i++)
    {
        var _h = _w.humans[_i];
        if (_h.dead || _h.civ != _civ.id) continue;

        _mood_sum += _h.mood;
        _mood_count += 1;
        if (_h.infected) _civ.infected += 1;
        if (_h.job == JOB_GUARD) _civ.soldiers += 1;
    }

    // Individual faction membership changes the civilization's balance of power.
    var _faction_counts = { hearth: 0, forge: 0, wardens: 0, lore: 0 };
    for (var _faction_i = 0; _faction_i < array_length(_w.humans); _faction_i++)
    {
        var _faction_person = _w.humans[_faction_i];
        if (_faction_person.dead || _faction_person.civ != _civ.id || _faction_person.age < ADULT_AGE) continue;
        var _faction_key = _faction_person.faction;
        if (struct_exists(_faction_counts, _faction_key))
        {
            variable_struct_set(_faction_counts, _faction_key, variable_struct_get(_faction_counts, _faction_key) + 1);
        }
    }

    var _adult_count = max(1, _civ.adults);
    var _faction_keys = ["hearth", "forge", "wardens", "lore"];
    for (var _faction_j = 0; _faction_j < array_length(_faction_keys); _faction_j++)
    {
        var _key = _faction_keys[_faction_j];
        var _actual = variable_struct_get(_faction_counts, _key) / _adult_count;
        var _old = variable_struct_get(_civ.faction, _key);
        variable_struct_set(_civ.faction, _key, _old + (_actual - _old) * min(1, _dt * 0.025));
    }

    var _avg_mood = (_mood_count > 0) ? _mood_sum / _mood_count : 40;
    var _food_security = clamp(world_civ_food_days(_w, _civ) / 6.0, 0, 1);
    var _housing_security = clamp(_civ.housing / max(1, _civ.population), 0, 1);
    var _morale_target = _avg_mood * 0.62 + _food_security * 22 + _housing_security * 16 - _civ.infected * 0.4 - _civ.unrest * 9;
    _civ.morale += (_morale_target - _civ.morale) * min(1, _dt * 0.045);
    _civ.morale = clamp(_civ.morale, 0, 100);

    _civ.legitimacy += ((_civ.morale * 0.3 + 35) - _civ.legitimacy) * min(1, _dt * 0.006);
    _civ.stability += ((_civ.morale * 0.4 + _civ.legitimacy * 0.3 + 20) - _civ.stability) * min(1, _dt * 0.005);
    _civ.legitimacy = clamp(_civ.legitimacy, 0, 100);
    _civ.stability = clamp(_civ.stability, 0, 100);

    _civ.priority_timer -= _dt;
    if (_civ.priority_timer <= 0)
    {
        _civ.priority_timer = 4;

        var _housing_gap = max(0, _civ.population - _civ.housing);
        var _food_days = _civ.food / max(0.2, _civ.adults * 0.0045 + _civ.children * 0.0022) / 60;
        var _threat = _w.at_war ? 1 : clamp(array_length(_w.wolves) * 0.16, 0, 0.8);

        if (_food_days < 2.5) _civ.priority = "SURVIVE";
        else if (_w.at_war) _civ.priority = "DEFEND";
        else if (_housing_gap > 2) _civ.priority = "GROW";
        else if (_civ.infected > 2) _civ.priority = "SURVIVE";
        else if (_civ.tech_points > 10 && _civ.tech < 3) _civ.priority = "STUDY";
        else if (world_is_peaceful(_w) && _w.relation > 18) _civ.priority = "TRADE";
        else _civ.priority = "GROW";

        if (_civ.priority != _civ.last_priority)
        {
            _civ.last_priority = _civ.priority;
            show_debug_message("CIVPRIORITY: " + _civ.name + " -> " + _civ.priority);
        }

        // Factions shift on material conditions, not random whim.
        var _hearth = 0.24 + _food_security * 0.3 + _housing_security * 0.1;
        var _forge = 0.18 + (_civ.project != -1 ? 0.2 : 0) + clamp(_civ.wood / 300, 0, 0.2);
        var _wardens = 0.15 + _threat * 0.4 + (_w.at_war ? 0.25 : 0);
        var _lore = 0.12 + clamp(_civ.tech_points / 220, 0, 0.3) + (_civ.tech * 0.03);
        var _total = max(0.1, _hearth + _forge + _wardens + _lore);

        _civ.faction.hearth += (_hearth / _total - _civ.faction.hearth) * 0.08;
        _civ.faction.forge += (_forge / _total - _civ.faction.forge) * 0.08;
        _civ.faction.wardens += (_wardens / _total - _civ.faction.wardens) * 0.08;
        _civ.faction.lore += (_lore / _total - _civ.faction.lore) * 0.08;
    }

    // Consumption and spoilage.
    var _consume = (_civ.adults * 0.0045 + _civ.children * 0.0022) * _w.season_consume;
    _civ.food = max(0, _civ.food - _consume * _dt);

    if (_civ.food > world_civ_food_capacity(_w, _civ.id))
    {
        _civ.food = max(world_civ_food_capacity(_w, _civ.id), _civ.food - _dt * 2.0);
    }

    // Household wealth is taxed, and the treasury can buy grain in a bad season.
    for (var _tax_i = 0; _tax_i < array_length(_w.households); _tax_i++)
    {
        var _tax_house = _w.households[_tax_i];
        if (_tax_house.civ != _civ.id || array_length(_tax_house.members) <= 0) continue;

        var _tax = _tax_house.wealth * 0.00045 * _dt;
        _tax_house.wealth = max(0, _tax_house.wealth - _tax);
        _civ.treasury += _tax;
    }

    if (_civ.food < 4 && _civ.treasury > 24)
    {
        _civ.treasury -= 24;
        _civ.food += 30;
        world_event(_w, _civ.name + " OPENS ITS TREASURY FOR GRAIN.", _w.ui_good, 5, _civ.id);
    }

    if (_civ.food <= 0)
    {
        for (var _i = 0; _i < array_length(_w.humans); _i++)
        {
            var _hungry = _w.humans[_i];
            if (_hungry.dead || _hungry.civ != _civ.id) continue;
            _hungry.hunger = min(1, _hungry.hunger + _dt * 0.004);
            _hungry.mood = max(0, _hungry.mood - _dt * 0.8);
        }
    }

    civ_assign_jobs(_w, _civ, _dt);
    civ_choose_project(_w, _civ, _dt);
    civ_building_effects(_w, _civ, _dt);
    civ_form_pairs(_w, _civ, _dt);
    civ_births(_w, _civ, _dt);
    civ_update_research(_w, _civ, _dt);

    // A leader can die. The office has to pass to someone.
    var _leader = world_find_human(_w, _civ.leader_id);
    if (_leader == noone || _leader.dead)
    {
        civ_choose_leader(_w, _civ);
    }

    civ_politics(_w, _civ, _dt);
};
