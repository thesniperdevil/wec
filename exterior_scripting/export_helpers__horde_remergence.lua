function attempt_to_spawn_scripted_army(faction_name)
	local possible_spawn_points = {
		{519, 516, "wh_main_middenland_middenheim"},
		{486, 438, "wh_main_reikland_altdorf"},
		{415, 318, "wh_main_carcassone_et_brionne_castle_carcassonne"},
		{416, 398, "wh_main_bastonne_et_montfort_castle_bastonne"},
		{630, 342, "wh_main_eastern_border_princes_akendorf"},
		{680, 287, "wh_main_death_pass_iron_rock"},
		{572, 190, "wh_main_southern_badlands_galbaraz"},
		{747, 328, "wh_main_the_silver_road_mount_squighorn"},
		{772, 223, "wh_main_desolation_of_nagash_spitepeak"},
		{728, 445, "wh_main_peak_pass_karak_kadrin"},
		{721, 503, "wh_main_northern_worlds_edge_mountains_karak_ungor"},
		{664, 535, "wh_main_southern_oblast_kislev"},
		{558, 408, "wh_main_averland_averheim"},
		{688, 342, "wh_main_blood_river_valley_varenka_hills"},
		{604, 604, "wh_main_troll_country_zoishenk"},
		{676, 454, "wh_main_eastern_sylvania_waldenhof"},
		{526, 327, "wh_main_the_vaults_karak_izor"},
		{370, 261, "wh_main_estalia_magritta"},
		{545, 164, "wh_main_southern_badlands_gor_gazan"},
		{691, 195, "wh_main_blightwater_karak_azgal"},
		{45, 704, "wh2_main_ironfrost_glacier_dagraks_end"},
		{180, 704, "wh2_main_the_road_of_skulls_kauark"},
		{395, 700, "wh2_main_aghol_wastelands_palace_of_princes"},
		{15, 565, "wh2_main_blackspine_mountains_red_desert"},
		{116, 546, "wh2_main_obsidian_peaks_circle_of_destruction"},
		{17, 498, "wh2_main_blackspine_mountains_plain_of_spiders"},
		{99, 462, "wh2_main_doom_glades_vauls_anvil"},
		{50, 361, "wh2_main_titan_peaks_ssildra_tor"},
		{39, 247, "wh2_main_northern_jungle_of_pahualaxa_shrine_of_sotek"},
		{76, 198, "wh2_main_southern_jungle_of_pahualaxa_floating_pyramid"},
		{95, 79, "wh2_main_southern_great_jungle_itza"},
		{200, 38, "wh2_main_headhunters_jungle_marks_of_the_old_ones"},
		{418, 87, "wh2_main_land_of_assassins_lashiek"},
		{507, 8, "wh2_main_great_desert_of_araby_el-kalabad"},
		{679, 120, "wh2_main_ash_river_quatar"},
		{872, 47, "wh2_main_southlands_jungle_golden_tower_of_the_gods"},
		{824, 156, "wh2_main_devils_backbone_lahmia"}
	};
    
   
    -- get the highest ranked general's position
    --[[ old CA stuff.
	local current_turn_faction = cm:model():world():whose_turn_is_it();
	local highest_ranked_general = cm:get_highest_ranked_general_for_faction(current_turn_faction);

	if highest_ranked_general then
		char_x = highest_ranked_general:logical_position_x();
		char_y = highest_ranked_general:logical_position_y();
	else
		return;
	end;

	local min_distance = 50;
	local closest_distance = 500000;
	local chosen_spawn_point = nil;
	
	-- get the closest spawn point to the chosen general that isn't in a region owned by the player
	for i = 1, #possible_spawn_points do
		local current_distance = distance_squared(char_x, char_y, possible_spawn_points[i][1], possible_spawn_points[i][2]);
		local region = cm:get_region(possible_spawn_points[i][3]);
		
		if region:owning_faction() ~= current_turn_faction and current_distance < closest_distance and current_distance > min_distance then
			closest_distance = current_distance;
			chosen_spawn_point = possible_spawn_points[i];
		end;
	end;
    ]]--
     --DF ADDITIONS

    local valid_spawns = {}
    for i = 1, #possible_spawn_points do
        if not cm:get_region(possible_spawn_points[i][3]):owning_faction():is_human() then
            table.insert(valid_spawns, possible_spawn_points[i])
        end
    end
    local chosen_spawn_index = cm:random_number(#valid_spawns)
    local chosen_spawn_point = valid_spawns[chosen_spawn_index]

	--end of df additions

	if not chosen_spawn_point then
		return;
	end;
	
	local x = chosen_spawn_point[1];
	local y = chosen_spawn_point[2];
	
	-- check if there is a character at that point, if so, return
	local faction_list = cm:model():world():faction_list();
	
	for i = 0, faction_list:num_items() - 1 do
		local current_faction = faction_list:item_at(i);
		local char_list = current_faction:character_list();
		
		for j = 0, char_list:num_items() - 1 do
			local current_char = char_list:item_at(j);
			if current_char:logical_position_x() == x and current_char:logical_position_y() == y then
				return;
			end;
		end;
	end;
	
	-- just using region for the id for now, but could uncover shroud
	local region_name = chosen_spawn_point[3];
	
	local faction = cm:get_faction(faction_name);
	local subculture = faction:subculture();
	local building = "wh_dlc03_horde_beastmen_gors_1";
	
	if subculture == "wh_main_sc_grn_savage_orcs" then
		building = "wh_main_horde_savage_military_1";
	end;
	
	local difficulty = cm:model():combined_difficulty_level();

	local army_size = 8;			-- easy

	if difficulty == 0 then
		army_size = 10;				-- normal
	elseif difficulty == -1 then
		army_size = 12;				-- hard
	elseif difficulty == -2 then
		army_size = 14;				-- very hard
	elseif difficulty == -3 then
		army_size = 16;				-- legendary
	end;
	
	cm:create_force(
		faction_name,
		ram:generate_force(subculture .. "_horde", army_size),
		region_name,
		x,
		y,
		false,
		true,
		function(cqi)
			show_spawned_army_event(subculture, x, y);
			
			-- add recruitment buildings to the spawned horde
			local character = cm:get_character_by_cqi(cqi);
			local mf_cqi = character:military_force():command_queue_index();
			cm:add_building_to_force(mf_cqi, building);
			
			local current_turn_faction_name = cm:model():world():whose_turn_is_it():name();
			cm:add_turn_countdown_event(current_turn_faction_name, faction_reemerge_cooldown_turns, "ScriptEventFactionReemergeCooldownExpired");
			
			cm:set_saved_value("allow_factions_to_reemerge", false);
			cm:set_saved_value(faction_name .. "_dead", 0);
		end
	);
end;