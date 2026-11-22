/// @description Selection, dossier navigation, camera and passive simulation controls.
var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);
var _real_dt = min(delta_time / 1000000, 0.05);

if (global.zoom_feedback > 0)
{
    global.zoom_feedback = max(0, global.zoom_feedback - _real_dt);
}

var _dossier = (global.selected_id != -1);
var _ui_click = false;

// A selected person can die or be removed while the page is open.
if (_dossier)
{
    var _selected = world_find_human(self, global.selected_id);
    if (_selected == noone || _selected.dead)
    {
        global.selected_id = -1;
        global.pan_active = false;
        _dossier = false;
    }
}

if (_dossier)
{
    // Escape closes the page. Q / E and the wheel turn pages.
    if (keyboard_check_pressed(vk_escape))
    {
        global.selected_id = -1;
        _dossier = false;
    }

    if (_dossier)
    {
        if (keyboard_check_pressed(ord("Q"))) global.panel_page = (global.panel_page + UI_PERSON_PAGES - 1) mod UI_PERSON_PAGES;
        if (keyboard_check_pressed(ord("E"))) global.panel_page = (global.panel_page + 1) mod UI_PERSON_PAGES;

        if (mouse_wheel_up()) global.panel_page = (global.panel_page + UI_PERSON_PAGES - 1) mod UI_PERSON_PAGES;
        if (mouse_wheel_down()) global.panel_page = (global.panel_page + 1) mod UI_PERSON_PAGES;

        if (device_mouse_check_button_pressed(0, mb_left))
        {
            _ui_click = true;
            var _close_left = UI_PERSON_W - UI_PERSON_PAD - UI_PERSON_CLOSE_W;

            if (_mx >= _close_left && _mx <= _close_left + UI_PERSON_CLOSE_W
                && _my >= UI_PERSON_CLOSE_Y && _my <= UI_PERSON_CLOSE_Y + UI_PERSON_CLOSE_H)
            {
                global.selected_id = -1;
                _dossier = false;
            }
            else if (_my >= UI_PERSON_TAB_Y && _my <= UI_PERSON_TAB_Y + UI_PERSON_TAB_H)
            {
                var _tab_area = UI_PERSON_W - UI_PERSON_PAD * 2;
                var _tab_index = floor((_mx - UI_PERSON_PAD) / (_tab_area / UI_PERSON_PAGES));
                if (_tab_index >= 0 && _tab_index < UI_PERSON_PAGES) global.panel_page = _tab_index;
            }
        }
    }
}

if (!_dossier)
{
    // Camera zoom: mouse wheel or the main-row +/- keys, centred on the pointer.
    if (mouse_wheel_up()) ui_zoom_set(global.game_zoom * UI_ZOOM_STEP, _mx, _my);
    if (mouse_wheel_down()) ui_zoom_set(global.game_zoom / UI_ZOOM_STEP, _mx, _my);
    if (keyboard_check_pressed(ord("="))) ui_zoom_set(global.game_zoom * UI_ZOOM_STEP, _mx, _my);
    if (keyboard_check_pressed(ord("-"))) ui_zoom_set(global.game_zoom / UI_ZOOM_STEP, _mx, _my);

    // Drag panning with the middle or right mouse button.
    if (device_mouse_check_button_pressed(0, mb_middle) || device_mouse_check_button_pressed(0, mb_right))
    {
        global.pan_active = true;
        global.pan_anchor_x = _mx;
        global.pan_anchor_y = _my;
        global.pan_origin_x = global.cam_x;
        global.pan_origin_y = global.cam_y;
    }

    if (global.pan_active)
    {
        if (device_mouse_check_button(0, mb_middle) || device_mouse_check_button(0, mb_right))
        {
            if (global.game_zoom > UI_ZOOM_MIN)
            {
                global.cam_x = global.pan_origin_x - (_mx - global.pan_anchor_x) / global.game_zoom;
                global.cam_y = global.pan_origin_y - (_my - global.pan_anchor_y) / global.game_zoom;
                ui_camera_apply();
            }
        }
        else
        {
            global.pan_active = false;
        }
    }

    // Arrow keys or WASD pan at a constant on-screen speed.
    var _pan_x = 0;
    var _pan_y = 0;
    if (keyboard_check(vk_right) || keyboard_check(ord("D"))) _pan_x += 1;
    if (keyboard_check(vk_left) || keyboard_check(ord("A"))) _pan_x -= 1;
    if (keyboard_check(vk_down) || keyboard_check(ord("S"))) _pan_y += 1;
    if (keyboard_check(vk_up) || keyboard_check(ord("W"))) _pan_y -= 1;

    if (_pan_x != 0 || _pan_y != 0)
    {
        var _pan_step = UI_PAN_SPEED * _real_dt;
        ui_pan_screen(-_pan_x * _pan_step, -_pan_y * _pan_step);
    }

    // Left click selects the nearest person under the cursor.
    if (!global.pan_active && !_ui_click && device_mouse_check_button_pressed(0, mb_left))
    {
        var _wx = global.cam_x + _mx / global.game_zoom;
        var _wy = global.cam_y + _my / global.game_zoom;
        var _pick = 14;
        var _best_id = -1;
        var _best_dist = _pick;

        for (var _i = 0; _i < array_length(humans); _i++)
        {
            var _person = humans[_i];
            if (_person.dead) continue;

            var _dist = point_distance(_wx, _wy, _person.x, _person.y);
            if (_dist < _best_dist)
            {
                _best_dist = _dist;
                _best_id = _person.id;
            }
        }

        global.selected_id = _best_id;
        global.panel_page = 0;
        global.pan_active = false;
    }
}

// The dossier is a paused reading view: opening it freezes the colony, and
// closing it restores whatever pause state the observer had beforehand.
var _dossier_now = (global.selected_id != -1);

if (_dossier_now && !global.dossier_open)
{
    global.game_paused_before_dossier = global.game_paused;
}

if (_dossier_now)
{
    global.game_paused = true;
}
else if (global.dossier_open)
{
    global.game_paused = global.game_paused_before_dossier;
}

global.dossier_open = _dossier_now;

// Hidden observation-speed shortcuts stay inactive while the page is open.
if (!_dossier_now)
{
    if (keyboard_check_pressed(vk_space)) global.game_paused = !global.game_paused;
    if (keyboard_check_pressed(ord("1"))) { global.game_speed = 1; global.game_paused = false; }
    if (keyboard_check_pressed(ord("2"))) { global.game_speed = 2; global.game_paused = false; }
    if (keyboard_check_pressed(ord("3"))) { global.game_speed = 4; global.game_paused = false; }
    if (keyboard_check_pressed(ord("4"))) { global.game_speed = 8; global.game_paused = false; }
}

var _steps = global.game_paused ? 0 : global.game_speed;
var _dt = min(delta_time / 1000000, 0.05);

for (var _step = 0; _step < _steps; _step++)
{
    world_update(self, _dt);
}
