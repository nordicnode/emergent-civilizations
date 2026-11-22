/// @description Draw the ant by caste, with a visible food load.
draw_set_colour(colour);
draw_set_alpha((role == ANT_ROLE_NURSE) ? 0.78 : 1);

if (role == ANT_ROLE_SOLDIER)
{
    draw_circle(x, y, 3, false);
    draw_set_colour(make_colour_rgb(255, 238, 200));
    draw_circle(x, y, 1, false);
    draw_set_colour(colour);
}
else if (role == ANT_ROLE_NURSE)
{
    draw_circle(x, y, 1.6, false);
}
else
{
    draw_circle(x, y, 2, false);
}

if (carrying)
{
    draw_set_colour(c_lime);
    draw_circle(x - lengthdir_x(2, heading), y - lengthdir_y(2, heading), 1, false);
}

draw_set_alpha(1);
draw_set_colour(c_white);
