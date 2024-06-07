-- cdtweaks, revised archer kit: +X missile thac0/damage bonus with bows only! --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	-- internal function that applies the actual bonus via "CDFRLNTD.SPL"
	local apply = function(spriteLevel1, spriteLevel2, spriteLevel3)
		-- Update vars
		sprite:setLocalInt("cdtweaksRevisedArcherHelper1", spriteLevel1)
		sprite:setLocalInt("cdtweaksRevisedArcherHelper2", spriteLevel2)
		sprite:setLocalInt("cdtweaksRevisedArcherHelper3", spriteLevel3)
		-- Mark the creature as 'bonus applied'
		sprite:setLocalInt("cdtweaksRevisedArcher", 1)
		--
		sprite:applyEffect({
			["effectID"] = 146, -- Cast spell
			["dwFlags"] = 1, -- Cast instantly (caster level)
			["durationType"] = 1,
			["res"] = "CDFRLNTD",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
	end
	-- Check creature's equipment / kit
	local equipment = sprite.m_equipment
	local selectedItem = equipment.m_items:get(equipment.m_selectedWeapon)
	local itemHeader = selectedItem.pRes.pHeader
	--
	local spriteKitStr = GT_Resource_IDSToSymbol["kit"][EEex_BOr(EEex_LShift(sprite.m_baseStats.m_mageSpecUpperWord, 16), sprite.m_baseStats.m_mageSpecialization)]
	--
	local spriteClassStr = GT_Resource_IDSToSymbol["class"][sprite.m_typeAI.m_Class]
	--
	local selectedWeaponTypeStr = GT_Resource_IDSToSymbol["itemcat"][itemHeader.itemType]
	--
	local spriteFlags = sprite.m_baseStats.m_flags
	-- since ``EEex_Opcode_AddListsResolvedListener`` is running after the effect lists have been evaluated, ``m_bonusStats`` has already been added to ``m_derivedStats`` by the engine
	local spriteLevel1 = sprite.m_derivedStats.m_nLevel1
	local spriteLevel2 = sprite.m_derivedStats.m_nLevel2
	local spriteLevel3 = sprite.m_derivedStats.m_nLevel3
	-- (Bow with arrows equipped || bow with unlimited ammo equipped) && Archer kit
	local applyCondition = (selectedWeaponTypeStr == "ARROW" or selectedWeaponTypeStr == "BOW")
		and spriteKitStr == "FERALAN"
		and (spriteClassStr == "RANGER"
			-- incomplete dual-class characters are not supposed to benefit from this passive feat
			or (spriteClassStr == "CLERIC_RANGER" and (EEex_IsBitUnset(spriteFlags, 0x8) or spriteLevel1 > spriteLevel2)))
		and EEex_IsBitUnset(spriteFlags, 10) -- not Fallen Ranger
	--
	if sprite:getLocalInt("cdtweaksRevisedArcher") == 0 then
		if applyCondition then
			apply(spriteLevel1, spriteLevel2, spriteLevel3)
		end
	else
		if applyCondition then
			-- Check if level has changed since the last application
			if spriteLevel1 ~= sprite:getLocalInt("cdtweaksRevisedArcherHelper1")
				or spriteLevel2 ~= sprite:getLocalInt("cdtweaksRevisedArcherHelper2")
				or spriteLevel3 ~= sprite:getLocalInt("cdtweaksRevisedArcherHelper3")
			then
				apply(spriteLevel1, spriteLevel2, spriteLevel3)
			end
		else
			-- Mark the creature as 'bonus removed'
			sprite:setLocalInt("cdtweaksRevisedArcher", 0)
			--
			sprite:applyEffect({
				["effectID"] = 321, -- Remove effects by resource
				["durationType"] = 1,
				["res"] = "CDFRLNTD",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)
