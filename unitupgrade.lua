--v function()
function unitupgrade()
    setupUnitUpgradeButton();
    out("VANDY: Initializing script!");
end


function setupUnitUpgradeButton()
    out("VANDY: Setting up listeners!");
    core:add_listener(
        "KDUnitUpgradeButtonAdd",
        "PanelOpenedCampaign",
        function(context)
            out("VANDY: Checking opened context");
            return context.string == "units_panel";
        end,
        function(context)
            out("VANDY: Add button listener triggered!");
            AddUpgradeButton();
            out("VANDY: Add button listener successful!");
        end,
        true);

    core:add_listener(
        "KDUnitUpgradeButtonRemove",
        "PanelClosedCampaign",
        function(context)
            out("VANDY: Checking closed context");
            return context.string == "units_panel";         
        end,
        function(context)
            out("VANDY: Remove button listener triggered!");
            RemoveUpgradeButton();
            out("VANDY: Remove button listener successful!");
        end,
        true);

end

function AddUpgradeButton()
    out("VANDY: Add button function triggered!");
    local UnitsPanel = find_uicomponent(core:get_ui_root(), "units_panel");

    if not not UnitsPanel then
        out("VANDY: UnitsPanel found!"); 
        local ButtonSubpanel = find_uicomponent(core:get_ui_root(), "layout", "hud_center_docker", "hud_center", "small_bar", "button_group_army");
        if not not ButtonSubpanel then
            out("VANDY: UnitsPanel ButtonSubpanel found!");
            local ButtonRenown = find_uicomponent(ButtonSubpanel, "button_renown");
            local UnitUpgradeButton = Button.new("UnitUpgradeButton", ButtonSubpanel, "SQUARE", "ui/skins/default/icon_unit_upgrade_wh2.png"); 
            out("VANDY: Beginning of the actual add button function");
            UnitUpgradeButton:Resize(ButtonRenown:Bounds());

            local uuWidth, uuHeight = ButtonRenown:Bounds();
            local uuXPos, uuYPos = ButtonRenown:Position();
            local gap = 5;

            UnitUpgradeButton:PositionRelativeTo(ButtonRenown, gap + uuWidth, 0);

            --UnitUpgradeButton:PositionRelativeTo(ButtonRenown, 50, 0);
            UnitUpgradeButton:RegisterForClick(
                function(context)
                    UpgradeUnitOnClick();
                end
            );

            UnitUpgradeButton:SetState("inactive");

            local uic = find_uicomponent(ButtonSubpanel, "UnitUpgradeButton");
            if uic then
                out("VANDY: Attempting to make a tooltip, plz work");
                core:cache_and_set_tooltip_for_component_state(uic, "inactive", "ui_text_replacements_localised_text_makethiswork");
            end;
            --function core_object:cache_and_set_tooltip_for_component_state(uic, state, new_tooltip)
            --			local uic_end_turn_button = find_uicomponent(core:get_ui_root(), "faction_buttons_docker", "button_end_turn");
			--if uic_end_turn_button then
			--	core:cache_and_set_tooltip_for_component_state(uic_end_turn_button, "inactive", "ui_text_replacements_localised_text_end_turn_button_disabled_for_advice");
			--end;
            --UnitUpgradeButton:InterfaceFunction("SetTooltip", "THISISVANDYTESTING");
            --UnitUpgradeButton:SetTooltipText("this is a fucking test", true);
            UnitUpgradeButton:SetVisible(true);
            out("VANDY: Completion of the actual add button function");
        end
    end


end

function RemoveUnitButton()
    out("VANDY: Remove button function triggered!");
    local UnitUpgradeButton = Util.getComponentWithName("UnitUpgradeButton")
    --# assume UnitUpgradeButton: BUTTON
    UnitUpgradeButton:Delete();
end  

function UpgradeUnitOnClick()
    out("VANDY: Button click function triggered!");
    --herein goes the unit upgrade stuff, kthnxbai
end