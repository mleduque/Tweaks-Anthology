--[[
+---------------------------------------------+
| cdtweaks, NWN-ish Disarm ability for Rogues |
+---------------------------------------------+
--]]

-- NWN-ish Disarm ability. Small / Medium / Large weapons --

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

-- NWN-ish Disarm ability (main) --

function %THIEF_DISARM%(CGameEffect, CGameSprite)
	local sourceSprite = EEex_GameObject_Get(CGameEffect.m_sourceId) -- CGameSprite
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
	local targetSelectedWeapon = CGameSprite:getLauncher(targetSelectedWeapon:getAbility(targetEquipment.m_selectedWeaponAbility)) or targetSelectedWeapon -- CItem
	--
	local targetSelectedWeaponResRef = targetSelectedWeapon.pRes.resref:get()
	local targetSelectedWeaponHeader = targetSelectedWeapon.pRes.pHeader -- Item_Header_st
	--
	local targetActiveStats = EEex_Sprite_GetActiveStats(CGameSprite)
	-- MAIN --
	-- Check if inventory is full
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
						local targetSaveVSBreath = targetActiveStats.m_nSaveVSBreath
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
								["durationType"] = 1,
								["effectAmount"] = targetSelectedWeapon.m_useCount1,
								["m_effectAmount2"] = targetSelectedWeapon.m_useCount2,
								["m_effectAmount3"] = targetSelectedWeapon.m_useCount3,
								["res"] = targetSelectedWeaponResRef,
								["sourceID"] = sourceSprite.m_id,
								["sourceTarget"] = sourceSprite.m_id,
							})
							-- restore ``CItem`` flags
							do
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
							end
							--
							CGameSprite:applyEffect({
								["effectID"] = 112, -- remove item
								["res"] = targetSelectedWeaponResRef,
								["sourceID"] = CGameEffect.m_sourceId,
								["sourceTarget"] = CGameEffect.m_sourceTarget,
							})
							-- make sure to unequip ammo (apparently, if you disarm a launcher, the corresponding ammo is still equipped)
							do
								local targetItems = CGameSprite.m_equipment.m_items -- Array<CItem*,39>
								for i = 11, 13 do -- ammo slots
									local item = targetItems:get(i) -- CItem
									if item then
										local resref = item.pRes.resref:get()
										--
										local responseString = EEex_Action_ParseResponseString(string.format('XEquipItem("%s",Myself,%d,UNEQUIP)', resref, i))
										responseString:executeResponseAsAIBaseInstantly(CGameSprite)
										--
										responseString:free()
									end
								end
							end
						end
					else
						CGameSprite:applyEffect({
							["effectID"] = 139, -- display string
							["effectAmount"] = %feedback_strref_cannot_be_disarmed%,
							["sourceID"] = CGameEffect.m_sourceId,
							["sourceTarget"] = CGameEffect.m_sourceTarget,
						})
					end
				else
					CGameSprite:applyEffect({
						["effectID"] = 139, -- display string
						["effectAmount"] = %feedback_strref_cannot_be_disarmed%,
						["sourceID"] = CGameEffect.m_sourceId,
						["sourceTarget"] = CGameEffect.m_sourceTarget,
					})
				end
			else
				CGameSprite:applyEffect({
					["effectID"] = 139, -- display string
					["effectAmount"] = %feedback_strref_cannot_be_disarmed%,
					["sourceID"] = CGameEffect.m_sourceId,
					["sourceTarget"] = CGameEffect.m_sourceTarget,
				})
			end
		else
			CGameSprite:applyEffect({
				["effectID"] = 139, -- display string
				["effectAmount"] = %feedback_strref_cannot_be_disarmed%,
				["sourceID"] = CGameEffect.m_sourceId,
				["sourceTarget"] = CGameEffect.m_sourceTarget,
			})
		end
	else
		sourceSprite:applyEffect({
			["effectID"] = 139, -- display string
			["effectAmount"] = %feedback_strref_inventory_full%,
			["sourceID"] = sourceSprite.m_id,
			["sourceTarget"] = sourceSprite.m_id,
		})
	end
	--
	inventoryFull:free()
end

-- Make it castable at will. Prevent spell disruption. Check if melee weapon equipped --

EEex_Sprite_AddQuickListsCheckedListener(function(sprite, resref, changeAmount)
	local curAction = sprite.m_curAction
	local spriteAux = EEex_GetUDAux(sprite)

	if not (curAction.m_actionID == 31 and resref == "%THIEF_DISARM%" and changeAmount < 0) then
		return
	end

	-- nuke current action
	curAction.m_actionID = 0

	local spellHeader = EEex_Resource_Demand(resref, "SPL")
	local spellLevelMemListArray = sprite.m_memorizedSpellsInnate
	local memList = spellLevelMemListArray:getReference(spellHeader.spellLevel - 1) -- !!!count starts from 0!!!

	-- restore memorization bit
	EEex_Utility_IterateCPtrList(memList, function(memInstance)
		local memInstanceResref = memInstance.m_spellId:get()
		if memInstanceResref == resref then
			local memFlags = memInstance.m_flags
			if EEex_IsBitUnset(memFlags, 0x0) then
				memInstance.m_flags = EEex_SetBit(memFlags, 0x0)
			end
		end
	end)

	-- make sure the creature is equipped with a melee weapon
	local isWeaponRanged = EEex_Trigger_ParseConditionalString("IsWeaponRanged(Myself)")
	if not isWeaponRanged:evalConditionalAsAIBase(sprite) then
		-- store target id
		spriteAux["gtDisarmTargetID"] = curAction.m_acteeID.m_Instance
		-- initialize the attack frame counter
		sprite.m_attackFrame = 0
		-- recast the ability as "ForceSpell()"
		local targetSprite = EEex_GameObject_Get(curAction.m_acteeID.m_Instance)
		targetSprite:applyEffect({
			["effectID"] = 146, -- Cast spell
			["res"] = resref,
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = targetSprite.m_id,
		})
	else
		sprite:applyEffect({
			["effectID"] = 139, -- Display string
			["effectAmount"] = %feedback_strref_melee_only%,
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
	end

	isWeaponRanged:free()
end)

-- Cast the "real" spl (ability) when the attack frame counter is 6 --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	--
	local spriteAux = EEex_GetUDAux(sprite)
	--
	local isWeaponRanged = EEex_Trigger_ParseConditionalString("IsWeaponRanged(Myself)")
	--
	if sprite:getLocalInt("gtThiefDisarm") == 1 then
		if not isWeaponRanged:evalConditionalAsAIBase(sprite) then
			if sprite.m_nSequence == 0 and sprite.m_attackFrame == 6 then -- SetSequence(SEQ_ATTACK)
				if spriteAux["gtDisarmTargetID"] then
					-- retrieve / forget target sprite
					local targetSprite = EEex_GameObject_Get(spriteAux["gtDisarmTargetID"])
					spriteAux["gtDisarmTargetID"] = nil
					--
					targetSprite:applyEffect({
						["effectID"] = 138, -- set animation
						["dwFlags"] = 4, -- SEQ_DAMAGE
						["sourceID"] = sprite.m_id,
						["sourceTarget"] = targetSprite.m_id,
					})
					targetSprite:applyEffect({
						["effectID"] = 402, -- invoke lua
						["res"] = "%THIEF_DISARM%",
						["sourceID"] = sprite.m_id,
						["sourceTarget"] = targetSprite.m_id,
					})
				end
			end
		end
	end
	--
	isWeaponRanged:free()
end)

-- Forget about ``spriteAux["gtDisarmTargetID"]`` if the player manually interrupts the action --

EEex_Action_AddSpriteStartedActionListener(function(sprite, action)
	local spriteAux = EEex_GetUDAux(sprite)
	--
	if sprite:getLocalInt("gtThiefDisarm") == 1 then
		if not (action.m_actionID == 113 and action.m_string1.m_pchData:get() == "%THIEF_DISARM%") then
			if spriteAux["gtDisarmTargetID"] ~= nil then
				spriteAux["gtDisarmTargetID"] = nil
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
		sprite:setLocalInt("gtThiefDisarm", 1)
		--
		local effectCodes = {
			{["op"] = 172}, -- remove spell
			{["op"] = 171}, -- give spell
		}
		--
		for _, attributes in ipairs(effectCodes) do
			sprite:applyEffect({
				["effectID"] = attributes["op"] or EEex_Error("opcode number not specified"),
				["res"] = "%THIEF_DISARM%",
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
	if sprite:getLocalInt("gtThiefDisarm") == 0 then
		if gainAbility then
			gain()
		end
	else
		if gainAbility then
			-- do nothing
		else
			-- Mark the creature as 'feat removed'
			sprite:setLocalInt("gtThiefDisarm", 0)
			--
			sprite:applyEffect({
				["effectID"] = 172, -- remove spell
				["res"] = "%THIEF_DISARM%",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)
