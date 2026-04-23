
local mod_storage = minetest.get_mod_storage()

-- Data
local moon_phase_count = 8
local moon_phase = 1
local special_moon = "normal"
local special_sun = "normal"
local special_month = "normal"
local moon_texture = "moon-0.png"
local moon_visible = true
local moon_scale = 0.8

local sun_texture = "sun.png"
local sun_scale = 3

local astral_day_offset = mod_storage:get_int( "astral_day_offset" )
if astral_day_offset == 0 then
	-- First time loading the mod, init it
	astral_day_offset = math.random( 1 , 10000 )
	mod_storage:set_int( "astral_day_offset", astral_day_offset )
end



local moon_phase_name = {
	[0] = "New Moon" ,
	"Waxing Crescent" ,
	"First Quarter" ,
	"Waxing Gibbous" ,
	"Full Moon" ,
	"Waning Gibbous" ,
	"Last Quarter" ,
	"Waning Crescent"
}

local month_cycle = {
	{ special = "normal" , name = "Wolf Month" } ,
	{ special = "black_moon" , name = "Crow Month" } ,
	{ special = "rainbow_sun" , name = "Ouroboros Month" } ,
	{ special = "blue_moon" , name = "Whisper Month" } ,
	{ special = "normal" , name = "Patience Month" } ,	-- or perseverance?
	{ special = "harvest_moon" , name = "Unicorn Month" } ,
	{ special = "crescent_sun" , name = "Wedding Month" } ,
	{ special = "blood_moon" , name = "Phoenix Month" } ,
	{ special = "normal" , name = "Child month" } ,
	{ special = "golden_moon" , name = "Golden Month" } ,
	{ special = "ring_sun" , name = "Emerald Month" } ,
	{ special = "super_moon" , name = "World Month" } ,
	{ special = "ring_of_fire" , name = "Month" } ,
	{ special = "vibrant_sun" , name = "Ruby Month" } ,
	{ special = "pink_moon", name = "Pink Month" } ,
	{ special = "blood_moon2" , name = "Some Month" } ,
}



local special_moon_config = {
	blood_moon = {
		name = "Blood Moon",
		at_phase = 4,
		texture = "blood-moon.png",
		scale = 2,
		sky_color = "#a74ddfff",
		horizon_color = "#ff44aaff",
		star_color = "#ffcbcb70" ,
	} ,
	pink_moon = {
		name = "Pink Moon",
		at_phase = 4,
		texture = "pink_moon.png",
		scale = 3.0,
		sky_color = "#db00ff",
		horizon_color = "#9e00b8",
		star_color = "#8b00a2",
	} ,
	blue_moon = {
		name = "Blue Moon",
		at_phase = 4,
		texture = "blue-moon.png",
		scale = 2,
		sky_color = "#57ff9dff",
		horizon_color = "#73ffccff" ,
		star_color = "#b0cccc70" ,
	} ,
	harvest_moon = {
		name = "harvest_moon",
		at_phase = 4,
		texture = "harvest_moon.png",
		scale = 4.5,
		sky_color = "#993300",
		horizon_color = "#7c2a00" ,
		star_color = "#9c2003" ,
	} ,
	black_moon = {
		name = "Black Moon",
		at_phase = 0,
		texture = "black-moon.png",
		scale = 2.8,
		sky_color = "#579dffff",
		horizon_color = "#73aeffff" ,
	} ,
	golden_moon = {
		name = "Golden Crescent",
		at_phase = 1,
		texture = "golden-moon.png",
		scale = 2.2,
		sky_color = "#9d57ffff",
		horizon_color = "#ae73ffff" ,
		star_color = "#ffff9088" ,
	} ,
	super_moon = {
		name = "Super Moon",
		at_phase = 4,
		texture = "super-moon.png",
		scale = 5,
		sky_color = "#579dffff",
		horizon_color = "#73aeffff"
	} ,
	crescent_sun = {
		name = "Crescent Sun",
		at_phase = 0,
		at_phase2 = 1,
		no_astral_event = true,
		not_visible = true,
		texture = "moon-0.png",
		sky_color = "#579dffff",
		horizon_color = "#73aeffff" ,
	} ,
	ring_sun = {
		name = "Ring Sun",
		at_phase = 0,
		at_phase2 = 1,
		no_astral_event = true,
		not_visible = true,
		texture = "moon-0.png",
		sky_color = "#579dffff",
		horizon_color = "#73aeffff" ,
	} ,
	ring_of_fire = {
		name = "Ring Of_Fire",
		at_phase = 0,
		texture = "ring_of_fire.png",
		scale = 2,
		sky_color = "#000000ff",
		horizon_color = "#2d1200",
		time_speed = 88,
	} ,
	blood_moon2 = {
		name = "Blood Moon Large",
		at_phase = 0,
		texture = "blood_moon_2.png",
		scale = 2.5,
		sky_color = "#a74ddfff",
		horizon_color = "#ff44aaff",
		star_color = "#ffcbcb70" ,
	} ,
}



local special_sun_config = {
	rainbow_sun = {
		name = "Rainbow Sun",
		at_phase = 6,
		texture = "rainbow-sun.png",
		scale = 5,
	} ,
	crescent_sun = {
		name = "Crescent Sun",
		at_phase = 0,
		texture = "crescent-sun.png",
		scale = 3,
		sky_color = "#549aaa",
		horizon_color = "#5a90a0",
	} ,
	vibrant_sun = {
		name = "Vibrant Sun",
		at_phase = 0,
		texture = "vibrant_sun.png",
		scale = 3,
		sky_color = "#d16000",
		horizon_color = "#6c545f",
	} ,
	ring_sun = {
		name = "Ring Sun",
		at_phase = 0,
		texture = "ring-sun.png",
		scale = 3,
		sky_color = "#546a6a",
		horizon_color = "#5a6868",
	} ,
}

local moon_phase_sky_color = {
	"#000000ff",
	"#1d293aff",
	"#1c4b8dff",
	"#206affff",
	"#579dffff",
	"#206affff",
	"#1c4b8dff",
	"#1d293aff",
}

local moon_phase_horizon_color = {
	"#000000ff",
	"#243347ff",
	"#235fb3ff",
	"#4090ffff",
	"#73aeffff",
	"#4090ff",
	"#3079dfff",
	"#173154ff",
}

local normal_star_color = "#ebebff69"
local star_color = normal_star_color

local normal_cloud_density = 0.4
local cloud_density = normal_cloud_density

local normal_night_sky_color = "#006aff"
local normal_night_horizon_color = "#4090ff"
local night_sky_color = moon_phase_sky_color[ 0 ]
local night_horizon_color = moon_phase_horizon_color[ 0 ]
local normal_moon_scale = 0.8

local normal_day_sky_color = "#8cbafa"
local normal_day_horizon_color = "#9bc1f0"
local day_sky_color = normal_day_sky_color
local day_horizon_color = normal_day_horizon_color
local normal_sun_scale = 3

local moon_day = nil
local sun_day = nil
local astral_event = "none"
local astral_event_name = "none"
local month = 1



local function compute_moon()
	local old_moon_day = moon_day
	moon_day = minetest.get_day_count() + astral_day_offset
	
	-- For the moon, changed at the middle of the day to avoid glitches
	if minetest.get_timeofday() > 0.5 then
		moon_day = moon_day + 1
	end
	
	-- Nothing changed?
	if old_moon_day == moon_day then
		return false
	end

	moon_visible = true
	
	moon_phase = moon_day % moon_phase_count

	local cycle_count = math.floor( moon_day / moon_phase_count )
	month = 1 + cycle_count % #month_cycle
	special_month = month_cycle[ month ].special

	local config = special_moon_config[ special_month ]
	
	if
		special_month == "normal"
		or not config
		or ( config.at_phase ~= moon_phase and config.at_phase2 ~= moon_phase )
	then
		special_moon = "normal"
		moon_texture = "moon-" .. moon_phase .. ".png"
		moon_scale = normal_moon_scale
		night_sky_color = moon_phase_sky_color[ 1 + moon_phase ]
		night_horizon_color = moon_phase_horizon_color[ 1 + moon_phase ]

		-- Only the moon can change stars and clouds
		star_color = normal_star_color
		cloud_density = normal_cloud_density

		return true
	end
	
	special_moon = special_month
	moon_texture = config.texture
	if config.not_visible then moon_visible = false end
	moon_scale = config.scale
	night_sky_color = config.sky_color
	night_horizon_color = config.horizon_color
	
	-- Only the moon can change stars and clouds
	star_color = config.star_color or normal_star_color
	cloud_density = 0.2
	
	return true
end



local function compute_sun()
	local old_sun_day = sun_day
	sun_day = minetest.get_day_count() + astral_day_offset
	
	--if minetest.get_timeofday() > 0.25 then sun_day = sun_day + 1 end
	
	-- Nothing changed?
	if old_sun_day == sun_day then
		return false
	end

	-- Fake (local) moon_phase
	local moon_phase = sun_day % moon_phase_count

	local cycle_count = math.floor( sun_day / moon_phase_count )
	
	-- Fake (local) month and special_month
	local month = 1 + cycle_count % #month_cycle
	local special_month = month_cycle[ month ].special
	
	local config = special_sun_config[ special_month ]
	
	if
		special_month == "normal"
		or not config
		or config.at_phase ~= moon_phase
	then
		special_sun = "normal"
		sun_texture = "sun.png"
		sun_scale = normal_sun_scale
		day_sky_color = normal_day_sky_color
		day_horizon_color = normal_day_horizon_color

		return true
	end
	
	special_sun = special_month
	sun_texture = config.texture or "sun.png"
	sun_scale = config.scale or normal_sun_scale
	day_sky_color = config.sky_color or normal_day_sky_color
	day_horizon_color = config.horizon_color or normal_day_horizon_color
	
	return true
end



local function compute_astral()
	local moon_changed = compute_moon()
	local sun_changed = compute_sun()

	local moon_config = special_moon_config[ special_moon ]
	local sun_config = special_sun_config[ special_sun ]

	local time_of_day = minetest.get_timeofday()
	
	if
		special_moon ~= "normal"
		and moon_config
		and not moon_config.no_astral_event
		and ( time_of_day < 0.21 or time_of_day > 0.79 )
	then
		astral_event = special_moon
		astral_event_name = moon_config.name
	elseif
		special_sun ~= "normal"
		and sun_config
		and not sun_config.no_astral_event
		and time_of_day > 0.2 and time_of_day < 0.8
	then
		astral_event = special_sun
		astral_event_name = sun_config.name
	else
		astral_event = "none"
		astral_event_name = "none"
	end

	return moon_changed or sun_changed
end



-- Set all sky features
local function set_player_sky( player )
	player:set_sky( {
		type = "regular",
		sky_color = {
			day_sky = day_sky_color,
			day_horizon = day_horizon_color,
			night_sky = night_sky_color,
			night_horizon = night_horizon_color
		}
	} )
	
	player:set_stars( {
		count = 1500,
		star_color = star_color
	} )
	
	player:set_moon( {
		visible = moon_visible,
		texture = moon_texture,
		scale = moon_scale
	} )

	player:set_sun( {
		visible = true,
		texture = sun_texture,
		scale = sun_scale or 3
	} )
	
	-- This causes bugs (Minetest 5.3.0)
	player:set_clouds( { density = cloud_density } )
end



-- Check for day changes
local function update_moon()
	if compute_astral() then
		for _, player in ipairs( minetest.get_connected_players() ) do
			set_player_sky( player )
		end
	end
end



-- Probably deprecated
astral.set_moon_phase = function( new_moon_phase )
	-- May originate from command line
	new_moon_phase = math.floor( tonumber( new_moon_phase ) or 0 ) % moon_phase_count

	if new_moon_phase == moon_phase then
		return false
	end
	
	astral_day_offset = astral_day_offset + new_moon_phase - moon_phase
	mod_storage:set_int( "astral_day_offset", astral_day_offset )
	update_moon()
	return true
end



astral.set_astral_day_offset = function( new_astral_day_offset )
	-- May originate from command line
	new_astral_day_offset = math.floor( tonumber( new_astral_day_offset ) or 0 )

	astral_day_offset = new_astral_day_offset
	mod_storage:set_int( "astral_day_offset", astral_day_offset )
	update_moon()
end



-- API
astral.get_astral_day_offset = function() return astral_day_offset end
astral.get_month = function() return month , month_cycle[ month ].name end
astral.get_moon_phase = function() return moon_phase , moon_phase_name[ moon_phase ] end
astral.get_special_month = function() return special_month end
astral.get_special_day = function() return special_sun , special_moon end
astral.get_astral_event = function() return astral_event , astral_event_name end



local timer = 0
minetest.register_globalstep( function( dtime )
	timer = timer + dtime
	if timer < 0.5 then return end
	update_moon()
	timer = 0
end )



-- set the sky for newly joined player
minetest.register_on_joinplayer( function( player )
	set_player_sky( player, moon_phase )
end )

