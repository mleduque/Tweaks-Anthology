--[[
+-------------------------------------------------------+
| cdtweaks: automatically change FPS during playthrough |
+-------------------------------------------------------+
--]]

-- When in combat or cutscene, lock FPS to 30. Otherwise, set to 60 --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) or not sprite.m_pArea then
		return
	end
	--
	local actuallyInCombat = sprite.m_pArea.m_nBattleSongCounter > 0
	--
	if sprite.m_inCutScene == 1 then
		EEex_GameState_SetGlobalInt("gtCutSceneMode", 1)
		--
		if EEex_CChitin.TIMER_UPDATES_PER_SECOND ~= 30 then
			EEex_CChitin.TIMER_UPDATES_PER_SECOND = 30
		end
	elseif EEex_GameState_GetGlobalInt("gtCutSceneMode") == 0 then
		if actuallyInCombat then
			if EEex_CChitin.TIMER_UPDATES_PER_SECOND ~= 30 then
				EEex_CChitin.TIMER_UPDATES_PER_SECOND = 30
			end
		else
			if EEex_CChitin.TIMER_UPDATES_PER_SECOND ~= 60 then
				EEex_CChitin.TIMER_UPDATES_PER_SECOND = 60
			end
		end
	end
end)

-- Reset helper var to 0 upon exiting cutscene mode --

EEex_Action_AddSpriteStartedActionListener(function(sprite, action)
	if sprite.m_inCutScene == 1 and action.m_actionID == 122 then -- EndCutSceneMode()
		EEex_GameState_SetGlobalInt("gtCutSceneMode", 0)
	end
end)
