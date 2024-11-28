--[[
+-----------------------------------------------------------+
| cdtweaks, NWN-ish Parry mode for Blades and Swashbucklers |
+-----------------------------------------------------------+
--]]

-- Gain ability --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	-- internal function that grants the ability
	local gain = function()
		-- Mark the creature as 'feat granted'
		sprite:setLocalInt("cdtweaksParryMode", 1)
		--
		local effectCodes = {
			{["op"] = 172}, -- remove spell
			{["op"] = 171}, -- give spell
		}
		--
		for _, attributes in ipairs(effectCodes) do
			sprite:applyEffect({
				["effectID"] = attributes["op"] or EEex_Error("opcode number not specified"),
				["res"] = "%BLADE_SWASHBUCKLER_PARRY%",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
	-- Check creature's class / kit
	local spriteClassStr = GT_Resource_IDSToSymbol["class"][sprite.m_typeAI.m_Class]
	--
	local spriteFlags = sprite.m_baseStats.m_flags
	-- since ``EEex_Opcode_AddListsResolvedListener`` is running after the effect lists have been evaluated, ``m_bonusStats`` has already been added to ``m_derivedStats`` by the engine
	local spriteLevel1 = sprite.m_derivedStats.m_nLevel1
	local spriteLevel2 = sprite.m_derivedStats.m_nLevel2
	local spriteKitStr = GT_Resource_IDSToSymbol["kit"][sprite.m_derivedStats.m_nKit]
	--
	local gainAbility = (spriteClassStr == "BARD" and spriteKitStr == "BLADE")
		or (spriteKitStr == "SWASHBUCKLER"
			and ((spriteClassStr == "MAGE_THIEF" and (EEex_IsBitUnset(spriteFlags, 0x6) or spriteLevel1 > spriteLevel2))
			or (spriteClassStr == "CLERIC_THIEF" and (EEex_IsBitUnset(spriteFlags, 0x6) or spriteLevel1 > spriteLevel2))
			or (spriteClassStr == "FIGHTER_THIEF" and (EEex_IsBitUnset(spriteFlags, 0x6) or spriteLevel1 > spriteLevel2))
			or (spriteClassStr == "THIEF")))
	--
	if sprite:getLocalInt("cdtweaksParryMode") == 0 then
		if gainAbility then
			gain()
		end
	else
		if gainAbility then
			-- do nothing
		else
			-- Mark the creature as 'feat removed'
			sprite:setLocalInt("cdtweaksParryMode", 0)
			--
			if EEex_Sprite_GetLocalInt(sprite, "gtParryMode") == 1 then
				sprite:applyEffect({
					["effectID"] = 146, -- Cast spell
					["dwFlags"] = 1, -- instant/ignore level
					["res"] = "%BLADE_SWASHBUCKLER_PARRY%D",
					["sourceID"] = sprite.m_id,
					["sourceTarget"] = sprite.m_id,
				})
			end
			--
			sprite:applyEffect({
				["effectID"] = 172, -- remove spell
				["res"] = "%BLADE_SWASHBUCKLER_PARRY%",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)

-- save vs. breath to parry an incoming attack; the higher DEX, the easier is to succeed --

EEex_Sprite_AddBlockWeaponHitListener(function(args)
	local toReturn = false
	--
	local fatigmod = GT_Resource_2DA["fatigmod"]
	local dexmod = GT_Resource_2DA["dexmod"]
	--
	local attackingWeapon = args.weapon -- CItem
	local targetSprite = args.targetSprite -- CGameSprite
	local attackingSprite = args.attackingSprite -- CGameSprite
	local attackingWeaponAbility = args.weaponAbility -- Item_ability_st
	-- you cannot parry weapons with bare hands (only other bare hands)
	local equipment = targetSprite.m_equipment
	local targetWeapon = equipment.m_items:get(equipment.m_selectedWeapon) -- CItem
	local targetWeaponHeader = targetWeapon.pRes.pHeader -- Item_Header_st
	--
	local attackingWeaponHeader = attackingWeapon.pRes.pHeader -- Item_Header_st
	-- by default, the character can parry max 2 attacks per round (1 if slowed OR fatigued, 1 per second if hasted)
	local time = 3
	if EEex_IsBitSet(targetSprite.m_derivedStats.m_generalState, 16) or tonumber(fatigmod[string.format("%s", targetSprite.m_derivedStats.m_nFatigue)]["LUCK"]) < 0 then
		time = 6
	elseif EEex_IsBitSet(targetSprite.m_derivedStats.m_generalState, 15) then
		time = 1
	end
	local responseString = EEex_Action_ParseResponseString(string.format('SetGlobalTimer("gtParryModeTimer","LOCALS",%d)', time))
	local conditionalString = EEex_Trigger_ParseConditionalString('!GlobalTimerNotExpired("gtParryModeTimer","LOCALS") \n InWeaponRange(EEex_Target("GT_ParryModeTarget"))')
	targetSprite:setStoredScriptingTarget("GT_ParryModeTarget", attackingSprite)
	--
	if targetSprite:getLocalInt("gtParryMode") == 1 then -- parry mode ON
		if attackingWeaponAbility.type == 1 and attackingWeaponAbility.range <= 2 then -- only melee attacks can be parried
			if (attackingWeaponHeader.itemType == 28 or targetWeaponHeader.itemType ~= 28) then -- bare hands can only parry bare hands
				if conditionalString:evalConditionalAsAIBase(targetSprite) then
					if targetSprite.m_derivedStats.m_nSaveVSBreath - tonumber(dexmod[string.format("%s", targetSprite.m_derivedStats.m_nDEX)]["MISSILE"]) <= targetSprite.m_saveVSBreathRoll then
						-- set timer
						responseString:executeResponseAsAIBaseInstantly(targetSprite)
						-- initialize the attack frame counter
						targetSprite.m_attackFrame = 0
						-- store attacking ID
						targetSprite:setLocalInt("gtParryModeAtkID", attackingSprite.m_id)
						-- cast a dummy spl that performs the attack animation via op138 (p2=0)
						attackingSprite:applyEffect({
							["effectID"] = 146, -- Cast spl
							["res"] = "%BLADE_SWASHBUCKLER_PARRY%B",
							["sourceID"] = targetSprite.m_id,
							["sourceTarget"] = attackingSprite.m_id,
						})
						-- block base weapon damage + on-hit effects
						toReturn = true
					end
				end
			end
		end
	end
	--
	conditionalString:free()
	responseString:free()
	--
	return toReturn
end)

-- cast a spl when ``m_attackFrame`` is equal to 6 (that should be approx. the value corresponding to the weapon hit...?) --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	-- if the blade / swashbuckler gets hit while performing a riposte attack, the attack will be canceled
	if sprite:getLocalInt("gtParryMode") == 1 and sprite.m_attackFrame == 6 and sprite.m_nSequence == 0 then
		local attackingSprite = EEex_GameObject_Get(sprite:getLocalInt("gtParryModeAtkID"))
		--
		attackingSprite:applyEffect({
			["effectID"] = 146, -- Cast spl
			["dwFlags"] = 1, -- mode: instant / permanent
			["res"] = "%BLADE_SWASHBUCKLER_PARRY%C",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = attackingSprite.m_id,
		})
	end
end)

-- automatically cancel mode if ranged weapon / polymorphed --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	--
	local isWeaponRanged = EEex_Trigger_ParseConditionalString("IsWeaponRanged(Myself)")
	--
	if sprite:getLocalInt("cdtweaksParryMode") == 1 then
		if EEex_Sprite_GetLocalInt(sprite, "gtParryMode") == 1 and (isWeaponRanged:evalConditionalAsAIBase(sprite) or sprite.m_derivedStats.m_bPolymorphed == 1) then
			sprite:applyEffect({
				["effectID"] = 146, -- Cast spell
				["dwFlags"] = 1, -- instant/ignore level
				["res"] = "%BLADE_SWASHBUCKLER_PARRY%D",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
	--
	isWeaponRanged:free()
end)

-- make sure it cannot be disrupted. Cancel mode if no longer idle --

EEex_Action_AddSpriteStartedActionListener(function(sprite, action)
	if sprite:getLocalInt("cdtweaksParryMode") == 1 then
		if EEex_Sprite_GetLocalInt(sprite, "gtParryMode") == 0 then
			if action.m_actionID == 31 and action.m_string1.m_pchData:get() == "%BLADE_SWASHBUCKLER_PARRY%" then
				action.m_actionID = 113 -- ForceSpell()
			end
		else
			if not (action.m_actionID == 113 and action.m_string1.m_pchData:get() == "%BLADE_SWASHBUCKLER_PARRY%B") then
				sprite:applyEffect({
					["effectID"] = 146, -- Cast spell
					["dwFlags"] = 1, -- instant/ignore level
					["res"] = "%BLADE_SWASHBUCKLER_PARRY%D",
					["sourceID"] = sprite.m_id,
					["sourceTarget"] = sprite.m_id,
				})
			end
		end
	end
end)

-- core op402 listener --

function %BLADE_SWASHBUCKLER_PARRY%(CGameEffect, CGameSprite)
	if CGameEffect.m_effectAmount == 0 then
		-- we apply effects here due to op232's presence (which for best results requires EFF V2.0)
		local effectCodes = {
			{["op"] = 321, ["res"] = "%BLADE_SWASHBUCKLER_PARRY%"}, -- remove effects by resource
			{["op"] = 232, ["p2"] = 16, ["res"] = "%BLADE_SWASHBUCKLER_PARRY%D", ["tmg"] = 1}, -- cast spl on condition (condition: Die(); target: self)
			{["op"] = 142, ["p2"] = %feedback_icon%, ["tmg"] = 1}, -- feedback icon
		}
		--
		for _, attributes in ipairs(effectCodes) do
			CGameSprite:applyEffect({
				["effectID"] = attributes["op"] or EEex_Error("opcode number not specified"),
				["dwFlags"] = attributes["p2"] or 0,
				["res"] = attributes["res"] or "",
				["durationType"] = attributes["tmg"] or 0,
				["m_sourceRes"] = "%BLADE_SWASHBUCKLER_PARRY%",
				["sourceID"] = CGameSprite.m_id,
				["sourceTarget"] = CGameSprite.m_id,
			})
		end
		--
		EEex_Sprite_SetLocalInt(CGameSprite, "gtParryMode", 1)
	elseif CGameEffect.m_effectAmount == 1 then
		CGameSprite:applyEffect({
			["effectID"] = 321, -- Remove effects by resource
			["res"] = "%BLADE_SWASHBUCKLER_PARRY%",
			["sourceID"] = CGameSprite.m_id,
			["sourceTarget"] = CGameSprite.m_id,
		})
		--
		EEex_Sprite_SetLocalInt(CGameSprite, "gtParryMode", 0)
	elseif CGameEffect.m_effectAmount == 2 then
		local itemflag = GT_Resource_SymbolToIDS["itemflag"]
		--
		local targetActiveStats = EEex_Sprite_GetActiveStats(CGameSprite)
		--
		local sourceSprite = EEex_GameObject_Get(CGameEffect.m_sourceId)
		local sourceActiveStats = EEex_Sprite_GetActiveStats(sourceSprite)
		--
		local strmod = GT_Resource_2DA["strmod"]
		local strmodex = GT_Resource_2DA["strmodex"]
		local strBonus = tonumber(strmod[string.format("%s", sourceActiveStats.m_nSTR)]["DAMAGE"] + strmodex[string.format("%s", sourceActiveStats.m_nSTRExtra)]["DAMAGE"])
		--
		local equipment = sourceSprite.m_equipment
		local selectedWeapon = equipment.m_items:get(equipment.m_selectedWeapon) -- CItem
		local selectedWeaponResRef = selectedWeapon.pRes.resref:get()
		local selectedWeaponHeader = selectedWeapon.pRes.pHeader -- Item_Header_st
		--
		local selectedWeaponAbility = EEex_Resource_GetItemAbility(selectedWeaponHeader, equipment.m_selectedWeaponAbility) -- Item_ability_st
		--
		if EEex_BAnd(selectedWeaponHeader.itemFlags, itemflag["TWOHANDED"]) == 0 and Infinity_RandomNumber(1, 2) == 1 then -- if single-handed and 1d2 == 1 (50% chance)
			local items = sourceSprite.m_equipment.m_items -- Array<CItem*,39>
			local offHand = items:get(9) -- CItem
			--
			if offHand then -- sanity check
				local pHeader = offHand.pRes.pHeader -- Item_Header_st
				if pHeader.itemType ~= 0xC then -- if not shield, then overwrite item resref / header / ability...
					selectedWeaponResRef = offHand.pRes.resref:get()
					selectedWeaponHeader = pHeader -- Item_Header_st
					selectedWeaponAbility = EEex_Resource_GetItemAbility(pHeader, 0) -- Item_ability_st
				end
			end
		end
		-- collect on-hit effects (if any)
		local onHitEffects = {}
		do
			local currentEffectAddress = EEex_UDToPtr(selectedWeaponHeader) + selectedWeaponHeader.effectsOffset + selectedWeaponAbility.startingEffect * Item_effect_st.sizeof
			--
			for idx = 1, selectedWeaponAbility.effectCount do
				local pEffect = EEex_PtrToUD(currentEffectAddress, "Item_effect_st")
				--
				table.insert(onHitEffects, {
					["effectID"] = pEffect.effectID,
					["targetType"] = pEffect.targetType,
					["spellLevel"] = pEffect.spellLevel,
					["effectAmount"] = pEffect.effectAmount,
					["dwFlags"] = pEffect.dwFlags,
					["durationType"] = EEex_BAnd(pEffect.durationType, 0xFF),
					["m_flags"] = EEex_RShift(pEffect.durationType, 8),
					["duration"] = pEffect.duration,
					["probabilityUpper"] = pEffect.probabilityUpper,
					["probabilityLower"] = pEffect.probabilityLower,
					["res"] = pEffect.res:get(),
					["numDice"] = pEffect.numDice,
					["diceSize"] = pEffect.diceSize,
					["savingThrow"] = pEffect.savingThrow,
					["saveMod"] = pEffect.saveMod,
					["special"] = pEffect.special,
				})
				--
				currentEffectAddress = currentEffectAddress + Item_effect_st.sizeof
			end
		end
		--
		local itmAbilityDamageTypeToIDS = {
			[0] = 0x0 -- none (crushing)
			[1] = 0x10, -- piercing
			[2] = 0x0, -- crushing
			[3] = 0x100, -- slashing
			[4] = 0x80, -- missile
			[5] = 0x800, -- non-lethal
			[6] = targetActiveStats.m_nResistPiercing > targetActiveStats.m_nResistCrushing and 0x0 or 0x10, -- piercing/crushing (better)
			[7] = targetActiveStats.m_nResistPiercing > targetActiveStats.m_nResistSlashing and 0x100 or 0x10, -- piercing/slashing (better)
			[8] = targetActiveStats.m_nResistCrushing > targetActiveStats.m_nResistSlashing and 0x0 or 0x100, -- slashing/crushing (worse)
		}
		--
		if itmAbilityDamageTypeToIDS[selectedWeaponAbility.damageType] then -- sanity check
			-- damage type ``NONE`` requires extra care
			local mode = 0 -- normal
			if selectedWeaponAbility.damageType == 0 and selectedWeaponAbility.damageDiceCount > 0 then
				mode = 1 -- set HP to value
			end
			--
			EEex_GameObject_ApplyEffect(CGameSprite,
			{
				["effectID"] = 0xC, -- Damage (12)
				["dwFlags"] = itmAbilityDamageTypeToIDS[selectedWeaponAbility.damageType] * 0x10000 + mode,
				["effectAmount"] = selectedWeaponAbility.damageDiceBonus + strBonus,
				["numDice"] = selectedWeaponAbility.damageDiceCount,
				["diceSize"] = selectedWeaponAbility.damageDice,
				--["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
				--["m_sourceType"] = CGameEffect.m_sourceType,
				["sourceID"] = CGameEffect.m_sourceId,
				["sourceTarget"] = CGameEffect.m_sourceTarget,
			})
			-- apply on-hit effects (if any)
			for _, v in ipairs(onHitEffects) do
				local array = {}
				--
				if v["targetType"] == 1 or v["targetType"] == 9 then -- self / original caster
					table.insert(array, sourceSprite)
				elseif v["targetType"] == 2 then -- projectile target
					table.insert(array, CGameSprite)
				elseif v["targetType"] == 3 or (v["targetType"] == 6 and sourceSprite.m_typeAI.m_EnemyAlly == 2) then -- party
					for i = 0, 5 do
						local partyMember = EEex_Sprite_GetInPortrait(i) -- CGameSprite
						if partyMember and EEex_BAnd(partyMember.m_derivedStats.m_generalState, 0x800) == 0 then -- skip if STATE_DEAD
							table.insert(array, partyMember)
						end
					end
				elseif v["targetType"] == 4 then -- everyone
					local everyone = EEex_Area_GetAllOfTypeInRange(sourceSprite.m_pArea, sourceSprite.m_pos.x, sourceSprite.m_pos.y, GT_AI_ObjectType["ANYONE"], 0x7FFF, false, nil, nil)
					--
					for _, sprite in ipairs(everyone) do
						if EEex_BAnd(sprite.m_derivedStats.m_generalState, 0x800) == 0 then -- skip if STATE_DEAD
							table.insert(array, sprite)
						end
					end
				elseif v["targetType"] == 5 then -- everyone but party
					local everyone = EEex_Area_GetAllOfTypeInRange(sourceSprite.m_pArea, sourceSprite.m_pos.x, sourceSprite.m_pos.y, GT_AI_ObjectType["ANYONE"], 0x7FFF, false, nil, nil)
					--
					for _, sprite in ipairs(everyone) do
						if sprite.m_typeAI.m_EnemyAlly ~= 2 then
							if EEex_BAnd(sprite.m_derivedStats.m_generalState, 0x800) == 0 then -- skip if STATE_DEAD
								table.insert(array, sprite)
							end
						end
					end
				elseif v["targetType"] == 6 and sourceSprite.m_typeAI.m_EnemyAlly ~= 2 then -- caster group
					local casterGroup = EEex_Area_GetAllOfTypeStringInRange(sourceSprite.m_pArea, sourceSprite.m_pos.x, sourceSprite.m_pos.y, string.format("[0.0.0.0.%d]", sourceSprite.m_typeAI.m_Specifics), 0x7FFF, false, nil, nil)
					--
					for _, sprite in ipairs(casterGroup) do
						if EEex_BAnd(sprite.m_derivedStats.m_generalState, 0x800) == 0 then -- skip if STATE_DEAD
							table.insert(array, sprite)
						end
					end
				elseif v["targetType"] == 7 then -- target group
					local targetGroup = EEex_Area_GetAllOfTypeStringInRange(sourceSprite.m_pArea, sourceSprite.m_pos.x, sourceSprite.m_pos.y, string.format("[0.0.0.0.%d]", CGameSprite.m_typeAI.m_Specifics), 0x7FFF, false, nil, nil)
					--
					for _, sprite in ipairs(targetGroup) do
						if EEex_BAnd(sprite.m_derivedStats.m_generalState, 0x800) == 0 then -- skip if STATE_DEAD
							table.insert(array, sprite)
						end
					end
				elseif v["targetType"] == 8 then -- everyone but self
					local everyone = EEex_Area_GetAllOfTypeInRange(sourceSprite.m_pArea, sourceSprite.m_pos.x, sourceSprite.m_pos.y, GT_AI_ObjectType["ANYONE"], 0x7FFF, false, nil, nil)
					--
					for _, sprite in ipairs(everyone) do
						if sprite.m_id ~= sourceSprite.m_id then
							if EEex_BAnd(sprite.m_derivedStats.m_generalState, 0x800) == 0 then -- skip if STATE_DEAD
								table.insert(array, sprite)
							end
						end
					end
				end
				--
				for _, object in ipairs(array) do
					EEex_GameObject_ApplyEffect(object,
					{
						["effectID"] = v["effectID"],
						["spellLevel"] = v["spellLevel"],
						["effectAmount"] = v["effectAmount"],
						["dwFlags"] = v["dwFlags"],
						["durationType"] = v["durationType"],
						["m_flags"] = v["m_flags"],
						["duration"] = v["duration"],
						["probabilityUpper"] = v["probabilityUpper"],
						["probabilityLower"] = v["probabilityLower"],
						["res"] = v["res"],
						["numDice"] = v["numDice"],
						["diceSize"] = v["diceSize"],
						["savingThrow"] = v["savingThrow"],
						["saveMod"] = v["saveMod"],
						["special"] = v["special"],
						--
						["m_sourceRes"] = selectedWeaponResRef,
						["m_sourceType"] = 2,
						["sourceID"] = CGameEffect.m_sourceId,
						["sourceTarget"] = CGameEffect.m_sourceTarget,
					})
				end
			end
		end
	end
end
