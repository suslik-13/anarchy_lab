-- init.lua

factions = {}
factions.claims = {}
factions.roles = {}

-- Load the files
dofile(core.get_modpath("serverfactions").."/commands.lua")
dofile(core.get_modpath("serverfactions").."/factions.lua")
dofile(core.get_modpath("serverfactions").."/claims.lua")
dofile(core.get_modpath("serverfactions") .. "/relations.lua")

-- Init the claims, factions, relations and homes
factions.claims.load_claims()
factions.load_factions()
relations.load_relations()
factions.load_homes()