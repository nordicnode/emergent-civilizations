/// Pheromone grid helpers shared by the ants and the world.

#macro PH_CELL 16
#macro PH_W 120
#macro PH_H 68
#macro PH_COUNT (PH_W * PH_H)

#macro ANT_SEARCH 0
#macro ANT_RETURN 1

#macro ANT_CASTE_WORKER 0
#macro ANT_CASTE_SOLDIER 1

#macro ANT_ROLE_NURSE 0
#macro ANT_ROLE_FORAGER 1
#macro ANT_ROLE_SOLDIER 2

#macro BROOD_EGG 0
#macro BROOD_LARVA 1
#macro BROOD_PUPA 2

function ph_index(_px, _py)
{
    var _cx = clamp(floor(_px / PH_CELL), 0, PH_W - 1);
    var _cy = clamp(floor(_py / PH_CELL), 0, PH_H - 1);
    return _cy * PH_W + _cx;
}

function ph_sample(_grid, _px, _py)
{
    return _grid[ph_index(_px, _py)];
}

function ph_gradient_angle(_grid, _px, _py, _angle, _reach)
{
    var _best_angle = _angle;
    var _best = 0;

    for (var _side = -1; _side <= 1; _side++)
    {
        var _a = _angle + _side * 42;
        var _sx = _px + lengthdir_x(_reach, _a);
        var _sy = _py + lengthdir_y(_reach, _a);

        if (_sx < 0 || _sx >= room_width || _sy < 0 || _sy >= room_height) continue;

        var _value = ph_sample(_grid, _sx, _sy);
        if (_value > _best)
        {
            _best = _value;
            _best_angle = _a;
        }
    }

    return _best_angle;
}
