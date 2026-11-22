#macro UI_GLYPH_W 16
#macro UI_GLYPH_H 16
#macro UI_GLYPH_COLS 16
#macro UI_GLYPH_FIRST 32
#macro UI_GLYPH_LAST 126

// The atlas is an 8x8 bitmap font expanded 2x for crisp world glyphs.
// UI text is drawn at its native size, so the dossier reads as a terminal
// rather than an oversized poster.
#macro UI_TEXT_SCALE 0.5
#macro UI_LINE_H 14
#macro UI_ROW_H 14
#macro UI_ROW_H_BAR 18
#macro UI_ROW_GAP 22
#macro UI_SECTION_H 30
#macro UI_SECTION_RULE 22
#macro UI_GAP_SMALL 6
#macro UI_GAP_TINY 2
#macro UI_GAP_TIES 12

#macro UI_PERSON_X 0
#macro UI_PERSON_Y 0
#macro UI_PERSON_W 1920
#macro UI_PERSON_H 1080
#macro UI_PERSON_PAD 40
#macro UI_PERSON_PAGES 7
#macro UI_PERSON_TAB_Y 78
#macro UI_PERSON_TAB_H 30
#macro UI_PERSON_CLOSE_Y 24
#macro UI_PERSON_CLOSE_W 224
#macro UI_PERSON_CLOSE_H 32

#macro UI_ZOOM_MIN 1
#macro UI_ZOOM_MAX 8
#macro UI_ZOOM_STEP 1.25
#macro UI_PAN_SPEED 900

/// @description Draw pixel text from the ASCII atlas.
function ui_text(_x, _y, _text, _colour, _scale)
{
    var _length = string_length(_text);
    var _draw_scale = _scale * UI_TEXT_SCALE;

    for (var _i = 1; _i <= _length; _i++)
    {
        var _code = ord(string_char_at(_text, _i));
        if (_code < UI_GLYPH_FIRST || _code > UI_GLYPH_LAST) _code = 63;
        ui_glyph(_x + (_i - 1) * UI_GLYPH_W * _draw_scale, _y, _code, _colour, _draw_scale);
    }
}

/// @description Section heading and rule inside the dossier.
function ui_section(_x, _y, _w, _text, _text_colour, _line_colour)
{
    ui_text(_x, _y, _text, _text_colour, 2);
    draw_set_alpha(0.55);
    draw_set_colour(_line_colour);
    draw_line(_x, _y + UI_SECTION_RULE, _x + _w, _y + UI_SECTION_RULE);
    draw_set_alpha(1);
}

/// @description Draw one glyph cell from the font atlas.
function ui_glyph(_x, _y, _code, _colour, _scale)
{
    _code = clamp(_code, 0, 255);
    var _cell_x = (_code mod UI_GLYPH_COLS) * UI_GLYPH_W;
    var _cell_y = (_code div UI_GLYPH_COLS) * UI_GLYPH_H;

    draw_sprite_part_ext(
        spr_df_font,
        0,
        _cell_x,
        _cell_y,
        UI_GLYPH_W,
        UI_GLYPH_H,
        _x,
        _y,
        _scale,
        _scale,
        _colour,
        draw_get_alpha()
    );
}

/// @description Draw one glyph centred on a world point.
function ui_glyph_centred(_x, _y, _code, _colour, _scale)
{
    ui_glyph(
        _x - UI_GLYPH_W * _scale / 2,
        _y - UI_GLYPH_H * _scale / 2,
        _code,
        _colour,
        _scale
    );
}

/// @description Width of text at the given scale.
function ui_text_width(_text, _scale)
{
    return string_length(_text) * UI_GLYPH_W * _scale * UI_TEXT_SCALE;
}

/// @description Draw text with its right edge at _x.
function ui_text_right(_x, _y, _text, _colour, _scale)
{
    ui_text(_x - ui_text_width(_text, _scale), _y, _text, _colour, _scale);
}

/// @description Draw text centred on _x.
function ui_text_centred(_x, _y, _text, _colour, _scale)
{
    ui_text(_x - ui_text_width(_text, _scale) / 2, _y, _text, _colour, _scale);
}

/// @description Trim text to a character budget, with a visible cut mark.
function ui_fit(_text, _max_chars)
{
    if (_max_chars <= 2) return "";
    if (string_length(_text) <= _max_chars) return _text;
    return string_copy(_text, 1, _max_chars - 2) + "..";
}

/// @description Compact elapsed-time label for the dossier.
function ui_clock(_seconds)
{
    if (_seconds < 60) return string(floor(_seconds)) + "S";
    return string(floor(_seconds / 60)) + "M";
}

/// @description Full-width labelled meter for a character-page column.
function ui_bar_row(_x, _y, _w, _label, _value, _colour, _label_colour)
{
    ui_text(_x, _y, _label, _label_colour, 1);
    ui_text_right(_x + _w, _y, string(round(clamp(_value, 0, 1) * 100)), _colour, 1);
    ui_meter(_x, _y + 12, _w, clamp(_value, 0, 1), _colour);
}

/// @description Compact labelled meter for the dossier's two-column rows.
function ui_metric(_x, _y, _label, _value, _colour, _label_colour)
{
    ui_text(_x, _y, _label, _label_colour, 1);
    ui_meter(_x + 140, _y + 6, 48, _value, _colour);
    ui_text_right(_x + 228, _y, string(round(clamp(_value, 0, 1) * 100)), _colour, 1);
}

/// @description Draw wrapped text and return how many lines were used.
function ui_text_wrapped(_x, _y, _text, _colour, _max_chars, _max_lines, _line_height)
{
    var _remaining = _text;
    var _line = 0;

    while (string_length(_remaining) > 0 && _line < _max_lines)
    {
        var _cut = min(_max_chars, string_length(_remaining));

        if (_cut < string_length(_remaining))
        {
            var _scan = _cut;
            while (_scan > 1 && string_char_at(_remaining, _scan) != " ")
            {
                _scan -= 1;
            }
            if (_scan > 1) _cut = _scan;
        }

        ui_text(_x, _y + _line * _line_height, string_copy(_remaining, 1, _cut), _colour, 1);
        _remaining = string_delete(_remaining, 1, _cut);
        while (string_length(_remaining) > 0 && string_char_at(_remaining, 1) == " ")
        {
            _remaining = string_delete(_remaining, 1, 1);
        }
        _line += 1;
    }

    return _line;
}

/// @description One label/value row for the dossier.
function ui_key_value(_x, _y, _label, _value, _label_colour, _value_colour, _value_chars)
{
    ui_text(_x, _y, _label, _label_colour, 1);
    ui_text(_x + 96, _y, ui_fit(_value, min(_value_chars, 48)), _value_colour, 1);
}

/// @description A flat four-pixel meter used by the person panel.
function ui_meter(_x, _y, _w, _value, _colour)
{
    draw_set_alpha(0.16);
    draw_set_colour(c_white);
    draw_rectangle(_x, _y, _x + _w, _y + 3, false);

    draw_set_alpha(1);
    draw_set_colour(_colour);
    draw_rectangle(_x, _y, _x + _w * clamp(_value, 0, 1), _y + 3, false);
}

/// @description Current zoom as short display text, e.g. "1.25X".
function ui_zoom_text()
{
    return string(round(global.game_zoom * 100) / 100) + "X";
}

/// @description Clamp and apply the current camera state.
function ui_camera_apply()
{
    var _view_w = room_width / global.game_zoom;
    var _view_h = room_height / global.game_zoom;

    global.cam_x = clamp(global.cam_x, 0, max(0, room_width - _view_w));
    global.cam_y = clamp(global.cam_y, 0, max(0, room_height - _view_h));

    camera_set_view_size(global.game_camera, _view_w, _view_h);
    camera_set_view_pos(global.game_camera, global.cam_x, global.cam_y);
}

/// @description Pan the camera by a screen-space distance.
function ui_pan_screen(_dx_screen, _dy_screen)
{
    if (global.game_zoom <= UI_ZOOM_MIN) return;

    global.cam_x -= _dx_screen / global.game_zoom;
    global.cam_y -= _dy_screen / global.game_zoom;
    ui_camera_apply();
}

/// @description Zoom the world camera around a point in the GUI layer.
function ui_zoom_set(_new_zoom, _screen_x, _screen_y)
{
    _new_zoom = clamp(_new_zoom, UI_ZOOM_MIN, UI_ZOOM_MAX);
    if (abs(_new_zoom - global.game_zoom) < 0.001) return;

    var _world_x = global.cam_x + _screen_x / global.game_zoom;
    var _world_y = global.cam_y + _screen_y / global.game_zoom;

    global.game_zoom = _new_zoom;
    global.cam_x = _world_x - _screen_x / _new_zoom;
    global.cam_y = _world_y - _screen_y / _new_zoom;
    ui_camera_apply();

    // A short readout confirms the zoom without adding permanent HUD chrome.
    global.zoom_feedback = 1.1;
}
