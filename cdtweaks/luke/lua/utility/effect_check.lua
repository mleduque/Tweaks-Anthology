-- Utility: check if the specified effect (i.e. opcode, target, power, parameter[1-2], probability[1-2], ...) is present on the given sprite --

function GT_Utility_EffectCheck(CGameSprite, table, checkTimed, checkEquiped)

	local found = false -- default return value

	if checkTimed == nil then
		checkTimed = true -- default to true if omitted
	elseif type(checkTimed) ~= "boolean" then
		checkTimed = false -- default to false if not boolean
	end
	if checkEquiped == nil then
		checkEquiped = true
	elseif type(checkEquiped) ~= "boolean" then
		checkEquiped = false
	end

	local check = function(effect)
		if not table["op"] or table["op"] == effect.m_effectId then
			if not table["p1"] or table["p1"] == effect.m_effectAmount then
				if not table["p2"] or table["p2"] == effect.m_dWFlags then
					if not table["res"] or string.upper(table["res"]) == string.upper(effect.m_res:get()) then
						if not table["spec"] or table["spec"] == effect.m_special then
							if not table["effres"] or string.upper(table["effres"]) == string.upper(effect.m_sourceRes:get()) then
								if not table["effvar"] or table["effvar"] == effect.m_scriptName:get() then -- case-sensitive check!
									found = true
									return true
								end
							end
						end
					end
				end
			end
		end
	end

	if checkTimed then
		EEex_Utility_IterateCPtrList(CGameSprite.m_timedEffectList, check)
	end
	if not found then
		if checkEquiped then
			EEex_Utility_IterateCPtrList(CGameSprite.m_equipedEffectList, check)
		end
	end

	return found

end
