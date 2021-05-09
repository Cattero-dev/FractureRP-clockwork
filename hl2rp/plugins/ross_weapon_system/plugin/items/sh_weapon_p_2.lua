﻿local ITEM = Clockwork.item:New("weapon_base");
	ITEM.name = "FN FiveSeven";
	ITEM.model = "models/weapons/tfa_ins2/w_fn57.mdl";
	ITEM.weight = 1.2;
	ITEM.category = "Оружие";
	ITEM.uniqueID = "tfa_ins2_fiveseven";
	ITEM.description = "";
	ITEM.isAttachment = true;
	ITEM.attachmentBone = "ValveBiped.Bip01_Pelvis";
	ITEM.attachmentOffsetAngles = Angle(360, 290, -90);
	ITEM.attachmentOffsetVector = Vector(5, -7, -4);

function ITEM:AdjustAttachmentOffsetInfo(player, entity, info)
	if ( string.find(player:GetModel(), "female") ) then
		info.offsetAngle = Angle(-90, 90, 0);
		info.offsetVector = Vector(4, -4, 2);
	end;
end;

ITEM:Register();