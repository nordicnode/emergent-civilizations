/// @description Build the two civilizations, their people and the shared world.
try
{
    world_init(self);
}
catch (_exception)
{
    show_debug_message("INIT ERROR: " + _exception.message);
    show_debug_message("INIT LONG: " + _exception.longMessage);
    show_debug_message("INIT SCRIPT: " + _exception.script);
    show_debug_message("INIT STACK: " + string(_exception.stacktrace));
}
