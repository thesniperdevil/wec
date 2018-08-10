DF_CHAOS_PORTAL_BUILDING = {
"wh_main_dwf_grn_settlement_major_chaosruin",
"wh_main_dwf_grn_settlement_major_chaosruin_coast",
"wh_main_dwf_grn_settlement_minor_chaosruin",
"wh_main_dwf_grn_settlement_minor_chaosruin_coast",
"wh_main_HUMAN_settlement_major_chaosruin",
"wh_main_HUMAN_settlement_major_chaosruin_coast",
"wh_main_HUMAN_settlement_minor_chaosruin",
"wh_main_HUMAN_settlement_minor_chaosruin_coast",
"wh_main_HUMAN_outpostnorsca_major_chaosruin",
"wh_main_HUMAN_outpostnorsca_major_chaosruin_coast",
"wh_main_HUMAN_outpostnorsca_minor_chaosruin",
"wh_main_HUMAN_outpostnorsca_minor_chaosruin_coast",
"wh_main_special_settlement_altdorf_chaosruin",
"wh_main_special_settlement_black_crag_chaosruin",
"wh_main_special_settlement_castle_drakenhof_chaosruin",
"wh_main_special_settlement_eight_peaks_chaosruin",
"wh_main_special_settlement_karaz_a_karak_chaosruin",
"wh_main_special_settlement_kislev_chaosruin",
"wh_main_special_settlement_miragliano_chaosruin",
"wh2_main_special_fortress_gate_eagle_chaos_ruins",
"wh2_main_special_fortress_gate_griffon_chaos_ruins",
"wh2_main_special_fortress_gate_phoenix_chaos_ruins",
"wh2_main_special_fortress_gate_unicorn_chaos_ruins",
}--:vector<string>

DF_CHAOS_SPAWN_CHANCE = 10
DF_BASE_COOLDOWN = 4

DF_CHAOS_ARMY_LIST =  {"wh_dlc01_chs_inf_forsaken_0", "wh_main_chs_mon_chaos_warhounds_0", "wh_main_chs_mon_chaos_spawn", "wh_main_chs_mon_chaos_spawn",
"wh_dlc06_chs_feral_manticore", "wh_dlc01_chs_inf_chaos_warriors_2", "wh_dlc01_chs_inf_chaos_warriors_2", "wh_main_chs_mon_chaos_spawn", "wh_main_chs_mon_chaos_spawn",
"wh_dlc01_chs_inf_forsaken_0", "wh_main_chs_mon_chaos_warhounds_0", "wh_main_chs_mon_chaos_spawn", "wh_main_chs_mon_chaos_spawn"
} --:vector<string>
DF_CHAOS_ARMY_SIZES = {9, 11, 13} --:vector<number>
DF_CHAOS_ARMY_FACTION = "wh2_main_chs_chaos_incursion_lzd" --:string






--v function(text: string)
function GOCLOG(text)
    if not __write_output_to_logfile then
        return; 
    end

    local logText = tostring(text)
    local logTimeStamp = os.date("%d, %m %Y %X")
    local popLog = io.open("warhammer_expanded_log.txt","a")
    --# assume logTimeStamp: string
    popLog :write("GOC:  [".. logTimeStamp .. "]:  "..logText .. "  \n")
    popLog :flush()
    popLog :close()
end



if not not _G.sfo then
    GOCLOG("Startup: SFO is active!")
    DF_CHAOS_ARMY_LIST =  {"wh_dlc01_chs_inf_forsaken_0", "wh_main_chs_mon_chaos_warhounds_0", "wh_main_chs_mon_chaos_spawn", "wh_main_chs_mon_chaos_spawn",
    "chs_zelot", "chs_zelot", "chs_nurgle_sons", "chs_slaanesh_bless", "chs_khorne_berserk", "chs_chaos_dragon", "wh_main_chs_mon_chaos_spawn", "wh_main_chs_mon_chaos_spawn"}
else
    GOCLOG("Startup: SFO not active!")
end

if cm:get_saved_value("whenever catap gets around to adding this ctt shit I guess man") == true then
    GOCLOG("Startup: CTT is active!")

else
    GOCLOG("Startup: CTT not active!")
end




--v function() --> vector<CA_FACTION>
local function GetPlayerFactions()
    local player_factions = {};
    local faction_list = cm:model():world():faction_list();
    for i = 0, faction_list:num_items() - 1 do
        local curr_faction = faction_list:item_at(i);
        if (curr_faction:is_human() == true) then
            table.insert(player_factions, curr_faction);
        end
    end
    return player_factions;
end;

--v function(ax: number, ay: number, bx: number, by: number) --> number
local function distance_2D(ax, ay, bx, by)
    return (((bx - ax) ^ 2 + (by - ay) ^ 2) ^ 0.5);
end;

--v function(players: vector<CA_FACTION>, region: CA_REGION) --> boolean
local function CheckIfPlayerIsNearFaction(players, region)
    local result = false;
    local settlement = region:settlement()
    local radius = 20;
    for i,value in ipairs(players) do
        local player_force_list = value:military_force_list();
        local j = 0;
        while (result == false) and (j < player_force_list:num_items()) do
            local player_character = player_force_list:item_at(j):general_character();
            local distance = distance_2D(settlement:logical_position_x(), settlement:logical_position_y(), player_character:logical_position_x(), player_character:logical_position_y());
            result = (distance < radius);
            j = j + 1;
        end
        local player_region_list = value:region_list();
        local j = 0;
        while (result == false) and (j < player_region_list:num_items()) do
            local player_character = player_region_list:item_at(j):settlement();
            local distance = distance_2D(settlement:logical_position_x(), settlement:logical_position_y(), player_character:logical_position_x(), player_character:logical_position_y());
            result = (distance < radius);
            j = j + 1;
        end
    end
    GOCLOG("is player near settlement returning ["..tostring(result).."] ")
    return result;
end

--v function(x: number, y: number) --> boolean
local function IsValidSpawnPoint(x, y)
	local faction_list = cm:model():world():faction_list();
	
	for i = 0, faction_list:num_items() - 1 do
		local current_faction = faction_list:item_at(i);
		local char_list = current_faction:character_list();
		
		for i = 0, char_list:num_items() - 1 do
			local current_char = char_list:item_at(i);
            if current_char:logical_position_x() == x and current_char:logical_position_y() == y then
                GOCLOG("Is valid spawn point returning false")
				return false;
			end;
		end;
    end;
    GOCLOG("is valid spawn point returning true")
	return true;
end;


--v function(region: CA_REGION) --> boolean
function region_has_portal(region)
    for i = 1, #DF_CHAOS_PORTAL_BUILDING do
        if region:building_exists(DF_CHAOS_PORTAL_BUILDING[i]) then
            GOCLOG("Region has portal returning true for region ["..region:name().."] ")
            return true
        end
    end
    return false
end




--v function(region: CA_REGION)
local function spawn_chaos(region)

    local unit_string = DF_CHAOS_ARMY_LIST[cm:random_number(#DF_CHAOS_ARMY_LIST)]
    for i = 1, DF_CHAOS_ARMY_SIZES[cm:random_number(#DF_CHAOS_ARMY_SIZES)] do
        local new_string = unit_string..","..DF_CHAOS_ARMY_LIST[cm:random_number(#DF_CHAOS_ARMY_LIST)]
        unit_string = new_string
    end
    GOCLOG("Assembled the spawn string as ["..unit_string.."] ")
    cm:create_force(
        DF_CHAOS_ARMY_FACTION,
        unit_string,
        region:name(),
        region:settlement():logical_position_x() + 1,
        region:settlement():logical_position_y() + 1,
        true,
        true,
        function(cqi)
            GOCLOG("Spawned a chaos army at ["..region:name().."] sucessfully with cqi ["..tostring(cqi).."]")
            cm:force_diplomacy("faction:"..DF_CHAOS_ARMY_FACTION, "faction:wh_main_chs_chaos", "war", false, false, false)
            if cm:get_faction("wh_main_chs_chaos"):is_dead() == false and cm:get_faction(DF_CHAOS_ARMY_FACTION):is_vassal_of(cm:get_faction("wh_main_chs_chaos")) == false then
                GOCLOG("Making the spawned faction a vassal!")
                cm:force_make_vassal("wh_main_chs_chaos", DF_CHAOS_ARMY_FACTION)
            end
        end)
    
        cm:set_saved_value("chaos_gates_cooldown_"..region:province_name(), 18)
        if cm:is_multiplayer() then --in multiplayer games we tick twice every single round. Double the cooldown
            cm:set_saved_value("chaos_gates_cooldown_"..region:province_name(), 36)
        end
end


--v function (region: CA_REGION)
local function chaos_gates(region)
    if cm:get_saved_value("chaos_gates_cooldown_"..region:province_name()) == nil then
        cm:set_saved_value("chaos_gates_cooldown_"..region:province_name(), DF_BASE_COOLDOWN)
    end
    local cooldown = cm:get_saved_value("chaos_gates_cooldown_"..region:province_name())
    if cooldown > 1 then
        GOCLOG("region ["..region:name().."] is not off cooldown! It has ["..cooldown.."] turns remaining!")
        cm:set_saved_value("chaos_gates_cooldown_"..region:province_name(), cooldown - 1)
        return
    end

    if cm:is_multiplayer() then
        if CheckIfPlayerIsNearFaction(GetPlayerFactions(), region) == false and IsValidSpawnPoint(region:settlement():logical_position_x() + 1, region:settlement():logical_position_y() + 1) then
            if cm:random_number(100) <= DF_CHAOS_SPAWN_CHANCE/2 then
                GOCLOG("Chance check passed, spawning chaos")
                spawn_chaos(region)
            else
                GOCLOG("Chance check failed, maybe next time!")
            end
        end
        return
    end



    if cm:random_number(100) <= DF_CHAOS_SPAWN_CHANCE then
        GOCLOG("Chance check passed, spawning chaos")
        if CheckIfPlayerIsNearFaction(GetPlayerFactions(), region) == false and IsValidSpawnPoint(region:settlement():logical_position_x() + 1, region:settlement():logical_position_y() + 1) then
            spawn_chaos(region)
        end
    else
        GOCLOG("Chance check failed, maybe next time!")
    end

end





core:add_listener(
    "ChaosGatesTurnStart",
    "FactionTurnStart",
    function(context)
        return context:faction():is_human()
    end,
    function(context)
        local region_list = cm:model():world():region_manager():region_list()
        for i = 0, region_list:num_items() - 1 do
            local region = region_list:item_at(i)
            if not region:settlement():is_null_interface() then
                if region_has_portal(region) then
                    chaos_gates(region)
                end
            end
        end
    end,
    true)