
minetest.register_privilege( "astral", {
	description = "Change astral features",
	give_to_singleplayer = false
})



minetest.register_chatcommand( "set_astral_day_offset", {
	params = "<phase>",
	description = "Set the astral day offset to the given value",
	privs = { astral = true },
	func = function( playername, params )
		if params == nil or params == "" then
			minetest.chat_send_player(playername, "Missing day offset number")
		else
			astral.set_astral_day_offset( params )
		end
	end
})



minetest.register_chatcommand( "get_astral_day_offset", {
	description = "Get the astral day offset",
	privs = { astral = true },
	func = function( playername )
		minetest.chat_send_player(playername, "Astral day offset: " .. astral.get_astral_day_offset() )
	end
})



minetest.register_chatcommand( "get_astral_event", {
	description = "Display the current astral event",
	privs = { astral = true },
	func = function( playername )
		local id, name = astral.get_astral_event()
		minetest.chat_send_player(playername, "Astral event: " .. name )
		--minetest.chat_send_player(playername, "Astral event: " .. name .. "   " .. minetest.get_timeofday())
	end
})


minetest.register_chatcommand( "get_astral_day", {
	description = "Display the current astral day",
	privs = { astral = true },
	func = function( playername )
		local month , month_name = astral.get_month()
		local moon_phase , moon_phase_name = astral.get_moon_phase()
		local special_sun, special_moon = astral.get_special_day()
		local event_id, event_name = astral.get_astral_event()
		local time_of_day = minetest.get_timeofday()
		local day = minetest.get_day_count()
		
		minetest.chat_send_player(playername, "Astral day: " .. moon_phase_name .. " (" .. moon_phase .. ") of " .. month_name .. " (" .. month .. ") -- special: ".. special_sun .. " / " .. special_moon .. " => " .. event_name )
		--minetest.chat_send_player(playername, "Astral day: " .. moon_phase_name .. " (" .. moon_phase .. ") of " .. moonth_name .. " (" .. moonth .. ") -- special: ".. special_sun .. " / " .. special_moon .. " => " .. event_name .. " --  D: " .. day .. " H: " .. time_of_day )
	end
})
