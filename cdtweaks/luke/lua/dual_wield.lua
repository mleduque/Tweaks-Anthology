-- cdtweaks, dual-wield feat for rangers: Force the targeted creature to wield light armors (or no armor) in order to benefit from Two-Weapon Style --

function GTDLWLD(CGameEffect, CGameSprite)
	local equipment = CGameSprite.m_equipment -- CGameSpriteEquipment
	local selectedItem = equipment.m_items:get(equipment.m_selectedWeapon) -- CItem
	local itemHeader = selectedItem.pRes.pHeader -- Item_Header_st
	local mainHandFlags = itemHeader.itemFlags
	local itemAbility = EEex_PtrToUD(EEex_UDToPtr(itemHeader) + itemHeader.abilityOffset + Item_ability_st.sizeof * equipment.m_selectedWeaponAbility, "Item_ability_st") -- Item_ability_st
	local mainHandAbilityType = itemAbility.type
	--
	local items = CGameSprite.m_equipment.m_items -- Array<CItem*,39>
	--
	local armor = items:get(1) -- CItem (index from "slots.ids")
	local armorType = nil
	local armorAnimation = nil
	if armor then -- if the character is equipped with an armor...
		local itemHeader = armor.pRes.pHeader -- Item_Header_st
		armorType = itemHeader.itemType
		armorAnimation = EEex_CastUD(itemHeader.animationType, "CResRef"):get() -- certain engine types are nonsensical. We usually create fixups for the bindings whenever we run into them. We'll need to cast the value to properly read them
	end
	--
	local offHand = items:get(9) -- CItem (index from "slots.ids")
	local offHandType = nil
	if offHand then
		local itemHeader = offHand.pRes.pHeader -- Item_Header_st
		offHandType = itemHeader.itemType
	end
	--
	local spriteProficiency2Weapon = CGameSprite.m_derivedStats.m_nProficiency2Weapon + CGameSprite.m_bonusStats.m_nProficiency2Weapon
	--
	local stylbonu = EEex_Resource_Load2DA("STYLBONU")
	local maxThac0RightPenalty = tonumber(EEex_Resource_GetAt2DALabels(stylbonu, "THAC0_RIGHT", "TWOWEAPON-0"))
	local maxThac0LeftPenalty = tonumber(EEex_Resource_GetAt2DALabels(stylbonu, "THAC0_LEFT", "TWOWEAPON-0"))
	local curThac0RightPenalty = tonumber(EEex_Resource_GetAt2DALabels(stylbonu, "THAC0_RIGHT", string.format("TWOWEAPON-%s", spriteProficiency2Weapon)))
	local curThac0LeftPenalty = tonumber(EEex_Resource_GetAt2DALabels(stylbonu, "THAC0_LEFT", string.format("TWOWEAPON-%s", spriteProficiency2Weapon)))
	-- reset var if either curThac0RightPenalty or curThac0LeftPenalty changes
	if curThac0RightPenalty ~= CGameEffect.m_effectAmount2 or curThac0LeftPenalty ~= CGameEffect.m_effectAmount3 then
		EEex_Sprite_SetLocalInt(CGameSprite, "cdtweaksDualWield", -1)
		CGameEffect.m_effectAmount2 = curThac0RightPenalty -- store curThac0RightPenalty in param#3
		CGameEffect.m_effectAmount3 = curThac0LeftPenalty -- store curThac0RightPenalty in param#4
	end
	-- if the character is dual-wielding and is equipped with a medium or heavy armor ...
	if not EEex_IsBitSet(mainHandFlags, 0x1) and mainHandAbilityType == 1 and offHand and offHandType ~= 0xC and armor and armorType == 0x2 and (armorAnimation == "3A" or armorAnimation == "4A") then
		if EEex_Sprite_GetLocalInt(CGameSprite, "cdtweaksDualWield") ~= 1 then
			EEex_Sprite_SetLocalInt(CGameSprite, "cdtweaksDualWield", 1)
			--
			EEex_GameObject_ApplyEffect(CGameSprite,
			{
				["effectID"] = 321, -- Remove effects by resource
				["durationType"] = 1,
				["res"] = "CDDLWLD",
				["sourceID"] = CGameEffect.m_sourceId, -- Certain opcodes (see f.i. op326) use this field internally... it's probably a good idea to always specify it...
				["sourceTarget"] = CGameEffect.m_sourceTarget, -- Certain opcodes (see f.i. op326) use this field internally... it's probably a good idea to always specify it...
			})
			EEex_GameObject_ApplyEffect(CGameSprite,
			{
				["effectID"] = 306, -- Main-hand THAC0 bonus
				["effectAmount"] = curThac0RightPenalty - maxThac0RightPenalty,
				["durationType"] = 9,
				["m_sourceRes"] = "CDDLWLD",
				["sourceID"] = CGameEffect.m_sourceId, -- Certain opcodes (see f.i. op326) use this field internally... it's probably a good idea to always specify it...
				["sourceTarget"] = CGameEffect.m_sourceTarget, -- Certain opcodes (see f.i. op326) use this field internally... it's probably a good idea to always specify it...
			})
			EEex_GameObject_ApplyEffect(CGameSprite,
			{
				["effectID"] = 305, -- Off-hand THAC0 bonus
				["effectAmount"] = curThac0LeftPenalty - maxThac0LeftPenalty,
				["durationType"] = 9,
				["m_sourceRes"] = "CDDLWLD",
				["sourceID"] = CGameEffect.m_sourceId, -- Certain opcodes (see f.i. op326) use this field internally... it's probably a good idea to always specify it...
				["sourceTarget"] = CGameEffect.m_sourceTarget, -- Certain opcodes (see f.i. op326) use this field internally... it's probably a good idea to always specify it...
			})
			EEex_GameObject_ApplyEffect(CGameSprite,
			{
				["effectID"] = 142, -- Display portrait icon
				["dwFlags"] = %feedback_icon%,
				["durationType"] = 9,
				["m_sourceRes"] = "CDDLWLD",
				["sourceID"] = CGameEffect.m_sourceId, -- Certain opcodes (see f.i. op326) use this field internally... it's probably a good idea to always specify it...
				["sourceTarget"] = CGameEffect.m_sourceTarget, -- Certain opcodes (see f.i. op326) use this field internally... it's probably a good idea to always specify it...
			})
		end
	else
		if EEex_Sprite_GetLocalInt(CGameSprite, "cdtweaksDualWield") ~= 0 then
			EEex_Sprite_SetLocalInt(CGameSprite, "cdtweaksDualWield", 0)
			EEex_GameObject_ApplyEffect(CGameSprite,
			{
				["effectID"] = 321, -- Remove effects by resource
				["durationType"] = 1,
				["res"] = "CDDLWLD",
				["sourceID"] = CGameEffect.m_sourceId, -- Certain opcodes (see f.i. op326) use this field internally... it's probably a good idea to always specify it...
				["sourceTarget"] = CGameEffect.m_sourceTarget, -- Certain opcodes (see f.i. op326) use this field internally... it's probably a good idea to always specify it...
			})
		end
	end
end