-- cdtweaks: NWN Dark Blessing feat for Blackguards --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- internal function that applies the actual bonus
	local apply = function(bonus)
		-- Update var
		sprite:setLocalInt("cdtweaksDarkBlessingHelper", bonus)
		-- Mark the creature as 'bonus applied'
		sprite:setLocalInt("cdtweaksDarkBlessing", 1)
		--
		sprite:applyEffect({
			["effectID"] = 321, -- Remove effects by resource
			["durationType"] = 1,
			["res"] = "CDDRKBLS",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		sprite:applyEffect({
			["effectID"] = 325, -- All saving throws bonus
			["durationType"] = 9,
			["effectAmount"] = bonus,
			["m_sourceRes"] = "CDDRKBLS",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		sprite:applyEffect({
			["effectID"] = 142, -- Display portrait icon
			["durationType"] = 9,
			["dwFlags"] = %feedback_icon_blackguard%,
			["m_sourceRes"] = "CDDRKBLS",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
	end
	-- Check creature's class / kit / flags / CHR
	local spriteClassStr = GT_Resource_IDSToSymbol["class"][sprite.m_typeAI.m_Class]
	--
	local spriteKitStr = GT_Resource_IDSToSymbol["kit"][EEex_BOr(EEex_LShift(sprite.m_baseStats.m_mageSpecUpperWord, 16), sprite.m_baseStats.m_mageSpecialization)]
	--
	local spriteFlags = sprite.m_baseStats.m_flags
	-- Charisma => bonus
	local darkBlessing = {
		["0"] = -5,
		["1"] = -5,
		["2"] = -4,
		["3"] = -4,
		["4"] = -3,
		["5"] = -3,
		["6"] = -2,
		["7"] = -2,
		["8"] = -1,
		["9"] = -1,
		["10"] = 0,
		["11"] = 0,
		["12"] = 1,
		["13"] = 1,
		["14"] = 2,
		["15"] = 2,
		["16"] = 3,
		["17"] = 3,
		["18"] = 4,
		["19"] = 4,
		["20"] = 5,
		["21"] = 5,
		["22"] = 6,
		["23"] = 6,
		["24"] = 7,
		["25"] = 7,
	}
	-- since ``EEex_Opcode_AddListsResolvedListener`` is running after the effect lists have been evaluated, ``m_bonusStats`` has already been added to ``m_derivedStats`` by the engine
	local spriteCharisma = sprite.m_derivedStats.m_nCHR
	--
	local bonus = darkBlessing[string.format("%s", spriteCharisma)]
	-- The blackguard adds its charisma bonus to all saving throws (provided it is not fallen)
	local applyCondition = spriteClassStr == "PALADIN" and spriteKitStr == "Blackguard" and bonus and EEex_IsBitUnset(spriteFlags, 0x9)
	--
	if sprite:getLocalInt("cdtweaksDarkBlessing") == 0 then
		if applyCondition then
			apply(bonus)
		end
	else
		if applyCondition then
			-- Check if Charisma has changed since the last application
			if bonus ~= sprite:getLocalInt("cdtweaksDarkBlessingHelper") then
				apply(bonus)
			end
		else
			-- Mark the creature as 'bonus removed'
			sprite:setLocalInt("cdtweaksDarkBlessing", 0)
			--
			sprite:applyEffect({
				["effectID"] = 321, -- Remove effects by resource
				["durationType"] = 1,
				["res"] = "CDDRKBLS",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)
