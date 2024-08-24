-- cdtweaks, Spellcraft / Counterspell class feat for spellcasters --

local cdtweaks_Spellcraft_CheckForDeafness = function(effect)
	if effect.m_effectId == 0x50 then -- op80
		isDeafened = true
		return true
	end
end

-- cdtweaks, Spellcraft / Counterspell class feat for spellcasters --

local cdtweaks_Counterspell_OppositionSchool = { -- based on iwdee
	[1] = {{5, 8}, "CDCTR#01"}, -- ABJURER countered by ILLUSIONIST and TRANSMUTER
	[2] = {{3, 6}, "CDCTR#02"}, -- CONJURER countered by DIVINER and INVOKER
	[3] = {{6}, "CDCTR#03"}, -- DIVINER countered by INVOKER
	[4] = {{7}, "CDCTR#04"}, -- ENCHANTER countered by NECROMANCER
	[5] = {{1, 7}, "CDCTR#05"}, -- ILLUSIONIST countered by ABJURER and NECROMANCER
	[6] = {{2, 4}, "CDCTR#06"}, -- INVOKER countered by CONJURER and ENCHANTER
	[7] = {{5, 8}, "CDCTR#07"}, -- NECROMANCER countered by ILLUSIONIST and TRANSMUTER
	[8] = {{1}, "CDCTR#08"}, -- TRANSMUTER countered by ABJURER
}

-- cdtweaks, Spellcraft / Counterspell class feat for spellcasters --

local cdtweaks_Counterspell_UniversalCounter = {
	["CLERIC_DISPEL_MAGIC"] = true,
	["WIZARD_REMOVE_MAGIC"] = true,
	["WIZARD_DISPEL_MAGIC"] = true,
	["WIZARD_TRUE_DISPEL_MAGIC"] = true,
}
