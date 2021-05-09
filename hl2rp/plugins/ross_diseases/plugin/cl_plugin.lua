
local PLUGIN = PLUGIN;

function PLUGIN:PlayerEyeDisease()
	
    local tab = {
    	["pp_colormod"]	= 1,
	    ["pp_colormod_addb"] = 0,
    	["pp_colormod_addg"] = 0,
	    ["pp_colormod_addr"] =	0,
	    ["pp_colormod_brightness"] = -20,
    	["pp_colormod_color"] = 0.000000,
	    ["pp_colormod_contrast"] = -5,
    	["pp_colormod_mulb"] = 0,
	    ["pp_colormod_mulg"] = 0,
    	["pp_colormod_mulr"] = 0
    };
	DrawColorModify(tab);
end;

function PLUGIN:HUDPaint()
	if Clockwork.Client:GetSharedVar("Eyeache") then
		self:PlayerEyeDisease()
	end;
end;
