-- claims.lua

-- Load the claims of the factions
factions.claims = {}
factions.claims.data = {}
factions.load_factions()

-- Function for get the bounds of the chunks
function get_chunk_bounds(x, z)
    local chunk_size = 16
    local map_min = -30000
    local map_max = 30000

    if x < map_min or x > map_max or z < map_min or z > map_max then
        return nil, "The coordinates must be between " .. map_min .. " and " .. map_max
    end

    local chunk_x = math.floor(x / chunk_size)
    local chunk_z = math.floor(z / chunk_size)

    local x1 = chunk_x * chunk_size
    local z1 = chunk_z * chunk_size
    local x2 = x1 + chunk_size - 1
    local z2 = z1 + chunk_size - 1

    return x1, z1, x2, z2
end

-- Create a new boundary entity
core.register_entity(
    "serverfactions:boundary_entity",
    {
        initial_properties = {
            visual = "cube",
            textures = {
                "factions_boundary.png",
                "factions_boundary.png",
                "factions_boundary.png",
                "factions_boundary.png",
                "factions_boundary.png",
                "factions_boundary.png"
            },
            physical = false,
            collide_with_objects = false,
            collide_with_world = false,
            visual_size = {x = 1, y = 1, z = 1},
            glow = 10
        }
    }
)

-- Function for load the claims of the factions
function factions.claims.load_claims()
    local file = io.open(core.get_worldpath() .. "/claims.txt", "r")
    if file then
        for line in file:lines() do
            local x, z, faction_name = line:match("([^,]+),([^,]+),([^,]+)")
            factions.claims.data[x .. "," .. z] = faction_name
        end
        file:close()
    end
end

-- Function for load the claims of the factions
function factions.claims.save_claim(chunk_x, chunk_z, faction_name)
    local file = io.open(core.get_worldpath() .. "/claims.txt", "a")
    if file then
        file:write(chunk_x .. "," .. chunk_z .. "," .. faction_name .. "\n")
        file:close()
    end
    factions.claims.data[chunk_x .. "," .. chunk_z] = faction_name
end

-- Function for remove claims
function factions.remove_claims(faction_name)
    local claims_to_remove = {}

    for coords, owner_faction in pairs(factions.claims.data) do
        if owner_faction == faction_name then
            table.insert(claims_to_remove, coords)
        end
    end

    for _, coords in ipairs(claims_to_remove) do
        factions.claims.data[coords] = nil
    end

    factions.claims.save_all_claims()
end

-- Function for save every the claims
function factions.claims.save_all_claims()
    local file = io.open(core.get_worldpath() .. "/claims.txt", "w")
    if file then
        for coords, faction_name in pairs(factions.claims.data) do
            local x, z = coords:match("([^,]+),([^,]+)")
            file:write(x .. "," .. z .. "," .. faction_name .. "\n")
        end
        file:close()
    end
end

-- Function for claim a chunk
function factions.claim(player_name)
    local faction_name = factions.get_player_faction(player_name)
    if not faction_name then
        return false, "You must be in a faction to claim territory."
    end

    local player = core.get_player_by_name(player_name)
    if not player then
        return false, "Can't find the player."
    end

    local faction = factions.list[faction_name]
    if
        faction.members[player_name] ~= "factionleader" and faction.members[player_name] ~= "advisor" and
            faction.members[player_name] ~= "co-leader"
     then
        return false, "Only the advisor, co-leader or faction leader has the right to protect an area."
    end

    local nombre_de_membres = 0
    for _, role in pairs(faction.members) do
        nombre_de_membres = nombre_de_membres + 1
    end

    if nombre_de_membres >= 3 then
        faction.max_claim = 9
    end

    if faction.claim_count >= faction.max_claim then
        return false, core.chat_send_player(player_name, "You have reached the limit of " .. faction.max_claim .. " claims for your faction.")
    end

    local pos = player:get_pos()
    local x1, z1, x2, z2 = get_chunk_bounds(pos.x, pos.z)

    if not x1 then
        return false, z1
    end

    if
        factions.claims.data[x1 .. "," .. z1] and
            factions.claims.data[x1 .. "," .. z1] == factions.get_player_faction(player_name)
     then
        return false, "This chunk is already claimed by your faction."
    elseif factions.claims.data[x1 .. "," .. z1] then
        return false, "This chunk is already claimed by another faction."
    end

    factions.claims.save_claim(x1, z1, faction_name)
    core.chat_send_player(player_name, "You just claimed this territory: (" .. x1 .. ", " .. z1 .. ").")

    factions.create_boundaries(x1, z1, pos.y, player_name) 
    faction.claim_count = faction.claim_count + 1
    return true, core.chat_send_player(player_name, "Claimed territory.")
end

-- Function for show the bounds of the chunks claims around the player
function factions.create_boundaries(chunk_x, chunk_z, player_y, player_name)
    local chunk_size = 16
    local min_x = chunk_x
    local max_x = chunk_x + chunk_size - 1
    local min_z = chunk_z
    local max_z = chunk_z + chunk_size - 1
    local entities = factions.claims.boundary_entities[player_name] or {}

    -- Function to check if a position is already occupied by an entity
    local function is_position_occupied(x, y, z)
        local objects = core.get_objects_inside_radius({x = x, y = y, z = z}, 0.5)
        return #objects > 0
    end

    -- Create entities for each edge of the chunk, checking for collisions
    for high = (player_y - 5), (player_y + 5) do
        for x = min_x, max_x do
            if not is_position_occupied(x, high, min_z) then
                table.insert(entities, core.add_entity({x = x, y = high, z = min_z}, "serverfactions:boundary_entity"))
            end
            if not is_position_occupied(x, high, max_z) then
                table.insert(entities, core.add_entity({x = x, y = high, z = max_z}, "serverfactions:boundary_entity"))
            end
        end
    end
    for high = (player_y - 5), (player_y + 5) do
        for z = min_z, max_z do
            if not is_position_occupied(min_x, high, z) then
                table.insert(entities, core.add_entity({x = min_x, y = high, z = z}, "serverfactions:boundary_entity"))
            end
            if not is_position_occupied(max_x, high, z) then
                table.insert(entities, core.add_entity({x = max_x, y = high, z = z}, "serverfactions:boundary_entity"))
            end
        end
    end

    -- Save boundary entities for this player
    factions.claims.boundary_entities[player_name] = entities

    -- Delete entities after a delay
    core.after(
        10,
        function()
            for _, entity in ipairs(entities) do
                if entity and entity:get_luaentity() then
                    entity:remove()
                end
            end
            factions.claims.boundary_entities[player_name] = nil
        end
    )
end

-- Save every the boundaries created by a player
factions.claims.boundary_entities = {}

-- Delete every the boundaries entities if the player leave the game
core.register_on_leaveplayer(
    function(player)
        local player_name = player:get_player_name()

        local entities = factions.claims.boundary_entities[player_name]

        if entities then
            for _, entity in ipairs(entities) do
                if entity and entity:get_luaentity() then
                    entity:remove()
                end
            end
        end

        factions.claims.boundary_entities[player_name] = nil
    end
)

-- Function which check if the chunk of the player is claimed
local function is_position_claimed(pos)
    local x1, z1, x2, z2 = get_chunk_bounds(pos.x, pos.z)
    if not x1 then
        return false, z1
    end

    if factions.claims.data[x1 .. "," .. z1] then
        return true
    else
        return false
    end
end

-- Check if the player is allowed to modify the claim
local function player_can_modify(player_name, pos)
    local faction_name = factions.get_player_faction(player_name)
    if not faction_name then
        return false 
    end

    local x1, z1 = get_chunk_bounds(pos.x, pos.z)
    if not x1 then
        return false 
    end

    local owner_faction = factions.claims.data[x1 .. "," .. z1]

    if owner_faction == faction_name then
        return true
    else 
        return false
    end
end

-- Function for cancel a terrain modification if the player is not in the claim
local old_is_protected = core.is_protected
function core.is_protected(pos, name)
    if is_position_claimed(pos) and not player_can_modify(name, pos) then
        return true
    end
    return old_is_protected(pos, name)
end

-- Function for release a claim of your faction
function factions.release_claim(player_name)
    local faction_name = factions.get_player_faction(player_name)
    if not faction_name then
        return false, "You must be in a faction to liberate a territory."
    end

    local player = core.get_player_by_name(player_name)
    if not player then
        return false, "Can't find the player."
    end

    local faction = factions.list[faction_name]
    if faction.members[player_name] ~= "factionleader" and faction.members[player_name] ~= "co-leader" then
        return false, "Only the faction leader or co-leader can liberate a territory."
    end

    local pos = player:get_pos()
    local x1, z1, x2, z2 = get_chunk_bounds(pos.x, pos.z)

    if not x1 then
        return false, z1 
    end

    if factions.claims.data[x1 .. "," .. z1] ~= faction_name then
        return false, "This chunk is not claimed by your faction."
    end

    if not faction.claim_count then
        faction.claim_count = 0
    end

    factions.claims.data[x1 .. "," .. z1] = nil
    factions.claims.save_all_claims()
    faction.claim_count = faction.claim_count - 1
    core.chat_send_player(player_name, "You have liberated the territory: (" .. x1 .. ", " .. z1 .. ").")
    factions.show_claims(player_name)
    return true, "Territory liberated."
end

-- Function for show the bounds of the chunks claimed around the player
factions.show_claims_timer = {}
function factions.show_claims(player_name)
    local faction_name = factions.get_player_faction(player_name)
    if not faction_name then
        core.chat_send_player(player_name, "Your not in a faction.")
        return
    end

    local current_time = core.get_gametime()
    local last_time = factions.show_claims_timer[player_name] or 0
    if current_time - last_time < 20 then
        core.chat_send_player(player_name, "You must wait 20 seconds before the borders are redisplayed..")
        return
    end

    local claims_list = "Claimed territories:\n"
    local player_pos = core.get_player_by_name(player_name):get_pos()
    local player_chunk_x = math.floor(player_pos.x / 16)
    local player_chunk_z = math.floor(player_pos.z / 16)

    local has_claims = false

    for coords, faction in pairs(factions.claims.data) do
        if faction == faction_name then
            local x, z = coords:match("([^,]+),([^,]+)")
            x = tonumber(x)
            z = tonumber(z)

            local chunk_center_x = x + 8
            local chunk_center_z = z + 8

            local dist = math.sqrt((chunk_center_x - player_pos.x) ^ 2 + (chunk_center_z - player_pos.z) ^ 2)

            if dist <= 100 then
                claims_list = claims_list .. "Chunk (" .. x .. "," .. z .. ")\n"
                has_claims = true

                factions.create_boundaries(x, z, player_pos.y, player_name)
            end
        end
    end

    if not has_claims then
        claims_list = claims_list .. "No territory claimed."
    end

    core.chat_send_player(player_name, claims_list)
    factions.show_claims_timer[player_name] = current_time
    core.after(20, function()
        factions.show_claims_timer[player_name] = nil
    end)
end

-- Load the claims when launching the game
factions.claims.load_claims()
