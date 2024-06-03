-- cdtweaks, good aim feat for halflings --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- internal function that applies the actual bonus
	local apply = function()
		-- Mark the creature as 'bonus applied'
		sprite:setLocalInt("cdtweaksGoodAim", 1)
		--
		sprite:applyEffect({
			["effectID"] = 321, -- Remove effects by resource
			["durationType"] = 1,
			["res"] = "CDHLGAIM",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		sprite:applyEffect({
			["effectID"] = 167, -- Missile THAC0 bonus
			["effectAmount"] = 1,
			["durationType"] = 9,
			["m_sourceRes"] = "CDHLGAIM",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		sprite:applyEffect({
			["effectID"] = 142, -- Display portrait icon
			["durationType"] = 9,
			["dwFlags"] = %feedback_icon%,
			["m_sourceRes"] = "CDHLGAIM",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
	end
	-- Check creature's equipment / race
	local equipment = sprite.m_equipment
	local selectedItem = equipment.m_items:get(equipment.m_selectedWeapon)
	local itemHeader = selectedItem.pRes.pHeader
	local itemAbility = EEex_Resource_GetItemAbility(itemHeader, equipment.m_selectedWeaponAbility) -- Item_ability_st
	--
	local spriteRaceStr = GT_Resource_IDSToSymbol["race"][sprite.m_typeAI.m_Race]
	--
	local itemTypeStr = GT_Resource_IDSToSymbol["itemcat"][itemHeader.itemType]
	-- This feat grants a +1 thac0 bonus with throwing weapons (slings, throwing daggers, throwing axes, darts, throwing hammers)
	local applyCondition = (itemTypeStr == "DAGGER" or itemTypeStr == "AXE" or itemTypeStr == "HAMMER" or itemTypeStr == "DART" or itemTypeStr == "SLING")
		and (itemAbility.type == 2 or itemAbility.type == 4) -- Ranged / Launcher
		and spriteRaceStr and spriteRaceStr == "HALFLING"
	--
	if sprite:getLocalInt("cdtweaksGoodAim") == 0 then
		if applyCondition then
			apply()
		end
	else
		if applyCondition then
			-- do nothing
		else
			-- Mark the creature as 'bonus removed'
			sprite:setLocalInt("cdtweaksGoodAim", 0)
			--
			sprite:applyEffect({
				["effectID"] = 321, -- Remove effects by resource
				["durationType"] = 1,
				["res"] = "CDHLGAIM",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)
