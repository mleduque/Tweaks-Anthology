-- cdtweaks, NWN-ish Disarm ability. Light / Medium / Heavy weapons --

local cdtweaks_Disarm_WeaponSize = {
	["small"] = {"", "CL", "DD", "F2", "M2", "MC", "SL", "SS"},
	["medium"] = {"AX", "BS", "CB", "FS", "MS", "S1", "SC", "WH"},
	["large"] = {"BW", "F0", "F1", "F3", "FL", "GS", "HB", "Q2", "Q3", "Q4", "QS", "S0", "S2", "S3", "SP"},
}

local function cdtweaks_Disarm_CheckWeaponSize(animationType)
	for size, animationTypeList in pairs(cdtweaks_Disarm_WeaponSize) do
		for _, value in ipairs(animationTypeList) do
			if value == animationType then
				return size
			end
		end
	end
	return "none" -- should not happen
end

-- cdtweaks, NWN-ish Disarm ability --

function %ROGUE_DISARM%(CGameEffect, CGameSprite)
	local sourceSprite = EEex_GameObject_Get(CGameEffect.m_sourceId) -- CGameSprite
	-- Check source's currently selected weapon
	local isWeaponRanged = EEex_Trigger_ParseConditionalString("IsWeaponRanged(Myself)")
	--
	local inventoryFull = EEex_Trigger_ParseConditionalString("InventoryFull(Myself)")
	-- Get source's currently selected weapon
	local sourceEquipment = sourceSprite.m_equipment
	local sourceSelectedWeapon = sourceEquipment.m_items:get(sourceEquipment.m_selectedWeapon) -- CItem
	--
	local sourceSelectedWeaponHeader = sourceSelectedWeapon.pRes.pHeader -- Item_Header_st
	-- Get target's currently selected weapon
	local targetEquipment = CGameSprite.m_equipment
	local targetSelectedWeapon = targetEquipment.m_items:get(targetEquipment.m_selectedWeapon) -- CItem
	-- Get launcher if needed
	local targetSelectedWeapon = CGameSprite:getLauncher(targetSelectedWeapon:getAbility(targetEquipment.m_selectedWeaponAbility)) or targetSelectedWeapon
	--
	local targetSelectedWeaponResRef = targetSelectedWeapon.pRes.resref:get()
	local targetSelectedWeaponHeader = targetSelectedWeapon.pRes.pHeader -- Item_Header_st
	--
	local inWeaponRange = EEex_Trigger_ParseConditionalString('InWeaponRange(EEex_Target("GT_RogueDisarmTarget"))')
	--
	local attackOneRound = EEex_Action_ParseResponseString('AttackOneRound(EEex_Target("GT_RogueDisarmTarget"))')
	--
	local stats = GT_Resource_SymbolToIDS["stats"]
	-- Melee weapon equipped!
	if not isWeaponRanged:evalConditionalAsAIBase(sourceSprite) then
		if CGameEffect.m_effectAmount == 0 then
			sourceSprite:setStoredScriptingTarget("GT_RogueDisarmTarget", CGameSprite)
			-- check range
			if inWeaponRange:evalConditionalAsAIBase(sourceSprite) then
				--
				local effectCodes = {
					{["op"] = 401, ["p2"] = 1, ["p1"] = 3, ["tmg"] = 10, ["dur"] = 1, ["spec"] = stats["GT_IGNORE_ACTION_ADD_SPRITE_STARTED_ACTION_LISTENER"]}, -- set extended stat
					{["op"] = 284, ["tmg"] = 1, ["p1"] = -6}, -- melee thac0 bonus
					{["op"] = 142, ["tmg"] = 1, ["p2"] = %feedback_icon_canDisarm%}, -- feedback icon
					{["op"] = 248, ["tmg"] = 1, ["res"] = "%ROGUE_DISARM%B"}, -- melee hit effect
				}
				--
				for _, attributes in ipairs(effectCodes) do
					sourceSprite:applyEffect({
						["effectID"] = attributes["op"] or -1,
						["effectAmount"] = attributes["p1"] or 0,
						["dwFlags"] = attributes["p2"] or 0,
						["special"] = attributes["spec"] or 0,
						["res"] = attributes["res"] or "",
						["duration"] = attributes["dur"] or 0,
						["durationType"] = attributes["tmg"] or 0,
						["m_sourceRes"] = "%ROGUE_DISARM%",
						["m_sourceType"] = CGameEffect.m_sourceType,
						["sourceID"] = sourceSprite.m_id,
						["sourceTarget"] = sourceSprite.m_id,
					})
				end
				--
				attackOneRound:queueResponseOnAIBase(sourceSprite)
			else
				CGameSprite:applyEffect({
					["effectID"] = 139, -- display string
					["effectAmount"] = %feedback_strref_outOfRange%,
					["sourceID"] = CGameEffect.m_sourceId,
					["sourceTarget"] = CGameEffect.m_sourceTarget,
				})
			end
		elseif CGameEffect.m_effectAmount == 1 then
			-- check if inventory is full
			if not inventoryFull:evalConditionalAsAIBase(sourceSprite) then
				-- check if NONDROPABLE
				if EEex_IsBitUnset(targetSelectedWeapon.m_flags, 0x3) then
					-- check if DROPPABLE
					if EEex_IsBitSet(targetSelectedWeaponHeader.itemFlags, 0x2) then
						-- check if CURSED
						if EEex_IsBitUnset(targetSelectedWeaponHeader.itemFlags, 0x4) then
							--
							local sourceAnimationType = EEex_CastUD(sourceSelectedWeaponHeader.animationType, "CResRef"):get()
							local targetAnimationType = EEex_CastUD(targetSelectedWeaponHeader.animationType, "CResRef"):get()
							-- sanity check (only darts are supposed to have a null animation)
							if (targetAnimationType ~= "") or (targetSelectedWeaponHeader.itemType == 24) then
								-- set ``savebonus``
								local savebonus = 0
								--
								local sourceWeaponSize = cdtweaks_Disarm_CheckWeaponSize(sourceAnimationType)
								local targetWeaponSize = cdtweaks_Disarm_CheckWeaponSize(targetAnimationType)
								--
								if (sourceWeaponSize == "small" and targetWeaponSize == "medium") or (sourceWeaponSize == "medium" and targetWeaponSize == "large") then
									savebonus = 2
								elseif (sourceWeaponSize == "medium" and targetWeaponSize == "small") or (sourceWeaponSize == "large" and targetWeaponSize == "medium") then
									savebonus = -2
								elseif sourceWeaponSize == "small" and targetWeaponSize == "large" then
									savebonus = 4
								elseif sourceWeaponSize == "large" and targetWeaponSize == "small" then
									savebonus = -4
								end
								--
								local targetSaveVSBreath = CGameSprite.m_derivedStats.m_nSaveVSBreath + CGameSprite.m_bonusStats.m_nSaveVSBreath
								local adjustedRoll = CGameSprite.m_saveVSBreathRoll + savebonus
								--
								if adjustedRoll >= targetSaveVSBreath then
									CGameSprite:applyEffect({
										["effectID"] = 139, -- display string
										["effectAmount"] = %feedback_strref_resisted%,
										["sourceID"] = CGameEffect.m_sourceId,
										["sourceTarget"] = CGameEffect.m_sourceTarget,
									})
								else
									CGameSprite:applyEffect({
										["effectID"] = 139, -- display string
										["effectAmount"] = %feedback_strref_hit%,
										["sourceID"] = CGameEffect.m_sourceId,
										["sourceTarget"] = CGameEffect.m_sourceTarget,
									})
									--
									sourceSprite:applyEffect({
										["effectID"] = 122, -- create inventory item
										["effectAmount"] = targetSelectedWeapon.m_useCount1,
										["m_effectAmount2"] = targetSelectedWeapon.m_useCount2,
										["m_effectAmount3"] = targetSelectedWeapon.m_useCount3,
										["res"] = targetSelectedWeaponResRef,
										["sourceID"] = sourceSprite.m_id,
										["sourceTarget"] = sourceSprite.m_id,
									})
									-- restore ``CItem`` flags
									local sourceItems = sourceEquipment.m_items -- Array<CItem*,39>
									for i = 18, 33 do -- inventory slots
										local item = sourceItems:get(i) -- CItem
										if item then
											local resref = item.pRes.resref:get()
											if resref == targetSelectedWeaponResRef then
												if item.m_flags == 0 then
													if item.m_useCount1 == targetSelectedWeapon.m_useCount1 then
														if item.m_useCount2 == targetSelectedWeapon.m_useCount2 then
															if item.m_useCount3 == targetSelectedWeapon.m_useCount3 then
																item.m_flags = targetSelectedWeapon.m_flags
																break
															end
														end
													end
												end
											end
										end
									end
									--
									CGameSprite:applyEffect({
										["effectID"] = 112, -- remove item
										["res"] = targetSelectedWeaponResRef,
										["sourceID"] = CGameEffect.m_sourceId,
										["sourceTarget"] = CGameEffect.m_sourceTarget,
									})
								end
							else
								CGameSprite:applyEffect({
									["effectID"] = 139, -- display string
									["effectAmount"] = %feedback_strref_immune%,
									["sourceID"] = CGameEffect.m_sourceId,
									["sourceTarget"] = CGameEffect.m_sourceTarget,
								})
							end
						else
							CGameSprite:applyEffect({
								["effectID"] = 139, -- display string
								["effectAmount"] = %feedback_strref_immune%,
								["sourceID"] = CGameEffect.m_sourceId,
								["sourceTarget"] = CGameEffect.m_sourceTarget,
							})
						end
					else
						CGameSprite:applyEffect({
							["effectID"] = 139, -- display string
							["effectAmount"] = %feedback_strref_immune%,
							["sourceID"] = CGameEffect.m_sourceId,
							["sourceTarget"] = CGameEffect.m_sourceTarget,
						})
					end
				else
					CGameSprite:applyEffect({
						["effectID"] = 139, -- display string
						["effectAmount"] = %feedback_strref_immune%,
						["sourceID"] = CGameEffect.m_sourceId,
						["sourceTarget"] = CGameEffect.m_sourceTarget,
					})
				end
			else
				CGameSprite:applyEffect({
					["effectID"] = 139, -- display string
					["effectAmount"] = %feedback_strref_inventoryFull%,
					["sourceID"] = CGameEffect.m_sourceId,
					["sourceTarget"] = CGameEffect.m_sourceTarget,
				})
			end
		end
	else
		CGameSprite:applyEffect({
			["effectID"] = 139, -- display string
			["effectAmount"] = %feedback_strref_meleeOnly%,
			["sourceID"] = CGameEffect.m_sourceId,
			["sourceTarget"] = CGameEffect.m_sourceTarget,
		})
	end
	--
	inWeaponRange:free()
	isWeaponRanged:free()
	inventoryFull:free()
	attackOneRound:free()
end

-- cdtweaks, NWN-ish Disarm ability. Make sure one and only one attack roll is performed --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	--
	local isWeaponRanged = EEex_Trigger_ParseConditionalString("IsWeaponRanged(Myself)")
	--
	if sprite:getLocalInt("cdtweaksDisarm") == 1 then
		if GT_Utility_EffectCheck(sprite, {["op"] = 0xF8, ["res"] = "%ROGUE_DISARM%B"}) then
			if sprite.m_startedSwing == 1 and sprite:getLocalInt("gtCGameSpriteStartedSwing") == 0 and not isWeaponRanged:evalConditionalAsAIBase(sprite) then
				sprite:setLocalInt("gtCGameSpriteStartedSwing", 1)
			elseif (sprite.m_startedSwing == 0 and sprite:getLocalInt("gtCGameSpriteStartedSwing") == 1) or isWeaponRanged:evalConditionalAsAIBase(sprite) then
				sprite:setLocalInt("gtCGameSpriteStartedSwing", 0)
				--
				sprite.m_curAction.m_actionID = 0 -- nuke current action
				--
				EEex_GameObject_ApplyEffect(sprite,
				{
					["effectID"] = 321, -- remove effects by resource
					["res"] = "%ROGUE_DISARM%",
					["sourceID"] = sprite.m_id,
					["sourceTarget"] = sprite.m_id,
				})
			end
		else
			-- in case the character dies while swinging...
			if sprite:getLocalInt("gtCGameSpriteStartedSwing") == 1) then
				sprite:setLocalInt("gtCGameSpriteStartedSwing", 0)
			end
		end
	end
	--
	isWeaponRanged:free()
end)

-- cdtweaks, NWN-ish Disarm ability. Make sure it cannot be disrupted --

EEex_Action_AddSpriteStartedActionListener(function(sprite, action)
	if sprite:getLocalInt("cdtweaksDisarm") == 1 then
		local stats = GT_Resource_SymbolToIDS["stats"]
		--
		if action.m_actionID == 31 and action.m_string1.m_pchData:get() == "%ROGUE_DISARM%" then
			if EEex_Sprite_GetCastTimer(sprite) == -1 then
				action.m_actionID = 113 -- ForceSpell()
				--
				sprite.m_castCounter = 0
			else
				action.m_actionID = 0 -- nuke current action
				--
				EEex_GameObject_ApplyEffect(sprite,
				{
					["effectID"] = 321, -- remove effects by resource
					["res"] = "%ROGUE_DISARM%",
					["sourceID"] = sprite.m_id,
					["sourceTarget"] = sprite.m_id,
				})
				EEex_GameObject_ApplyEffect(sprite,
				{
					["effectID"] = 139, -- display string
					["effectAmount"] = %feedback_strref_auraFree%,
					["sourceID"] = sprite.m_id,
					["sourceTarget"] = sprite.m_id,
				})
			end
		else
			if EEex_Sprite_GetStat(sprite, stats["GT_IGNORE_ACTION_ADD_SPRITE_STARTED_ACTION_LISTENER"]) ~= 3 then
				EEex_GameObject_ApplyEffect(sprite,
				{
					["effectID"] = 321, -- remove effects by resource
					["res"] = "%ROGUE_DISARM%",
					["sourceID"] = sprite.m_id,
					["sourceTarget"] = sprite.m_id,
				})
			end
		end
	end
end)

-- cdtweaks, NWN-ish Disarm ability. Gain ability --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	-- internal function that grants the ability
	local gain = function()
		-- Mark the creature as 'feat granted'
		sprite:setLocalInt("cdtweaksDisarm", 1)
		--
		local effectCodes = {
			{["op"] = 172}, -- remove spell
			{["op"] = 171}, -- give spell
		}
		--
		for _, attributes in ipairs(effectCodes) do
			sprite:applyEffect({
				["effectID"] = attributes["op"] or -1,
				["res"] = "%ROGUE_DISARM%",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
	-- Check creature's class
	local spriteClassStr = GT_Resource_IDSToSymbol["class"][sprite.m_typeAI.m_Class]
	--
	local spriteFlags = sprite.m_baseStats.m_flags
	-- since ``EEex_Opcode_AddListsResolvedListener`` is running after the effect lists have been evaluated, ``m_bonusStats`` has already been added to ``m_derivedStats`` by the engine
	local spriteLevel1 = sprite.m_derivedStats.m_nLevel1
	local spriteLevel2 = sprite.m_derivedStats.m_nLevel2
	--
	local gainAbility = spriteClassStr == "THIEF" or spriteClassStr == "FIGHTER_MAGE_THIEF"
		or (spriteClassStr == "MAGE_THIEF" and (EEex_IsBitUnset(spriteFlags, 0x6) or spriteLevel1 > spriteLevel2))
		or (spriteClassStr == "CLERIC_THIEF" and (EEex_IsBitUnset(spriteFlags, 0x6) or spriteLevel1 > spriteLevel2))
		or (spriteClassStr == "FIGHTER_THIEF" and (EEex_IsBitUnset(spriteFlags, 0x6) or spriteLevel1 > spriteLevel2))
	--
	if sprite:getLocalInt("cdtweaksDisarm") == 0 then
		if gainAbility then
			gain()
		end
	else
		if gainAbility then
			-- do nothing
		else
			-- Mark the creature as 'feat removed'
			sprite:setLocalInt("cdtweaksDisarm", 0)
			--
			sprite:applyEffect({
				["effectID"] = 172, -- remove spell
				["res"] = "%ROGUE_DISARM%",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
			sprite:applyEffect({
				["effectID"] = 321, -- remove effects by resource
				["res"] = "%ROGUE_DISARM%",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)
