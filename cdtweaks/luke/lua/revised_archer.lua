-- cdtweaks, revised archer kit: Called Shot ability (bows only!) --

function GTCLDSHT(CGameEffect, CGameSprite)
	local equipment = CGameSprite.m_equipment -- CGameSpriteEquipment
	local selectedItem = equipment.m_items:get(equipment.m_selectedWeapon) -- CItem
	local itemHeader = selectedItem.pRes.pHeader -- Item_Header_st
	--
	if itemHeader.itemType == 0x5 or itemHeader.itemType == 0xF then -- bow with arrows equipped || bow with unlimited ammo equipped
		EEex_GameObject_ApplyEffect(CGameSprite,
		{
			["effectID"] = 326, -- Apply effects list
			["durationType"] = 1,
			["res"] = "CDCL121",
			["sourceID"] = CGameEffect.m_sourceId,
			["sourceTarget"] = CGameEffect.m_sourceTarget,
		})
	end
end