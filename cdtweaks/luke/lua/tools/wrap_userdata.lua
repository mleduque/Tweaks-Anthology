-- Tool: Function to wrap userdata in a table with dynamic field access --

function GT_LuaTool_WrapUserdata(ud)

	--[[ In Lua, metamethods are special functions that start with double underscores (``__``).
	These are reserved names that Lua recognizes as metamethods, which define how certain operations are handled for tables or userdata.
	The ``__index`` metamethod, for example, is called when a key is not found in a table, allowing us to define custom behavior for missing keys. --]]

	local t = {}

	setmetatable(t, { -- The ``setmetatable`` function in Lua is used to set a metatable for a given table or userdata. This allows us to define custom behavior for operations like indexing, addition, and more
		__index = function(_, key) -- Metamethod: This checks if the userdata has an __index metamethod in its metatable and uses it to access the field
			-- Attempt to access the field using a method or metamethod
			if type(ud) == "userdata" then
				local mt = getmetatable(ud) -- The ``getmetatable`` function in Lua is used to retrieve the metatable of a given table or userdata. A metatable is a table that can change the behavior of another table or userdata by defining certain metamethods
				if mt and mt.__index then
					local value = mt.__index(ud, key)
					if value ~= nil then
						return value
					else
						EEex_Error("Field '" .. key .. "' does not exist on userdata")
						return nil
					end
				else
					print("No __index metamethod found for userdata")
					return nil
				end
			else
				print("Not a userdata")
				return nil
			end
		end,
		__newindex = function(_, key, value) -- Metamethod: This checks if the userdata has a __newindex metamethod in its metatable and uses it to set the field
			-- Attempt to set the field using a method or metamethod
			if type(ud) == "userdata" then
				local mt = getmetatable(ud)
				if mt and mt.__newindex then
					mt.__newindex(ud, key, value)
				else
					EEex_Error("Cannot set field '" .. key .. "' on userdata")
				end
			else
				print("Not a userdata")
			end
		end
	})

	return t -- The table ``t`` appears empty because it doesn't actually store any fields itself; it's acting as a proxy to access the userdata's fields through the metatable. The fields are not stored in ``t`` but are accessed dynamically via the ``__index`` metamethod

end
