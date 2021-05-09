
local PLUGIN = PLUGIN;
local Clockwork = Clockwork;

-- Called when a player's default skin is needed
function PLUGIN:GetPlayerDefaultSkin(player)
	-- Check for a player-adjustable skin first
	local toggleSkin = player:GetCharacterData("toggle_skin", {});
	toggleSkin = toggleSkin[player:GetModel()];
	if (toggleSkin) then
		return toggleSkin;
	end;
	-- Check for a personal skin
	local skin = player:GetCharacterData("skins", {});
	skin = skin[player:GetModel()];
	if (skin) then
		return skin;
	end;
	-- Check for a skin
	local skinq = player:GetCharacterData("Skin", {});
	skinq = skinq[player:GetModel()];
	if (skinq) then
		return skinq;
	end;
	-- Check for a class skin
	local class = Clockwork.class:FindByID(player:Team());
	if (class and class.skin) then
		return class.skin;
	end;
	-- Check for a faction skin
	local faction = Clockwork.faction:FindByID(player:GetFaction());
	if (faction and faction.skin) then
		return faction.skin;
	end;
	-- No skin found so return nothing
end;

function PLUGIN:PostPlayerSpawn(player, lightSpawn, changeClass, firstSpawn)
	if (firstSpawn) then
		local bodygroups = player:GetCharacterData("bgs", {});
		for k, v in pairs(bodygroups) do
			if (bodygroups[k]) then
				for k1, v1 in pairs(bodygroups[k]) do
					if (type(k1) != "string") then
						bodygroups[k][k1] = nil;
					end;
				end;
			end;
		end;
		local bodygroupsq = player:GetCharacterData("BodyGroups", {});
		for k, v in pairs(bodygroupsq) do
			if (bodygroupsq[k]) then
				for k1, v1 in pairs(bodygroupsq[k]) do
					if (type(k1) != "string") then
						bodygroupsq[k][k1] = nil;
					end;
				end;
			end;
		end;
		local toggle_groups = player:GetCharacterData("toggle_bodygroup", {});
		for k, v in pairs(toggle_groups) do
			if (toggle_groups[k]) then
				for k1, v1 in pairs(toggle_groups[k]) do
					if (type(k1) != "string") then
						toggle_groups[k][k1] = nil;
					end;
				end;
			end;
		end;
	end;

	player:SetBodyGroups();
	player:SetPlayerScale();
end;

-- Called when the player's model has been changed
function PLUGIN:PlayerModelChanged(player, model)
	player:SetBodyGroups();
	player:SetPlayerScale();
end;