-- cdtweaks, Spellcraft / Counterspell class feat for spellcasters --

local cdtweaks_Counterspell_OppositionSchool = { -- based on iwdee
	[1] = {{5, 8}, "%INNATE_COUNTERSPELL%A"}, -- ABJURER countered by ILLUSIONIST and TRANSMUTER
	[2] = {{3, 6}, "%INNATE_COUNTERSPELL%B"}, -- CONJURER countered by DIVINER and INVOKER
	[3] = {{6}, "%INNATE_COUNTERSPELL%C"}, -- DIVINER countered by INVOKER
	[4] = {{7}, "%INNATE_COUNTERSPELL%D"}, -- ENCHANTER countered by NECROMANCER
	[5] = {{1, 7}, "%INNATE_COUNTERSPELL%E"}, -- ILLUSIONIST countered by ABJURER and NECROMANCER
	[6] = {{2, 4}, "%INNATE_COUNTERSPELL%F"}, -- INVOKER countered by CONJURER and ENCHANTER
	[7] = {{5, 8}, "%INNATE_COUNTERSPELL%G"}, -- NECROMANCER countered by ILLUSIONIST and TRANSMUTER
	[8] = {{1}, "%INNATE_COUNTERSPELL%H"}, -- TRANSMUTER countered by ABJURER
}

-- cdtweaks, Spellcraft / Counterspell class feat for spellcasters --

local cdtweaks_Counterspell_UniversalCounter = {
	["CLERIC_DISPEL_MAGIC"] = true,
	["WIZARD_REMOVE_MAGIC"] = true,
	["WIZARD_DISPEL_MAGIC"] = true,
	["WIZARD_TRUE_DISPEL_MAGIC"] = true,
}

-- cdtweaks, Spellcraft / Counterspell class feat for spellcasters. Set SEQ_READY when idle --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	--
	local cdStateNotValid = EEex_Trigger_ParseConditionalString("StateCheck(Myself,CD_STATE_NOTVALID)")
	--
	if sprite:getLocalInt("cdtweaksCounterspell") == 1 then
		if sprite.m_nSequence ~= 7 and sprite.m_curAction.m_actionID == 0 and not cdStateNotValid:evalConditionalAsAIBase(sprite) then
			EEex_GameObject_ApplyEffect(sprite,
			{
				["effectID"] = 138, -- set animation sequence
				["dwFlags"] = 7, -- SEQ_READY
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
	--
	cdStateNotValid:free()
end)
