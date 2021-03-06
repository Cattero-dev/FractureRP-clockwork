
local PLUGIN = PLUGIN;

local frptext = surface.GetTextureID( 'poing' );

function Schema:AddCombineDisplayLine(text, color)
	if (self:PlayerIsCombine(Clockwork.Client)) then
		if (!self.combineDisplayLines) then
			self.combineDisplayLines = {};
		end;
		if Clockwork.Client:GasmaskInfo() > 0 then
			surface.PlaySound('buttons/button16.wav');
		end;
		table.insert(self.combineDisplayLines, {"<:: "..T(text), CurTime() + 70, 6, color});
	end;
end;

function Schema:HUDPaintTopScreen(info)
	local blackFadeAlpha = Clockwork.kernel:GetBlackFadeAlpha();
	local colorWhite = Clockwork.option:GetColor("white");
	local curTime = CurTime();
	local p = Clockwork.Client
	
	if (self:PlayerIsCombine(p) && self.combineDisplayLines && p:GasmaskInfo() > 0) then
		local height = draw.GetFontHeight("BudgetLabel");
		
		for k, v in ipairs(self.combineDisplayLines) do
			if (curTime >= v[2]) then
				table.remove(self.combineDisplayLines, k);
			else
				local color = v[4] or colorWhite;
				local textColor = Color(color.r, color.g, color.b, 255 - blackFadeAlpha);
				
				draw.SimpleText(utf8.sub(v[1], 1, v[3]), "BudgetLabel", info.x, info.y, textColor);
				
				if (v[3] < utf8.len(v[1])) then
					v[3] = v[3] + 1;
				end;
				
				info.y = info.y + height;
			end;
		end;
	end;
end;

function Schema:RenderScreenspaceEffects()
	if (!Clockwork.kernel:IsScreenFadedBlack()) then
		local p = Clockwork.Client;
		if (self:PlayerIsCombine(p) && p:GasmaskInfo() > 0) then
			render.UpdateScreenEffectTexture();
			
			self.combineOverlay:SetFloat("$refractamount", 0.3);
			self.combineOverlay:SetFloat("$envmaptint", 0);
			self.combineOverlay:SetFloat("$envmap", 0);
			self.combineOverlay:SetFloat("$alpha", 0.5);
			self.combineOverlay:SetInt("$ignorez", 1);
			
			render.SetMaterial(self.combineOverlay);
			render.DrawScreenQuad();
		end;
	end;
end;

function PLUGIN:GetPlayerInfoText(playerInfoText)
	local citizenID = Clockwork.Client:GetSharedVar("cid");
	local fac = Clockwork.Client:GetFaction()
	
	if (citizenID) then
		if (!Schema:PlayerIsCombine(Clockwork.Client) && fac != FACTION_REBELS && fac != FACTION_REFUGEE && fac != FACTION_ANTLION ) then
			playerInfoText:Add("CITIZEN_ID", '?????????????????????? ID: '..citizenID);
		end;
	end;
end;

function GetMaskStatus(bool)

	if !bool then
		return '??????????????';
	end;

	return '????????????????????'
end;

function statusToColor(status)
	if status == '??????????????' then
		return Color(100, 255, 100);
	elseif status == '????????????' then
		return Color(248, 242, 33);
	elseif status == '??????????????' then
		return Color(255, 100, 100);
	elseif status == '????????????' then
		return Color(30, 30, 30);
	end;
	return Color(100, 255, 100);
end;

function PLUGIN:HUDPaint() 
	local p = Clockwork.Client
	local x = ScrW()/2 + 40;
	local y = ScrH()/2 + 1;
	local curTime = CurTime()

	if p:GasmaskInfo() > 0 && p:Alive() then
		local trace = Clockwork.player:GetRealTrace(p)
		local ply = Clockwork.entity:GetPlayer(trace.Entity);
		local check = p:GetSharedVar('GasMaskCheck');
		local s = Clockwork.kernel:GetSharedVar('CityStatus')
		local maskstatus = p:GetSharedVar('status');
		local fixableSize = 20
		
		draw.SimpleText("<:: ?????????????????????? = "..s.." ::>", "BudgetLabel", ScrW() - 8, 8, statusToColor(s), TEXT_ALIGN_RIGHT);
		draw.SimpleText("<:: ?????? ???????????? = "..maskstatus.." ::>", "BudgetLabel", ScrW() - 8, 24, colorWhite, TEXT_ALIGN_RIGHT);
		draw.SimpleText("<:: ?????????? ?????????????????? = "..GetMaskStatus(check).."( N ) ::>", "BudgetLabel", ScrW() - 8, 42, colorWhite, TEXT_ALIGN_RIGHT);
		if check then	
			local shotpos = p:GetShootPos();
			if trace && ply && trace.Entity && shotpos:Distance(trace.HitPos) <= 127 then
				local fac = ply:GetFaction();
				local allow = !Schema:PlayerIsCombine(ply) && fac != FACTION_ADMIN && fac != FACTION_REBELS && fac != FACTION_REFUGEE && fac != FACTION_ANTLION;

				draw.SimpleTextOutlined( '??????: '..ply:Name(), "BudgetLabel", x+4, y, Color(50, 100, 150), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 0.5, Color(255, 255, 255) )
				if allow then
					fixableSize = 80
					draw.SimpleTextOutlined( 'CID: '..ply:GetSharedVar("cid"), "BudgetLabel", x+4, y+11, Color(50, 100, 150), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 0.5, Color(255, 255, 255) )
					draw.SimpleTextOutlined( '????: '..ply:GetSharedVar("ol"), "BudgetLabel", x+4, y+23, Color(50, 100, 150), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 0.5, Color(255, 255, 255) )
					draw.SimpleTextOutlined( '????: '..ply:GetSharedVar("on"), "BudgetLabel", x+4, y+37, Color(50, 100, 150), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 0.5, Color(255, 255, 255) )
					draw.SimpleTextOutlined( '?????????? ????????????: '..ply:GetSharedVar("work"), "BudgetLabel", x+4, y+49, Color(50, 100, 150), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 0.5, Color(255, 255, 255) )
					draw.SimpleTextOutlined( '?????????? ????????????????????: '..ply:GetSharedVar("liveplace"), "BudgetLabel", x+4, y+61, Color(50, 100, 150), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 0.5, Color(255, 255, 255) )
				elseif fac == FACTION_MPF then
					fixableSize = 60
					draw.SimpleTextOutlined( '????????: '..ply:GetSharedVar("CombineRanke"), "BudgetLabel", x+4, y+11, Color(50, 100, 150), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 0.5, Color(255, 255, 255) )
					draw.SimpleTextOutlined( '??????????: '..ply:GetSharedVar("squad"), "BudgetLabel", x+4, y+23, Color(50, 100, 150), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 0.5, Color(255, 255, 255) )
					draw.SimpleTextOutlined( '????????????: '..ply:GetSharedVar("status"), "BudgetLabel", x+4, y+37, Color(50, 100, 150), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 0.5, Color(255, 255, 255) )
				end;
				surface.SetDrawColor(50, 100, 150, 255);
				surface.DrawRect(x, y, 1, fixableSize);
			end;
		end;
		if self.waypointDisplay then
			for id, tbl in pairs(self.waypointDisplay) do
				if (curTime >= tbl[1]) then
					table.remove(self.waypointDisplay, id);
				else
					local WaypointPos = tbl[2] + Vector(0, 0, 50);
					local WaypointPosScreen = WaypointPos:ToScreen()
					local DistanceFromPly = tostring(math.Round( WaypointPos:Distance( Clockwork.Client:GetPos() ) / 28, 1 ), 1) .. " ??."
					DistanceFromPly = tostring(math.Round( WaypointPos:Distance( Clockwork.Client:GetPos() ) / 28, 1 ), 1) .. " ??."
					local clr = colorWhite

					if tbl[4] == 'request' then
						clr = Color(255, 180, 80)
					elseif tbl[4] == 'backup' || tbl[4] == 'loss' then
						clr = Color(255, 100, 100)
					elseif tbl[4] == 'notify' then
						clr = Color(100, 100, 255)
					end;

					draw.TexturedQuad({texture = frptext, color = colorWhite, x = WaypointPosScreen.x-16, y = WaypointPosScreen.y, w = 32, h = 32})
					draw.SimpleText("<:: "..tbl[3].." ::>", "BudgetLabel", WaypointPosScreen.x, WaypointPosScreen.y+30, clr, TEXT_ALIGN_CENTER )
					draw.SimpleText("<:: ??????????????????: "..DistanceFromPly.." ::>", "BudgetLabel", WaypointPosScreen.x, WaypointPosScreen.y+40, clr, TEXT_ALIGN_CENTER ) 
					if tbl[4] == 'request' then
						if tbl[5] then
							draw.SimpleText("<:: ".. utf8.sub(tbl[5], 1, 43).."...".." ::>", "BudgetLabel", WaypointPosScreen.x, WaypointPosScreen.y+50, clr, TEXT_ALIGN_CENTER )
						elseif !tbl[5] || utf8.len(tbl[5]) == 0 then
							draw.SimpleText("<:: ???????????? ?????? ????????????????. ::>", "BudgetLabel", WaypointPosScreen.x, WaypointPosScreen.y+50, clr, TEXT_ALIGN_CENTER )
						end;
					elseif tbl[4] == 'backup' then
						draw.SimpleText("<:: ?????????????????? ??????????????????! ::>", "BudgetLabel", WaypointPosScreen.x, WaypointPosScreen.y+50, clr, TEXT_ALIGN_CENTER )
					elseif tbl[4] == 'notify' then
						if tbl[5] then
							draw.SimpleText("<:: ".. utf8.sub(tbl[5], 1, 64).."...".." ::>", "BudgetLabel", WaypointPosScreen.x, WaypointPosScreen.y+50, clr, TEXT_ALIGN_CENTER )
						elseif !tbl[5] || utf8.len(tbl[5]) == 0 then
							draw.SimpleText("<:: #ERR# ::>", "BudgetLabel", WaypointPosScreen.x, WaypointPosScreen.y+50, clr, TEXT_ALIGN_CENTER )
						end;
					elseif tbl[4] == 'loss' then
						draw.SimpleText("<:: ?????????????????? ??????????????! ::>", "BudgetLabel", WaypointPosScreen.x, WaypointPosScreen.y+50, clr, TEXT_ALIGN_CENTER )
					end;

				end;
			end;
		end;

	end;

end;

cable.receive('CreateWaypoint', function(location, name, time, type, sometext)
    if (!PLUGIN.waypointDisplay) then
		PLUGIN.waypointDisplay = {};
	end;

	if !time then
		time = 10;
	end;

	if !type then
		type = 'backup'
		sometext = nil;
	end;

	table.insert(PLUGIN.waypointDisplay, {CurTime() + time, location, name, type, sometext})
end);