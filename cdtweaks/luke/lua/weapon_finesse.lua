-- cdtweaks: Weapon Finesse feat for Thieves --

function GTWPNFIN(CGameEffect, CGameSprite)
	local equipment = CGameSprite.m_equipment -- CGameSpriteEquipment
	local selectedItem = equipment.m_items:get(equipment.m_selectedWeapon) -- CItem
	local itemResRef = string.upper(selectedItem.pRes.resref:get())
	local itemHeader = selectedItem.pRes.pHeader -- Item_Header_st
	local itemAbility = EEex_PtrToUD(EEex_UDToPtr(itemHeader) + itemHeader.abilityOffset + Item_ability_st.sizeof * equipment.m_selectedWeaponAbility, "Item_ability_st") -- Item_ability_st
	--
	local strmod = EEex_Resource_Load2DA("STRMOD")
	local strmodex = EEex_Resource_Load2DA("STRMODEX")
	local dexmod = EEex_Resource_Load2DA("DEXMOD")
	--
	local spriteSTR = CGameSprite.m_derivedStats.m_nSTR + CGameSprite.m_bonusStats.m_nSTR
	local spriteSTRExtra = CGameSprite.m_derivedStats.m_nSTRExtra + CGameSprite.m_bonusStats.m_nSTRExtra
	local spriteDEX = CGameSprite.m_derivedStats.m_nDEX + CGameSprite.m_bonusStats.m_nDEX
	--
	local curStrBonus = tonumber(EEex_Resource_GetAt2DALabels(strmod, "TO_HIT", string.format("%s", spriteSTR)) + EEex_Resource_GetAt2DALabels(strmodex, "TO_HIT", string.format("%s", spriteSTRExtra)))
	local curDexBonus = tonumber(EEex_Resource_GetAt2DALabels(dexmod, "MISSILE", string.format("%s", spriteDEX)))
	--
	local unusuallyLargeWeapon = {
		["BDBONE02"] = true -- Ettin Club +1
	}
	-- reset var if bonus changes
	if CGameEffect.m_effectAmount2 ~= curDexBonus or CGameEffect.m_effectAmount3 ~= curStrBonus then
		CGameEffect.m_effectAmount2 = curDexBonus -- store current DEX bonus in param#3
		CGameEffect.m_effectAmount3 = curStrBonus -- store current DEX bonus in param#4
		EEex_Sprite_SetLocalInt(CGameSprite, "cdtweaksWeaponFinesse", -1)
	end
	-- if the character is wielding a small blade / mace / club that scales with STR and "dexmod.2da" is better than "strmod.2da" + "strmodex.2da" ...
	if (itemHeader.itemType == 0x10 or itemHeader.itemType == 0x11 or itemHeader.itemType == 0x13) and not unusuallyLargeWeapon[itemResRef] and (curDexBonus > curStrBonus) and itemAbility.quickSlotType == 1 and itemAbility.type == 1 and (EEex_IsBitSet(itemAbility.abilityFlags, 0x0) or EEex_IsBitSet(itemAbility.abilityFlags, 0x3)) then
		if EEex_Sprite_GetLocalInt(CGameSprite, "cdtweaksWeaponFinesse") ~= 1 then
			EEex_Sprite_SetLocalInt(CGameSprite, "cdtweaksWeaponFinesse" , 1)
			--
			EEex_GameObject_ApplyEffect(CGameSprite,
			{
				["effectID"] = 321, -- Remove effects by resource
				["res"] = "CDWPNFIN",
				["durationType"] = 1,
				["sourceID"] = CGameEffect.m_sourceId, -- Certain opcodes (see f.i. op326) use this field internally... it's probably a good idea to always specify it...
				["sourceTarget"] = CGameEffect.m_sourceTarget, -- Certain opcodes (see f.i. op326) use this field internally... it's probably a good idea to always specify it...
			})
			EEex_GameObject_ApplyEffect(CGameSprite,
			{
				["effectID"] = 306, -- Main hand THAC0 bonus
				["effectAmount"] = curDexBonus - curStrBonus,
				["durationType"] = 9,
				["m_sourceRes"] = "CDWPNFIN",
				["sourceID"] = CGameEffect.m_sourceId, -- Certain opcodes (see f.i. op326) use this field internally... it's probably a good idea to always specify it...
				["sourceTarget"] = CGameEffect.m_sourceTarget, -- Certain opcodes (see f.i. op326) use this field internally... it's probably a good idea to always specify it...
			})
			EEex_GameObject_ApplyEffect(CGameSprite,
			{
				["effectID"] = 142, -- portrait icon
				["dwFlags"] = %feedback_icon%,
				["durationType"] = 9,
				["m_sourceRes"] = "CDWPNFIN",
				["sourceID"] = CGameEffect.m_sourceId, -- Certain opcodes (see f.i. op326) use this field internally... it's probably a good idea to always specify it...
				["sourceTarget"] = CGameEffect.m_sourceTarget, -- Certain opcodes (see f.i. op326) use this field internally... it's probably a good idea to always specify it...
			})
		end
	else
		if EEex_Sprite_GetLocalInt(CGameSprite, "cdtweaksWeaponFinesse") ~= 0 then
			EEex_Sprite_SetLocalInt(CGameSprite, "cdtweaksWeaponFinesse" , 0)
			--
			EEex_GameObject_ApplyEffect(CGameSprite,
			{
				["effectID"] = 321, -- Remove effects by resource
				["res"] = "CDWPNFIN",
				["durationType"] = 1,
				["sourceID"] = CGameEffect.m_sourceId, -- Certain opcodes (see f.i. op326) use this field internally... it's probably a good idea to always specify it...
				["sourceTarget"] = CGameEffect.m_sourceTarget, -- Certain opcodes (see f.i. op326) use this field internally... it's probably a good idea to always specify it...
			})
		end
	end
end