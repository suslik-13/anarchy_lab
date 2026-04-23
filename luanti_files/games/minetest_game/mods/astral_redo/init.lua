-- Global landscape_shaping namespace
astral = {}
astral.path = minetest.get_modpath( minetest.get_current_modname() )

-- Load files
dofile( astral.path .. "/astral.lua" )
dofile( astral.path .. "/commands.lua" )


