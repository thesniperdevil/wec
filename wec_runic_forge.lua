--DF-VANDY DWARVEN FORGE PROJECT SCRIPT
--Writen by Drunk Flamingo


---If you're looking at this script because you're trying to override the images for a custom pooled resource, message me on https://discord.gg/4ee5vVB @DrunkFlamingo and I will help you set the script up.













dwarven_factions_list = {
	"wh_main_dwf_barak_varr",
	"wh_main_dwf_dwarfs",
	"wh_main_dwf_karak_azul",
	"wh_main_dwf_karak_hirn",
	"wh_main_dwf_karak_izor",
	"wh_main_dwf_karak_kadrin",
	"wh_main_dwf_karak_norn",
	"wh_main_dwf_karak_ziflin",
	"wh_main_dwf_kraka_drak",
	"wh_main_dwf_zhufbar",
	"wh2_main_dwf_greybeards_prospectors",
	"wh2_main_dwf_karak_zorn",
	"wh2_main_dwf_spine_of_sotek_dwarfs"
};






icon_table_dwf_craft = {
{"mortuary_cult", "listview", "list_clip", "list_box", "df_armour_rune_of_adamant", "requirement_list", "dwf_knowledge"},
{"mortuary_cult", "listview", "list_clip", "list_box", "wh_main_anc_rune_master_rune_of_battle", "requirement_list", "dwf_knowledge"},
{"mortuary_cult", "listview", "list_clip", "list_box", "wh_main_anc_rune_master_rune_of_sanctuary", "requirement_list", "dwf_knowledge"},
{"mortuary_cult", "listview", "list_clip", "list_box", "wh_main_anc_rune_master_rune_of_stoicism", "requirement_list", "dwf_knowledge"},
{"mortuary_cult", "listview", "list_clip", "list_box", "wh_main_anc_rune_master_rune_of_battle", "requirement_list", "dwf_knowledge"},
{"mortuary_cult", "listview", "list_clip", "list_box", "df_banner_rune_of_valaya", "requirement_list", "dwf_knowledge"},
{"mortuary_cult", "listview", "list_clip", "list_box", "df_engineering_rune_of_disguise", "requirement_list", "dwf_knowledge"},
{"mortuary_cult", "listview", "list_clip", "list_box", "df_talisman_rune_of_spite", "requirement_list", "dwf_knowledge"},
{"mortuary_cult", "listview", "list_clip", "list_box", "df_talisman_rune_of_passage", "requirement_list", "dwf_knowledge"},
{"mortuary_cult", "listview", "list_clip", "list_box", "df_talisman_rune_of_balance", "requirement_list", "dwf_knowledge"},
{"mortuary_cult", "listview", "list_clip", "list_box", "df_master_rune_of_alaric_the_mad", "requirement_list", "dwf_knowledge"},
{"mortuary_cult", "listview", "list_clip", "list_box", "df_master_rune_of_breaking", "requirement_list", "dwf_knowledge"},
{"mortuary_cult", "listview", "list_clip", "list_box", "df_master_rune_of_dragon_slaying", "requirement_list", "dwf_knowledge"},
{"mortuary_cult", "listview", "list_clip", "list_box", "df_master_rune_of_skalf_blackhammer", "requirement_list", "dwf_knowledge"},
{"mortuary_cult", "listview", "list_clip", "list_box", "df_master_rune_of_snorri_spangelhelm", "requirement_list", "dwf_knowledge"},
{"mortuary_cult", "listview", "list_clip", "list_box", "df_master_rune_of_swiftness", "requirement_list", "dwf_knowledge"}
};




icon_table_kraka_drak = {
{"mortuary_cult", "listview", "list_clip", "list_box", "runic_forge_dragon_rune_of_drak", "requirement_list", "dwf_knowledge"},
{"mortuary_cult", "listview", "list_clip", "list_box", "runic_forge_dragon_rune_of_valar_grunsonn", "requirement_list", "dwf_knowledge"}
};



dwf_craft_button_list = {
{"mortuary_cult", "listview", "list_clip", "list_box", "df_armour_rune_of_adamant"},
{"mortuary_cult", "listview", "list_clip", "list_box", "df_armour_rune_of_fortitude"},
{"mortuary_cult", "listview", "list_clip", "list_box", "df_armour_rune_of_gromril"},
{"mortuary_cult", "listview", "list_clip", "list_box", "df_armour_rune_of_impact"},
{"mortuary_cult", "listview", "list_clip", "list_box", "df_armour_rune_of_shielding"},
{"mortuary_cult", "listview", "list_clip", "list_box", "df_banner_rune_of_courage"},
{"mortuary_cult", "listview", "list_clip", "list_box", "df_banner_rune_of_groth_one_eye"},
{"mortuary_cult", "listview", "list_clip", "list_box", "df_banner_rune_of_grungi"},
{"mortuary_cult", "listview", "list_clip", "list_box", "df_banner_rune_of_strollaz"},
{"mortuary_cult", "listview", "list_clip", "list_box", "df_banner_rune_of_stromni_redbeard"},
{"mortuary_cult", "listview", "list_clip", "list_box", "df_banner_rune_of_valaya"},
{"mortuary_cult", "listview", "list_clip", "list_box", "df_engineering_rune_of_accuracy"},
{"mortuary_cult", "listview", "list_clip", "list_box", "df_engineering_rune_of_burning"},
{"mortuary_cult", "listview", "list_clip", "list_box", "df_engineering_rune_of_disguise"},
{"mortuary_cult", "listview", "list_clip", "list_box", "df_engineering_rune_of_penetrating"},
{"mortuary_cult", "listview", "list_clip", "list_box", "df_engineering_rune_of_stalwart"},
{"mortuary_cult", "listview", "list_clip", "list_box", "df_master_rune_of_alaric_the_mad"},
{"mortuary_cult", "listview", "list_clip", "list_box", "df_master_rune_of_breaking"},
{"mortuary_cult", "listview", "list_clip", "list_box", "df_master_rune_of_dragon_slaying"},
{"mortuary_cult", "listview", "list_clip", "list_box", "df_master_rune_of_skalf_blackhammer"},
{"mortuary_cult", "listview", "list_clip", "list_box", "df_master_rune_of_snorri_spangelhelm"},
{"mortuary_cult", "listview", "list_clip", "list_box", "df_master_rune_of_swiftness"},
{"mortuary_cult", "listview", "list_clip", "list_box", "df_talisman_rune_of_balance"},
{"mortuary_cult", "listview", "list_clip", "list_box", "df_talisman_rune_of_passage"},
{"mortuary_cult", "listview", "list_clip", "list_box", "df_talisman_rune_of_spellbreaking"},
{"mortuary_cult", "listview", "list_clip", "list_box", "df_talisman_rune_of_spite"},
{"mortuary_cult", "listview", "list_clip", "list_box", "df_talisman_rune_of_warding"},
{"mortuary_cult", "listview", "list_clip", "list_box", "df_weapons_rune_of_dismay"},
{"mortuary_cult", "listview", "list_clip", "list_box", "df_weapons_rune_of_fire"},
{"mortuary_cult", "listview", "list_clip", "list_box", "df_weapons_rune_of_might"},
{"mortuary_cult", "listview", "list_clip", "list_box", "df_weapons_rune_of_parrying"},
{"mortuary_cult", "listview", "list_clip", "list_box", "df_weapons_rune_of_speed"},
{"mortuary_cult", "listview", "list_clip", "list_box", "df_weapons_rune_of_striking"},
{"mortuary_cult", "listview", "list_clip", "list_box", "wh_main_anc_rune_master_rune_of_battle"},
{"mortuary_cult", "listview", "list_clip", "list_box", "wh_main_anc_rune_master_rune_of_sanctuary"},
{"mortuary_cult", "listview", "list_clip", "list_box", "wh_main_anc_rune_master_rune_of_slowness"},
{"mortuary_cult", "listview", "list_clip", "list_box", "wh_main_anc_rune_master_rune_of_stoicism"},
{"mortuary_cult", "listview", "list_clip", "list_box", "runic_forge_dragon_rune_of_drak"},
{"mortuary_cult", "listview", "list_clip", "list_box", "runic_forge_dragon_rune_of_concentration"},
{"mortuary_cult", "listview", "list_clip", "list_box", "runic_forge_dragon_rune_of_giantsbane"},
{"mortuary_cult", "listview", "list_clip", "list_box", "runic_forge_dragon_rune_of_frostbite"},
{"mortuary_cult", "listview", "list_clip", "list_box", "runic_forge_dragon_rune_of_the_north"},
{"mortuary_cult", "listview", "list_clip", "list_box", "runic_forge_dragon_rune_of_valar_grunsonn"}
};








function df_dwf_forge()
	if not cm:is_multiplayer() then
		cm:set_saved_value("df_dwf_forge", true);
		jar_list_init("wh_main_sc_dwf_dwarfs", "active");
		
		df_player_faction = cm:get_local_faction();
		local faction = cm:model():world():faction_by_key(df_player_faction);
		df_subculture = faction:subculture();
		
		
		
		if df_subculture == "wh_main_sc_dwf_dwarfs" then
			output("DFCRAFT: player is a dwarf, setting up listeners");
			if get_faction("wh_main_dwf_kraka_drak"):is_human() and cm:get_saved_value("Cataph_Kraka_Drak") == true then 
				custom_cat_init("wh_main_dwf_kraka_drak", "active");
				add_drak_listeners()
			else 
				custom_cat_init("wh_main_dwf_kraka_drak", "disabled");
			end
			add_forge_listeners()
		end
	end
   
end











function add_forge_listeners()

core:add_listener(
	"dwarfgromriltrade",
	"FactionTurnStart",
	function(context) return context:faction():name() == df_player_faction end,
	function(context) df_trade_gainz(context) end,
	true);
	
	
core:add_listener(
	"dwarfancestralknowledge",
	"CharacterSkillPointAllocated",
	function(context) return context:character():faction():is_human() and context:skill_point_spent_on():find("ancestral_knowledge") end,
	function(context) 
	
	if context:skill_point_spent_on() == "xx_runesmith_ancestral_knowledge" then
		cm:pooled_resource_mod(context:character():faction():command_queue_index(), "dwf_knowledge", "wh2_main_resource_factor_characters", 1);
	elseif context:skill_point_spent_on() == "xx_runelord_ancestral_knowledge" then
		cm:pooled_resource_mod(context:character():faction():command_queue_index(), "dwf_knowledge", "wh2_main_resource_factor_characters", 2);
	elseif context:skill_point_spent_on() == "xx_runelord_ancestral_knowledge_jr" then
		cm:pooled_resource_mod(context:character():faction():command_queue_index(), "dwf_knowledge", "wh2_main_resource_factor_characters", 2);
	elseif context:skill_point_spent_on() == "xx_wardlord_ancestral_knowledge" then
		cm:pooled_resource_mod(context:character():faction():command_queue_index(), "dwf_knowledge", "wh2_main_resource_factor_characters", 2);
	elseif context:skill_point_spent_on() == "xx_kraka_drak_ancestral_knowledge" then
		cm:pooled_resource_mod(context:character():faction():command_queue_index(), "dwf_knowledge", "wh2_main_resource_factor_characters", 2);		
	elseif context:skill_point_spent_on() == "xx_kraka_ancestral_knowledge" then
		cm:pooled_resource_mod(context:character():faction():command_queue_index(), "dwf_knowledge", "wh2_main_resource_factor_characters", 2);			
	elseif context:skill_point_spent_on() == "xx_kraka_ancestral_knowledge_wl" then
		cm:pooled_resource_mod(context:character():faction():command_queue_index(), "dwf_knowledge", "wh2_main_resource_factor_characters", 2);			

		
	end
	end,
	true);
	
	
	
	
	
add_ui_listeners();
		
		
		
output("DFCRAFT: listeners set");


end;
		
		
function add_ui_listeners()

core:add_listener(
	"cat_clicked_cmf_cat_wh_main_sc_dwf_dwarfs_1",
	"ComponentLClickUp",
	function(context)
		local uic = UIComponent(context.component)
		return uic:Id() == "button" and uicomponent_descended_from(uic, "cmf_cat_wh_main_sc_dwf_dwarfs_1")
	end,
	function(context)
		output("DFCRAFT: setting the current panel to cmf_cat_wh_main_sc_dwf_dwarfs_1");
		cm:callback( function() override_ancestral_image() end);
	end,
	true);

core:add_listener(
	"cat_clicked_cmf_cat_wh_main_sc_dwf_dwarfs_2",
	"ComponentLClickUp",
	function(context)
		local uic = UIComponent(context.component)
		return uic:Id() == "button" and uicomponent_descended_from(uic, "cmf_cat_wh_main_sc_dwf_dwarfs_2")
	end,
	function(context)
		output("DFCRAFT: setting the current panel to cmf_cat_wh_main_sc_dwf_dwarfs_2");
		cm:callback( function() override_ancestral_image() end, 0.1);
	end,
	true);
	
	
core:add_listener(
	"cat_clicked_cmf_cat_wh_main_sc_dwf_dwarfs_3",
	"ComponentLClickUp",
	function(context)
		local uic = UIComponent(context.component)
		return uic:Id() == "button" and uicomponent_descended_from(uic, "cmf_cat_wh_main_sc_dwf_dwarfs_3")
	end,
	function(context)
		output("DFCRAFT: setting the current panel to cmf_cat_wh_main_sc_dwf_dwarfs_3");
		cm:callback( function() override_ancestral_image() end, 0.1);
	end,
	true);
	
core:add_listener(
	"cat_clicked_cmf_cat_wh_main_sc_dwf_dwarfs_4",
	"ComponentLClickUp",
	function(context)
		local uic = UIComponent(context.component)
		return uic:Id() == "button" and uicomponent_descended_from(uic, "cmf_cat_wh_main_sc_dwf_dwarfs_4")
	end,
	function(context)
		output("DFCRAFT: setting the current panel to cmf_cat_wh_main_sc_dwf_dwarfs_4");
		cm:callback( function() override_ancestral_image() end, 0.1);
	end,
	true);
	
core:add_listener(
	"cat_clicked_cmf_cat_wh_main_sc_dwf_dwarfs_5",
	"ComponentLClickUp",
	function(context)
		local uic = UIComponent(context.component)
		return uic:Id() == "button" and uicomponent_descended_from(uic, "cmf_cat_wh_main_sc_dwf_dwarfs_5")
	end,
	function(context)
		output("DFCRAFT: setting the current panel to cmf_cat_wh_main_sc_dwf_dwarfs_5");
		cm:callback( function() override_ancestral_image() end, 0.1);
	end,
	true);
	
core:add_listener(
	"cat_clicked_cmf_cat_wh_main_sc_dwf_dwarfs_6",
	"ComponentLClickUp",
	function(context)
		local uic = UIComponent(context.component)
		return uic:Id() == "button" and uicomponent_descended_from(uic, "cmf_cat_wh_main_sc_dwf_dwarfs_6")
	end,
	function(context)
		output("DFCRAFT: setting the current panel to cmf_cat_wh_main_sc_dwf_dwarfs_2");
		cm:callback( function() override_ancestral_image() end, 0.1);
	end,
	true);

core:add_listener(
	"cat_clicked_cmf_custom_cat_kraka_drak",
	"ComponentLClickUp",
	function(context)
		local uic = UIComponent(context.component)
		return uic:Id() == "button" and uicomponent_descended_from(uic, "cmf_custom_cat_kraka_drak")
	end,
	function(context)
		output("DFCRAFT: setting the current panel to cmf_custom_cat_kraka_drak");
		cm:callback( function() override_kraka_image() end, 0.1);
	end,
	true);
	
	
	


end;





function override_ancestral_image()


for i = 1, #icon_table_dwf_craft do
	current_path = icon_table_dwf_craft[i];
	current_icon = find_uicomponent_from_table(core:get_ui_root(), current_path);
	if is_uicomponent(current_icon) then
		output("DFCRAFT: overwriting an image");
		current_icon:SetImage("ui/campaign ui/technologies/wh_main_dwf_grimnirs_favour.png");
		
		local compA = find_uicomponent(current_icon, "icon");
		if not not compA then
			compA:SetVisible(false);
		end
		output("done");

	end
end

--df_test_component_printer()

end;


function override_kraka_image()


icon_table_giantsbane = {"mortuary_cult", "listview", "list_clip", "list_box", "runic_forge_dragon_rune_of_giantsbane", "requirement_list", "kraka_giantsbane"};
icon_table_frostbite = {"mortuary_cult", "listview", "list_clip", "list_box", "runic_forge_dragon_rune_of_frostbite", "requirement_list", "kraka_frostbite"};

giantsbaneIcon = find_uicomponent_from_table(core:get_ui_root(), icon_table_giantsbane);
frostbiteIcon = find_uicomponent_from_table(core:get_ui_root(), icon_table_frostbite);

if is_uicomponent(giantsbaneIcon) then
	output("DFCRAFT: setting the giantsbane icon")
	giantsbaneIcon:SetImage("ui/campaign ui/technologies/wh_main_dwf_slayers_onslaught.png");
	local CompB = find_uicomponent(giantsbaneIcon, "icon");
	if not not CompB then
		CompB:SetVisible(false);
	end
	output("done");
end

if is_uicomponent(frostbiteIcon) then
	output("DFCRAFT: setting the frostbite icon")
	frostbiteIcon:SetImage("ui/campaign ui/technologies/wh_main_dwf_interchangable_parts.png");
	local CompB = find_uicomponent(frostbiteIcon, "icon");
	if not not CompB then
		CompB:SetVisible(false);
	end
	output("done");
end

for i = 1, #icon_table_kraka_drak do
	current_path = icon_table_kraka_drak[i];
	current_icon = find_uicomponent_from_table(core:get_ui_root(), current_path);
	if is_uicomponent(current_icon) then
		output("DFCRAFT: overwriting an image");
		current_icon:SetImage("ui/campaign ui/technologies/wh_main_dwf_grimnirs_favour.png");
		
		local compA = find_uicomponent(current_icon, "icon");
		if not not compA then
			compA:SetVisible(false);
		end
		output("done");

	end
end


--df_test_component_printer();

end;


function df_test_component_printer()


output("DWFCRAFT: fixing craft buttons");


for i = 1, #dwf_craft_button_list do
	local path_to_print = dwf_craft_button_list[i];
	local target_comp = find_uicomponent_from_table(core:get_ui_root(), path_to_print);
	print_all_uicomponent_children(target_comp)

end






end;





function df_trade_gainz(context)
	
output("DFCRAFT firing trade listener, "..tostring(df_player_faction).." is the player faction");
		
for i = 1, #dwarven_factions_list do
	local current_dwarf = dwarven_factions_list[i]
	local player_faction = get_faction(df_player_faction)
	local current_faction = get_faction(current_dwarf)
	if not (player_faction == current_faction) then
		output("DFCRAFT: checking trade with "..tostring(current_faction:name()).." to award gromril");
		if faction_has_trade_agreement_with_faction(player_faction, current_faction) then
			output("DFCRAFT: trade check passed");
			cm:pooled_resource_mod(player_faction:command_queue_index(), "tmb_canopic_jars", "wh2_dlc09_resource_factor_great_incantation_of_geheb", 1);
		end
	end
end
		
		
		
		
end;





---kraka drak





function add_drak_listeners()

output("Adding kraka drak listeners");
core:add_listener(
	"reconquestofdorden",
	"ResearchCompleted",
	function(context)
			local faction = context:faction();
			
			return faction:has_technology("kraka_tech+_03"); end,
	function(context) 
		cm:pooled_resource_mod(context:faction():command_queue_index(), "dwf_knowledge", "wh2_main_resource_factor_characters", 2);	
	end,
	true);





end;


		
function faction_has_trade_agreement_with_faction(faction_a, faction_b)
	local trade_list = faction_a:factions_trading_with();
	for i = 0, trade_list:num_items() - 1 do
		if trade_list:item_at(i) == faction_b then
			return true;
		end;
	end;
	return false;
end;