
local Clockwork = Clockwork;

local COMMAND = Clockwork.command:New("PlaySound");
COMMAND.tip = "Plays a sound to all players.";
COMMAND.text = "<string SoundPath> [string SoundPaths]";
COMMAND.access = "s";
COMMAND.arguments = 1;
COMMAND.optionalArguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	Clockwork.datastream:Start(nil, "play_sound", arguments);
end;

COMMAND:Register();