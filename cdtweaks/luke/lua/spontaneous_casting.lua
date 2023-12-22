-- Decrement by 1 all memorized divine spells of level spellLevel (level specified by param1 of op402) --

function GTSPCST1(effect, sprite) -- args: CGameEffect, CGameSprite
	-- CGameEffect (this effect, i.e. op402)
	local spellLevel = effect.m_effectAmount -- param1 of op402
	-- CGameSprite (the target object this effect is attached to)
	local spellLevelMemListArray = sprite.m_memorizedSpellsPriest
	-- Get all clerical spells of level spellLevel
	local memList = spellLevelMemListArray:getReference(spellLevel - 1) -- level starts from 0!!!
	local alreadyDecreasedResrefs = {}
	-- Initialize my custom var to 0
	EEex_Sprite_SetLocalInt(sprite, "cdtweaksSpontaneousCasting", 0)
	-- Cycle through all memorized divine spells of level spellLevel
	EEex_Utility_IterateCPtrList(memList, function(memInstance)
		local memInstanceResref = memInstance.m_spellId:get() -- We need to use :get() to export a CResRef field as a Lua string!
		if not alreadyDecreasedResrefs[memInstanceResref] then
			local memFlags = memInstance.m_flags
			if EEex_IsBitSet(memFlags, 0) then
				memInstance.m_flags = EEex_UnsetBit(memFlags, 0)
				-- Set my custom var to 1, meaning that at least one divine spell of level spellLevel is memorized
				EEex_Sprite_SetLocalInt(sprite, "cdtweaksSpontaneousCasting", 1)
				-- Make sure the engine catches the change
				EEex_RunWithStackManager({
					{ ["name"] = "abilityId", ["struct"] = "CAbilityId" } },
					function(manager)
						local abilityId = manager:getUD("abilityId")
						abilityId.m_itemType = 1 -- spell, not an item
						abilityId.m_res:set(memInstanceResref)
						-- CAbilityId* ab, short changeAmount, int remove, int removeSpellIfZero
						sprite:CheckQuickLists(abilityId, -1, 0, 0)
					end
				)
				alreadyDecreasedResrefs[memInstanceResref] = true
			end
		end
	end)
end

-- Check if the caster has at least one divine spell of level spellLevel memorized (feedback string specified by param1 of op402) --

function GTSPCST2(effect, sprite) -- args: CGameEffect, CGameSprite
	local parentResRef = effect.m_sourceRes:get() -- We need to use :get() to export a CResRef field as a Lua string!
	local feedbackString = effect.m_effectAmount -- param1 of op402
	--
	if EEex_Sprite_GetLocalInt(sprite, "cdtweaksSpontaneousCasting") ~= 1 then
		EEex_GameObject_ApplyEffect(sprite,
		{
			["effectID"] = 206, -- Protection from spell
			["effectAmount"] = feedbackString,
			["res"] = parentResRef,
		})
	end
end