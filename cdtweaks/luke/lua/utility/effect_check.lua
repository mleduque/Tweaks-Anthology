-- Utility: check if the specified effect (i.e. opcode, target, power, parameter[1-2], probability[1-2], ...) is present on the given sprite --

function GT_Utility_EffectCheck(CGameSprite, tbl)

	local found = false

	local check = function(effect)
		local wrappedEffect = GT_LuaTool_WrapUserdata(effect)
		for attribute, value in pairs(tbl) do
			found = false
			if wrappedEffect[attribute] == value then
				found = true
			end
		end
		if found then
			return true
		end
	end

	EEex_Utility_IterateCPtrList(CGameSprite.m_timedEffectList, check)
	if not found then
		EEex_Utility_IterateCPtrList(CGameSprite.m_equipedEffectList, check)
	end

	return found

end
