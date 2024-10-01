-- cdtweaks, Spellcraft / Counterspell class feat for spellcasters --

-- check if there is someone casting a wizard/priest spell --
-- perform a counterspell if appropriate --

EEex_Action_AddSpriteStartedActionListener(function(sprite, action)
	local state = GT_Resource_SymbolToIDS["state"]
	local stats = GT_Resource_SymbolToIDS["stats"]
	--
	local spriteActiveStats = EEex_Sprite_GetActiveStats(sprite)
	--
	local actionSources = {
		[31] = true, -- Spell()
		[95] = true, -- SpellPoint()
		[191] = true, -- SpellNoDec()
		[192] = true, -- SpellPointNoDec()
		[113] = true, -- ForceSpell()
		[114] = true, -- ForceSpellPoint()
		[181] = true, -- ReallyForceSpell()
		[337] = true, -- ReallyForceSpellPoint()
		[476] = true, -- EEex_SpellObjectOffset()
		[477] = true, -- EEex_SpellObjectOffsetNoDec()
		[478] = true, -- EEex_ForceSpellObjectOffset()
		[479] = true, -- EEex_ReallyForceSpellObjectOffset()
	}
	--
	if actionSources[action.m_actionID] then
		local spriteArray = {}
		--
		local spellResRef = action.m_string1.m_pchData:get()
		if spellResRef == "" then
			spellResRef = GT_Utility_DecodeSpell(action.m_specificID)
		end
		local spellHeader = EEex_Resource_Demand(spellResRef, "SPL")
		local spellType = spellHeader.itemType
		local spellSchool = spellHeader.school
		local spellLevel = spellHeader.spellLevel
		--
		if (spellType == 1 or spellType == 2) and (spellSchool > 0 and spellSchool <= 8) then
			--
			if sprite.m_typeAI.m_EnemyAlly > 200 then -- EVILCUTOFF
				spriteArray = EEex_Sprite_GetAllOfTypeStringInRange(sprite, "[GOODCUTOFF]", 448, nil, nil, nil)
			elseif sprite.m_typeAI.m_EnemyAlly < 30 then -- GOODCUTOFF
				spriteArray = EEex_Sprite_GetAllOfTypeStringInRange(sprite, "[EVILCUTOFF]", 448, nil, nil, nil)
			end
			--
			local found = -1
			--
			for _, itrSprite in ipairs(spriteArray) do
				if itrSprite:getLocalInt("cdtweaksSpellcraft") == 1 then
					local itrSpriteActiveStats = EEex_Sprite_GetActiveStats(itrSprite)
					-- lore-based check (a lore score of 240+ => automatic success)
					if itrSpriteActiveStats.m_nLore >= spellLevel * 10 + math.random(150) then
						if EEex_BAnd(itrSpriteActiveStats.m_generalState, state["CD_STATE_NOTVALID"]) == 0 then
							if EEex_IsBitUnset(spriteActiveStats.m_generalState, 0x4) or itrSpriteActiveStats.m_bSeeInvisible > 0 then
								-- deafness => extra check
								if not GT_Utility_EffectCheck(itrSprite, {["op"] = 0x50}) or math.random(0, 1) == 1 then 
									-- provide feedback if PC
									if itrSprite.m_typeAI.m_EnemyAlly == 2 then
										Infinity_DisplayString(itrSprite:getName() .. ": " .. Infinity_FetchString(%feedback_strref_spellcraft%) .. sprite:getName() .. Infinity_FetchString(%feedback_strref_isCasting%) .. Infinity_FetchString(spellHeader.genericName))
									end
									-- check if ``itrSprite`` is counterspelling...
									if spriteActiveStats.m_bSanctuary == 0 and EEex_Sprite_GetCastTimer(itrSprite) == -1 and itrSprite:getLocalInt("cdtweaksCounterspell") == 1 and EEex_IsBitUnset(itrSpriteActiveStats.m_generalState, 12) then
										local spellLevelMemListTable = {[7] = itrSprite.m_memorizedSpellsPriest, [9] = itrSprite.m_memorizedSpellsMage}
										--
										for maxLevel, spellLevelMemListArray in pairs(spellLevelMemListTable) do
											for i = spellLevel, maxLevel do
												local memList = spellLevelMemListArray:getReference(i - 1) -- count starts from 0, that's why ``-1``
												--
												EEex_Utility_IterateCPtrList(memList, function(memInstance)
													local memInstanceResref = memInstance.m_spellId:get()
													local memFlags = memInstance.m_flags
													--
													if EEex_IsBitSet(memFlags, 0x0) then -- if memorized, ...
														local memInstanceHeader = EEex_Resource_Demand(memInstanceResref, "SPL")
														-- universal counters
														if string.match(memInstanceResref:upper(), "^SPPR[1-7][0-9][0-9]$") or string.match(memInstanceResref:upper(), "^SPWI[1-9][0-9][0-9]$") then
															local memIDS = memInstanceHeader.itemType == 1 and 2 .. memInstanceResref:sub(-3) or 1 .. memInstanceResref:sub(-3)
															local memSymbol = GT_Resource_IDSToSymbol["spell"][tonumber(memIDS)]
															--
															if memSymbol and cdtweaks_Counterspell_UniversalCounter[memSymbol] then
																memInstance.m_flags = EEex_UnsetBit(memFlags, 0x0) -- ... unmemorize
																found = memInstanceHeader.school
																return true
															end
														end
														-- resref counter
														if memInstanceResref == spellResRef then
															memInstance.m_flags = EEex_UnsetBit(memFlags, 0x0) -- ... unmemorize
															found = memInstanceHeader.school
															return true
														end
														-- mschool counter
														for _, mschool in ipairs(cdtweaks_Counterspell_OppositionSchool[spellSchool][1]) do
															if mschool == memInstanceHeader.school then
																memInstance.m_flags = EEex_UnsetBit(memFlags, 0x0) -- ... unmemorize
																found = memInstanceHeader.school
																return true
															end
														end
													end
												end)
												--
												if found > 0 then
													-- momentarily flag the creature as 'ignore EEex_Action_AddSpriteStartedActionListener()'
													itrSprite:applyEffect({
														["effectID"] = 401, -- extended stat
														["effectAmount"] = 4,
														["dwFlags"] = 1, -- set
														["duration"] = 1,
														["durationType"] = 10, -- instant/limited (ticks)
														["special"] = stats["GT_IGNORE_ACTION_ADD_SPRITE_STARTED_ACTION_LISTENER"],
														["sourceID"] = itrSprite.m_id,
														["sourceTarget"] = itrSprite.m_id,
													})
													-- actual counterspell
													sprite:applyEffect({
														["effectID"] = 146, -- Cast spell
														["durationType"] = 1,
														["res"] = cdtweaks_Counterspell_OppositionSchool[found][2],
														["sourceID"] = itrSprite.m_id,
														["sourceTarget"] = sprite.m_id,
													})
													-- op146*p2=0 corresponds to 'ForceSpell()', so we have to manually set the aura
													itrSprite.m_castCounter = 0
													--
													goto continue
												end
											end
										end
									end
								end
							end
						end
					end
				end
			end
			--
			::continue::
		end
	end
end)

-- cdtweaks, Counterspell class feat for spellcasters --

function %INNATE_COUNTERSPELL%(CGameEffect, CGameSprite)
	if CGameEffect.m_effectAmount == 1 then
		CGameSprite:setLocalInt("cdtweaksCounterspell", 1)
		--
		CGameSprite:applyEffect({
			["effectID"] = 232, -- Cast spell on condition
			["durationType"] = 1,
			["dwFlags"] = 16, -- Die()
			["res"] = "%INNATE_COUNTERSPELL%Z",
			["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
			["m_sourceType"] = CGameEffect.m_sourceType,
			["sourceID"] = CGameSprite.m_id,
			["sourceTarget"] = CGameSprite.m_id,
		})
	elseif CGameEffect.m_effectAmount == 2 then
		CGameSprite:setLocalInt("cdtweaksCounterspell", 0)
		--
		CGameSprite:applyEffect({
			["effectID"] = 321, -- Remove effects by resource
			["durationType"] = 1,
			["res"] = "%INNATE_COUNTERSPELL%Y",
			["sourceID"] = CGameSprite.m_id,
			["sourceTarget"] = CGameSprite.m_id,
		})
		CGameSprite:applyEffect({
			["effectID"] = 171, -- Give spell
			["durationType"] = 1,
			["res"] = "%INNATE_COUNTERSPELL%Y",
			["sourceID"] = CGameSprite.m_id,
			["sourceTarget"] = CGameSprite.m_id,
		})
	elseif CGameEffect.m_effectAmount == 3 then
		CGameSprite.m_curAction.m_actionID = 0 -- nuke current action
	end
end

-- cdtweaks, Counterspell class feat for spellcasters. Make sure it cannot be disrupted --

EEex_Action_AddSpriteStartedActionListener(function(sprite, action)
	local stats = GT_Resource_SymbolToIDS["stats"]
	--
	if sprite:getLocalInt("cdtweaksCounterspell") == 0 then
		if action.m_actionID == 31 and action.m_string1.m_pchData:get() == "%INNATE_COUNTERSPELL%Y" then
			action.m_actionID = 113 -- ForceSpell()
		end
	elseif sprite:getLocalInt("cdtweaksCounterspell") == 1 then
		if EEex_Sprite_GetStat(sprite, stats["GT_IGNORE_ACTION_ADD_SPRITE_STARTED_ACTION_LISTENER"]) ~= 4 then
			sprite:applyEffect({
				["effectID"] = 146, -- Cast spell
				["durationType"] = 1,
				["dwFlags"] = 1, -- instant/ignore level
				["res"] = "%INNATE_COUNTERSPELL%Z",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)
