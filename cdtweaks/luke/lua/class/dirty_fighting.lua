-- cdtweaks, Dirty Fighting class feat for chaotic-aligned rogues --

function %ROGUE_DIRTY_FIGHTING%(CGameEffect, CGameSprite)
	if CGameEffect.m_effectAmount == 1 then
		-- NB.: Only the first op1*p2=3 effect will take hold; any later ones will be skipped...
		local found = false
		EEex_Utility_IterateCPtrList(CGameSprite.m_equipedEffectList, function(effect)
			if effect.m_effectId == 1 and effect.m_dWFlags == 3 then
				effect.m_scriptName:set("gtRogueDirtyFightingOp1")
				effect.m_effectAmount2 = effect.m_effectAmount
				effect.m_effectAmount = 1
				found = true
			end
		end)
		-- NB.: Op1*p2=3 only functions when using Timing Modes 2/5/8
		if not found then
			CGameSprite:applyEffect({
				["effectID"] = 1, -- Modify attacks per round
				["effectList"] = 2, -- adds the effect to the sprite's equipped list
				["durationType"] = 2,
				["dwFlags"] = 3, -- Modifier type: Set final
				["effectAmount"] = 1,
				["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
				["m_sourceType"] = CGameEffect.m_sourceType,
				["sourceID"] = CGameSprite.m_id,
				["sourceTarget"] = CGameSprite.m_id,
			})
		end
		-- The following is probably not necessary...
		CGameSprite:applyEffect({
			["effectID"] = 232, -- Cast spell on condition
			["durationType"] = 1,
			["dwFlags"] = 16, -- Die()
			["res"] = "%ROGUE_DIRTY_FIGHTING%B",
			["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
			["m_sourceType"] = CGameEffect.m_sourceType,
			["sourceID"] = CGameSprite.m_id,
			["sourceTarget"] = CGameSprite.m_id,
		})
	elseif CGameEffect.m_effectAmount == 2 then
		CGameSprite:applyEffect({
			["effectID"] = 321, -- Remove effects by resource
			["res"] = "%ROGUE_DIRTY_FIGHTING%",
			["sourceID"] = CGameSprite.m_id,
			["sourceTarget"] = CGameSprite.m_id,
		})
		-- Restore existing op1*p2=3 effects
		EEex_Utility_IterateCPtrList(CGameSprite.m_equipedEffectList, function(effect)
			if effect.m_scriptName:get() == "gtRogueDirtyFightingOp1" then
				effect.m_scriptName:set("")
				effect.m_effectAmount = effect.m_effectAmount2
				effect.m_effectAmount2 = 0
			end
		end)
	elseif CGameEffect.m_effectAmount == 3 then
		local itemflag = GT_Resource_SymbolToIDS["itemflag"]
		--
		local immunityToDamage = EEex_Trigger_ParseConditionalString("EEex_IsImmuneToOpcode(Myself,12)")
		--
		local targetActiveStats = EEex_Sprite_GetActiveStats(CGameSprite)
		--
		local sourceSprite = EEex_GameObject_Get(CGameEffect.m_sourceId)
		--
		local equipment = sourceSprite.m_equipment
		local selectedWeapon = equipment.m_items:get(equipment.m_selectedWeapon) -- CItem
		local selectedWeaponHeader = selectedWeapon.pRes.pHeader -- Item_Header_st
		--
		local selectedWeaponAbility = EEex_Resource_GetItemAbility(selectedWeaponHeader, equipment.m_selectedWeaponAbility) -- Item_ability_st
		--
		if selectedWeaponAbility.type == 1 and EEex_BAnd(selectedWeaponHeader.itemFlags, itemflag["TWOHANDED"]) == 0 then -- if melee and single-handed
			local items = sourceSprite.m_equipment.m_items -- Array<CItem*,39>
			local offHand = items:get(9) -- CItem
			--
			if offHand and sourceSprite.m_leftAttack == 1 then
				local offHandHeader = offHand.pRes.pHeader -- Item_Header_st
				if not (offHandHeader.itemType == 0xC) then -- if not shield, then overwrite item ability...
					selectedWeaponAbility = EEex_Resource_GetItemAbility(offHandHeader, 0) -- Item_ability_st
				end
			end
		end
		--
		local resistDamageTypeTable = {
			[0x10] = targetActiveStats.m_nResistPiercing, -- piercing
			[0x0] = targetActiveStats.m_nResistCrushing, -- crushing
			[0x100] = targetActiveStats.m_nResistSlashing, -- slashing
			[0x80] = targetActiveStats.m_nResistMissile, -- missile
			[0x800] = targetActiveStats.m_nResistCrushing, -- non-lethal
		}
		local itmDamageTypeToIDS = {
			0x10, -- piercing
			0x0, -- crushing
			0x100, -- slashing
			0x80, -- missile
			0x800, -- non-lethal
			targetActiveStats.m_nResistPiercing > targetActiveStats.m_nResistCrushing and 0x0 or 0x10, -- piercing/crushing (better)
			targetActiveStats.m_nResistPiercing > targetActiveStats.m_nResistSlashing and 0x100 or 0x10, -- piercing/slashing (better)
			targetActiveStats.m_nResistCrushing > targetActiveStats.m_nResistSlashing and 0x0 or 0x100, -- slashing/crushing (worse)
		}
		--
		if itmDamageTypeToIDS[selectedWeaponAbility.damageType] then -- sanity check
			if resistDamageTypeTable[itmDamageTypeToIDS[selectedWeaponAbility.damageType]] < 100 and not immunityToDamage:evalConditionalAsAIBase(CGameSprite) then
				EEex_GameObject_ApplyEffect(CGameSprite,
				{
					["effectID"] = 12, -- Damage
					["dwFlags"] = itmDamageTypeToIDS[selectedWeaponAbility.damageType] * 0x10000 + 3, -- Percentage
					["effectAmount"] = 20,
					["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
					["m_sourceType"] = CGameEffect.m_sourceType,
					["sourceID"] = CGameEffect.m_sourceId,
					["sourceTarget"] = CGameEffect.m_sourceTarget,
				})
				-- the percentage mode of op12 does not provide feedback, so we have to manually display it...
				EEex_GameObject_ApplyEffect(CGameSprite,
				{
					["effectID"] = 139, -- Display string
					["effectAmount"] = %feedback_strref_hit%,
					["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
					["m_sourceType"] = CGameEffect.m_sourceType,
					["sourceID"] = CGameEffect.m_sourceId,
					["sourceTarget"] = CGameEffect.m_sourceTarget,
				})
			else
				EEex_GameObject_ApplyEffect(CGameSprite,
				{
					["effectID"] = 139, -- Display string
					["effectAmount"] = %feedback_strref_immune%,
					["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
					["m_sourceType"] = CGameEffect.m_sourceType,
					["sourceID"] = CGameEffect.m_sourceId,
					["sourceTarget"] = CGameEffect.m_sourceTarget,
				})
			end
		end
		--
		immunityToDamage:free()
	end
end

-- cdtweaks, NWN-ish Dirty Fighting class feat for chaotic-aligned rogues. Make sure it cannot be disrupted --

EEex_Action_AddSpriteStartedActionListener(function(sprite, action)
	local stats = GT_Resource_SymbolToIDS["stats"]
	--
	local actionSources = {
		[3] = true, -- Attack()
		[94] = true, -- GroupAttack()
		[98] = true, -- AttackNoSound()
		[105] = true, -- AttackOneRound()
		[134] = true, -- AttackReevaluate()
	}
	--
	if sprite:getLocalInt("cdtweaksDirtyFighting") == 1 then
		if EEex_Sprite_GetStat(sprite, stats["GT_COMBAT_MODE"]) == 0 then
			if action.m_actionID == 31 and action.m_string1.m_pchData:get() == "%ROGUE_DIRTY_FIGHTING%" then
				action.m_actionID = 113 -- ForceSpell()
			end
		elseif EEex_Sprite_GetStat(sprite, stats["GT_COMBAT_MODE"]) == 2 then
			if not actionSources[action.m_actionID] then
				sprite:applyEffect({
					["effectID"] = 146, -- Cast spell
					["dwFlags"] = 1, -- instant/ignore level
					["res"] = "%ROGUE_DIRTY_FIGHTING%B",
					["sourceID"] = sprite.m_id,
					["sourceTarget"] = sprite.m_id,
				})
			end
		end
	end
end)

-- cdtweaks: NWN-ish Dirty Fighting class feat for chaotic-aligned rogues --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	--
	local stats = GT_Resource_SymbolToIDS["stats"]
	-- internal function that grants the actual feat
	local gain = function()
		-- Mark the creature as 'feat granted'
		sprite:setLocalInt("cdtweaksDirtyFighting", 1)
		--
		sprite:applyEffect({
			["effectID"] = 172, -- Remove spell
			["res"] = "%ROGUE_DIRTY_FIGHTING%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		sprite:applyEffect({
			["effectID"] = 171, -- Give spell
			["res"] = "%ROGUE_DIRTY_FIGHTING%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
	end
	-- Check creature's class / flags
	local spriteClassStr = GT_Resource_IDSToSymbol["class"][sprite.m_typeAI.m_Class]
	--
	local spriteFlags = sprite.m_baseStats.m_flags
	-- since ``EEex_Opcode_AddListsResolvedListener`` is running after the effect lists have been evaluated, ``m_bonusStats`` has already been added to ``m_derivedStats`` by the engine
	local spriteLevel1 = sprite.m_derivedStats.m_nLevel1
	local spriteLevel2 = sprite.m_derivedStats.m_nLevel2
	-- Check if rogue class -- single/multi/(complete)dual
	local gainAbility = spriteClassStr == "THIEF" or spriteClassStr == "FIGHTER_MAGE_THIEF"
		or (spriteClassStr == "FIGHTER_THIEF" and (EEex_IsBitUnset(spriteFlags, 0x6) or spriteLevel1 > spriteLevel2))
		or (spriteClassStr == "MAGE_THIEF" and (EEex_IsBitUnset(spriteFlags, 0x6) or spriteLevel1 > spriteLevel2))
		or (spriteClassStr == "CLERIC_THIEF" and (EEex_IsBitUnset(spriteFlags, 0x6) or spriteLevel1 > spriteLevel2))
	-- Check if chaotic
	local alignmentMaskChaotic = EEex_Trigger_ParseConditionalString("Alignment(Myself,MASK_CHAOTIC)")
	--
	local gainAbility = gainAbility and alignmentMaskChaotic:evalConditionalAsAIBase(sprite)
	--
	if sprite:getLocalInt("cdtweaksDirtyFighting") == 0 then
		if gainAbility then
			gain()
		end
	else
		if gainAbility then
			-- do nothing
		else
			-- Mark the creature as 'feat removed'
			sprite:setLocalInt("cdtweaksDirtyFighting", 0)
			--
			if EEex_Sprite_GetStat(sprite, stats["GT_COMBAT_MODE"]) == 2 then
				sprite:applyEffect({
					["effectID"] = 146, -- Cast spell
					["dwFlags"] = 1, -- instant/ignore level
					["res"] = "%ROGUE_DIRTY_FIGHTING%B",
					["sourceID"] = sprite.m_id,
					["sourceTarget"] = sprite.m_id,
				})
			end
			--
			sprite:applyEffect({
				["effectID"] = 172, -- Remove spell
				["res"] = "%ROGUE_DIRTY_FIGHTING%",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
	--
	alignmentMaskChaotic:free()
end)
