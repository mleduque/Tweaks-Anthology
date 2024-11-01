--[[
+------------------------------------------------------------------------+
| cdtweaks, NWN-ish Dirty Fighting class feat for chaotic-aligned rogues |
+------------------------------------------------------------------------+
--]]

-- Core function --

function %ROGUE_DIRTY_FIGHTING%(CGameEffect, CGameSprite)
	if CGameEffect.m_effectAmount == 0 then
		-- we apply effects here due to op232's presence (which for best results requires EFF V2.0)
		local effectCodes = {
			{["op"] = 321, ["res"] = "%ROGUE_DIRTY_FIGHTING%"}, -- remove effects by resource
			{["op"] = 1, ["p2"] = 3, ["p1"] = 1, ["tmg"] = 2}, -- set apr to 1 (mode: final, i.e.: ignore warrior bonus apr, proficiency and haste/slow. Only functions if ``timing=2``. Unfortunately, the op182 trick does not work in this case...)
			{["op"] = 232, ["p2"] = 16, ["res"] = "%ROGUE_DIRTY_FIGHTING%B", ["tmg"] = 1}, -- cast spl on condition (condition: Die(); target: self)
			{["op"] = 142, ["p2"] = %feedback_icon%, ["tmg"] = 1}, -- feedback icon
			{["op"] = 248, ["res"] = "%ROGUE_DIRTY_FIGHTING%B", ["tmg"] = 1}, -- melee hit effect
		}
		--
		for _, attributes in ipairs(effectCodes) do
			CGameSprite:applyEffect({
				["effectID"] = attributes["op"] or EEex_Error("opcode number not specified"),
				["effectAmount"] = attributes["p1"] or 0,
				["dwFlags"] = attributes["p2"] or 0,
				["res"] = attributes["res"] or "",
				["durationType"] = attributes["tmg"] or 0,
				["m_sourceRes"] = "%ROGUE_DIRTY_FIGHTING%",
				["sourceID"] = CGameSprite.m_id,
				["sourceTarget"] = CGameSprite.m_id,
			})
		end
		--
		EEex_Sprite_SetLocalInt(CGameSprite, "gtDirtyFightingMode", 1)
	elseif CGameEffect.m_effectAmount == 1 then
		CGameSprite:applyEffect({
			["effectID"] = 321, -- Remove effects by resource
			["res"] = "%ROGUE_DIRTY_FIGHTING%",
			["sourceID"] = CGameSprite.m_id,
			["sourceTarget"] = CGameSprite.m_id,
		})
		-- Restore existing op1*p2=3 effects
		EEex_Utility_IterateCPtrList(CGameSprite.m_equipedEffectList, function(effect)
			if effect.m_scriptName:get() == "gtDirtyFightingOp1" then
				effect.m_scriptName:set("")
				effect.m_effectAmount = effect.m_effectAmount2
				effect.m_effectAmount2 = 0
			end
		end)
		--
		EEex_Sprite_SetLocalInt(CGameSprite, "gtDirtyFightingMode", 0)
	elseif CGameEffect.m_effectAmount == 2 then
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
		if sourceSprite.m_leftAttack == 1 then -- if off-hand attack
			local items = sourceSprite.m_equipment.m_items -- Array<CItem*,39>
			local offHand = items:get(9) -- CItem
			--
			if offHand then -- sanity check
				local pHeader = offHand.pRes.pHeader -- Item_Header_st
				if not (pHeader.itemType == 0xC) then -- if not shield, then overwrite item ability...
					selectedWeaponAbility = EEex_Resource_GetItemAbility(pHeader, 0) -- Item_ability_st
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
		local itmAbilityDamageTypeToIDS = {
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
		if itmAbilityDamageTypeToIDS[selectedWeaponAbility.damageType] then -- sanity check
			if resistDamageTypeTable[itmAbilityDamageTypeToIDS[selectedWeaponAbility.damageType]] < 100 and not immunityToDamage:evalConditionalAsAIBase(CGameSprite) then
				EEex_GameObject_ApplyEffect(CGameSprite,
				{
					["effectID"] = 12, -- Damage
					["dwFlags"] = itmAbilityDamageTypeToIDS[selectedWeaponAbility.damageType] * 0x10000 + 3, -- mode: Percentage
					["effectAmount"] = 15,
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

-- Automatically cancel mode if ranged weapon --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	--
	local isWeaponRanged = EEex_Trigger_ParseConditionalString("IsWeaponRanged(Myself)")
	--
	if sprite:getLocalInt("cdtweaksDirtyFighting") == 1 then
		if EEex_Sprite_GetLocalInt(sprite, "gtDirtyFightingMode") == 1 and isWeaponRanged:evalConditionalAsAIBase(sprite) then
			sprite:applyEffect({
				["effectID"] = 146, -- Cast spell
				["dwFlags"] = 1, -- instant/ignore level
				["res"] = "%ROGUE_DIRTY_FIGHTING%B",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
	--
	isWeaponRanged:free()
end)

-- Make sure it cannot be disrupted. Cancel mode if not attacking --

EEex_Action_AddSpriteStartedActionListener(function(sprite, action)
	local actionSources = {
		[3] = true, -- Attack()
		[94] = true, -- GroupAttack()
		[98] = true, -- AttackNoSound()
		[105] = true, -- AttackOneRound()
		[134] = true, -- AttackReevaluate()
	}
	--
	if sprite:getLocalInt("cdtweaksDirtyFighting") == 1 then
		if EEex_Sprite_GetLocalInt(sprite, "gtDirtyFightingMode") == 0 then
			if action.m_actionID == 31 and action.m_string1.m_pchData:get() == "%ROGUE_DIRTY_FIGHTING%" then
				action.m_actionID = 113 -- ForceSpell()
			end
		else
			if actionSources[action.m_actionID] then
				-- NB.: Only the first op1*p2=3 effect will take hold; any later ones will be skipped...
				EEex_Utility_IterateCPtrList(sprite.m_equipedEffectList, function(effect)
					if effect.m_effectId == 1 and effect.m_dWFlags == 3 and effect.m_scriptName:get() ~= "gtDirtyFightingOp1" then
						effect.m_scriptName:set("gtDirtyFightingOp1")
						effect.m_effectAmount2 = effect.m_effectAmount
						effect.m_effectAmount = 1
					end
				end)
				-- NB.: ``timing=2`` effects not attached directly as equipped effects get removed upon saving & reloading!!!
				-- think about saving & reloading while being in Dirty Fighting mode...
				if not GT_Utility_Sprite_CheckForEffect(sprite, {["m_effectId"] = 0x1, ["m_sourceRes"] = "%ROGUE_DIRTY_FIGHTING%"}) then
					sprite:applyEffect({
						["effectID"] = 0x1,
						["effectAmount"] = 1,
						["dwFlags"] = 3,
						["durationType"] = 2,
						["m_sourceRes"] = "%ROGUE_DIRTY_FIGHTING%",
						["sourceID"] = sprite.m_id,
						["sourceTarget"] = sprite.m_id,
					})
				end
			else
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

-- Give ability --

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
			if EEex_Sprite_GetLocalInt(sprite, "gtDirtyFightingMode") == 1 then
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
