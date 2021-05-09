--[[
	© 2014 TeslaCloud Studios.
	Feel free to use, edit or share the plugin, but
	do not re-distribute without the permission of it's author.
--]]

local COMMAND = Clockwork.command:New("ApplySay");
COMMAND.tip = "Says your Name and CID informally.";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player)
	local CitizenID = player:GetSharedVar("cid");
	local name = player:Name();
    local radius = Clockwork.config:Get("talk_radius"):Get();
    
	if (!Schema:PlayerIsCombine(player)) then
		Clockwork.chatBox:AddInTargetRadius(player, "ic", "Меня зовут "..name..", и мой CID #"..CitizenID..".", player:GetPos(), radius);	
    else
        Clockwork.player:Notify(player, "У вас нет CID. Используйте /name");
    end;

	for k, v in pairs(_player.GetAll()) do
	    if (v:GetPos():Distance(player:GetPos()) <= radius 
		and Clockwork.config:Get("apply_recognise_enable"):Get() 
		and IsValid(v) and v:HasInitialized()) then
			Clockwork.player:SetRecognises(v, player, RECOGNISE_TOTAL);
		end;
	end;
end;

COMMAND:Register();