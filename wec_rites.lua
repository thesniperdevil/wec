-------WRITTEN BY: DrunkFlamingo for Vandy
--last update 6/2/2018


OWR_LOG_ALLOWED = false 






function WEC_REFRESH_LOG()
    if not OWR_LOG_ALLOWED then
        return;
    end
    
    local logTimeStamp = os.date("%d, %m %Y %X")
    --# assume logTimeStamp: string
    
    local popLog = io.open("WEC_LOG.txt","w+")
    popLog :write("NEW LOG ["..logTimeStamp.."] \n")
    popLog :flush()
    popLog :close()
end

--v function(text: string)
function OWRLOG(text)
    ftext = "OWR" 
    --sometimes I use ftext as an arg of this function, but for simple mods like this one I don't need it.

    if not OWR_LOG_ALLOWED then
      return; --if our bool isn't set true, we don't want to spam the end user with logs. 
    end

  local logText = tostring(text)
  local logContext = tostring(ftext)
  local logTimeStamp = os.date("%d, %m %Y %X")
  local popLog = io.open("WEC_LOG.txt","a")
  --# assume logTimeStamp: string
  popLog :write("WEC:  "..logText .. "    : [" .. logContext .. "] : [".. logTimeStamp .. "]\n")
  popLog :flush()
  popLog :close()
end




---Overwritin' here instead of there, gotta add them peasants!
--v [NO_CHECK] function(faction: CA_FACTION)
function Calculate_Economy_Penalty(faction)
    if Is_Bretonnian(faction:name()) and faction:is_human() then
        output_P("---- Calculate_Economy_Penalty ----");
        local peasant_count = 0;
        local force_list = faction:military_force_list();
        local region_count = faction:region_list():num_items();
        
        for i = 0, force_list:num_items() - 1 do
            local force = force_list:item_at(i);
            
            -- Make sure this isn't a garrison!
            if force:is_armed_citizenry() == false and force:has_general() == true then
                local unit_list = force:unit_list();
                
                for j = 0, unit_list:num_items() - 1 do
                    local unit = unit_list:item_at(j);
                    local key = unit:unit_key();
                    local val = Bretonnia_Peasant_Units[key] or 0;
                    
                    output_P("\t"..key.." - "..val);
                    peasant_count = peasant_count + val;
                end
            end
        end
        
        if cm:is_multiplayer() == false then
            if PEASANTS_WARNING_COOLDOWN > 0 then
                PEASANTS_WARNING_COOLDOWN = PEASANTS_WARNING_COOLDOWN - 1;
            end
        end
        
        output_P("\tPeasants: "..peasant_count);
        Remove_Economy_Penalty(faction);
        
    
    
        local peasants_per_region_fac = PEASANTS_PER_REGION;
        local peasants_base_amount_fac = PEASANTS_BASE_AMOUNT;
        
        -- Peasants Per Region Modifiers
        if faction:name() == "wh_main_brt_carcassonne" then
            peasants_base_amount_fac = peasants_base_amount_fac + 5;
        end
        if faction:has_technology("tech_dlc07_brt_economy_farm_4") then
            peasants_per_region_fac = peasants_per_region_fac + 1;
        end
        
        -- Make sure player has regions
        if faction:region_list():num_items() < 1 then
            peasants_base_amount_fac = 0;
        end
        
		--------------------------
        ----OWR INJECTION HERE----
        --------------------------
        
        if faction:has_effect_bundle("wh_main_ritual_brt_peasants") then
            peasants_base_amount_fac = peasants_base_amount_fac + 10;
        end
        
        
        --------------------------
		----OWR INJECTION END-----
        --------------------------
        
        local free_peasants = (region_count * peasants_per_region_fac) + peasants_base_amount_fac;
        free_peasants = math.max(1, free_peasants);
        output_P("Free Peasants: "..free_peasants);
        local peasant_percent = (peasant_count / free_peasants) * 100;
        output_P("Peasant Percent: "..peasant_percent.."%");
        peasant_percent = RoundUp(peasant_percent);
        output_P("Peasant Percent Rounded: "..peasant_percent.."%");
        peasant_percent = math.min(peasant_percent, 200);
        output_P("Peasant Percent Clamped: "..peasant_percent.."%");
        
        if peasant_percent > 100 then
            peasant_percent = peasant_percent - 100;
            output_P("Peasant Percent Final: "..peasant_percent);
            cm:apply_effect_bundle(PEASANTS_EFFECT_PREFIX..peasant_percent, faction:name(), 0);
            
            if cm:get_saved_value("ScriptEventNegativePeasantEconomy") ~= true and faction:is_human() then
                core:trigger_event("ScriptEventNegativePeasantEconomy");
                cm:set_saved_value("ScriptEventNegativePeasantEconomy", true);
            end
            if cm:is_multiplayer() == false then
                if PEASANTS_RATIO_POSITIVE == true and PEASANTS_WARNING_COOLDOWN < 1 then
                    Show_Peasant_Warning(faction:name());
                    PEASANTS_WARNING_COOLDOWN = 25;
                end
            end
            
            PEASANTS_RATIO_POSITIVE = false;
        else
            output_P("Peasant Percent Final: 0");
            cm:apply_effect_bundle(PEASANTS_EFFECT_PREFIX.."0", faction:name(), 0);
            
            if cm:get_saved_value("ScriptEventNegativePeasantEconomy") == true and cm:get_saved_value("ScriptEventPositivePeasantEconomy") ~= true and faction:is_human() then
                core:trigger_event("ScriptEventPositivePeasantEconomy");
                cm:set_saved_value("ScriptEventPositivePeasantEconomy", true);
            end
            PEASANTS_RATIO_POSITIVE = true;
        end
    end
end;

--v function(faction_name: string)
function df_spawn_cultists(faction_name)

OWRLOG("OWR: spawning cultists")

local army = cm:get_highest_ranked_general_for_faction(faction_name);
OWRLOG("1")
local spawnx = army:logical_position_x() + 3;
OWRLOG("2")
local spawny = army:logical_position_y() - 3;
OWRLOG("3")
local spawnregion = "wh_main_goromandy_mountains_baersonlings_camp"
OWRLOG("4")
local unit_list = "wh_dlc01_chs_inf_forsaken_0,wh_dlc01_chs_inf_forsaken_0,wh_main_chs_inf_chosen_0,wh_main_chs_inf_chaos_marauders_0,wh_main_chs_inf_chaos_marauders_0,wh_main_chs_inf_chaos_marauders_0,wh_main_chs_inf_chaos_marauders_0,wh_main_chs_inf_chaos_warriors_1,wh_main_chs_inf_chaos_warriors_1,wh_main_chs_inf_chaos_warriors_1,wh_main_chs_mon_chaos_spawn,wh_main_chs_mon_chaos_spawn,wh_main_chs_mon_chaos_warhounds_0"
OWRLOG("5")
local turn = cm:model():turn_number();


OWRLOG("spawning army");
	cm:create_force(
	"wh2_main_chs_chaos_incursion_def",
	unit_list,
	spawnregion,
	spawnx,
	spawny,
	true,
	true);
	
	cm:callback( function()
		cm:force_diplomacy("faction:wh2_main_chs_chaos_incursion_def", "faction:"..faction_name, "war,break vassal,break alliance,break client state", false, false, false);	
		cm:force_make_vassal(faction_name, "wh2_main_chs_chaos_incursion_def");
	
	end, 0.5);


end;

--v function()
function OWR_chs_cults()
	
	local majorcities_list = {
		"wh_main_reikland_altdorf",
		"wh_main_middenland_middenheim",
		"wh_main_southern_oblast_kislev",
		"wh_main_couronne_et_languille_couronne",
		"wh_main_bordeleaux_et_aquitaine_bordeleaux",
		"wh_main_estalia_magritta",
		"wh2_main_nagarythe_tor_anlec",
		"wh2_main_yvresse_tor_yvresse",
		"wh2_main_eataine_lothern",
		"wh2_main_the_chill_road_ghrond",
		"wh2_main_iron_mountains_naggarond",
		"wh2_main_titan_peaks_ancient_city_of_quintex",
		"wh2_main_the_road_of_skulls_har_ganeth",
		"wh_main_tilea_miragliano",
		"wh_main_eastern_border_princes_akendorf",
		"wh_main_western_border_princes_myrmidens"
	}--: vector<string>
		
	
	for i = 1, #majorcities_list do
		cm:apply_effect_bundle_to_region("wh_main_ritual_chs_cults_corruption", majorcities_list[i], 10)
	end;
end;



--function (re)applies region effect bundle to all capitals of given faction.
--expects faction():name() and a string for the effect bundle name.
--v function(faction: string, effect_bundle: string)
function apply_effect_to_regions(faction, effect_bundle)
	local effectBundle = effect_bundle
	local thisFaction = cm:model():world():faction_by_key(faction);
	local regionList = thisFaction:region_list();
	OWRLOG("TP: effect function called");
	
	for i = 0, regionList:num_items() - 1 do
		local current_region = regionList:item_at(i);
		OWRLOG("TP: checking regions with trade");
			
		if current_region:is_province_capital() then
			OWRLOG("TP: applying bundle to capital.");
			cm:remove_effect_bundle_from_region(effectBundle, current_region:name());
			cm:apply_effect_bundle_to_region(effectBundle, current_region:name(), 10);
		end;
	end;
end;








--v function(faction: CA_FACTION)
function dwf_holds_listeners(faction)
OWRLOG("began dwarf hold for "..tostring(faction:name()).." applying the effect bundles");
local current_faction = cm:get_faction((faction:name()));
local region_list = current_faction:region_list();


for i = 0, region_list:num_items() - 1 do
	local current_region = region_list:item_at(i);
	local current_region_name = current_region:name();
	OWRLOG("applying to "..tostring(current_region_name).." for dwf_holds");		
	cm:apply_effect_bundle_to_region("wh_main_ritual_dwf_holds_movement", current_region_name, 5);
	
end


	
end;

--v function(faction: CA_FACTION)
function OWR_emp_policy(faction)
    if faction:is_human() then
        local dilemma_list = {
            "wh_main_ritual_emp_policy_cults",
            "wh_main_ritual_emp_policy_enemies",
            "wh_main_ritual_emp_policy_friends",
            "wh_main_ritual_emp_policy_leaders"
        }--:vector<string>
        
        local index = cm:random_number(#dilemma_list);
        
        cm:trigger_dilemma(faction:name(), dilemma_list[index], true);
    else
        local effect_bundle_list = {
            "wh_main_ritual_emp_policy_cults_taal",
            "wh_main_ritual_emp_policy_cults_sigmar",
            "wh_main_ritual_emp_policy_cults_ulric",
            "wh_main_ritual_emp_policy_cults_varena",
            "wh_main_ritual_emp_policy_enemies_vmp",
            "wh_main_ritual_emp_policy_enemies_chs",
            "wh_main_ritual_emp_policy_enemies_grn",
            "wh_main_ritual_emp_policy_enemies_emp",
            "wh_main_ritual_emp_policy_friends_brt",
            "wh_main_ritual_emp_policy_friends_hef",
            "wh_main_ritual_emp_policy_friends_dwf",
            "wh_main_ritual_emp_policy_friends_ksl",
            "wh_main_ritual_emp_policy_leaders_necessary_evils",
            "wh_main_ritual_emp_policy_leaders_army",
            "wh_main_ritual_emp_policy_leaders_cults",
            "wh_main_ritual_emp_policy_leaders_cities"
        }--: vector<string>
        
        local index = cm:random_number(#effect_bundle_list);
        local faction_name = faction:name();
        
        cm:apply_effect_bundle(effect_bundle_list[index], faction_name, 10);
    end;
end;




--this function uses CA's rite condition loading function to load custom conditions for OWR.
function owr_rite_unlock_listeners()
	out("test1");
	
	OWRLOG("Starting Rite Unlocks");
	out("test2");
	local rite_templates = {

		--BEASTMEN--
		--Vicious Shadows--
		--win an ambush battle
		{
			["subculture"] = "wh_dlc03_sc_bst_beastmen",
			["rite_name"] = "wh_main_ritual_bst_vicious_shadows",
			["event_name"] = "CharacterCompletedBattle",
			["condition"] =
			function(context, --: WHATEVER
			faction_name --: string 	
			)
					local character = context:character();
					local pb = context:pending_battle();
					--# assume character: CA_CHAR
					--# assume pb: CA_PENDING_BATTLE
					return character:faction():name() == faction_name and pb:ambush_battle() and character == pb:attacker() and character:won_battle();
			end
		},

		--Vicious Heart--
		--get bray shaman to level 10
		{
			["subculture"] = "wh_dlc03_sc_bst_beastmen",
			["rite_name"] = "wh_main_ritual_bst_vicious_heart",
			["event_name"] = "CharacterRankUp",
			["condition"] =
			function(context --: WHATEVER
				,faction_name --: string 	
			)
					local character = context:character();
					
					return character:faction():name() == faction_name and character:character_type("wizard") and character:rank() >= 10;
				end
		},
		--Vicious Herd--
		--build wh_dlc03_horde_beastmen_gors_4
		{
			["subculture"] = "wh_dlc03_sc_bst_beastmen",
			["rite_name"] = "wh_main_ritual_bst_vicious_herd",
			["event_name"] = "MilitaryForceBuildingCompleteEvent",
			["condition"] =
			function(context --: WHATEVER
				,faction_name --: string 	
			)
					return context:building() == "wh_dlc03_horde_beastmen_gors_4" and context:character():faction():is_human();
				end
		},

		--Vicious Demise--
		--raze 10 settlements
        {
            ["subculture"] = "wh_dlc03_sc_bst_beastmen",
            ["rite_name"] = "wh_main_ritual_bst_vicious_demise",
            ["event_name"] = "CharacterRazedSettlement",
            ["condition"] =
			function(context --: WHATEVER
				,faction_name --: string 	
			)
                
                    if context:character():faction():name() == faction_name then
                
                        local raze_count = cm:get_saved_value("wh_main_ritual_bst_vicious_demise_count");
                        if raze_count == nil then raze_count = 0 end
                        raze_count = raze_count + 1;
                        cm:set_saved_value("wh_main_ritual_bst_vicious_demise_count", raze_count);
                
                        return raze_count >= 10
                    end
                    return false; 
                
                end
        },

		--VAMPIRES--
		--Intrigue--
		--NAP w/ Emp
		{
			["subculture"] = "wh_main_sc_vmp_vampire_counts",
			["rite_name"] = "wh_main_ritual_vmp_intrigue",
			["event_name"] = "FactionTurnStart",
			["condition"] =
			function(context --: WHATEVER
				,faction_name --: string 	
			)
									
					return context:faction():name() == faction_name and context:faction():has_technology("tech_vmp_blood_07")
				end
		},
		
		--Willpower--
		--build wh_main_vmp_balefire_3
		{
			["subculture"] = "wh_main_sc_vmp_vampire_counts",
			["rite_name"] = "wh_main_ritual_vmp_willpower",
			["event_name"] = "BuildingCompleted",
			["condition"] =
			function(context --: WHATEVER
				,faction_name --: string 	
			)
					local building = context:building();
					
					return building:faction():name() == faction_name and building:name() == "wh_main_vmp_balefire_3";
				end
		},
		{
			["subculture"] = "wh_main_sc_vmp_vampire_counts",
			["rite_name"] = "wh_main_ritual_vmp_willpower",
			["event_name"] = "GarrisonOccupiedEvent",
			["condition"] =
			function(context --: WHATEVER
				,faction_name --: string 	
			)
					local region = context:garrison_residence():region();
					
					return context:character():faction():name() == faction_name and region:building_exists("wh_main_vmp_balefire_3");
				end
		},
		
		--Strength--
		--win 5 battles	
		{
            ["subculture"] = "wh_main_sc_vmp_vampire_counts",
            ["rite_name"] = "wh_main_ritual_vmp_strength",
            ["event_name"] = "CharacterCompletedBattle",
            ["condition"] =
			function(context --: WHATEVER
				,faction_name --: string 	
			)
                    local victory_count = cm:get_saved_value("wh_main_ritual_vmp_strength_count");
                    if victory_count == nil then victory_count = 0 end
                    
                    if context:character():faction():name() == faction_name and context:character():won_battle() then
                        victory_count = victory_count + 1;
                        cm:set_saved_value("wh_main_ritual_vmp_strength_count", victory_count);
                    end
                
                    return victory_count >= 5;
                end
        },

		--Dominance--
		--level 7 faction leader
		{
			["subculture"] = "wh_main_sc_vmp_vampire_counts",
			["rite_name"] = "wh_main_ritual_vmp_dominance",
			["event_name"] = "CharacterRankUp",
			["condition"] =
			function(context --: WHATEVER
				,faction_name --: string 	
			)
					local character = context:character();
					
					return character:faction():name() == faction_name and tonumber(character:rank()) >= 7;
				end
		},
		
		--DWARFS--
		--Guilds--
		--research tech_dwf_civ_3_3
		{
			["subculture"] = "wh_main_sc_dwf_dwarfs",
			["rite_name"] = "wh_main_ritual_dwf_guilds",
			["event_name"] = "FactionTurnStart",
			["condition"] =
			function(context --: WHATEVER
				,faction_name --: string 	
			)
									
					return context:faction():name() == faction_name and context:faction():has_technology("tech_dwf_civ_3_3")
				end
		},

		--Holds--
		--own 6 settlements
		{
			["subculture"] = "wh_main_sc_dwf_dwarfs",
			["rite_name"] = "wh_main_ritual_dwf_holds",
			["event_name"] = "GarrisonOccupiedEvent",
			["condition"] =
			function(context --: WHATEVER
				,faction_name --: string 	
			)
					local faction = context:character():faction();
					
					return faction:name() == faction_name and faction:region_list():num_items() >= 6;
				end
		},		
		
		--Underway--
		--level 7 faction leader
		{
			["subculture"] = "wh_main_sc_dwf_dwarfs",
			["rite_name"] = "wh_main_ritual_dwf_underway",
			["event_name"] = "CharacterRankUp",
			["condition"] =
			function(context --: WHATEVER
				,faction_name --: string 	
			)
					local character = context:character();
					
					return character:faction():name() == faction_name and tonumber(character:rank()) >= 7;
				end
		},		
		
		--Oath--
		--build wh_main_dwf_slayer_2
		{
			["subculture"] = "wh_main_sc_dwf_dwarfs",
			["rite_name"] = "wh_main_ritual_dwf_oath",
			["event_name"] = "BuildingCompleted",
			["condition"] =
			function(context --: WHATEVER
				,faction_name --: string 	
			)
					local building = context:building();
					
					return building:faction():name() == faction_name and building:name() == "wh_main_dwf_slayer_2";
				end
		},
		--Oath secondary--
		{
			["subculture"] = "wh_main_sc_dwf_dwarfs",
			["rite_name"] = "wh_main_ritual_dwf_oath",
			["event_name"] = "GarrisonOccupiedEvent",
			["condition"] =
			function(context --: WHATEVER
				,faction_name --: string 	
			)
					local region = context:garrison_residence():region();
					
					return context:character():faction():name() == faction_name and region:building_exists("wh_main_dwf_slayer_2");
				end
		},

		--KRAKA DRAK--
		--Guilds--
		--research kraka_tech4_ancestors
		{
			["subculture"] = "wh_main_sc_dwf_dwarfs",
			["rite_name"] = "wh_main_ritual_dwf_guilds",
			["event_name"] = "FactionTurnStart",
			["condition"] =
			function(context --: WHATEVER
				,faction_name --: string 	
			)
									
					return context:faction():name() == faction_name and context:faction():has_technology("kraka_tech4_ancestors")
				end,
			["faction_name"] = "wh_main_dwf_kraka_drak"
		},

		--Holds--
		--own 6 settlements
		{
			["subculture"] = "wh_main_sc_dwf_dwarfs",
			["rite_name"] = "wh_main_ritual_dwf_holds",
			["event_name"] = "GarrisonOccupiedEvent",
			["condition"] =
			function(context --: WHATEVER
				,faction_name --: string 	
			)
					local faction = context:character():faction();
					
					return faction:name() == faction_name and faction:region_list():num_items() >= 6;
				end,
			["faction_name"] = "wh_main_dwf_kraka_drak"
		},		
		
		--Underway--
		--level 7 faction leader
		{
			["subculture"] = "wh_main_sc_dwf_dwarfs",
			["rite_name"] = "wh_main_ritual_dwf_underway",
			["event_name"] = "CharacterRankUp",
			["condition"] =
			function(context --: WHATEVER
				,faction_name --: string 	
			)
					local character = context:character();
					
					return character:faction():name() == faction_name and tonumber(character:rank()) >= 7;
				end,
			["faction_name"] = "wh_main_dwf_kraka_drak"
		},		
		
		--Oath--
		--build wh_main_dwf_slayer_2
		{
			["subculture"] = "wh_main_sc_dwf_dwarfs",
			["rite_name"] = "wh_main_ritual_dwf_oath",
			["event_name"] = "BuildingCompleted",
			["condition"] =
			function(context --: WHATEVER
				,faction_name --: string 	
			)
					local building = context:building();
					
					return building:faction():name() == faction_name and building:name() == "wh_main_dwf_slayer_2";
				end,
			["faction_name"] = "wh_main_dwf_kraka_drak"
		},
		--Oath secondary--
		{
			["subculture"] = "wh_main_sc_dwf_dwarfs",
			["rite_name"] = "wh_main_ritual_dwf_oath",
			["event_name"] = "GarrisonOccupiedEvent",
			["condition"] =
			function(context --: WHATEVER
				,faction_name --: string 	
			)
					local region = context:garrison_residence():region();
					
					return context:character():faction():name() == faction_name and region:building_exists("wh_main_dwf_slayer_2");
				end,
			["faction_name"] = "wh_main_dwf_kraka_drak"
		},		


		---EMPIRE---
		--Gunpowder
		--build wh_main_emp_forges_3
		{
			["subculture"] = "wh_main_sc_emp_empire",
			["rite_name"] = "wh_main_ritual_emp_gunpowder",
			["event_name"] = "BuildingCompleted",
			["condition"] =
			function(context --: WHATEVER
				,faction_name --: string 	
			)
					local building = context:building();
					
					return building:faction():name() == faction_name and building:name() == "wh_main_emp_forges_3";
				end
		},
		--Gunpowder secondary--
		{
			["subculture"] = "wh_main_sc_emp_empire",
			["rite_name"] = "wh_main_ritual_emp_gunpowder",
			["event_name"] = "GarrisonOccupiedEvent",
			["condition"] =
			function(context --: WHATEVER
				,faction_name --: string 	
			)
					local region = context:garrison_residence():region();
					
					return context:character():faction():name() == faction_name and region:building_exists("wh_main_emp_forges_3");
				end
		},		
		
		--Faith
		--perform action w/ wizard
		{
			["subculture"] = "wh_main_sc_emp_empire",
			["rite_name"] = "wh_main_ritual_emp_faith",
			["event_name"] = "CharacterCharacterTargetAction",
			["condition"] =
			function(context --: WHATEVER
				,faction_name --: string 	
			)
					local character = context:character();
					
					return character:faction():name() == faction_name and character:character_type("wizard");
				end
		},
		{
			["subculture"] = "wh_main_sc_emp_empire",
			["rite_name"] = "wh_main_ritual_emp_faith",
			["event_name"] = "CharacterGarrisonTargetAction",
			["condition"] =
			function(context --: WHATEVER
				,faction_name --: string 	
			)
					local character = context:character();
					
					return character:faction():name() == faction_name and character:character_type("wizard");
				end
		},
		
		--Steel
		--own 20 units
		{
			["subculture"] = "wh_main_sc_emp_empire",
			["rite_name"] = "wh_main_ritual_emp_steel",
			["event_name"] = "FactionTurnStart",
			["condition"] =
			function(context --: WHATEVER
				,faction_name --: string 	
			)
					local faction = context:faction();
					
					if faction:name() == faction_name then
						local mf_list = faction:military_force_list();
						local units = 0;
						
						for i = 0, mf_list:num_items() - 1 do
							local current_mf = mf_list:item_at(i);
							
							if current_mf:has_general() and not current_mf:is_armed_citizenry() then
								units = units + current_mf:unit_list():num_items();
							end;
						end;
						
						return units > 19;
					end;
				end
		},

		--Policy
		--faction leader rank 7
		{
			["subculture"] = "wh_main_sc_emp_empire",
			["rite_name"] = "wh_main_ritual_emp_policy",			
			["event_name"] = "CharacterRankUp",
			["condition"] =
			function(context --: WHATEVER
				,faction_name --: string 	
			)
					local character = context:character();
					
					return character:faction():name() == faction_name and tonumber(character:rank()) >= 7;
				end
		},

		----------------
		---GREENSKINS---
		----------------
		
		--WAAAAGH!
		--own 40 units
		{
			["subculture"] = "wh_main_sc_grn_greenskins",
			["rite_name"] = "wh_main_ritual_grn_waaagh",
			["event_name"] = "FactionTurnStart",
			["condition"] =
			function(context --: WHATEVER
				,faction_name --: string 	
			)
					local faction = context:faction();
					
					if faction:name() == faction_name then
						local mf_list = faction:military_force_list();
						local units = 0;
						
						for i = 0, mf_list:num_items() - 1 do
							local current_mf = mf_list:item_at(i);
							
							if current_mf:has_general() and not current_mf:is_armed_citizenry() then
								units = units + current_mf:unit_list():num_items();
							end;
						end;
						
						return units > 39;
					end;
				end
		},
		
		--Da Bad Moon
		--fight ambush battle
		{
			["subculture"] = "wh_main_sc_grn_greenskins",
			["rite_name"] = "wh_main_ritual_grn_badmoon",
			["event_name"] = "CharacterCompletedBattle",
			["condition"] =
			function(context --: WHATEVER
				,faction_name --: string 	
			)
					local character = context:character();
					local pb = context:pending_battle();
					
					return character:faction():name() == faction_name and pb:ambush_battle() and character == pb:attacker() and character:won_battle();
				end
		},			
		
		
		--Gork n' Mork
		--LL rank 7
		{
			["subculture"] = "wh_main_sc_grn_greenskins",
			["rite_name"] = "wh_main_ritual_grn_gorknmork",
			["event_name"] = "CharacterRankUp",
			["condition"] =
			function(context --: WHATEVER
				,faction_name --: string 	
			)
					local character = context:character();

					return character:faction():name() == faction_name and tonumber(character:rank()) >= 7;
				end
		},
		
		--Spider God
		--build wh_main_grn_forest_beasts_3
		{
			["subculture"] = "wh_main_sc_grn_greenskins",
			["rite_name"] = "wh_main_ritual_grn_spidergod",
			["event_name"] = "BuildingCompleted",
			["condition"] =
			function(context --: WHATEVER
				,faction_name --: string 	
			)
					local building = context:building();
					
					return building:faction():name() == faction_name and building:name() == "wh_main_grn_forest_beasts_3";
				end
		},
		--Spider God secondary--
		{
			["subculture"] = "wh_main_sc_grn_greenskins",
			["rite_name"] = "wh_main_ritual_grn_spidergod",
			["event_name"] = "GarrisonOccupiedEvent",
			["condition"] =
			function(context --: WHATEVER
				,faction_name --: string 	
			)
					local region = context:garrison_residence():region();
					
					return context:character():faction():name() == faction_name and region:building_exists("wh_main_grn_forest_beasts_3");
				end
		},
			
		--KISLEV--

		--Winter
		--build wh_main_emp_settlement_major_5
		{
			["subculture"] = "wh_main_sc_ksl_kislev",
			["rite_name"] = "wh_main_ritual_ksl_winter",
			["event_name"] = "BuildingCompleted",
			["condition"] =
			function(context --: WHATEVER
				,faction_name --: string 	
			)
					local building = context:building();
					--return false;
					return building:faction():name() == faction_name and building:name() == "wh_main_emp_settlement_major_5";
				end,
			["faction_name"] = "wh_main_ksl_kislev"
		},	
		{
			["subculture"] = "wh_main_sc_ksl_kislev",
			["rite_name"] = "wh_main_ritual_ksl_winter",
			["event_name"] = "BuildingCompleted",
			["condition"] =
			function(context --: WHATEVER
				,faction_name --: string 	
			)
					local building = context:building();
					--return false;
					return building:faction():name() == faction_name and building:name() == "wh_main_emp_settlement_major_5";
				end,
			["faction_name"] = "wh_main_ksl_erengrad"			
		},
		--Winter secondary--
		{
			["subculture"] = "wh_main_sc_ksl_kislev",
			["rite_name"] = "wh_main_ritual_ksl_winter",
			["event_name"] = "GarrisonOccupiedEvent",
			["condition"] =
			function(context --: WHATEVER
				,faction_name --: string 	
			)
					local region = context:garrison_residence():region();
					--return false;
					return context:character():faction():name() == faction_name and region:building_exists("wh_main_emp_settlement_major_5");
				end,
			["faction_name"] = "wh_main_ksl_kislev"				
		},
		{
			["subculture"] = "wh_main_sc_ksl_kislev",
			["rite_name"] = "wh_main_ritual_ksl_winter",
			["event_name"] = "GarrisonOccupiedEvent",
			["condition"] =
			function(context --: WHATEVER
				,faction_name --: string 	
			)
					local region = context:garrison_residence():region();
					--return false;
					return context:character():faction():name() == faction_name and region:building_exists("wh_main_emp_settlement_major_5");
				end,
			["faction_name"] = "wh_main_ksl_erengrad"	
		},	
		--War
		--own 20 units; maybe change to tech?
		{
			["subculture"] = "wh_main_sc_ksl_kislev",
			["rite_name"] = "wh_main_ritual_ksl_levy",
			["event_name"] = "FactionTurnStart",
			["condition"] =
			function(context --: WHATEVER
				,faction_name --: string 	
			)
					local faction = context:faction();
					
					if faction:name() == faction_name then
						local mf_list = faction:military_force_list();
						local units = 0;
						
						for i = 0, mf_list:num_items() - 1 do
							local current_mf = mf_list:item_at(i);
							
							if current_mf:has_general() and not current_mf:is_armed_citizenry() then
								units = units + current_mf:unit_list():num_items();
							end;
						end;
						
						return units > 19;
					end;
				end,
			["faction_name"] = "wh_main_ksl_kislev"				
		},
		{
			["subculture"] = "wh_main_sc_ksl_kislev",
			["rite_name"] = "wh_main_ritual_ksl_levy",
			["event_name"] = "FactionTurnStart",
			["condition"] =
			function(context --: WHATEVER
				,faction_name --: string 	
			)
					local faction = context:faction();
					
					if faction:name() == faction_name then
						local mf_list = faction:military_force_list();
						local units = 0;
						
						for i = 0, mf_list:num_items() - 1 do
							local current_mf = mf_list:item_at(i);
							
							if current_mf:has_general() and not current_mf:is_armed_citizenry() then
								units = units + current_mf:unit_list():num_items();
							end;
						end;
						
						return units > 19;
					end;
				end,
			["faction_name"] = "wh_main_ksl_erengrad"				
		},		
		
		--Tides
		--LL rank 7
		
		{
			["subculture"] = "wh_main_sc_ksl_kislev",
			["rite_name"] = "wh_main_ritual_ksl_tide",
			["event_name"] = "CharacterRankUp",
			["condition"] =
			function(context --: WHATEVER
				,faction_name --: string 	
			)
					local character = context:character();
					
					return character:faction():name() == faction_name and tonumber(character:rank()) >= 7;
				end,
			["faction_name"] = "wh_main_ksl_kislev"					
		},
		{
			["subculture"] = "wh_main_sc_ksl_kislev",
			["rite_name"] = "wh_main_ritual_ksl_tide",
			["event_name"] = "CharacterRankUp",
			["condition"] =
			function(context --: WHATEVER
				,faction_name --: string 	
			)
					local character = context:character();
					
					return character:faction():name() == faction_name and tonumber(character:rank()) >= 7;
				end,
			["faction_name"] = "wh_main_ksl_erengrad"				
		},		
		
		--Envoys
		--war with chaos
		{
            ["subculture"] = "wh_main_sc_ksl_kislev",
            ["rite_name"] = "wh_main_ritual_ksl_emissaries",
            ["event_name"] = "FactionTurnStart",
            ["condition"] =
			function(context --: WHATEVER
				,faction_name --: string 	
			)
                    local human_factions = cm:get_human_factions();
                    local chaos = cm:get_faction("wh_main_chs_chaos");
                    for i = 1, #human_factions do 
                        local current_human = cm:get_faction(human_factions[i]);
                        if current_human:subculture() == "wh_main_sc_ksl_kislev" and current_human:at_war_with(chaos) then 
                            return true;
                        end
                    end
                    return false;
                end,
			["faction_name"] = "wh_main_ksl_kislev"				
        },	
		{
            ["subculture"] = "wh_main_sc_ksl_kislev",
            ["rite_name"] = "wh_main_ritual_ksl_emissaries",
            ["event_name"] = "FactionTurnStart",
            ["condition"] =
			function(context --: WHATEVER
				,faction_name --: string 	
			)
                    local human_factions = cm:get_human_factions();
                    local chaos = cm:get_faction("wh_main_chs_chaos");
                    for i = 1, #human_factions do 
                        local current_human = cm:get_faction(human_factions[i]);
                        if current_human:subculture() == "wh_main_sc_ksl_kislev" and current_human:at_war_with(chaos) then 
                            return true;
                        end
                    end
                    return false;
                end,
			["faction_name"] = "wh_main_ksl_erengrad"				
        },			
		
		---WOOD ELVES---
		
		--Athel Loren
		--build wh_dlc05_wef_oak_of_ages_2
		{
			["subculture"] = "wh_dlc05_sc_wef_wood_elves",
			["rite_name"] = "wh_main_ritual_wef_athelloren",
			["event_name"] = "BuildingCompleted",
			["condition"] =
			function(context --: WHATEVER
				,faction_name --: string 	
			)
					local building = context:building();
					
					return building:faction():name() == faction_name and building:name() == "wh_dlc05_wef_oak_of_ages_2";
				end
		},
		--Athel Loren secondary--
		{
			["subculture"] = "wh_dlc05_sc_wef_wood_elves",
			["rite_name"] = "wh_main_ritual_wef_athelloren",
			["event_name"] = "GarrisonOccupiedEvent",
			["condition"] =
			function(context --: WHATEVER
				,faction_name --: string 	
			)
					local region = context:garrison_residence():region();
					
					return context:character():faction():name() == faction_name and (region:building_exists("wh_dlc05_wef_oak_of_ages_2") or region:building_exists("wh_dlc05_wef_oak_of_ages_3") or region:building_exists("wh_dlc05_wef_oak_of_ages_4") or region:building_exists("wh_dlc05_wef_oak_of_ages_5"));
				end
		},		
		
		--Anath Raema
		--slaughter 10 sets of prisoners
        {
            ["subculture"] = "wh_dlc05_sc_wef_wood_elves",
            ["rite_name"] = "wh_main_ritual_wef_anathraema",
            ["event_name"] = "CharacterPostBattleSlaughter",
            ["condition"] =
			function(context --: WHATEVER
				,faction_name --: string 	
			)
                    if context:character():faction():name() == faction_name then
                        local slaughter_count = cm:get_saved_value("wh_main_ritual_wef_anathraema_count");
                        if slaughter_count == nil then slaughter_count = 0 end
                        
                        slaughter_count = slaughter_count + 1;
                        
                        cm:set_saved_value("wh_main_ritual_wef_anathraema_count", slaughter_count);
                        
                        return slaughter_count >= 10;
                    end
                end;
        },		
		
		--Loec
		--research tech_dlc05_1_loec
		
		{
			["subculture"] = "wh_dlc05_sc_wef_wood_elves",
			["rite_name"] = "wh_main_ritual_wef_loec",
			["event_name"] = "FactionTurnStart",
			["condition"] =
			function(context --: WHATEVER
				,faction_name --: string 	
			)
									
					return context:faction():name() == faction_name and context:faction():has_technology("tech_dlc05_1_loec")
				end
		},
		
		--Isha
		--NAP w/ High Elves
		
		{
			["subculture"] = "wh_dlc05_sc_wef_wood_elves",
			["rite_name"] = "wh_main_ritual_wef_isha",
			["event_name"] = "PositiveDiplomaticEvent",
			["condition"] =
			function(context --: WHATEVER
				,faction_name --: string 	
			)
					local proposer = context:proposer();
					local recipient = context:recipient();
					
					return ((proposer:is_human() and recipient:subculture() == "wh2_main_sc_hef_high_elves") or (recipient:is_human() and proposer:subculture() == "wh2_main_sc_hef_high_elves")) and cm:faction_has_trade_agreement_with_faction(proposer, recipient);
					
				end
		},

		---CHAOS---
		
		--Gods
		--slaughter 10 sets of prisoners
        {
            ["subculture"] = "wh_main_sc_chs_chaos",
            ["rite_name"] = "wh_main_ritual_chs_gods",
            ["event_name"] = "CharacterPostBattleSlaughter",
            ["condition"] =
			function(context --: WHATEVER
				,faction_name --: string 	
			)
                    if context:character():faction():name() == faction_name then
                        local slaughter_count = cm:get_saved_value("wh_main_ritual_chs_gods_count");
                        if slaughter_count == nil then slaughter_count = 0 end
                        
                        slaughter_count = slaughter_count + 1;
                        
                        cm:set_saved_value("wh_main_ritual_chs_gods_count", slaughter_count);
                        
                        return slaughter_count >= 10;
                    end
				end,
			["faction_name"] = "wh_main_chs_chaos"
		},
		
		--Storms
		--build wh_main_horde_chaos_magic_2
		{
			["subculture"] = "wh_main_sc_chs_chaos",
			["rite_name"] = "wh_main_ritual_chs_storms",
			["event_name"] = "MilitaryForceBuildingCompleteEvent",
			["condition"] =
			function(context --: WHATEVER
				,faction_name --: string 	
			)
					return context:building() == "wh_main_horde_chaos_magic_2" and context:character():faction():is_human();
					--return false;
				end,
			["faction_name"] = "wh_main_chs_chaos"
		},
		
		--Tides
		--LL rank 7
		{
			["subculture"] = "wh_main_sc_chs_chaos",
			["rite_name"] = "wh_main_ritual_chs_tides",
			["event_name"] = "CharacterRankUp",
			["condition"] =
			function(context --: WHATEVER
				,faction_name --: string 	
			)
					local character = context:character();
					
					return character:faction():name() == faction_name and tonumber(character:rank()) >= 7;
				end,
			["faction_name"] = "wh_main_chs_chaos"
		},
		
		--Cults
		--raze five cities
		
		{
			["subculture"] = "wh_main_sc_chs_chaos",
			["rite_name"] = "wh_main_ritual_chs_cults",
			["event_name"] = "CharacterRazedSettlement",
			["condition"] =
			function(context --: WHATEVER
				,faction_name --: string 	
			)
						
				local raze_count = cm:get_saved_value("wh_main_ritual_chs_cults_count");
					if raze_count == nil then raze_count = 0 end
					if context:character():faction():name() == faction_name then
						raze_count = raze_count + 1;
						cm:set_saved_value("wh_main_ritual_chs_cults_count", raze_count);
					end
					
					return raze_count >= 5
				
				
				end,
			["faction_name"] = "wh_main_chs_chaos"
		},	
		
		--SARTH--
		--Gods
		--slaughter 10 sets of prisoners
        {
            ["subculture"] = "wh_main_sc_chs_chaos",
            ["rite_name"] = "wh_main_ritual_chs_gods",
            ["event_name"] = "CharacterPostBattleSlaughter",
            ["condition"] =
			function(context --: WHATEVER
				,faction_name --: string 	
			)
                    if context:character():faction():name() == faction_name then
                        local slaughter_count = cm:get_saved_value("wh_main_ritual_chs_sarth_gods_count");
                        if slaughter_count == nil then slaughter_count = 0 end
                        
                        slaughter_count = slaughter_count + 1;
                        
                        cm:set_saved_value("wh_main_ritual_chs_sarth_gods_count", slaughter_count);
                        
                        return slaughter_count >= 10;
                    end
				end,
			["faction_name"] = "wh_main_chs_chaos_separatists"
        },		
		
		--Storms
		--build wh_main_horde_chaos_magic_2
		{
			["subculture"] = "wh_main_sc_chs_chaos",
			["rite_name"] = "wh_main_ritual_chs_storms",
			["event_name"] = "MilitaryForceBuildingCompleteEvent",
			["condition"] =
			function(context --: WHATEVER
				,faction_name --: string 	
			)
					return context:building() == "wh_main_horde_chaos_magic_2" and context:character():faction():is_human();
					--return false;
				end,
			["faction_name"] = "wh_main_chs_chaos_separatists"
		},
		
		--Tides
		--LL rank 7
		{
			["subculture"] = "wh_main_sc_chs_chaos",
			["rite_name"] = "wh_main_ritual_chs_tides",
			["event_name"] = "CharacterRankUp",
			["condition"] =
			function(context --: WHATEVER
				,faction_name --: string 	
			)
					local character = context:character();
					
					return character:faction():name() == faction_name and tonumber(character:rank()) >= 7;
				end,
			["faction_name"] = "wh_main_chs_chaos_separatists"
		},
		
		--Cults
		--raze five cities
		
		{
			["subculture"] = "wh_main_sc_chs_chaos",
			["rite_name"] = "wh_main_ritual_chs_cults",
			["event_name"] = "CharacterRazedSettlement",
			["condition"] =
			function(context --: WHATEVER
				,faction_name --: string 	
			)
						
				local raze_count = cm:get_saved_value("wh_main_ritual_chs_sarth_cults_count");
					if raze_count == nil then raze_count = 0 end
					if context:character():faction():name() == faction_name then
						raze_count = raze_count + 1;
						cm:set_saved_value("wh_main_ritual_chs_sarth_cults_count", raze_count);
					end
					
					return raze_count >= 5
				
				
				end,
			["faction_name"] = "wh_main_chs_chaos_separatists"
		},		
		
		
		---BRETONNIA---
		
		--Peasant
		--build 3x wh_main_brt_farm_3
		{
            ["subculture"] = "wh_main_sc_brt_bretonnia",
            ["rite_name"] = "wh_main_ritual_brt_peasants",
            ["event_name"] = "BuildingCompleted",
            ["condition"] =
			function(context --: WHATEVER
				,faction_name --: string 	
			)
				local building = context:building()
				--# assume building: CA_BUILDING
                    if building:faction():name() == faction_name and building:name() == "wh_main_brt_farm_3" then
                        local buillding_count = cm:get_saved_value("wh_main_ritual_brt_peasants_count");
                        if buillding_count == nil then buillding_count = 0 end
                        
                        buillding_count = buillding_count + 1;
                        
                        cm:set_saved_value("wh_main_ritual_brt_peasants_count", buillding_count);
                        
                        return buillding_count >= 3;
                    end
                end;
        },
		--Peasant secondary
        {
            ["subculture"] = "wh_main_sc_brt_bretonnia",
            ["rite_name"] = "wh_main_ritual_brt_peasants",
            ["event_name"] = "GarrisonOccupiedEvent",
            ["condition"] =
			function(context --: WHATEVER
				,faction_name --: string 	
			)
				local region = context:region()
				--# assume region: CA_REGION
                    if context:character():faction():name() == faction_name and region:building_exists("wh_main_brt_farm_3") then
                        local buillding_count = cm:get_saved_value("wh_main_ritual_brt_peasants_count");
                        if buillding_count == nil then buillding_count = 0 end
                        
                        buillding_count = buillding_count + 1;
                        
                        cm:set_saved_value("wh_main_ritual_brt_peasants_count", buillding_count);
                        
                        return buillding_count >= 3;
                    end
                end;
        },		
		
		--Errantry
		--fight battle outside Bretonnia
        {
            ["subculture"] = "wh_main_sc_brt_bretonnia",
            ["rite_name"] = "wh_main_ritual_brt_errantry",
            ["event_name"] = "CharacterCompletedBattle",
            ["condition"] =
			function(context --: WHATEVER
				,faction_name --: string 	
			)
                        return context:character():faction():name() == faction_name and not (context:character():region():owning_faction():subculture() == "wh_main_sc_brt_bretonnia" or context:character():region():owning_faction() == cm:get_faction("wh_main_vmp_mousillon"));
                end;
        },	
		
		--Blessing
		--build wh_main_brt_worship_3

		{
			["subculture"] = "wh_main_sc_brt_bretonnia",
			["rite_name"] = "wh_main_ritual_brt_blessing",
			["event_name"] = "BuildingCompleted",
			["condition"] =
			function(context --: WHATEVER
				,faction_name --: string 	
			)
					local building = context:building();
					
					return building:faction():name() == faction_name and building:name() == "wh_main_brt_worship_3";
				end
		},
		--Blessing secondary--
		{
			["subculture"] = "wh_main_sc_brt_bretonnia",
			["rite_name"] = "wh_main_ritual_brt_blessing",
			["event_name"] = "GarrisonOccupiedEvent",
			["condition"] =
				function(context --: WHATEVER
					,faction_name --: string 	
				)
					local region = context:garrison_residence():region();
					
					return context:character():faction():name() == faction_name and region:building_exists("wh_main_brt_worship_3");
				end
		},

		--Invaders
		--LL rank 7		
		{
			["subculture"] = "wh_main_sc_brt_bretonnia",
			["rite_name"] = "wh_main_ritual_brt_invaders",
			["event_name"] = "CharacterRankUp",
			["condition"] =
				function(context --: WHATEVER 	
					, faction_name --: string 	
				)
					local character = context:character();
					
					return character:faction():name() == faction_name and tonumber(character:rank()) >= 7;
				end
		},
		
		--NORSCA

		--Kharnath
		--execute 10 sets of prisoners
		{
            ["subculture"] = "wh_main_sc_nor_norsca",
            ["rite_name"] = "wh_main_ritual_nor_men",
            ["event_name"] = "CharacterPostBattleSlaughter",
            ["condition"] =
			function(context --: WHATEVER
				,faction_name --: string 	
			)
                    if context:character():faction():name() == faction_name then
                        local slaughter_count = cm:get_saved_value("wh_main_ritual_nor_men_count");
                        if slaughter_count == nil then slaughter_count = 0 end
                        
                        slaughter_count = slaughter_count + 1;
                        
                        cm:set_saved_value("wh_main_ritual_nor_men_count", slaughter_count);
                        
                        return slaughter_count >= 10;
                    end
                end,
				["faction_name"] = "wh_dlc08_nor_wintertooth"
		},
		
		--Mermedus
		--level 5 main settlement

		{
			["subculture"] = "wh_main_sc_nor_norsca",
			["rite_name"] = "wh_main_ritual_nor_ships",
			["event_name"] = "BuildingCompleted",
			["condition"] =
			function(context --: WHATEVER
				,faction_name --: string 	
			)
					local building = context:building();
					
					return building:faction():name() == faction_name and (building:name() == "wh_main_nor_settlement_major_5" or building:name() == "wh_main_nor_settlement_major_5_coast");
				end,
				["faction_name"] = "wh_dlc08_nor_wintertooth"
		},
		{
			["subculture"] = "wh_main_sc_nor_norsca",
			["rite_name"] = "wh_main_ritual_nor_ships",
			["event_name"] = "GarrisonOccupiedEvent",
			["condition"] =
			function(context --: WHATEVER
				,faction_name --: string 	
			)
					local region = context:garrison_residence():region();
					
					return context:character():faction():name() == faction_name and (region:building_exists("wh_main_nor_settlement_major_5") or region:building_exists("wh_main_nor_settlement_major_5_coast"));
				end,
				["faction_name"] = "wh_dlc08_nor_wintertooth"
		},

		--Shornaal
		--raze 5 settlements, dawg

		{
            ["subculture"] = "wh_main_sc_nor_norsca",
            ["rite_name"] = "wh_main_ritual_nor_goods",
            ["event_name"] = "CharacterRazedSettlement",
            ["condition"] =
			function(context --: WHATEVER
				,faction_name --: string 	
			)
                
                    if context:character():faction():name() == faction_name then
                
                        local raze_count = cm:get_saved_value("wh_main_ritual_nor_goods_count");
                        if raze_count == nil then raze_count = 0 end
                        raze_count = raze_count + 1;
                        cm:set_saved_value("wh_main_ritual_nor_goods_count", raze_count);
                
                        return raze_count >= 5
                    end
                    return false; 
                
                end,
				["faction_name"] = "wh_dlc08_nor_wintertooth"
		},

		--Troll-King
		--level 7 faction leader, dawg
		{
			["subculture"] = "wh_main_sc_nor_norsca",
			["rite_name"] = "wh_main_ritual_nor_throgg",
			["event_name"] = "CharacterRankUp",
			["condition"] =
			function(context --: WHATEVER
				,faction_name --: string 	
			)
					local character = context:character();
					
					return character:faction():name() == faction_name and tonumber(character:rank()) >= 7;
				end,
			["faction_name"] = "wh_dlc08_nor_wintertooth"
		},
		
		--Kharnath
		--execute 10 sets of prisoners
		{
            ["subculture"] = "wh_main_sc_nor_norsca",
            ["rite_name"] = "wh_main_ritual_nor_men",
            ["event_name"] = "CharacterPostBattleSlaughter",
            ["condition"] =
			function(context --: WHATEVER
				,faction_name --: string 	
			)
                    if context:character():faction():name() == faction_name then
                        local slaughter_count = cm:get_saved_value("wh_main_ritual_nor_men_count");
                        if slaughter_count == nil then slaughter_count = 0 end
                        
                        slaughter_count = slaughter_count + 1;
                        
                        cm:set_saved_value("wh_main_ritual_nor_men_count", slaughter_count);
                        
                        return slaughter_count >= 10;
                    end
                end,
				["faction_name"] = "wh_dlc08_nor_norsca"
		},
		
		--Mermedus
		--level 5 main settlement

		{
			["subculture"] = "wh_main_sc_nor_norsca",
			["rite_name"] = "wh_main_ritual_nor_ships",
			["event_name"] = "BuildingCompleted",
			["condition"] =
			function(context --: WHATEVER
				,faction_name --: string 	
			)
					local building = context:building();
					
					return building:faction():name() == faction_name and (building:name() == "wh_main_nor_settlement_major_5" or building:name() == "wh_main_nor_settlement_major_5_coast");
				end,
				["faction_name"] = "wh_dlc08_nor_norsca"
		},
		{
			["subculture"] = "wh_main_sc_nor_norsca",
			["rite_name"] = "wh_main_ritual_nor_ships",
			["event_name"] = "GarrisonOccupiedEvent",
			["condition"] =
			function(context --: WHATEVER
				,faction_name --: string 	
			)
					local region = context:garrison_residence():region();
					
					return context:character():faction():name() == faction_name and (region:building_exists("wh_main_nor_settlement_major_5") or region:building_exists("wh_main_nor_settlement_major_5_coast"));
				end,
				["faction_name"] = "wh_dlc08_nor_norsca"
		},

		--Shornaal
		--raze 5 settlements, dawg

		{
            ["subculture"] = "wh_main_sc_nor_norsca",
            ["rite_name"] = "wh_main_ritual_nor_goods",
            ["event_name"] = "CharacterRazedSettlement",
            ["condition"] =
			function(context --: WHATEVER
				,faction_name --: string 	
			)
                
                    if context:character():faction():name() == faction_name then
                
                        local raze_count = cm:get_saved_value("wh_main_ritual_nor_goods_count");
                        if raze_count == nil then raze_count = 0 end
                        raze_count = raze_count + 1;
                        cm:set_saved_value("wh_main_ritual_nor_goods_count", raze_count);
                
                        return raze_count >= 5
                    end
                    return false; 
                
                end,
				["faction_name"] = "wh_dlc08_nor_norsca"
		},
		--Wulfrik
		--level 7 faction leader
		{
			["subculture"] = "wh_main_sc_nor_norsca",
			["rite_name"] = "wh_main_ritual_nor_wulfrik",
			["event_name"] = "CharacterRankUp",
			["condition"] =
			function(context --: WHATEVER
				,faction_name --: string 	
			)
					local character = context:character();
					
					return character:faction():name() == faction_name and tonumber(character:rank()) >= 7;
				end,
				["faction_name"] = "wh_dlc08_nor_norsca"
		}


	
	}--:vector<{subculture: string, rite_name: string, event_name: string, condition: function(context: WHATEVER, faction_name: string) --> boolean, faction_name: string?}>
	
	local human_factions = cm:get_human_factions();
	
	for i = 1, #human_factions do
		for j = 1, #rite_templates do
			local current_rite_template = rite_templates[j];
			if cm:get_faction(human_factions[i]):subculture() == current_rite_template.subculture then
				--# assume rite_unlock: RITE_UNLOCK
				OWRLOG("Adding Rite Unlock Condition for ["..human_factions[i].."] with rite key ["..current_rite_template.rite_name.."] and event name ["..current_rite_template.event_name.."] ")
				local rite = rite_unlock:new(
					current_rite_template.rite_name,
					current_rite_template.event_name,
					current_rite_template.condition,
					current_rite_template.faction_name
				)
				
				rite:start(human_factions[i]);
				if cm:is_new_game() then
					local cqi = cm:get_faction(human_factions[i]):command_queue_index();
					cm:set_ritual_unlocked(cqi, current_rite_template.rite_name, false);
				end
				
				
			end;
		end;
	end;
	local chaos_restricted_factions = {
	"wh_dlc08_chs_chaos_challenger_khorne",
	"wh_dlc08_chs_chaos_challenger_nurgle",
	"wh_dlc08_chs_chaos_challenger_slaanesh",
	"wh_dlc08_chs_chaos_challenger_tzeentch",
	"wh_main_chs_chaos_rebels",
	"wh_main_chs_chaos_separatists",
	"wh2_main_chs_chaos_incursion_def",
	"wh2_main_chs_chaos_incursion_hef",
	"wh2_main_chs_chaos_incursion_lzd",
	"wh2_main_chs_chaos_incursion_skv"
	}

	local empire_restricted_factions = {
		"wh_main_emp_empire",
		"wh_main_emp_hochland",
		"wh_main_emp_averland",
		"wh_main_emp_ostermark" , "wh_main_emp_stirland" ,
		"wh_main_emp_middenland" , "wh_main_emp_nordland" , "wh_main_emp_talabecland" , "wh_main_emp_wissenland" ,
		"wh_main_emp_ostland"
	}
	--wh_main_ritual_chs_storms 
	for i = 1, #chaos_restricted_factions do
		local current_faction = chaos_restricted_factions[i]
		if not cm:get_faction(current_faction):is_human() then
			cm:set_ritual_unlocked (cm:get_faction(current_faction):cqi(), "wh_main_ritual_chs_storms", false)
		end
	end

	if cm:model():turn_number() < 30 then
		for i = 1, #empire_restricted_factions do 
			local current_faction = empire_restricted_factions[i]
			if not cm:get_faction(current_faction):is_human() then
				cm:set_ritual_unlocked (cm:get_faction(current_faction):cqi(), "wh_main_ritual_emp_gunpowder", false)
			end
		end
	end

end;

function vandy_scripted_effects()

	--Special scripted rite effects!
	
	OWRLOG("OWR: setting up scripted effect listeners");
	
	vandy_effects_list_wh_main_ritual_chs_gods = {
	"wh_main_ritual_chs_gods_slaanesh",
	"wh_main_ritual_chs_gods_tzeentch",
	"wh_main_ritual_chs_gods_khorne",
	"wh_main_ritual_chs_gods_nurgle"
	} --: vector<string>
	
	vandy_effects_list_wh_main_ritual_grn_gorknmork = {
	"wh_main_ritual_grn_gorknmork_gork",
	"wh_main_ritual_grn_gorknmork_mork"
	} --: vector<string>
	
	
	--Dilemma for Gork n' Mork & Chaos Gods


core:add_listener(
    "OWR_Dilemma_Listener",
    "RitualCompletedEvent",
    function(context)
        return context:ritual():ritual_category() == "STANDARD_RITUAL";
    end,
    function(context)
        local ritual = context:ritual();
        local ritual_key = ritual:ritual_key();
        local faction = context:performing_faction();
        local faction_name = faction:name();
        local index = cm:random_number(#vandy_effects_list_wh_main_ritual_chs_gods);
        local waaaagh = cm:random_number(#vandy_effects_list_wh_main_ritual_grn_gorknmork);
        if ritual_key == "wh_main_ritual_chs_gods" then
            if faction:is_human() then 
                cm:trigger_dilemma(faction_name, "wh_main_ritual_chs_gods", true);
            else 
                cm:apply_effect_bundle(vandy_effects_list_wh_main_ritual_chs_gods[index], faction_name, 10);
            end
        elseif ritual_key == "wh_main_ritual_grn_gorknmork" then
            if faction:is_human() then
                cm:trigger_dilemma(faction_name, "wh_main_ritual_grn_gorknmork", true);
            else
                cm:apply_effect_bundle(vandy_effects_list_wh_main_ritual_grn_gorknmork[waaaagh], faction_name, 5);
            end
        end
    end,
    true);
	
--Dwarf Holds movement script	
	
core:add_listener(
    "OWR_Holds_Movement",
    "RitualCompletedEvent",
    function(context)
        return context:ritual():ritual_category() == "STANDARD_RITUAL";
    end,
    function(context)
        local ritual = context:ritual();
        local ritual_key = ritual:ritual_key();
        local faction = context:performing_faction();
        local faction_name = faction:name();
		OWRLOG("OWR: "..tostring(faction_name).." preformed "..tostring(ritual_key).." rite");
        if ritual_key == "wh_main_ritual_dwf_holds" then
            dwf_holds_listeners(faction)
        end
    end,
    true);
	
core:add_listener(
		"IntrigueRiteListener",
		"RitualCompletedEvent",
		function(context)
			return context:ritual():ritual_category() == "STANDARD_RITUAL";
		end,
		function(context)
			local ritual = context:ritual();
			local ritual_key = ritual:ritual_key();
			local faction = context:performing_faction();
			local factions_trading_with = faction:factions_trading_with();
			OWRLOG("TP: Standard ritual completed. Checking for Intrigue rite");
			
			if ritual_key == "wh_main_ritual_vmp_intrigue" then
			OWRLOG("TP: Intrigue Rite detected");
			
				if factions_trading_with:num_items() > 0 then
				OWRLOG("TP: Rite 'owner' has trading partners");
				
					for i = 0, factions_trading_with:num_items() - 1 do
						local current_faction = factions_trading_with:item_at(i);
						
						apply_effect_to_regions(current_faction:name(),"tp_trade_corr_bundle_region_vamp")
						OWRLOG("TP: Effect being added.");
					end;
				end;
			end;
		end,
		true
	);	
	
core:add_listener(
	"cultists",
	"RitualCompletedEvent",
	function(context)
		return context:ritual():ritual_category() == "STANDARD_RITUAL";
	end,
	function(context)
		local ritual = context:ritual();
		local ritual_key = ritual:ritual_key();
		local faction = context:performing_faction();
		
		if ritual_key == "wh_main_ritual_chs_cults" then
			df_spawn_cultists(faction:name());
		end;
	end,
	true);
	
core:add_listener(
	"empdilemmas",
	"RitualCompletedEvent",
	function(context)
		return context:ritual():ritual_category() == "STANDARD_RITUAL";
	end,
	function(context)
		local ritual = context:ritual();
		local ritual_key = ritual:ritual_key();
		local faction = context:performing_faction();
		
		if ritual_key == "wh_main_ritual_emp_policy" then
			OWR_emp_policy(faction)
		end;
	end,
	true);
	
core:add_listener(
	"chs_cult_corruption",
	"RitualCompletedEvent",
	function(context)
		return context:ritual():ritual_category() == "STANDARD_RITUAL";
	end,
	function(context)
		local ritual = context:ritual();
		local ritual_key = ritual:ritual_key();
		local faction = context:performing_faction();
		
		if ritual_key == "wh_main_ritual_chs_cults" then
			OWR_chs_cults()
		end;
	end,
	true);
		
	
	
	
	
end;












function wec_rites()

	cm:set_saved_value("vandy_rites", true);
	out("OWR SCRIPT IS RUNNING");
	
	owr_rite_unlock_listeners();
	vandy_scripted_effects();
	
	OWRLOG("OWR INIT COMPLETE");
end;
