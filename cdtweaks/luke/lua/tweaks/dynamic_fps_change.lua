--[[
+-------------------------------------------------------+
| cdtweaks: automatically change FPS during playthrough |
+-------------------------------------------------------+
--]]

-- When in cutscene, lock FPS to 30 --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	--
	if sprite.m_inCutScene == 1 then
		if EEex_CChitin.TIMER_UPDATES_PER_SECOND ~= 30 then
			EEex_CChitin.TIMER_UPDATES_PER_SECOND = 30
		end
	end
end)

-- When in combat, lock FPS to 30. Otherwise, set to 60 --

function cdtweaks_DynamicFPSChange()
	if EEex_LuaAction_Object.m_pArea.m_nBattleSongCounter > 0 then
		if EEex_CChitin.TIMER_UPDATES_PER_SECOND ~= 30 then
			EEex_CChitin.TIMER_UPDATES_PER_SECOND = 30
		end
	else
		if EEex_CChitin.TIMER_UPDATES_PER_SECOND ~= 60 then
			EEex_CChitin.TIMER_UPDATES_PER_SECOND = 60
		end
	end
end
