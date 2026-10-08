var mx = keyboard_check(ord("D")) - keyboard_check(ord("A"));
var my = keyboard_check(ord("S")) - keyboard_check(ord("W"));

if (mx != 0 || my != 0)
{
    var len = point_distance(0,0,mx,my);

    mx /= len;
    my /= len;

    x += mx * vel;
    y += my * vel;
}

if (!place_meeting(x + mx * vel, y, Obj_pared))
{
    x += mx * vel;
}

if (!place_meeting(x, y + my * vel, Obj_pared))
{
    y += my * vel;
}

if (!place_meeting(x + mx * vel, y, Obj_reja))
{
    x += mx * vel;
}

if (!place_meeting(x, y + my * vel, Obj_reja))
{
    y += my * vel;
}