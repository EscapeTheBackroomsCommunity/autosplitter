/*
Escape the Backrooms Autosplitter for Update 5 by Reokin
Based on uhara by ru-mii (https://github.com/ru-mii/uhara)

Big thanks to Nikoheart and ru-mii for help!

Version history:
==Verson 3.1==
    Game versions: 5.0+
    Fixed Main Menu not being properly detected in versions 5.3+
    Fixed Controller Restarts not properly pausing the timer
    By RedTuna


==Version 3.0==
    Game versions: 5.0+
    By Reokin

==Version 2.0==
    Game versions: 1.21-4.5
	Fully reworked by theframeburglar

==Version 1.4==
    Game versions: 4.0-4.5
	Variables for 4.0+ found by Reokin
        Thanks to theframeburglar for teaching me how to do it!

==Version 1.3==
    Game versions: 3.0-3.13
==Version 1.2==
    Game versions: 3.0-3.11
==Version 1.1==
    Game versions: 3.0-3.10
	By Permamiss & HeXaGoN
		3.0 - 3.9 variables updated to work with newer versions by theframeburglar

==Version 1.0==
    Game versions: 3.0-3.9
	By Permamiss & HeXaGoN
		isLoading1, wasLoading1 variables found by HeXaGoN
		isLoading2, wasLoading2, multiplayer variables found by Permamiss

	    Shoutouts to Xero for consulting, and to Shad0w & for being our Fancy messenger!

==Version 0.1==
    Game versions: 2.3, 2.9
	By Xero
*/

state("Backrooms-Win64-Shipping") {}
state("Backrooms-WinGDK-Shipping") {}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/uhara10")).CreateInstance("Main");
    vars.Uhara.AlertLoadless();
    vars.Uhara.EnableDebug();

    vars.HasStarted = false;
    vars.HasExited = false;
    vars.Printed = false;
}

init
{

	vars.Events = vars.Uhara.CreateTool("UnrealEngine", "Events");
    vars.Utils = vars.Uhara.CreateTool("UnrealEngine", "Utils");

    vars.Resolver.Watch<ulong>("LoadingStart", vars.Events.FunctionFlag("WB_LoadingScreen_C", "WB_LoadingScreen_C", "PreConstruct"));
    vars.Resolver.Watch<ulong>("LoadingFinish", vars.Events.FunctionFlag("MP_PlayerController_C", "MP_PlayerController_C", "ClientGotoState"));
    vars.Resolver.Watch<ulong>("LoadingEnding", vars.Events.FunctionFlag("", "", "ExecuteUbergraph_BP_ExitZone_GameEnding"));
    vars.Tranisition = vars.Events.InstancePtr("Package", "/Game/Maps/TransitionLevel");
    vars.Resolver.Watch<uint>("GWorldName", vars.Utils.GWorld, 0x18);

    vars.WasEnding = false;
	vars.LoadingState = true;

    current.World = "";
}

start
{
    if (!vars.LoadingState && !vars.HasStarted) {
        vars.HasStarted = true;
        return true;
    }
}

update
{
    vars.Uhara.Update();
    
	var world = vars.Utils.FNameToString(current.GWorldName);
	if (!string.IsNullOrEmpty(world) && world != "None") current.World = world;
    
    IntPtr Tranisition = vars.Resolver.Read<IntPtr>(vars.Tranisition);

	if ((old.LoadingStart != current.LoadingStart) || (Tranisition != IntPtr.Zero)|| (current.World == "MainMenuMap")||(old.LoadingEnding != current.LoadingEnding)) vars.LoadingState = true;
    if (current.World == "MainMenuMap") vars.HasExited = true;
    if ((old.LoadingFinish != current.LoadingFinish) && vars.LoadingState) {
        vars.LoadingState = false;
        vars.HasExited = false;
        vars.WasEnding = false;
    }
    
}

split
{
    if ((old.LoadingStart != current.LoadingStart) && !vars.HasExited) {
        if (vars.WasEnding) {
            vars.WasEnding = false;
            return false;
        }
        return true;
    }
    if (old.LoadingEnding != current.LoadingEnding) {
        vars.WasEnding = true;
        return true;
    }
}

isLoading
{
	return vars.LoadingState;
}

onReset
{
    vars.HasStarted = false;
    vars.HasExited = false;
    vars.WasEnding = false;
	vars.LoadingState = true;
}

exit
{
    vars.HasExited = true;
    vars.WasEnding = false;
    vars.LoadingState = true;
    timer.IsGameTimePaused = true;
}
