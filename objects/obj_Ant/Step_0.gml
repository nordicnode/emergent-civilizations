/// @description Local behavior: nurse, forage from memory or trails, answer alarms, and defend.
if (!instance_exists(obj_World)) exit;

var _world = instance_find(obj_World, 0);
var _dt = min(delta_time / 1000000, 0.05);
if (_dt <= 0) exit;

age += _dt;
if (age >= lifespan)
{
    _world.ant_died(colony, caste, role);
    instance_destroy();
    exit;
}

if (feed_timer > 0) feed_timer = max(0, feed_timer - _dt);
if (flee_timer > 0) flee_timer = max(0, flee_timer - _dt);
if (memory_timer > 0) memory_timer = max(0, memory_timer - _dt);
if (memory_timer <= 0) has_memory = false;

var _home_x = _world.nest_x[colony];
var _home_y = _world.nest_y[colony];
var _home_dist = point_distance(x, y, _home_x, _home_y);

// Workers begin as nurses and graduate to foraging once the brood is covered.
if (caste == ANT_CASTE_WORKER)
{
    if (role == ANT_ROLE_NURSE)
    {
        if (age >= forage_age && _world.nurses[colony] > max(5, array_length(_world.brood[colony]) + 1))
        {
            role = ANT_ROLE_FORAGER;
            _world.nurses[colony] -= 1;
            speed_value = _world.colony_speed[colony] * random_range(0.92, 1.08);
            heading = random(360);
        }
    }
    else if (role == ANT_ROLE_FORAGER)
    {
        // A brood emergency can pull a young forager back inside.
        if (age < 120
            && array_length(_world.brood[colony]) > _world.nurses[colony] * 2
            && _world.nurses[colony] < 6
            && random(1) < _dt * 0.005)
        {
            role = ANT_ROLE_NURSE;
            _world.nurses[colony] += 1;
            speed_value = _world.colony_speed[colony] * 0.72 * random_range(0.92, 1.08);
            heading = point_direction(x, y, _home_x, _home_y);
        }
    }
}

if (_home_dist < 70 && hp < max_hp)
{
    hp = min(max_hp, hp + _dt * 0.02);
}

// Local threat scan. One pass provides both the nearest enemy and the odds nearby.
scan_timer -= _dt;
var _enemy = noone;
var _enemy_dist = 999;
var _allies = 0;
var _enemies = 0;

if (scan_timer <= 0)
{
    scan_timer = random_range(0.4, 0.8);

    var _scan_radius = (caste == ANT_CASTE_SOLDIER) ? 120 : ((role == ANT_ROLE_FORAGER) ? 80 : 35);
    var _count = instance_number(obj_Ant);

    for (var _other_i = 0; _other_i < _count; _other_i++)
    {
        var _other = instance_find(obj_Ant, _other_i);
        if (_other == id) continue;

        var _other_dist = point_distance(x, y, _other.x, _other.y);

        if (_other.colony == colony)
        {
            if (_other_dist < 85) _allies += 1;
        }
        else if (_other_dist < _scan_radius)
        {
            _enemies += 1;
            if (_other_dist < _enemy_dist)
            {
                _enemy_dist = _other_dist;
                _enemy = _other;
            }
        }
    }

    if (_enemy != noone)
    {
        _world.raise_alarm(colony, x, y, (caste == ANT_CASTE_SOLDIER) ? 1.0 : 0.7);
    }
}

var _alarm_grid = _world.alarm_grids[colony];
var _alarm_here = ph_sample(_alarm_grid, x, y);

if (role == ANT_ROLE_NURSE)
{
    if (_enemy != noone && _enemy_dist < 30)
    {
        heading += angle_difference(point_direction(_enemy.x, _enemy.y, x, y), heading) * min(1, _dt * 5);
        _world.raise_alarm(colony, x, y, 0.4);
    }
    else if (_home_dist > 110)
    {
        heading += angle_difference(point_direction(x, y, _home_x, _home_y), heading) * min(1, _dt * 4);
    }
    else
    {
        var _brood = _world.brood[colony];
        var _target = -1;
        var _target_dist = 999;

        for (var _brood_i = 0; _brood_i < array_length(_brood); _brood_i++)
        {
            var _item = _brood[_brood_i];
            if (_item.stage != BROOD_LARVA) continue;

            var _item_dist = point_distance(x, y, _item.x, _item.y);
            if (_item_dist < 130 && _item_dist < _target_dist)
            {
                _target_dist = _item_dist;
                _target = _brood_i;
            }
        }

        if (_target >= 0)
        {
            var _larva = _brood[_target];
            var _larva_dist = point_distance(x, y, _larva.x, _larva.y);

            if (_larva_dist > 24)
            {
                heading += angle_difference(point_direction(x, y, _larva.x, _larva.y), heading) * min(1, _dt * 5);
            }
            else
            {
                if (feed_timer <= 0 && _world.stores[colony] >= _world.feed_cost && _larva.hunger > 0.20)
                {
                    _world.stores[colony] -= _world.feed_cost;
                    _larva.hunger = max(0, _larva.hunger - 0.45);
                    _larva.feeds += 1;
                    feed_timer = 2.2;
                }

                wander_timer -= _dt;
                if (wander_timer <= 0)
                {
                    wander_timer = random_range(0.8, 1.6);
                    heading += random_range(-25, 25);
                }
            }
        }
        else
        {
            wander_timer -= _dt;
            if (wander_timer <= 0)
            {
                wander_timer = random_range(0.8, 1.6);
                heading += random_range(-30, 30);
            }
        }
    }
}
else
{
    var _busy = false;

    if (flee_timer > 0)
    {
        heading += angle_difference(point_direction(x, y, _home_x, _home_y), heading) * min(1, _dt * 5);
        _busy = true;
    }
    else if (_enemy != noone)
    {
        var _defender = (role == ANT_ROLE_SOLDIER) || (role == ANT_ROLE_FORAGER && _home_dist < 130);

        if (_defender)
        {
            if (role == ANT_ROLE_SOLDIER && _enemies > _allies + 2 && hp < max_hp * 0.6)
            {
                flee_timer = 1.0;
                heading = point_direction(_enemy.x, _enemy.y, x, y);
            }
            else
            {
                heading = point_direction(x, y, _enemy.x, _enemy.y);

                if (_enemy_dist < 16 && fight_timer <= 0)
                {
                    fight_timer = random_range(1.2, 2.0);

                    var _my_power = ((caste == ANT_CASTE_SOLDIER) ? 1.7 : 0.55) * _world.colony_strength[colony];
                    var _their_power = ((_enemy.caste == ANT_CASTE_SOLDIER) ? 1.7 : 0.55) * _world.colony_strength[_enemy.colony];

                    _enemy.hp -= _my_power * random_range(0.18, 0.28);
                    _world.raise_alarm(colony, x, y, 2.0);
                    _world.raise_alarm(_enemy.colony, _enemy.x, _enemy.y, 1.0);

                    if (_enemy.hp <= 0)
                    {
                        if (_enemy.carrying) _world.drop_food(_enemy.x, _enemy.y);

                        var _enemy_colony = _enemy.colony;
                        var _enemy_caste = _enemy.caste;
                        var _enemy_role = _enemy.role;

                        _world.ant_died(_enemy_colony, _enemy_caste, _enemy_role);
                        _world.report_battle(colony);
                        instance_destroy(_enemy);
                    }
                    else
                    {
                        _enemy.flee_timer = max(_enemy.flee_timer, 1.0);
                        _enemy.heading = point_direction(x, y, _enemy.x, _enemy.y);

                        hp -= _their_power * random_range(0.04, 0.10);

                        if (hp <= 0)
                        {
                            if (carrying) _world.drop_food(x, y);
                            _world.ant_died(colony, caste, role);
                            instance_destroy();
                            exit;
                        }
                    }
                }
            }
        }
        else
        {
            // A forager away from home avoids the fight, but a carrier keeps running for the nest.
            if (carrying)
            {
                heading += angle_difference(point_direction(x, y, _home_x, _home_y), heading) * min(1, _dt * 6);
            }
            else
            {
                heading += angle_difference(point_direction(_enemy.x, _enemy.y, x, y), heading) * min(1, _dt * 5);
            }

            flee_timer = max(flee_timer, 0.6);
        }

        _busy = true;
    }
    else if (role == ANT_ROLE_FORAGER && _alarm_here > 0.25 && _home_dist > 120 && !carrying)
    {
        flee_timer = max(flee_timer, 0.5);
        heading += angle_difference(point_direction(x, y, _home_x, _home_y), heading) * min(1, _dt * 5);
        _busy = true;
    }
    else if (role == ANT_ROLE_SOLDIER && (_world.alarm_level[colony] > 0.08 || _alarm_here > 0.05))
    {
        var _alert_x = _world.alarm_source_x[colony];
        var _alert_y = _world.alarm_source_y[colony];
        var _alert_dist = point_distance(x, y, _alert_x, _alert_y);

        if (_alert_dist > 40)
        {
            heading += angle_difference(point_direction(x, y, _alert_x, _alert_y), heading) * min(1, _dt * 4);
        }
        else
        {
            var _alert_angle = ph_gradient_angle(_alarm_grid, x, y, heading, 26);
            var _alert_ahead = ph_sample(
                _alarm_grid,
                x + lengthdir_x(26, _alert_angle),
                y + lengthdir_y(26, _alert_angle)
            );

            if (_alert_ahead > 0.05)
            {
                heading += angle_difference(_alert_angle, heading) * min(1, _dt * 5);
            }
        }

        _busy = true;
    }

    if (!_busy && role == ANT_ROLE_FORAGER)
    {
        if (mode == ANT_RETURN)
        {
            heading += angle_difference(point_direction(x, y, _home_x, _home_y), heading) * min(1, _dt * 6);

            var _grid = _world.pheromones[colony];
            var _cell = ph_index(x, y);
            _grid[_cell] = min(55, _grid[_cell] + 6 * _dt * recruiter);

            if (_home_dist < 16)
            {
                mode = ANT_SEARCH;
                carrying = false;
                _world.stores[colony] += _world.food_gain;
                _world.harvested[colony] += _world.food_gain;

                if (has_memory && memory_timer > 0)
                {
                    heading = point_direction(x, y, memory_x, memory_y);
                }
                else
                {
                    heading = random(360);
                }
            }
        }
        else
        {
            if (has_memory && memory_timer > 0)
            {
                var _memory_dist = point_distance(x, y, memory_x, memory_y);

                if (_memory_dist > 26)
                {
                    heading += angle_difference(point_direction(x, y, memory_x, memory_y), heading) * min(1, _dt * 4);
                }
                else
                {
                    memory_fail += _dt;
                    if (memory_fail > 4)
                    {
                        has_memory = false;
                        memory_timer = 0;
                    }

                    wander_timer -= _dt;
                    if (wander_timer <= 0)
                    {
                        wander_timer = random_range(0.6, 1.4);
                        heading += random_range(-60, 60);
                    }
                }
            }
            else
            {
                // Non-recruiters are scouts: they ignore trails and search new ground.
                if (recruiter > 0)
                {
                    var _grid = _world.pheromones[colony];
                    var _trail = ph_gradient_angle(_grid, x, y, heading, 20);
                    var _trail_ahead = ph_sample(
                        _grid,
                        x + lengthdir_x(20, _trail),
                        y + lengthdir_y(20, _trail)
                    );

                    if (_trail_ahead > 0.12)
                    {
                        heading += angle_difference(_trail, heading) * min(1, _dt * 4);
                    }
                }

                wander_timer -= _dt;
                if (wander_timer <= 0)
                {
                    wander_timer = random_range(0.5, 1.4);
                    heading += random_range(-70, 70);
                }
            }

            if (_home_dist < 55)
            {
                var _away = point_direction(_home_x, _home_y, x, y);
                heading += angle_difference(_away, heading) * min(1, _dt * 2);
            }

            var _food = instance_nearest(x, y, obj_Food);
            if (_food != noone && point_distance(x, y, _food.x, _food.y) < 7)
            {
                _world.report_food_found(colony);
                memory_x = _food.x;
                memory_y = _food.y;
                memory_timer = 90;
                memory_fail = 0;
                has_memory = true;

                instance_destroy(_food);
                carrying = true;
                mode = ANT_RETURN;
                heading = point_direction(x, y, _home_x, _home_y);
            }
        }
    }
    else if (!_busy && role == ANT_ROLE_SOLDIER)
    {
        if (_home_dist > 115)
        {
            heading += angle_difference(point_direction(x, y, _home_x, _home_y), heading) * min(1, _dt * 3);
        }
        else
        {
            wander_timer -= _dt;
            if (wander_timer <= 0)
            {
                wander_timer = random_range(0.8, 1.8);
                heading += random_range(-40, 40);
            }

            if (_home_dist < 55)
            {
                var _away = point_direction(_home_x, _home_y, x, y);
                heading += angle_difference(_away, heading) * min(1, _dt * 1.5);
            }
        }
    }
}

x += lengthdir_x(speed_value, heading) * _dt;
y += lengthdir_y(speed_value, heading) * _dt;

if (x < 12) { x = 12; heading = 180 - heading; heading += random_range(-20, 20); }
if (x > room_width - 12) { x = room_width - 12; heading = 180 - heading; heading += random_range(-20, 20); }
if (y < 12) { y = 12; heading = -heading; heading += random_range(-20, 20); }
if (y > room_height - 12) { y = room_height - 12; heading = -heading; heading += random_range(-20, 20); }
