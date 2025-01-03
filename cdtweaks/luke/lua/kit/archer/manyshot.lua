--[[
+---------------------------------------------+
| cdtweaks, Revised Archer Kit (Manyshot HLA) |
+---------------------------------------------+
--]]

-- Shoot two arrows at a time --

%ARCHER_MANYSHOT%P = {

	["typeMutator"] = function(context)
		local actionSources = {
			[EEex_Projectile_DecodeSource.CGameSprite_Swing] = true,
		}
		--
		if not actionSources[context.decodeSource] then
			return
		end
	end,

	["projectileMutator"] = function(context)
		local actionSources = {
			[EEex_Projectile_DecodeSource.CGameSprite_Swing] = true,
		}
		--
		if not actionSources[context.decodeSource] then
			return
		end
		--
		local originatingSprite = context["originatingSprite"] -- CGameSprite
		local targetSprite = EEex_GameObject_Get(originatingSprite.m_targetId) -- CGameSprite
		local targetActiveStats = EEex_Sprite_GetActiveStats(targetSprite) -- CDerivedStats
		--
		local equipment = originatingSprite.m_equipment
		local selectedWeapon = equipment.m_items:get(equipment.m_selectedWeapon) -- CItem
		local selectedWeaponHeader = selectedWeapon.pRes.pHeader -- Item_Header_st
		local selectedWeaponTypeStr = GT_Resource_IDSToSymbol["itemcat"][selectedWeaponHeader.itemType]
		local selectedWeaponAbility = EEex_Resource_GetCItemAbility(selectedWeapon, equipment.m_selectedWeaponAbility) -- Item_ability_st
		-- Bow with arrows equipped || bow with unlimited ammo equipped
		if selectedWeaponTypeStr == "ARROW" or selectedWeaponTypeStr == "BOW" then
			--
			local projectile = context["projectile"] -- CProjectile
			--
			local selectedLauncher = originatingSprite:getLauncher(selectedWeapon:getAbility(equipment.m_selectedWeaponAbility)) -- CItem
			local selectedLauncherDamageBonus = 0
			local weaponProficiencyDamageBonus = 0
			--
			if selectedLauncher then
				local pHeader = selectedLauncher.pRes.pHeader -- Item_Header_st
				--
				local pAbility
				for i = 1, pHeader.abilityCount do
					pAbility = EEex_Resource_GetCItemAbility(selectedLauncher, i - 1) -- Item_ability_st
					if pAbility.type == 0x4 then -- Launcher
						break
					end
				end
				--
				selectedLauncherDamageBonus = pAbility.damageDiceBonus
				--
				local wspecial = GT_Resource_2DA["wspecial"]
				weaponProficiencyDamageBonus = tonumber(wspecial[string.format("%s", EEex_BAnd(EEex_Sprite_GetStat(originatingSprite, pHeader.proficiencyType), 0x7))]["DAMAGE"]) -- consider only the first 3 bits
			end
			-- Add main op12 (launcher + wspecial + ammo)
			do
				local itmAbilityDamageTypeToIDS = {
					[0] = 0x0, -- none (crushing)
					[1] = 0x10, -- piercing
					[2] = 0x0, -- crushing
					[3] = 0x100, -- slashing
					[4] = 0x80, -- missile
					[5] = 0x800, -- non-lethal
					[6] = targetActiveStats.m_nResistPiercing > targetActiveStats.m_nResistCrushing and 0x0 or 0x10, -- piercing/crushing (better)
					[7] = targetActiveStats.m_nResistPiercing > targetActiveStats.m_nResistSlashing and 0x100 or 0x10, -- piercing/slashing (better)
					[8] = targetActiveStats.m_nResistCrushing > targetActiveStats.m_nResistSlashing and 0x0 or 0x100, -- slashing/crushing (worse)
				}
				--
				projectile:AddEffect(GT_Utility_DecodeEffect(
					{
						["effectID"] = 0xC, -- Damage
						["effectAmount"] = (selectedWeaponAbility.damageDiceCount == 0 and selectedWeaponAbility.damageDice == 0 and selectedWeaponAbility.damageDiceBonus == 0) and 0 or (selectedLauncherDamageBonus + weaponProficiencyDamageBonus + selectedWeaponAbility.damageDiceBonus),
						["numDice"] = selectedWeaponAbility.damageDiceCount,
						["diceSize"] = selectedWeaponAbility.damageDice,
						["dwFlags"] = itmAbilityDamageTypeToIDS[selectedWeaponAbility.damageType] * 0x10000,
						--
						["sourceX"] = originatingSprite.m_pos.x,
						["sourceY"] = originatingSprite.m_pos.y,
						["targetX"] = targetSprite.m_pos.x,
						["targetY"] = targetSprite.m_pos.y,
						--
						["sourceID"] = originatingSprite.m_id,
						["sourceTarget"] = targetSprite.m_id,
					}
				))
			end
			-- Add on-hit effect(s) (ammo)
			do
				local currentEffectAddress = EEex_UDToPtr(selectedWeaponHeader) + selectedWeaponHeader.effectsOffset + selectedWeaponAbility.startingEffect * Item_effect_st.sizeof
				--
				for i = 1, selectedWeaponAbility.effectCount do
					pEffect = EEex_PtrToUD(currentEffectAddress, "Item_effect_st")
					--
					projectile:AddEffect(GT_Utility_DecodeEffect(
						{
							["effectID"] = pEffect.effectID,
							["targetType"] = pEffect.targetType,
							["spellLevel"] = pEffect.spellLevel,
							["effectAmount"] = pEffect.effectAmount,
							["dwFlags"] = pEffect.dwFlags,
							["durationType"] = EEex_BAnd(pEffect.durationType, 0xFF),
							["duration"] = pEffect.duration,
							["probabilityUpper"] = pEffect.probabilityUpper,
							["probabilityLower"] = pEffect.probabilityLower,
							["res"] = pEffect.res:get(),
							["numDice"] = pEffect.numDice,
							["diceSize"] = pEffect.diceSize,
							["savingThrow"] = pEffect.savingThrow,
							["saveMod"] = pEffect.saveMod,
							["special"] = pEffect.special,
							--
							["m_school"] = selectedWeaponAbility.school,
							["m_secondaryType"] = selectedWeaponAbility.secondaryType,
							["m_flags"] = EEex_RShift(pEffect.durationType, 8),
							["m_projectileType"] = selectedWeaponAbility.missileType,
							--
							["m_sourceRes"] = selectedWeapon.pRes.resref:get(),
							["m_sourceType"] = 2,
							--
							["sourceX"] = originatingSprite.m_pos.x,
							["sourceY"] = originatingSprite.m_pos.y,
							["targetX"] = targetSprite.m_pos.x,
							["targetY"] = targetSprite.m_pos.y,
							--
							["sourceID"] = originatingSprite.m_id,
							["sourceTarget"] = targetSprite.m_id,
						}
					))
					--
					currentEffectAddress = currentEffectAddress + Item_effect_st.sizeof
				end
			end
			-- Add on-hit effect(s) (launcher)
			if selectedLauncher then
				local pHeader = selectedLauncher.pRes.pHeader -- Item_Header_st
				--
				local pAbility
				for i = 1, pHeader.abilityCount do
					pAbility = EEex_Resource_GetCItemAbility(selectedLauncher, i - 1) -- Item_ability_st
					if pAbility.type == 0x4 then -- Launcher
						break
					end
				end
				--
				local currentEffectAddress = EEex_UDToPtr(pHeader) + pHeader.effectsOffset + pAbility.startingEffect * Item_effect_st.sizeof
				--
				for i = 1, pAbility.effectCount do
					local pEffect = EEex_PtrToUD(currentEffectAddress, "Item_effect_st")
					--
					projectile:AddEffect(GT_Utility_DecodeEffect(
						{
							["effectID"] = pEffect.effectID,
							["targetType"] = pEffect.targetType,
							["spellLevel"] = pEffect.spellLevel,
							["effectAmount"] = pEffect.effectAmount,
							["dwFlags"] = pEffect.dwFlags,
							["durationType"] = EEex_BAnd(pEffect.durationType, 0xFF),
							["duration"] = pEffect.duration,
							["probabilityUpper"] = pEffect.probabilityUpper,
							["probabilityLower"] = pEffect.probabilityLower,
							["res"] = pEffect.res:get(),
							["numDice"] = pEffect.numDice,
							["diceSize"] = pEffect.diceSize,
							["savingThrow"] = pEffect.savingThrow,
							["saveMod"] = pEffect.saveMod,
							["special"] = pEffect.special,
							--
							["m_school"] = pAbility.school,
							["m_secondaryType"] = pAbility.secondaryType,
							["m_flags"] = EEex_RShift(pEffect.durationType, 8),
							["m_projectileType"] = pAbility.missileType,
							--
							["m_sourceRes"] = selectedLauncher.pRes.resref:get(),
							["m_sourceType"] = 2,
							--
							["sourceX"] = originatingSprite.m_pos.x,
							["sourceY"] = originatingSprite.m_pos.y,
							["targetX"] = targetSprite.m_pos.x,
							["targetY"] = targetSprite.m_pos.y,
							--
							["sourceID"] = originatingSprite.m_id,
							["sourceTarget"] = targetSprite.m_id,
						}
					))
					--
					currentEffectAddress = currentEffectAddress + Item_effect_st.sizeof
				end
			end
		end
	end,

	["effectMutator"] = function(context)
		local actionSources = {
			[EEex_Projectile_AddEffectSource.CGameSprite_Swing] = true,
		}
		--
		if not actionSources[context.addEffectSource] then
			return
		end
	end,

}

-- Apply ability --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	-- internal function that applies the actual passive HLA
	local apply = function()
		-- Mark the creature as 'HLA applied'
		sprite:setLocalInt("gtArcherManyshot", 1)
		--
		sprite:applyEffect({
			["effectID"] = 321, -- Remove effects by resource
			["res"] = "%ARCHER_MANYSHOT%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		sprite:applyEffect({
			["effectID"] = 408, -- EEex: Projectile Mutator
			["durationType"] = 9,
			["res"] = "%ARCHER_MANYSHOT%P", -- Lua
			["m_sourceRes"] = "%ARCHER_MANYSHOT%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
	end
	-- Check creature's / class / kit / levels
	local spriteClassStr = GT_Resource_IDSToSymbol["class"][sprite.m_typeAI.m_Class]
	--
	local spriteFlags = sprite.m_baseStats.m_flags
	-- since ``EEex_Opcode_AddListsResolvedListener`` is running after the effect lists have been evaluated, ``m_bonusStats`` has already been added to ``m_derivedStats`` by the engine
	local spriteLevel1 = sprite.m_derivedStats.m_nLevel1
	local spriteLevel2 = sprite.m_derivedStats.m_nLevel2
	local spriteKitStr = GT_Resource_IDSToSymbol["kit"][sprite.m_derivedStats.m_nKit]
	-- Level 25+ && Archer kit
	local applyHLA = spriteKitStr == "FERALAN"
		and ((spriteClassStr == "RANGER" and spriteLevel1 >= 25)
			-- incomplete dual-class characters are not supposed to benefit from this passive feat
			or (spriteClassStr == "CLERIC_RANGER" and (EEex_IsBitUnset(spriteFlags, 0x8) or spriteLevel1 > spriteLevel2) and spriteLevel2 >= 25))
		and EEex_IsBitUnset(spriteFlags, 10) -- not Fallen Ranger
	--
	if sprite:getLocalInt("gtArcherManyshot") == 0 then
		if applyHLA then
			apply()
		end
	else
		if applyHLA then
			-- Do nothing
		else
			-- Mark the creature as 'HLA removed'
			sprite:setLocalInt("gtArcherManyshot", 0)
			--
			sprite:applyEffect({
				["effectID"] = 321, -- Remove effects by resource
				["res"] = "%ARCHER_MANYSHOT%",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)
