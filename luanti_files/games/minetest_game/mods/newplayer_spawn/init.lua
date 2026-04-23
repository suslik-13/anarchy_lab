-- New Player Spawn Mod
-- Teleports only new players to random locations on first join

local newplayer_spawn = {}

-- Configuration
local SPAWN_RADIUS = 3000  -- Radius in blocks from world center
local MAX_HEIGHT = 50      -- Maximum spawn height
local MIN_HEIGHT = 1     -- Minimum spawn height
local MAX_ATTEMPTS = 30    -- Maximum attempts to find suitable spawn

-- Storage for tracking new players
local storage = minetest.get_mod_storage()

-- Function to check if position is safe for spawning
local function is_safe_position(pos)
    -- Check 3x3 area around player and 3 blocks up
    for dx = -1, 1 do
        for dz = -1, 1 do
            for dy = 0, 3 do -- 0 = feet level, 1 = body level, 2 = head level, 3 = above head
                local check_pos = {x = pos.x + dx, y = pos.y + dy, z = pos.z + dz}
                local node = minetest.get_node_or_nil(check_pos)
                
                if not node then
                    return false -- Chunk not loaded
                end
                
                if node.name ~= "air" then
                    return false -- Not enough free space
                end
            end
            
            -- Check that ground below is solid (not air, water, lava)
            local ground_pos = {x = pos.x + dx, y = pos.y - 1, z = pos.z + dz}
            local ground_node = minetest.get_node_or_nil(ground_pos)
            
            if not ground_node then
                return false -- Chunk not loaded
            end
            
            local ground_def = minetest.registered_nodes[ground_node.name]
            if not ground_def or not ground_def.walkable or ground_def.groups.liquid or ground_node.name == "air" then
                return false -- Unsafe ground
            end
        end
    end
    
    -- Check if position is protected
    if minetest.is_protected(pos, "") then
        return false
    end
    
    return true
end

-- Function to find random spawn position with callback
local function find_random_spawn(callback)
    local function try_position(attempt)
        if attempt > MAX_ATTEMPTS then
            minetest.log("warning", "[newplayer_spawn] Could not find safe spawn after " .. MAX_ATTEMPTS .. " attempts")
            callback({x=0, y=50, z=0}) -- High fallback position
            return
        end
        
        local angle = math.random() * 2 * math.pi
        local distance = math.random(200, SPAWN_RADIUS)
        
        local x = math.floor(distance * math.cos(angle))
        local z = math.floor(distance * math.sin(angle))
        
        -- Force load the area around this position
        minetest.emerge_area(
            {x=x-8, y=-32, z=z-8},
            {x=x+8, y=64, z=z+8},
            function(blockpos, action, calls_remaining, param)
                -- Wait until all chunks are loaded
                if calls_remaining == 0 then
                    -- Now find safe position in loaded chunks
                    local found_pos = nil
                    
                    -- Search in wider area around the target point
                    for dx = -5, 5 do
                        for dz = -5, 5 do
                            for y = MAX_HEIGHT, MIN_HEIGHT, -1 do
                                local test_pos = {x=x+dx, y=y, z=z+dz}
                                
                                -- Use improved safety check
                                if is_safe_position(test_pos) then
                                    found_pos = {x=test_pos.x, y=test_pos.y, z=test_pos.z}
                                    break
                                end
                            end
                            if found_pos then break end
                        end
                        if found_pos then break end
                    end
                    
                    if found_pos then
                        callback(found_pos)
                    else
                        -- Try next position
                        try_position(attempt + 1)
                    end
                end
            end
        )
    end
    
    try_position(1)
end

-- Function to check if player is new
local function is_new_player(name)
    local spawned = storage:get_string(name)
    return spawned == ""
end

-- Function to mark player as spawned
local function mark_player_spawned(name)
    storage:set_string(name, "spawned")
end

-- Handle new player join
minetest.register_on_newplayer(function(player)
    local name = player:get_player_name()
    
    if is_new_player(name) then
        minetest.chat_send_player(name, "Welcome to ANARCHY lab! Searching for a safe spawn location...")
        
        -- Generate random spawn position
        find_random_spawn(function(spawn_pos)
            -- Teleport player
            player:set_pos(spawn_pos)
            
            -- Mark player as spawned
            mark_player_spawned(name)
            
            -- Send welcome message
            minetest.chat_send_player(name, 
                "You've been spawned at a random location! " ..
                "Coordinates: " .. math.floor(spawn_pos.x) .. ", " .. 
                math.floor(spawn_pos.y) .. ", " .. math.floor(spawn_pos.z)
            )
            
            minetest.log("action", "New player " .. name .. " spawned at random location: " .. 
                spawn_pos.x .. "," .. spawn_pos.y .. "," .. spawn_pos.z)
        end)
    end
end)

-- Handle respawn (death) - use bed if available, otherwise random spawn
minetest.register_on_respawnplayer(function(player)
    local name = player:get_player_name()
    
    -- Check if player has a bed spawn point
    local bed_pos = nil
    
    -- Try to get bed position from beds mod if it exists
    if minetest.get_modpath("beds") and beds and beds.spawn then
        bed_pos = beds.spawn[name]
    end
    
    -- If player has a bed spawn, let default respawn behavior handle it
    if bed_pos then
        minetest.chat_send_player(name, "Respawning at your bed...")
        minetest.log("action", "Player " .. name .. " respawned at bed location")
        return false -- Allow default respawn behavior (bed spawn)
    end
    
    -- If no bed spawn, use random spawn
    minetest.chat_send_player(name, "No bed found. Finding new random spawn location...")
    
    find_random_spawn(function(spawn_pos)
        player:set_pos(spawn_pos)
        
        minetest.chat_send_player(name, 
            "You respawned at random location: " .. 
            math.floor(spawn_pos.x) .. ", " .. math.floor(spawn_pos.y) .. ", " .. math.floor(spawn_pos.z)
        )
        
        minetest.log("action", "Player " .. name .. " respawned at random location (no bed): " .. 
            spawn_pos.x .. "," .. spawn_pos.y .. "," .. spawn_pos.z)
    end)
    
    return true -- Prevent default respawn behavior for players without beds
end)

-- Optional: Command to manually respawn at random location
minetest.register_chatcommand("randomspawn", {
    description = "Teleport to a random spawn location",
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then
            return false, "Player not found"
        end
        
        minetest.chat_send_player(name, "Searching for random location...")
        
        find_random_spawn(function(spawn_pos)
            player:set_pos(spawn_pos)
            
            minetest.chat_send_player(name, "Teleported to random location: " .. 
                math.floor(spawn_pos.x) .. ", " .. math.floor(spawn_pos.y) .. ", " .. math.floor(spawn_pos.z))
        end)
        
        return true, "Searching for random location..."
    end,
})

minetest.log("action", "[newplayer_spawn] Mod loaded successfully")
