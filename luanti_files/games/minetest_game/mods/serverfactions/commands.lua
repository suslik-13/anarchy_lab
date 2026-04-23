-- commands.lua

-- Register every the /f <command> <arguments> commands
core.register_chatcommand(
    "f",
    {
        params = "<subcommand> <args>",
        description = "Faction commands: menu, claim, unclaim, claims, list, sethome, accept <player>, refuse <player>, help",
        func = function(name, param)
            local args = param:split(" ")
            local subcommand = args[1]
            if subcommand == "menu" then
                factions.show_menu(name)
                return true

            elseif subcommand == "claim" then
                local faction_name = factions.get_player_faction(name)
                if not faction_name then
                    return false, "Your not in a faction."
                end
                local success, msg = factions.claim(name)
                return success, msg

            elseif subcommand == "claims" then
                factions.show_claims(name)
                return true

            elseif subcommand == "list" then
                local faction_list = factions.list_factions()
                core.chat_send_player(name, faction_list)
                return true

            elseif subcommand == "unclaim" then
                local success, message = factions.release_claim(name)
                core.chat_send_player(name, message)
                return true

            elseif subcommand == "clear_boundaries" then
                if not core.check_player_privs(name, {server = true}) then
                    return false, "You do not have permission to run this command."
                end

                for _, entities in pairs(factions.claims.boundary_entities) do
                    for _, entity in ipairs(entities) do
                        if entity and entity:get_luaentity() then
                            entity:remove()
                        end
                    end
                end

                factions.claims.boundary_entities = {}
                return true, "All bounding entities have been deleted."


            elseif subcommand == "sethome" then
                local faction_name = factions.get_player_faction(name)
                if not faction_name then
                    return false, "Your not in a faction."
                end

                local faction = factions.list[faction_name]
                if faction.leader ~= name then
                    return false, "Only the faction leader can set the faction home."
                end

                local success, message = factions.set_faction_home(name)

                if message then
                    core.chat_send_player(name, message)
                else
                    core.chat_send_player(name, "Error setting home.")
                end
                return success

            elseif subcommand == "accept" then
                local target_player = args[2]
                local faction_name = factions.get_player_faction(name)
                
                if not faction_name then
                    return false, "Your not in a faction."
                end
            
                local faction = factions.list[faction_name]
                if faction.leader ~= name then
                    return false, "Only the faction leader can accept members into the faction."
                end
                local success, message = factions.accept_invite(target_player, faction_name)

                if success then
                    core.chat_send_player(name, message)
                else
                    core.chat_send_player(name, message or "Error while inviting.")
                end
                return success

            elseif subcommand == "refuse" then
                local args = args[2]
                local faction_name = factions.get_player_faction(name)
                if not faction_name then
                    return false, "Your not in a faction."
                end

                local faction = factions.list[faction_name]
                if faction.leader ~= name then
                    return false, "Only the faction leader can refuse members within the faction."
                end

                local success, message = factions.refuse_invite(args, faction_name)

                if message then
                    core.chat_send_player(name, message)
                else
                    core.chat_send_player(name, "Error declining invitation.")
                end
                return success


            elseif subcommand == "help" then
                local help_text =
                    [[
Available commands:
/f menu - Open the faction menu
/f claim - Claim a territory
/f unclaim - Cancel a territory claim
/f claims - Show claimed territories
/f list - List factions on the server
/f clear_boundaries - ADMIN - Remove all claim boundaries
/f refuse - Refuse a player's request to join your faction
/f accept - Accept a player's request to join your faction
/fc <message> - Allows you to send a message to your entire faction.
/f sethome - Allows the faction leader to set the faction home.
]]
                core.chat_send_player(name, help_text)
                return true
            else
                return false, "Unknown command. Type /f help for list of commands."
            end
        end
    }
)

-- Command for send a message in the faction chat
core.register_chatcommand(
    "fc",
    {
        params = "<message>",
        description = "Send a message to your faction chat (faction members only)",
        func = function(name, param)
            if param == "" then
                return false, "You must enter a message to send."
            end

            local args = param:split(" ")
            local message = table.concat(args, " ", 1) 

            local faction_name = factions.get_player_faction(name)
            if not faction_name then
                return false, "You are not in a faction."
            end

            for member_name in pairs(factions.list[faction_name].members) do
                core.chat_send_player(member_name, "[Faction] " .. name .. ": " .. message)
            end
            return true
        end
    }
)
