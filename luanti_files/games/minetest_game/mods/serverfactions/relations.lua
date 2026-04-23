--relations.lua

relations = {
    data = {}
}

-- Function for load the relations of factions
function relations.load_relations()
    local file = io.open(core.get_worldpath() .. "/relations.txt", "r")
    if file then
        for line in file:lines() do
            local faction_name, other_faction, status = line:match("([^,]+),%s*([^:]+):%s*(.+)")
            if faction_name and other_faction and status then
                relations.data[faction_name] = relations.data[faction_name] or {}
                
                if not relations.data[faction_name][other_faction] then
                    relations.data[faction_name][other_faction] = status
                end
            else
                print("Format error:", line)
            end
        end
        file:close()
    else
        print("Error : Cannot open relations.txt")
    end
end

-- Function for save the relations in the relations.txt
function relations.save_relations(full_save)
    local mode = full_save and "w" or "a"
    local file = io.open(core.get_worldpath() .. "/relations.txt", mode)

    if file then
        if full_save then
            for faction_name, relations_table in pairs(relations.data) do
                for other_faction, status in pairs(relations_table) do
                    file:write(faction_name .. ", " .. other_faction .. ": " .. status .. "\n")
                end
            end
        else
            for faction_name, relations_table in pairs(relations.data) do
                for other_faction, status in pairs(relations_table) do
                    file:write(faction_name .. ", " .. other_faction .. ": " .. status .. "\n")
                end
            end
        end
        file:close()
    else
        print("Error : Cannot open relations.txt for writting.")
    end
end

-- Function for show the relations of a faction
function relations.show_relations(faction_name)
    if not relations.data[faction_name] then
        return "Faction " .. faction_name .. " not find.\nAction canceled."
    end

    local relation_list = "Relations of the faction " .. faction_name .. ":\n"
    for other_faction, status in pairs(relations.data[faction_name]) do
        relation_list = relation_list .. other_faction .. ": " .. status .. "\n"
    end
    return relation_list
end

-- Function for defined relations
function relations.set_relation(player_name, fac1, fac2, choix)
    relations.load_relations()

    local faction_name = factions.get_player_faction(player_name)
    local faction = factions.list[faction_name]

    if not faction.members[player_name] or faction.members[player_name] ~= "factionleader" then
        return false, core.chat_send_player(player_name, "You must be chief or co-leader of your faction to defined a relation.")
    end

    relations.data[fac1] = relations.data[fac1] or {}
    relations.data[fac2] = relations.data[fac2] or {}

    local current_relation_fac1 = relations.data[fac1][fac2] or "NEUTRAL"
    local current_relation_fac2 = relations.data[fac2][fac1] or "NEUTRAL"

    if current_relation_fac1 == "NEUTRAL" then
        if choix == "ALLIE" then
            if current_relation_fac2 == "ASKALLY" then
                relations.data[fac1][fac2] = "ALLIE"
                relations.data[fac2][fac1] = "ALLIE"
            else
                relations.data[fac1][fac2] = "ASKALLY"
            end
        elseif choix == "ENEMY" then
            relations.data[fac1][fac2] = "ENEMY"
            relations.data[fac2][fac1] = "ENEMY"
        end

    elseif current_relation_fac1 == "ALLIE" then
        if choix == "NEUTRAL" then
            relations.data[fac1][fac2] = "NEUTRAL"
            relations.data[fac2][fac1] = "NEUTRAL"
        elseif choix == "ENEMY" then
            relations.data[fac1][fac2] = "ENEMY"
            relations.data[fac2][fac1] = "ENEMY"
        end

    elseif current_relation_fac1 == "ENEMY" then
        if choix == "NEUTRAL" then
            if current_relation_fac2 == "ASKTRUCE" then
                relations.data[fac1][fac2] = "NEUTRAL"
                relations.data[fac2][fac1] = "NEUTRAL"
            else
                relations.data[fac1][fac2] = "ASKTRUCE"
            end
        end
    end

    relations.save_relations(true)

    local final = relations.data[fac1][fac2] or "None"
    return true, core.chat_send_player(player_name, "Relation beetween " .. fac1 .. " et " .. fac2 .. " defined in " .. final .. ".")
end

-- Function for remove the relations of a faction
function relations.remove_faction_relations(faction_name)
    local file_path = core.get_worldpath() .. "/relations.txt"
    local file = io.open(file_path, "r")

    if not file then
        print("Error : Cannot open relations.txt for deleting.")
        return
    end

    local lines_to_keep = {}
    for line in file:lines() do
        local fac1, fac2 = line:match("([^,]+),%s*([^:]+):")

        if fac1 ~= faction_name and fac2 ~= faction_name then
            table.insert(lines_to_keep, line)
        end
    end
    file:close()

    file = io.open(file_path, "w")
    if not file then
        print("Error : Cannot write again in relations.txt after deleting.")
        return
    end

    for _, line in ipairs(lines_to_keep) do
        file:write(line .. "\n")
    end
    file:close()
end

-- Function for get the relations on two factions
function relations.get_relation(faction1, faction2)
    if relations.data[faction1] and relations.data[faction1][faction2] then
        return relations.data[faction1][faction2]
    end
    return "NEUTRAL"
end

-- Load relations when joining the game
relations.load_relations()
return relations
