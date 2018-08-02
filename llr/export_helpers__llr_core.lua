cm = get_cm(); events = get_events(); llr = _G.llr;

--no checking this because of Kailua's annoying integer type
--v [NO_CHECK] function(level: number) --> number
function get_exp_for_level(level)
    local exp_to_levels_table = {
        0, 900,  1900,  3000, 4200,  5500,6870, 8370, 9940,
        11510,13080,14660, 16240,17820,19400, 20990,22580,24170,25770,27370,28980,30590,32210,
        33830,35460,37100,38740, 40390,42050,43710,45380,47060,48740,50430,52130, 53830, 55540,57260,58990,
        60730, 60730, 60730, 60730,  60730, 60730, 60730, 60730, 60730,  60730, 60730, 60730,
        60730 }--:vector<number>
    return exp_to_levels_table[level]
end



--v function(cqi: CA_CQI, lord: LLR_LORD)
local function grant_quest_items(cqi, lord)

end








--v function(player_faction: string, lord: LLR_LORD, character: CA_CHAR)
local function respec_char_with_army(player_faction, lord, character)
    lord:set_lord_rank(character:rank())
    lord:set_coordinates(character:logical_position_x(), character:logical_position_y())
    lord:set_unit_string_from_force(character:military_force())
    
    cm:disable_event_feed_events(true, "", "wh_event_subcategory_character_deaths", "");
    cm:set_character_immortality(cm:char_lookup_str(character:command_queue_index()), false);
    for i = 1, #lord:traits() do
        cm:force_remove_trait(cm:char_lookup_str(character:command_queue_index()), lord:traits()[i])
    end
    
    cm:kill_character(character:command_queue_index(), true, true)

    cm:callback(function() cm:disable_event_feed_events(false, "", "wh_event_subcategory_character_deaths", "") end, 1);
        cm:callback( function()
            llr:log("spawning lord for respec!")
            cm:create_force_with_general(
            player_faction,
            lord:unit_list(),
            lord:region(),
            lord:x(),
            lord:y(),
            "general",
            lord:subtype(),
            lord:forename(),
            "",
            lord:surname(),
            "",
            false,
            function(cqi) 
                llr:log("Levelling up the respec'd lord!")
                cm:set_character_immortality(cm:char_lookup_str(cqi), true);
                grant_quest_items(cqi, lord)
                for i = 1, #lord:traits() do

                end
                cm:add_agent_experience(cm:char_lookup_str(cqi), get_exp_for_level(lord:rank()))       
                llr:log("Levelling up the respec'd lord finished.")
            end)
        end,
        0.1
    );

end

--v function(player_faction: string, lord: LLR_LORD, character: CA_CHAR)
local function respec_wounded_character(player_faction, lord, character)

    
end

--v function(lord: LLR_LORD)
local function respawn_to_pool(lord)

end




--v function(confederation_name: string, subtype: string) --> CA_CHAR
function lord_survived_confederation(confederation_name, subtype)
    local faction = cm:get_faction(confederation_name)
    local character_list = faction:character_list()
    for i = 0, character_list:num_items() - 1 do
        local character = character_list:item_at(i)
        if character:character_subtype_key() == subtype then
            return character
        end
    end
    return nil
end



--v function(faction_name: string, confederation_name: string)
local function player_faction_confederation(faction_name, confederation_name)
    local lords = llr:get_lords_for_faction(faction_name)
    for i = 1, #lords do
        local current_lord = lords[i]
        local character = lord_survived_confederation(confederation_name, current_lord:subtype())
        if character then
            if character:is_wounded() then
                respec_wounded_character(confederation_name, current_lord, character)
            else
                respec_char_with_army(confederation_name, current_lord, character)
            end
        else
            respawn_to_pool(current_lord)
        end
    end
end


core:add_listener(
    "llr_manager_confedation",
    "FactionJoinsConfederation",
    function(context)
        local sc = context:faction():subculture() --:string
        local faction = context:faction():name() --:string
        --make sure we are listening for this sub and faction
        return llr:is_tracking_faction(faction) and llr:is_tracking_subculture(sc)
    end,
    function(context)
        local faction_name = context:faction():name() --:string
        local confederation_name = context:confederation():name() --:string
        if cm:get_faction(confederation_name):is_human() then
            player_faction_confederation(faction_name, confederation_name)
        else
            llr:move_faction(faction_name, confederation_name)
        end
    end,
    true)
    