load_script_libraries();

bm = battle_manager:new(empire_battle:new());
local gc = generated_cutscene:new(true);
cam = bm:camera();

gb = generated_battle:new(
	false,                                      		-- screen starts black
	true,                                      		-- prevent deployment for player
	false,                                      		    -- prevent deployment for ai
	function() end_deployment_phase() end,          	-- intro cutscene function
	false                                      			-- debug mode
);

intro_cinematic_file = "script/battle/quest_battles/_cutscene/scenes/wolfplate_s01.CindyScene";
bm:cindy_preload(intro_cinematic_file);

wh2_main_sfx_01 = new_sfx("Play_wh2_main_qb_skv_skrolk_the_liber_bubonicus_stage_3_mortuary_of_tzulaqua_pt_01");
wh2_main_sfx_02 = new_sfx("Play_wh2_main_qb_skv_skrolk_the_liber_bubonicus_stage_3_mortuary_of_tzulaqua_pt_02");
wh2_main_sfx_03 = new_sfx("Play_wh2_main_qb_skv_skrolk_the_liber_bubonicus_stage_3_mortuary_of_tzulaqua_pt_03");
wh2_main_sfx_04 = new_sfx("Play_wh2_main_qb_skv_skrolk_the_liber_bubonicus_stage_3_mortuary_of_tzulaqua_pt_04");

fade_on_intro_cutscene_end = true;

function end_deployment_phase()
	bm:out("\tend_deployment_phase() called");
	
	cam:fade(true, 0);
		
	-- declare cutscene
	local cutscene_intro = cutscene:new(
		"cutscene_intro", 			-- unique string name for cutscene
		ga_player_01.sunits,			-- unitcontroller over player's army
		30000, 				-- duration of cutscene in ms
		function() intro_cutscene_end() end		-- what to call when cutscene is finished
	);


	
	local player_units_hidden = true;

	
	-- set up subtitles
	local subtitles = cutscene_intro:subtitles();
	subtitles:set_alignment("bottom_centre");
	subtitles:clear();
	
	cutscene_intro:set_is_ambush();
	
	-- skip callback
	cutscene_intro:set_skippable(
		true, 
		function()
			bm:stop_cindy_playback(true);
			
			if player_units_hidden then
				ga_player_01:set_enabled(true)
			end;
		end
	);



cutscene_intro:set_debug(true);
cutscene_intro:enable_debug_timestamps(false);

bm:repeat_callback(
function() CameraOut() end,
5000,
"CameraOut"
);

	-- set up actions on cutscene
	--cutscene_intro:action(function() cam:fade(false, 1) end, 100);	

	--cutscene_intro:action(function() cam:move_to(v(307.712, 725.585, 141.159), v(217.846, 699.303, 183.810), 0, true, 0) end, 0);

	cutscene_intro:action(function() bm:cindy_playback("script/battle/quest_battles/_cutscene/scenes/wolfplate_s01.CindyScene", true, true) end, 0);	
	
	cutscene_intro:action(
		function()
			player_units_hidden = false;
			ga_player_01:set_enabled(true) 
		end, 
		200
	);
	
	-- Voiceover and Subtitles --
	
	cutscene_intro:action(function() cutscene_intro:play_sound(wh2_main_sfx_01) end, 3000);	
	cutscene_intro:action(function() cutscene_intro:show_custom_cutscene_subtitle("scripted_subtitles_localised_text_wh2_main_qb_skv_skrolk_the_liber_bubonicus_stage_3_mortuary_of_tzulaqua_pt_01", "subtitle_with_frame", 1) end, 3500);	
	cutscene_intro:action(function() cutscene_intro:hide_custom_cutscene_subtitles() end, 5000);
	
	cutscene_intro:action(function() cutscene_intro:play_sound(wh2_main_sfx_02) end, 5500);	
	cutscene_intro:action(function() cutscene_intro:show_custom_cutscene_subtitle("scripted_subtitles_localised_text_wh2_main_qb_skv_skrolk_the_liber_bubonicus_stage_3_mortuary_of_tzulaqua_pt_02", "subtitle_with_frame", 5) end, 6000);	
	cutscene_intro:action(function() cutscene_intro:hide_custom_cutscene_subtitles() end, 11500);
	
	cutscene_intro:action(function() cutscene_intro:play_sound(wh2_main_sfx_03) end, 12000);	
	cutscene_intro:action(function() cutscene_intro:show_custom_cutscene_subtitle("scripted_subtitles_localised_text_wh2_main_qb_skv_skrolk_the_liber_bubonicus_stage_3_mortuary_of_tzulaqua_pt_03", "subtitle_with_frame", 9.5) end, 12500);	
	cutscene_intro:action(function() cutscene_intro:hide_custom_cutscene_subtitles() end, 22500);
	
	cutscene_intro:action(function() cutscene_intro:play_sound(wh2_main_sfx_04) end, 23000);
	cutscene_intro:action(function() cutscene_intro:show_custom_cutscene_subtitle("scripted_subtitles_localised_text_wh2_main_qb_skv_skrolk_the_liber_bubonicus_stage_3_mortuary_of_tzulaqua_pt_04", "subtitle_with_frame", 4) end, 23500);	
	cutscene_intro:action(function() cutscene_intro:hide_custom_cutscene_subtitles() end, 29500);
	
	cutscene_intro:start();
end;

function intro_cutscene_end()
	local sm = gb.sm
	sm:trigger_message("01_intro_cutscene_end")
end;

function CameraOut()
	bm:cache_camera();
	local pos = bm:get_cached_camera_pos()
	local targ = bm:get_cached_camera_targ()
	
	local pos_y = pos:get_y();
	local pos_x = pos:get_x();
	local pos_z = pos:get_z();
	
	local targ_y = targ:get_y();
	local targ_x = targ:get_x();
	local targ_z = targ:get_z();
	

	out("POS: ("..tostring(pos_x)..","..tostring(pos_y)..","..tostring(pos_z)..")");
	out("TARG: ("..tostring(targ_x)..","..tostring(targ_y)..","..tostring(targ_z)..")");
end;




---------------------------
----HARD SCRIPT VERSION----
---------------------------
gb:set_objective_on_message("deployment_started", "wh_main_qb_objective_attack_defeat_army_ambush");


-------ARMY SETUP-------
ga_player_01 = gb:get_army(gb:get_player_alliance_num(), "player");
ga_bst1 = gb:get_army(gb:get_non_player_alliance_num(), "bst1");
ga_bst2 = gb:get_army(gb:get_non_player_alliance_num(), "bst2");
ga_bst3 = gb:get_army(gb:get_non_player_alliance_num(), "bst3");
ga_emp1 = gb:get_army(gb:get_player_alliance_num(), "emp1");


-------OBJECTIVES-------
--gb:queue_help_on_message("battle_started", "wh_dlc03_qb_bst_khazrak_one_eye_scourge_stage_4_hint_objective");


-------ORDERS-------

ga_bst1:attack_on_message("01_intro_cutscene_end");

ga_bst1:message_on_casualties("summon_reinforcements", 0.4);

ga_bst3:reinforce_on_message("summon_reinforcements");
ga_bst3:attack_on_message("summon_reinforcements");
ga_emp1:reinforce_on_message("testing");
ga_emp1:attack_on_message("testing");
ga_bst2:reinforce_on_message("summon_reinforcements");
ga_bst2:attack_on_message("summon_reinforcemnts");

ga_player_01:message_on_casualties("testing", 0.01);