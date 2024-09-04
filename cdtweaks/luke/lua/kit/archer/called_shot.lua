-- cdtweaks, revised archer (Called Shot): NWN-ish Called Shot ability. Creatures with no arms --

local cdtweaks_CalledShot_NoArms = {
	{"WEAPON"}, -- GENERAL.IDS
	{"DOG", "WOLF", "ANKHEG", "BASILISK", "CARRIONCRAWLER", "SPIDER", "WYVERN", "SLIME", "BEHOLDER", "DEMILICH", "BEETLE", "BIRD", "WILL-O-WISP"}, -- RACE.IDS
	{"WOLF_WORG", "ELEMENTAL_AIR", "WIZARD_EYE"}, -- CLASS.IDS
	-- ANIMATE.IDS
	{
		"DOOM_GUARD", "DOOM_GUARD_LARGER",
		"SNAKE", "DANCING_SWORD", "BLOB_MIST_CREATURE", "HAKEASHAR", "NISHRUU", "SNAKE_WATER",
		"BOAR_ARCTIC", "BOAR_WILD", "BONEBAT", "WATER_WEIRD"
	},
}

-- cdtweaks, revised archer (Called Shot): NWN-ish Called Shot ability. Creatures with no legs --

local cdtweaks_CalledShot_NoLegs = {
	{"WEAPON"}, -- GENERAL.IDS
	{"ANKHEG", "WYVERN", "SLIME", "BEHOLDER", "MEPHIT", "IMP", "YUANTI", "DEMILICH", "FEYR", "SALAMANDER", "BIRD", "WILL-O-WISP"}, -- RACE.IDS
	{"MEPHIT", "ELEMENTAL_AIR", "WIZARD_EYE"}, -- CLASS.IDS
	-- ANIMATE.IDS
	{
		"DOOM_GUARD", "DOOM_GUARD_LARGER",
		"IMP", "SNAKE", "DANCING_SWORD", "MIST_CREATURE", "BLOB_MIST_CREATURE", "HAKEASHAR", "NISHRUU", "SNAKE_WATER",
		"LEMURE", "BONEBAT", "SHADOW_SMALL", "SHADOW_LARGE", "WATER_WEIRD"
	},
}

-- cdtweaks, revised archer (Called Shot): NWN-ish Called Shot ability --

function %ARCHER_CALLED_SHOT%(CGameEffect, CGameSprite)
	local sourceSprite = EEex_GameObject_Get(CGameEffect.m_sourceId) -- CGameSprite
	-- Check creature's equipment
	local equipment = sourceSprite.m_equipment
	local selectedWeapon = equipment.m_items:get(equipment.m_selectedWeapon)
	local selectedWeaponHeader = selectedWeapon.pRes.pHeader
	local selectedWeaponTypeStr = GT_Resource_IDSToSymbol["itemcat"][selectedWeaponHeader.itemType]
	-- Get level
	local sourceLevel = sourceSprite.m_derivedStats.m_nLevel1 + sourceSprite.m_bonusStats.m_nLevel1
	if sourceSprite.m_typeAI.m_Class == 18 then -- CLERIC_RANGER
		sourceLevel = sourceSprite.m_derivedStats.m_nLevel2 + sourceSprite.m_bonusStats.m_nLevel2
	end
	--
	local savebonus = math.floor((sourceLevel - 1) / 4) -- +1 every 4 levels, starting at 0
	if savebonus > 7 then
		savebonus = 7 -- cap at 7
	end
	--
	local inWeaponRange = EEex_Trigger_ParseConditionalString("InWeaponRange(EEex_LuaObject)")
	local attackOneRound = EEex_Action_ParseResponseString("AttackOneRound(EEex_LuaObject)")
	--
	local stats = GT_Resource_SymbolToIDS["stats"]
	--
	local targetGeneralStr = GT_Resource_IDSToSymbol["general"][CGameSprite.m_typeAI.m_General]
	local targetRaceStr = GT_Resource_IDSToSymbol["race"][CGameSprite.m_typeAI.m_Race]
	local targetClassStr = GT_Resource_IDSToSymbol["class"][CGameSprite.m_typeAI.m_Class]
	local targetAnimateStr = GT_Resource_IDSToSymbol["animate"][CGameSprite.m_animation.m_animation.m_animationID]
	--
	local targetIDS = {targetGeneralStr, targetRaceStr, targetClassStr, targetAnimateStr}
	-- Bow with arrows equipped || bow with unlimited ammo equipped
	if selectedWeaponTypeStr == "ARROW" or selectedWeaponTypeStr == "BOW" then
		if CGameEffect.m_effectAmount == 0 then
			EEex_LuaObject = CGameSprite -- must be global
			-- check range
			if inWeaponRange:evalConditionalAsAIBase(sourceSprite) then
				--
				local effectCodes = {
					{["op"] = 401, ["p2"] = 1, ["p1"] = 1, ["tmg"] = 10, ["dur"] = 1, ["spec"] = stats["GT_IGNORE_ACTION_ADD_SPRITE_STARTED_ACTION_LISTENER"]}, -- set extended stat
					{["op"] = 167, ["tmg"] = 1, ["p1"] = -4}, -- missile thac0 bonus
					{["op"] = 249, ["tmg"] = 1, ["res"] = CGameEffect.m_sourceRes:get()}, -- ranged hit effect
					{["op"] = 142, ["tmg"] = 1, ["p2"] = 82} -- icon: called shot
					{["op"] = 408, ["tmg"] = 1, ["res"] = "%ARCHER_CALLED_SHOT%P"}, -- projectile mutator
				}
				--
				for _, attributes in ipairs(effectCodes) do
					sourceSprite:applyEffect({
						["effectID"] = attributes["op"] or -1,
						["effectAmount"] = attributes["p1"] or 0,
						["dwFlags"] = attributes["p2"] or 0,
						["special"] = attributes["spec"] or 0,
						["res"] = attributes["res"] or "",
						["duration"] = attributes["dur"] or 0,
						["durationType"] = attributes["tmg"] or 0,
						["m_sourceRes"] = "%ARCHER_CALLED_SHOT%",
						["m_sourceType"] = CGameEffect.m_sourceType,
						["sourceID"] = sourceSprite.m_id,
						["sourceTarget"] = sourceSprite.m_id,
					})
				end
				--
				attackOneRound:queueResponseOnAIBase(sourceSprite)
			else
				CGameSprite:applyEffect({
					["effectID"] = 139, -- display string
					["effectAmount"] = %feedback_strref_outOfRange%,
					["sourceID"] = CGameEffect.m_sourceId,
					["sourceTarget"] = CGameEffect.m_sourceTarget,
				})
			end
		elseif CGameEffect.m_effectAmount == 1 then
			-- Called Shot (Arms): -2 thac0 penalty
			local found = false
			--
			do
				for index, symbolList in ipairs(cdtweaks_CalledShot_NoArms) do
					for _, symbol in ipairs(symbolList) do
						if targetIDS[index] == symbol then
							found = true
							break
						end
					end
				end
			end
			--
			if not found then
				local effectCodes = {
					{["op"] = 54, ["p1"] = -2, ["dur"] = 24}, -- base thac0 bonus
					{["op"] = 139, ["p1"] = %feedback_strref_thac0Mod%} -- feedback string
				}
				--
				for _, attributes in ipairs(effectCodes) do
					CGameSprite:applyEffect({
						["effectID"] = attributes["op"] or -1,
						["effectAmount"] = attributes["p1"] or 0,
						["duration"] = attributes["dur"] or 0,
						["savingThrow"] = 0x2, -- save vs. breath
						["saveMod"] = -1 * savebonus,
						["m_sourceRes"] = "%ARCHER_CALLED_SHOT%B",
						["m_sourceType"] = 1,
						["sourceID"] = CGameEffect.m_sourceId,
						["sourceTarget"] = CGameEffect.m_sourceTarget,
					})
				end
			else
				CGameSprite:applyEffect({
					["effectID"] = 139, -- display string
					["effectAmount"] = %feedback_strref_immune%,
					["sourceID"] = CGameEffect.m_sourceId,
					["sourceTarget"] = CGameEffect.m_sourceTarget,
				})
			end
		elseif CGameEffect.m_effectAmount == 2 then
			-- Called Shot (Legs): -2 dex penalty, 20% movement rate penalty
			local found = false
			--
			do
				for index, symbolList in ipairs(cdtweaks_CalledShot_NoLegs) do
					for _, symbol in ipairs(symbolList) do
						if targetIDS[index] == symbol then
							found = true
							break
						end
					end
				end
			end
			--
			if not found then
				local targetDEX = CGameSprite.m_derivedStats.m_nDEX + CGameSprite.m_bonusStats.m_nDEX
				--
				local effectCodes = {
					{["op"] = 15, ["p1"] = (targetDEX <= 1) and 0 or ((targetDEX > 2) and -2 or -1), ["dur"] = 24}, -- dex bonus
					{["op"] = 176, ["p1"] = 80, ["p2"] = 5, ["dur"] = 24} -- movement rate bonus (mode: multiply %)
					{["op"] = 139, ["p1"] = %feedback_strref_dexMod%} -- feedback string
				}
				--
				for _, attributes in ipairs(effectCodes) do
					CGameSprite:applyEffect({
						["effectID"] = attributes["op"] or -1,
						["effectAmount"] = attributes["p1"] or 0,
						["dwFlags"] = attributes["p2"] or 0,
						["duration"] = attributes["dur"] or 0,
						["savingThrow"] = 0x2, -- save vs. breath
						["saveMod"] = -1 * savebonus,
						["m_sourceRes"] = "%ARCHER_CALLED_SHOT%C",
						["m_sourceType"] = 1,
						["sourceID"] = CGameEffect.m_sourceId,
						["sourceTarget"] = CGameEffect.m_sourceTarget,
					})
				end
			else
				CGameSprite:applyEffect({
					["effectID"] = 139, -- display string
					["effectAmount"] = %feedback_strref_immune%,
					["sourceID"] = CGameEffect.m_sourceId,
					["sourceTarget"] = CGameEffect.m_sourceTarget,
				})
			end
		end
	else
		sourceSprite:applyEffect({
			["effectID"] = 139, -- display string
			["effectAmount"] = %feedback_strref_bowOnly%,
			["sourceID"] = sourceSprite.m_id,
			["sourceTarget"] = sourceSprite.m_id,
		})
	end
	--
	inWeaponRange:free()
	attackOneRound:free()
end

-- cdtweaks, revised archer (Called Shot): NWN-ish Called Shot ability. Make sure one and only one attack roll is performed --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	--
	local equipment = sprite.m_equipment
	local selectedWeapon = equipment.m_items:get(equipment.m_selectedWeapon)
	local selectedWeaponHeader = selectedWeapon.pRes.pHeader
	local selectedWeaponTypeStr = GT_Resource_IDSToSymbol["itemcat"][selectedWeaponHeader.itemType]
	--
	if sprite:getLocalInt("cdtweaksCalledShot") == 1 then
		local calledShotMode = false
		--
		EEex_Utility_IterateCPtrList(sprite.m_timedEffectList, function(effect)
			if effect.m_effectId == 249 and (effect.m_res:get() == "%ARCHER_CALLED_SHOT%B" or effect.m_res:get() == "%ARCHER_CALLED_SHOT%C") then
				calledShotMode = true
				return true
			end
		end)
		--
		if calledShotMode then
			if sprite.m_startedSwing == 1 and sprite:getLocalInt("gtCGameSpriteStartedSwing") == 0 and (selectedWeaponTypeStr == "ARROW" or selectedWeaponTypeStr == "BOW") then
				sprite:setLocalInt("gtCGameSpriteStartedSwing", 1)
			elseif (sprite.m_startedSwing == 0 and sprite:getLocalInt("gtCGameSpriteStartedSwing") == 1) or not (selectedWeaponTypeStr == "ARROW" or selectedWeaponTypeStr == "BOW") then
				sprite:setLocalInt("gtCGameSpriteStartedSwing", 0)
				--
				sprite.m_curAction.m_actionID = 0 -- nuke current action
				--
				EEex_GameObject_ApplyEffect(sprite,
				{
					["effectID"] = 321, -- remove effects by resource
					["res"] = "%ARCHER_CALLED_SHOT%",
					["sourceID"] = sprite.m_id,
					["sourceTarget"] = sprite.m_id,
				})
			end
		else
			-- in case the character dies while swinging...
			if sprite:getLocalInt("gtCGameSpriteStartedSwing") == 1 then
				sprite:setLocalInt("gtCGameSpriteStartedSwing", 0)
			end
		end
	end
end)

-- cdtweaks, revised archer (Called Shot): NWN-ish Called Shot ability. Make sure it cannot be disrupted --

EEex_Action_AddSpriteStartedActionListener(function(sprite, action)
	if sprite:getLocalInt("cdtweaksCalledShot") == 1 then
		local stats = GT_Resource_SymbolToIDS["stats"]
		--
		if action.m_actionID == 31 and (action.m_string1.m_pchData:get() == "%ARCHER_CALLED_SHOT%B" or action.m_string1.m_pchData:get() == "%ARCHER_CALLED_SHOT%C") then
			if EEex_Sprite_GetCastTimer(sprite) == -1 then
				action.m_actionID = 113 -- ForceSpell()
				--
				sprite.m_castCounter = 0
			else
				action.m_actionID = 0
				--
				EEex_GameObject_ApplyEffect(sprite,
				{
					["effectID"] = 321, -- remove effects by resource
					["res"] = "%ARCHER_CALLED_SHOT%",
					["sourceID"] = sprite.m_id,
					["sourceTarget"] = sprite.m_id,
				})
				EEex_GameObject_ApplyEffect(sprite,
				{
					["effectID"] = 139, -- display string
					["effectAmount"] = %feedback_strref_auraFree%,
					["sourceID"] = sprite.m_id,
					["sourceTarget"] = sprite.m_id,
				})
			end
		else
			if EEex_Sprite_GetStat(sprite, stats["GT_IGNORE_ACTION_ADD_SPRITE_STARTED_ACTION_LISTENER"]) == 0 then
				EEex_GameObject_ApplyEffect(sprite,
				{
					["effectID"] = 321, -- remove effects by resource
					["res"] = "%ARCHER_CALLED_SHOT%",
					["sourceID"] = sprite.m_id,
					["sourceTarget"] = sprite.m_id,
				})
			end
		end
	end
end)

-- cdtweaks, revised archer (Called Shot): NWN-ish Called Shot ability. Cannot be used with AoE missiles (see f.i. Arrow of Detonation) --

%ARCHER_CALLED_SHOT%P = {

	["typeMutator"] = function(context)
		local actionSources = {
			[EEex_Projectile_DecodeSource.CGameSprite_Swing] = true,
		}
		--
		local calledShotMode = false
		local originatingSprite = context["originatingSprite"] -- CGameSprite
		--
		EEex_Utility_IterateCPtrList(originatingSprite.m_timedEffectList, function(effect)
			if effect.m_effectId == 249 and (effect.m_res:get() == "%ARCHER_CALLED_SHOT%B" or effect.m_res:get() == "%ARCHER_CALLED_SHOT%C") then
				calledShotMode = true
				return true
			end
		end)
		--
		if not (actionSources[context.decodeSource] and calledShotMode) then
			return
		end
	end,

	["projectileMutator"] = function(context)
		local actionSources = {
			[EEex_Projectile_DecodeSource.CGameSprite_Swing] = true,
		}
		--
		local calledShotMode = false
		local originatingSprite = context["originatingSprite"] -- CGameSprite
		--
		EEex_Utility_IterateCPtrList(originatingSprite.m_timedEffectList, function(effect)
			if effect.m_effectId == 249 and (effect.m_res:get() == "%ARCHER_CALLED_SHOT%B" or effect.m_res:get() == "%ARCHER_CALLED_SHOT%C") then
				calledShotMode = true
				return true
			end
		end)
		--
		if not (actionSources[context.decodeSource] and calledShotMode) then
			return
		end
		--
		local projectile = context["projectile"] -- CProjectile
		--
		if EEex_Projectile_IsOfType(projectile, EEex_Projectile_Type["CProjectileArea"]) then
			originatingSprite.m_curAction.m_actionID = 0 -- nuke current action
			--
			originatingSprite:applyEffect({
				["effectID"] = 321, -- remove effects by resource
				["res"] = "%ARCHER_CALLED_SHOT%",
				["sourceID"] = originatingSprite.m_id,
				["sourceTarget"] = originatingSprite.m_id,
			})
			originatingSprite:applyEffect({
				["effectID"] = 139, -- display string
				["effectAmount"] = %feedback_strref_AoE%,
				["sourceID"] = originatingSprite.m_id,
				["sourceTarget"] = originatingSprite.m_id,
			})
		end
	end,

	["effectMutator"] = function(context)
		local actionSources = {
			[EEex_Projectile_AddEffectSource.CGameSprite_Swing] = true,
		}
		--
		local calledShotMode = false
		local originatingSprite = context["originatingSprite"] -- CGameSprite
		--
		EEex_Utility_IterateCPtrList(originatingSprite.m_timedEffectList, function(effect)
			if effect.m_effectId == 249 and (effect.m_res:get() == "%ARCHER_CALLED_SHOT%B" or effect.m_res:get() == "%ARCHER_CALLED_SHOT%C") then
				calledShotMode = true
				return true
			end
		end)
		--
		if not (actionSources[context.addEffectSource] and calledShotMode) then
			return
		end
	end,
}

-- cdtweaks, revised archer (Called Shot): NWN-ish Called Shot ability. Gain ability --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	-- internal function that grants the ability
	local gain = function()
		-- Mark the creature as 'feat granted'
		sprite:setLocalInt("cdtweaksCalledShot", 1)
		--
		local effectCodes = {
			{["op"] = 172, ["res"] = "%ARCHER_CALLED_SHOT%B"}, -- remove spell
			{["op"] = 171, ["res"] = "%ARCHER_CALLED_SHOT%B"}, -- give spell
			{["op"] = 172, ["res"] = "%ARCHER_CALLED_SHOT%C"}, -- remove spell
			{["op"] = 171, ["res"] = "%ARCHER_CALLED_SHOT%C"}, -- give spell
		}
		--
		for _, attributes in ipairs(effectCodes) do
			sprite:applyEffect({
				["effectID"] = attributes["op"] or -1,
				["res"] = attributes["res"] or "",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
	-- Check creature's class / kit
	local spriteKitStr = GT_Resource_IDSToSymbol["kit"][sprite.m_derivedStats.m_nKit]
	--
	local spriteClassStr = GT_Resource_IDSToSymbol["class"][sprite.m_typeAI.m_Class]
	--
	local spriteFlags = sprite.m_baseStats.m_flags
	-- since ``EEex_Opcode_AddListsResolvedListener`` is running after the effect lists have been evaluated, ``m_bonusStats`` has already been added to ``m_derivedStats`` by the engine
	local spriteLevel1 = sprite.m_derivedStats.m_nLevel1
	local spriteLevel2 = sprite.m_derivedStats.m_nLevel2
	--
	local gainAbility = spriteKitStr == "FERALAN"
		and (spriteClassStr == "RANGER"
			or (spriteClassStr == "CLERIC_RANGER" and (EEex_IsBitUnset(spriteFlags, 0x8) or spriteLevel1 > spriteLevel2)))
		and EEex_IsBitUnset(spriteFlags, 10) -- must not be fallen
	--
	if sprite:getLocalInt("cdtweaksCalledShot") == 0 then
		if gainAbility then
			gain()
		end
	else
		if gainAbility then
			-- do nothing
		else
			-- Mark the creature as 'feat removed'
			sprite:setLocalInt("cdtweaksCalledShot", 0)
			--
			sprite:applyEffect({
				["effectID"] = 172, -- remove spell
				["res"] = "%ARCHER_CALLED_SHOT%B",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
			sprite:applyEffect({
				["effectID"] = 172, -- remove spell
				["res"] = "%ARCHER_CALLED_SHOT%C",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
			sprite:applyEffect({
				["effectID"] = 321, -- remove effects by resource
				["res"] = "%ARCHER_CALLED_SHOT%",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)
