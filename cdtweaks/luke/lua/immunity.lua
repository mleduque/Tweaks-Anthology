--[[
+------------------------------------------------------------------------------------+
| **EXPERIMENTAL**: Grant immunity to the specified opcode and its ancillary effects |
+------------------------------------------------------------------------------------+
--]]

local GT_ImmunitiesVia403_Definitions = {
	[0] = { ["opcode"] = {3, -1}, ["string"] = {"Berserk", "Berzerk"}, ["icon"] = {4}, ["vfx"] = {}, ["extra"] = {} }, -- berserk
	--
	[1] = { ["opcode"] = {5, -1}, ["string"] = {"Charmed", "Dire charmed", "Dominated"}, ["icon"] = {0, 1, 43}, ["vfx"] = {}, ["extra"] = {} }, -- charm
	--
	[2] = { ["opcode"] = {12, -1}, ["string"] = {"Poison", "Poisoned"}, ["icon"] = {6}, ["vfx"] = {}, ["extra"] = {} }, -- damage (poison)
	--
	[3] = { ["opcode"] = {13, -1}, ["string"] = {"Death", "Vorpal Hit"}, ["icon"] = {51}, ["vfx"] = {}, ["extra"] = {} }, -- kill
	--
	[4] = { ["opcode"] = {16, -1}, ["string"] = {"Haste", "Hasted"}, ["icon"] = {38, 110}, ["vfx"] = {}, ["extra"] = {93, 206} }, -- haste
	--
	[5] = { ["opcode"] = {24, 0}, ["string"] = {"Panic", "Morale Failure: Panic", "*flees in terror*"}, ["icon"] = {36}, ["vfx"] = {"CDHORROR"}, ["extra"] = {23, 54, 106} }, -- panic
	--
	[6] = { ["opcode"] = {25, -1}, ["string"] = {"Poison", "Poisoned"}, ["icon"] = {6, 101}, ["vfx"] = {}, ["extra"] = {} }, -- poison
	--
	[7] = { ["opcode"] = {38, -1}, ["string"] = {"Silence", "Silenced", "Bard Song Silenced"}, ["icon"] = {34}, ["vfx"] = {}, ["extra"] = {} }, -- silence
	--
	[8] = { ["opcode"] = {39, -1}, ["string"] = {"Sleep", "Unconscious"}, ["icon"] = {14, 44, 126, 130}, ["vvc"] = {}, ["extra"] = {} }, -- sleep
	--
	[9] = { ["opcode"] = {40, -1}, ["string"] = {"Slow", "Slowed"}, ["icon"] = {41}, ["vfx"] = {}, ["extra"] = {54, 0} }, -- slow
	--
	[10] = { ["opcode"] = {45, -1}, ["string"] = {"Stun", "Stunned"}, ["icon"] = {55}, ["vfx"] = {"CDSTUN", "SPFLAYER", "SPMINDAT"}, ["extra"] = {} }, -- stun
	--
	[11] = { ["opcode"] = {55, -1}, ["string"] = {"Death", "Vorpal Hit"}, ["icon"] = {51}, ["vfx"] = {}, ["extra"] = {} }, -- slay
	--
	[12] = { ["opcode"] = {74, -1}, ["string"] = {"Blind", "Blinded"}, ["icon"] = {8}, ["vfx"] = {}, ["extra"] = {54} }, -- blind
	--
	[13] = { ["opcode"] = {76, -1}, ["string"] = {"Feeblemind", "Feebleminded", "Mind Locked Away"}, ["icon"] = {48}, ["vfx"] = {"CDFEEBLE"}, ["extra"] = {} }, -- feeblemind
	--
	[14] = { ["opcode"] = {78, -1}, ["string"] = {"Diseased", "Stricken by a foul disease"}, ["icon"] = {7}, ["vfx"] = {}, ["extra"] = {} }, -- disease
	--
	[15] = { ["opcode"] = {80, -1}, ["string"] = {"Deaf", "Deafened"}, ["icon"] = {112}, ["vfx"] = {}, ["extra"] = {} }, -- deaf
	--
	[16] = { ["opcode"] = {109, -1}, ["string"] = {"Paralysed", "Paralyzed", "Held"}, ["icon"] = {13}, ["vfx"] = {"SPMINDAT", "OHNWAND1"}, ["extra"] = {} }, -- paralyze
	--
	[17] = { ["opcode"] = {111, -1}, ["string"] = {"Polymorphed"}, ["icon"] = {54, 124}, ["vfx"] = {}, ["extra"] = {135, 0, 18, 44, 60, 144, 145, 171, 172} }, -- create weapon (polymorph)
	--
	[18] = { ["opcode"] = {128, -1}, ["string"] = {"Confusion", "Confused"}, ["icon"] = {2, 3, 47}, ["vfx"] = {"SPCONFUS"}, ["extra"] = {} }, -- confusion
	--
	[19] = { ["opcode"] = {134, -1}, ["string"] = {"Petrification", "Petrified"}, ["icon"] = {171}, ["vfx"] = {}, ["extra"] = {} }, -- petrification
	--
	[20] = { ["opcode"] = {135, -1}, ["string"] = {"Polymorphed"}, ["icon"] = {54, 124}, ["vfx"] = {}, ["extra"] = {111, 0, 18, 44, 60, 144, 145, 171, 172} }, -- polymorph
	--
	[21] = { ["opcode"] = {151, -1}, ["string"] = {}, ["icon"] = {51}, ["vfx"] = {}, ["extra"] = {} }, -- replace self
	--
	[22] = { ["opcode"] = {154, -1}, ["string"] = {"Entangled"}, ["icon"] = {144}, ["vfx"] = {}, ["extra"] = {0, 126} }, -- entangle
	--
	[23] = { ["opcode"] = {157, -1}, ["string"] = {"Held", "Webbed"}, ["icon"] = {129}, ["vfx"] = {}, ["extra"] = {109} }, -- web
	--
	[24] = { ["opcode"] = {158, -1}, ["string"] = {"Greased"}, ["icon"] = {145}, ["vfx"] = {}, ["extra"] = {126} }, -- grease
	--
	[25] = { ["opcode"] = {175, -1}, ["string"] = {"Held"}, ["icon"] = {13}, ["vfx"] = {"SPMINDAT", "OHNWAND1"}, ["extra"] = {} }, -- hold
	--
	[26] = { ["opcode"] = {185, -1}, ["string"] = {"Held"}, ["icon"] = {13}, ["vfx"] = {"SPMINDAT", "OHNWAND1"}, ["extra"] = {} }, -- hold (2)
	--
	[27] = { ["opcode"] = {209, -1}, ["string"] = {"Death", "Vorpal Hit"}, ["icon"] = {}, ["vfx"] = {}, ["extra"] = {} }, -- power word, kill
	--
	[28] = { ["opcode"] = {210, -1}, ["string"] = {"Stun", "Stunned"}, ["icon"] = {55}, ["vfx"] = {}, ["extra"] = {} }, -- power word, stun
	--
	[29] = { ["opcode"] = {211, -1}, ["string"] = {}, ["icon"] = {79}, ["vfx"] = {"SPMAZE1", "SPMAZE2"}, ["extra"] = {} }, -- imprisonment
	--
	[30] = { ["opcode"] = {213, -1}, ["string"] = {}, ["icon"] = {78}, ["vfx"] = {"SPSPMAZE"}, ["extra"] = {} }, -- maze
	--
	[31] = { ["opcode"] = {216, -1}, ["string"] = {"One Level Drained", "Two Levels Drained", "Three Levels Drained", "Four Levels Drained", "Five Levels Drained", "Six Levels Drained", "Seven Levels Drained", "Eight Levels Drained", "Nine Levels Drained", "Ten Levels Drained", "Eleven Levels Drained", "Twelve Levels Drained", "Thirteen Levels Drained", "Fourteen Levels Drained", "Fifteen Levels Drained", "Sixteen Levels Drained"}, ["icon"] = {53, 59}, ["vfx"] = {}, ["extra"] = {} }, -- level drain
	--
	[32] = { ["opcode"] = {217, -1}, ["string"] = {"Sleep", "Unconscious"}, ["icon"] = {14, 130}, ["vfx"] = {}, ["extra"] = {} }, -- power word, sleep
	-- special cases
	[33] = { ["opcode"] = {142, 91}, ["string"] = {"Ability Score Drained"}, ["icon"] = {}, ["vfx"] = {}, ["extra"] = {6, 10, 15, 19, 44, 49, 97} }, -- ability score drained
	--
	[34] = { ["opcode"] = {142, 137}, ["string"] = {"Bleeding", "Suffers Bleeding Wound", "Bleeding Wound"}, ["icon"] = {}, ["vfx"] = {}, ["extra"] = {12} }, -- bleeding
	--
	[35] = { ["opcode"] = {142, 86}, ["string"] = {"Devour brain"}, ["icon"] = {}, ["vfx"] = {}, ["extra"] = {19} }, -- devour brain
	--
	[36] = { ["opcode"] = {12, -1}, ["string"] = {"Healed"}, ["icon"] = {}, ["vfx"] = {}, ["extra"] = {} }, -- hp drain
	--[[
	[32] = { ["opcode"] = {39, -1}, ["string"] = {"Sleep", "Unconscious"}, ["icon"] = {14}, ["vvc"] = {}, ["extra"] = {} }, -- sleep
	--
	[33] = { ["opcode"] = {39, -1}, ["string"] = {"Sleep", "Unconscious"}, ["icon"] = {126}, ["vvc"] = {}, ["extra"] = {} }, -- nausea
	--
	[34] = { ["opcode"] = {39, -1}, ["string"] = {"Sleep", "Unconscious"}, ["icon"] = {14, 130}, ["vvc"] = {}, ["extra"] = {12, 269, 67} }, -- earthquake
	--
	[35] = { ["opcode"] = {39, -1}, ["string"] = {"Sleep", "Unconscious"}, ["icon"] = {14, 130}, ["vvc"] = {}, ["extra"] = {235} }, -- knockback
	--]]
}

-- Check effect --

local function GT_ImmunitiesVia403_InstantEffect(CGameEffectBase)
	if CGameEffectBase.m_effectId == 139 then -- Display string
		return true
	elseif CGameEffectBase.m_effectId == 12 then -- Damage
		-- skip if hp drain
		if not (EEex_IsBitSet(CGameEffectBase.m_special, 0x0) or EEex_IsBitSet(CGameEffectBase.m_special, 0x1) or EEex_IsBitSet(CGameEffectBase.m_special, 0x3) or EEex_IsBitSet(CGameEffectBase.m_special, 0x4)) then
			return true
		end
	elseif CGameEffectBase.m_effectId == 177 or CGameEffectBase.m_effectId == 283 then -- Use EFF file
		-- NB.: In a recursive function, if the innermost call returns ``true``, it does not automatically cause the outermost function to return ``true``. We need to explicitly propagate the true value back up the call stack
		local result = GT_ImmunitiesVia403_InstantEffect(EEex_Resource_Demand(CGameEffectBase.m_res:get(), "eff")) -- recursive call
		if result then
			return true
		end
	end
	--
	return false
end

local function GT_ImmunitiesVia403_CheckEffect(CGameEffectBase, table, language, displaySubtitles, stored_duration, parent_duration, bit)
	if stored_duration == -1 and parent_duration == -1 then
		if CGameEffectBase.m_effectId == table["opcode"][1] then
			if table["opcode"][2] == -1 or CGameEffectBase.m_dWFlags == table["opcode"][2] then
				if not (table["opcode"][1] == 12 and bit == 36) or (EEex_IsMaskSet(CGameEffectBase.m_dWFlags, 0x400000) and (EEex_IsBitSet(CGameEffectBase.m_special, 0x0) or EEex_IsBitSet(CGameEffectBase.m_special, 0x1) or EEex_IsBitSet(CGameEffectBase.m_special, 0x3) or EEex_IsBitSet(CGameEffectBase.m_special, 0x4))) then
					if not (table["opcode"][1] == 12 and bit == 2) or EEex_IsMaskSet(CGameEffectBase.m_dWFlags, 0x200000) then
						if EEex_IsBitUnset(CGameEffectBase.m_savingThrow, 23) then
							return true
						end
					end
				end
			end
		-- EFF files
		elseif CGameEffectBase.m_effectId == 177 or CGameEffectBase.m_effectId == 283 then -- Use EFF file
			-- NB.: In a recursive function, if the innermost call returns ``true``, it does not automatically cause the outermost function to return ``true``. We need to explicitly propagate the true value back up the call stack
			local result = GT_ImmunitiesVia403_CheckEffect(EEex_Resource_Demand(CGameEffectBase.m_res:get(), "eff"), table, language, displaySubtitles, stored_duration, parent_duration, bit) -- recursive call
			if result then
				return true
			end
		end
	-- ancillary effects
	elseif CGameEffectBase.m_effectId == 142 then -- Display portrait icon
		if GT_LuaTool_ArrayContains(table["icon"], CGameEffectBase.m_dWFlags) then
			return true
		end
	elseif CGameEffectBase.m_effectId == 215 then -- Play visual effect
		if GT_LuaTool_ArrayContains(table["vfx"], CGameEffectBase.m_res:get()) then
			return true
		end
	elseif CGameEffectBase.m_effectId == 139 then -- Display string
		-- temporarily set language to English
		Infinity_SetLanguage("en_US", 0)
		--
		if GT_LuaTool_ArrayContains(table["string"], Infinity_FetchString(CGameEffectBase.m_effectAmount)) then
			-- restore original language / subtitles
			Infinity_SetLanguage(language, displaySubtitles)
			--
			return true
		end
		-- restore original language / subtitles
		Infinity_SetLanguage(language, displaySubtitles)
	elseif CGameEffectBase.m_effectId == 174 then -- Play sound
		if parent_duration == stored_duration then
			return true
		end
	elseif GT_LuaTool_ArrayContains(table["extra"], CGameEffectBase.m_effectId) then -- extra
		return true
	-- EFF files
	elseif CGameEffectBase.m_effectId == 177 or CGameEffectBase.m_effectId == 283 then -- Use EFF file
		-- NB.: In a recursive function, if the innermost call returns ``true``, it does not automatically cause the outermost function to return ``true``. We need to explicitly propagate the true value back up the call stack
		local result = GT_ImmunitiesVia403_CheckEffect(EEex_Resource_Demand(CGameEffectBase.m_res:get(), "eff"), table, language, displaySubtitles, stored_duration, parent_duration, bit) -- recursive call
		if result then
			return true
		end
	end
	--
	return false
end

-- op403 listener --

function GTIMMUNE(op403CGameEffect, CGameEffect, CGameSprite)
	local language = Infinity_GetINIString('Language', 'Text', 'should not happen')
	local displaySubtitles = Infinity_GetINIValue('Program Options', 'Display Subtitles', -1)
	--
	local stats = GT_Resource_SymbolToIDS["stats"]
	--
	local aux = EEex_GetUDAux(CGameSprite)
	if not aux["gt_ImmunitiesVia403_Aux"] then
		aux["gt_ImmunitiesVia403_Aux"] = {}
	end
	--
	local parentResRef = CGameEffect.m_sourceRes:get()
	--
	local mode = op403CGameEffect.m_special -- 0 (default: block); 1 (block if save vs. X at +2)
	-- check which bits are set
	for bit = 0, 36 do
		local original = (bit < 32) and op403CGameEffect.m_effectAmount or op403CGameEffect.m_dWFlags
		--
		if EEex_IsBitSet(original, bit % 32) then
			--
			if GT_ImmunitiesVia403_CheckEffect(CGameEffect, GT_ImmunitiesVia403_Definitions[bit], language, displaySubtitles, -1, -1, bit) then
				-- set a temporary marker
				local effectCodes = {
					{["op"] = 318, ["res"] = "GTIMM403", ["stype"] = CGameEffect.m_savingThrow, ["sbonus"] = CGameEffect.m_saveMod + 2}, -- protection from resource
					{["op"] = 401, ["p1"] = 1, ["p2"] = 1, ["spec"] = stats["GT_IMMUNITIES_VIA_403"]}, -- set extended stat
				}
				--
				for _, attributes in ipairs(effectCodes) do
					CGameSprite:applyEffect({
						["effectID"] = attributes["op"] or EEex_Error("opcode number not specified"),
						["effectAmount"] = attributes["p1"] or 0,
						["dwFlags"] = attributes["p2"] or 0,
						["special"] = attributes["spec"] or 0,
						["res"] = attributes["res"] or "",
						["savingThrow"] = attributes["stype"] or 0,
						["saveMod"] = attributes["sbonus"] or 0,
						["m_sourceRes"] = "GTIMM403",
						["sourceID"] = CGameSprite.m_id,
						["sourceTarget"] = CGameSprite.m_id,
					})
				end
				-- keep track of its parent and duration (needed to remove ancillary op174 effects)
				if mode == 0 or EEex_Sprite_GetStat(CGameSprite, stats["GT_IMMUNITIES_VIA_403"]) == 1 then
					--
					table.insert(aux["gt_ImmunitiesVia403_Aux"], {
						["m_sourceRes"] = parentResRef,
						["duration"] = CGameEffect.m_duration,
						["m_effectAmount5"] = CGameEffect.m_effectAmount5, -- time applied
						["bit"] = bit,
					})
					-- mark ancillary effects for later removal (if any)
					local effectList = {CGameSprite.m_timedEffectList, CGameSprite.m_equipedEffectList}
					for _, list in ipairs(effectList) do
						EEex_Utility_IterateCPtrList(list, function(effect)
							if effect.m_sourceRes:get() == parentResRef then
								if effect.m_effectAmount5 == CGameEffect.m_effectAmount5 then -- time applied
									if GT_ImmunitiesVia403_CheckEffect(effect, GT_ImmunitiesVia403_Definitions[bit], language, displaySubtitles, CGameEffect.m_duration, math.floor((effect.m_duration - effect.m_effectAmount5) / 15), bit) then
										effect.m_sourceRes:set("GTREMOVE")
									end
								end
							end
						end)
					end
					-- actual removal
					EEex_GameObject_ApplyEffect(CGameSprite,
					{
						["effectID"] = 321, -- Remove effects by resource
						["res"] = "GTREMOVE",
						["sourceID"] = CGameSprite.m_id,
						["sourceTarget"] = CGameSprite.m_id,
					})
					-- block
					return true
				end
			else
				-- block incoming ancillary effects (if any)
				for _, v in ipairs(aux["gt_ImmunitiesVia403_Aux"]) do
					if v["bit"] == bit then
						if v["m_sourceRes"] == parentResRef then
							if v["m_effectAmount5"] == CGameEffect.m_effectAmount5 then -- time applied
								if GT_ImmunitiesVia403_CheckEffect(CGameEffect, GT_ImmunitiesVia403_Definitions[bit], language, displaySubtitles, v["duration"], CGameEffect.m_duration, bit) then
									return true
								end
							end
						end
					end
				end
				-- instantaneous effects: change timing mode to instantaneous delay (so that they can properly be blocked if needed)
				if GT_ImmunitiesVia403_InstantEffect(CGameEffect) then
					if CGameEffect.m_durationType == 0 or CGameEffect.m_durationType == 1 or CGameEffect.m_durationType == 9 or CGameEffect.m_durationType == 10 then
						CGameEffect.m_durationType = 4
						CGameEffect.m_duration = 0
					end
				end
			end
		end
	end
end

-- clear aux if there is no ongoing combat (you know, we are not confortable with tables that grow indefinitely...) --

function GT_ImmunitiesVia403_ClearAux()
	-- [Bubb] Each area has its own combat counter. You can check the global script runner's area in this way...
	local globalScriptRunnerId = EngineGlobals.g_pBaldurChitin.m_pObjectGame.m_nAIIndex
	local globalScriptRunner = EEex_GameObject_Get(globalScriptRunnerId) -- CGameSprite
	local globalScriptRunnerArea = globalScriptRunner.m_pArea -- CGameArea
	--
	if globalScriptRunnerArea and globalScriptRunnerArea.m_nBattleSongCounter <= 0 then
		local everyone = EEex_Area_GetAllOfTypeInRange(globalScriptRunnerArea, globalScriptRunner.m_pos.x, globalScriptRunner.m_pos.y, GT_AI_ObjectType["ANYONE"], 0x7FFF, false, nil, nil)
		--
		for _, itrSprite in ipairs(everyone) do
			local aux = EEex_GetUDAux(itrSprite)
			--
			if aux["gt_ImmunitiesVia403_Aux"] then
				aux["gt_ImmunitiesVia403_Aux"] = nil
			end
		end
	end
end
