local RegionSelectedManager = {} --# assume RegionSelect: REGION_SELECTED

--v function(region: string) --> REGION_SELECTED
    function regionSelectedManager.new(region)
        local self = {}
        setmetatable(self, {
            __index = RegionSelected
        }) --# assume self: REGION_SELECTED
        self._regionSelected = region
        
        _G.rsm = self
        return self
    end






function clickBuildingUpgradeButton()



end;

function cacheRegion(region)
    local RegionSelected = region

end;


function addBuildingUpgradeButton()
    out("BUB: addBuildingUpgradeButton() start")
    local SettlementPanel = find_uicomponent(core:get_ui_root(), "settlement_panel");
    if not not SettlementPanel then
        out("BUB: SettlementPanel found")
        local ButtonSubpanel = find_uicomponent(SettlementPanel, "button_holder");
        if not not ButtonSubpanel then
            out("BUB: ButtonSubpanel found")

            local RenameButton = find_uicomponent(ButtonSubpanel, "button_rename");


            
            local BuildingUpgradeButton = Button.new("BuildingUpgradeButton", ButtonSubpanel, "SQUARE", "ui/skins/default/icon_rename.png");
            out("BUB: Building the Building Button")
            BuildingUpgradeButton:Resize(RenameButton:Bounds());
            local uuWidth, uuHeight = RenameButton:Bounds();
            local uuXPos, uuYPos = RenameButton:Position();
            local gap = 5;

            BuildingUpgradeButton:PositionRelativeTo(RenameButton, gap + uuWidth, 0);
            out("BUB: test1")
            BuildingUpgradeButton:RegisterForClick(
                function(context)
                    clickBuildingUpgradeButton();
                end
            );
            out("BUB: test2")


            BuildingUpgradeButton:SetState("active");
            out("BUB: test3")

            local uic = find_uicomponent(ButtonSubpanel, "BuildingUpgradeButton");
            if not not uic then
                out("BUB: Attempting to make a tooltip, plz work");
                core:cache_and_set_tooltip_for_component_state(uic, "active", "ui_text_replacements_localised_text_buildingupgradebutton");
            end;
            out("BUB: test4")
            BuildingUpgradeButton:SetVisible(true);
            out("BUB: addBuildingUpgradeButton() end");
        end;
    end;
end;

function destroyBuildingUpgradeButton()
    out("BUB: Remove button function triggered!");
    local BuildingUpgradeButton = Util.getComponentWithName("BuildingUpgradeButton")
    --# assume BuildingUpgradeButton: BUTTON
    BuildingUpgradeButton:Delete();

end;


function setupBuildingUpgradeButton()
    out("BUB: Beginning of setupBuildingUpgradeButton()");
    core:add_listener(
        "MarukaButtonAdd",
        "PanelOpenedCampaign",
        function(context)
            out("BUB: Checking panel opened context")
            return context.string == "settlement_panel";
        end,
        function(context)
            out("BUB: Add button listener triggered!");
            addBuildingUpgradeButton()
            out("BUB: Add button listener successful!");
        end,
        true
    );

    core:add_listener(
        "MarukaButtonDestroy",
        "PanelClosedCampaign",
        function(context)
            out("BUB: Checking panel closed context")
            return context.string == "settlement_panel";
        end,
        function(context)
            out("BUB: Destroy button listener triggered!");
            destroyBuildingUpgradeButton()
            out("BUB: Destroy button listener successful!");
        end,
        true            
    );

    core:add_listener(
        "MarukaRegionSelected",
        "RegionSelected",
        function(context)
            return context:region():settlement()
        end,
        function(context)
            if context:region():settlement():owning_faction():is_human() then
                local region = context:region():settlement()
                cacheRegion(region)
            end
        end,
        true
    );

end;

function wec_maruka_cheater()
    out("BUB: Giving Maruka his cheaty little button, the cheater")
    setupBuildingUpgradeButton()
end;
