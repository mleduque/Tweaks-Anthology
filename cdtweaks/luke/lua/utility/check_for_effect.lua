--[[
+-----------------------------------------------------------------------------------------------------------+
| Check if the specified effect is present on the given sprite                                              |
+-----------------------------------------------------------------------------------------------------------+
| Example usage:                                                                                            |
|      GT_Utility_Sprite_CheckForEffect(CGameSprite, {["m_effectId"] = 0x1, ["m_scriptName"] = "whatever"}) |
+-----------------------------------------------------------------------------------------------------------+
--]]

function GT_Utility_Sprite_CheckForEffect(CGameSprite, table, checkTimed, checkEquiped)
	local found = false  -- default return value

	if checkTimed == nil then
		checkTimed = true  -- default to true if omitted
	elseif type(checkTimed) ~= "boolean" then
		checkTimed = false  -- default to false if not boolean
	end

	if checkEquiped == nil then
		checkEquiped = true
	elseif type(checkEquiped) ~= "boolean" then
		checkEquiped = false
	end

	local check = function(effect)
		local wrappedEffect = GT_LuaTool_WrapUserdata(effect)
		-- Now we can interact with ``effect`` like a table
		local match = true
		for k, v in pairs(table) do
			if type(v) == "string" then
				if wrappedEffect[k]:get() ~= v then
					match = false
					break
				end
			else
				if wrappedEffect[k] ~= v then
					match = false
					break
				end
			end
		end
		--
		if match then
			found = true
			return true
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
