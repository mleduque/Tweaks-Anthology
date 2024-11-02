-- Maintain SEQ_READY when counterspelling --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	--
	local conditionalString = EEex_Trigger_ParseConditionalString('!GlobalTimerNotExpired("gtCounterspellSeqReady","LOCALS") \n !StateCheck(Myself,CD_STATE_NOTVALID)')
	local responseString = EEex_Action_ParseResponseString('SetGlobalTimer("gtCounterspellSeqReady","LOCALS",3)')
	--
	if sprite:getLocalInt("gtCounterspellMode") == 1 then
		if sprite.m_curAction.m_actionID == 0 and conditionalString:evalConditionalAsAIBase(sprite) then
			responseString:executeResponseAsAIBaseInstantly(sprite)
			--
			EEex_GameObject_ApplyEffect(sprite,
			{
				["effectID"] = 146, -- cast spl
				["res"] = "%INNATE_COUNTERSPELL%Y", -- set SEQ_READY
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
	--
	conditionalString:free()
	responseString:free()
end)
