local RecruiterChracter = {} --# assume RecruiterCharacter: RECRUITER_CHARACTER


--v function(cqi: CA_CQI) --> RECRUITER_CHARACTER
function RecruiterCharacter.Create(cqi)
local self = {}
setmetatable(self, {
    __index = RecruiterCharacter,
    __tostring = function() return "WEC_RECRUITER_CHARACTER" end
})
--# assume self: RECRUITER_CHARACTER

self.CommandQueueIndex = cqi

self.QueueTable = {} --:vector<string>
self.ArmyTable = {} --:vector<string>
self.UnitCounts = {} --:map<string, number>
self.CurrentRestrictions = {} --:map<string, boolean>
self.Region = nil --:string

return self
end;


--v function(self: RECRUITER_CHARACTER) --> CA_CQI
function RecruiterCharacter.GetCQI(self)
    return self.CommandQueueIndex
end

--v function(self: RECRUITER_CHARACTER)
function RecruiterCharacter.SetCounts(self)
    RCLOG("Setting counts for selected a RECRUITER_CHARACTER with CQI ["..tostring(self.CommandQueueIndex).."]", "RecruiterCharacter.SetCounts(self)")

    self.TotalCount = {}
    for i = 1, #self.QueueTable do
        local current_unit = self.QueueTable[i]
        if self.UnitCounts[current_unit] == nil then self.UnitCounts[current_unit] = 0 end
        self.UnitCounts[current_unit] = self.UnitCounts[current_unit] + 1;
    end
    for i = 1, #self.ArmyTable do
        local current_unit = self.ArmyTable[i]
        if self.UnitCounts[current_unit] == nil then self.UnitCounts[current_unit] = 0 end
        self.UnitCounts[current_unit] = self.UnitCounts[current_unit] + 1;
    end
end

--v function(self: RECRUITER_CHARACTER, unit_component_ID: string) --> number
function RecruiterCharacter.GetCountForUnit(self, unit_component_ID)
    if self.UnitCounts[unit_component_ID] == nil then
        return 0
    end
    return self.UnitCounts[unit_component_ID] 
end

--v function(index: int) --> string
local function GetQueuedUnit(index)
    local queuedUnit = find_uicomponent(core:get_ui_root(), "main_units_panel", "units", "QueuedLandUnit " .. index);
    if not not queuedUnit then
        queuedUnit:SimulateMouseOn();
        local unitInfo = find_uicomponent(core:get_ui_root(), "UnitInfoPopup", "tx_unit-type");
        local rawstring = unitInfo:GetStateText();
        local infostart = string.find(rawstring, "unit/") + 5;
        local infoend = string.find(rawstring, "]]") - 1;
        local QueuedUnitName = string.sub(rawstring, infostart, infoend).."_recruitable"
        return QueuedUnitName
    else
        return nil
    end
end


--v function(self: RECRUITER_CHARACTER)
function RecruiterCharacter.GenerateQueue(self)
    local NewQueue = {}
    for i = 1, 19 do
        local queuedUnit = GetQueuedUnit(i - 1)
        if queuedUnit then 
            RCLOG("Found unit in Queue: ["..queuedUnit.."]", "RecruiterCharacter.GenerateQueue(self)")
            table.insert(NewQueue, queuedUnit)
        else
            RCLOG("Could not find any queued unit at ["..tostring(i - 1).."], ending the loop!", "RecruiterCharacter.GenerateQueue(self)")
            break
        end
    end
end

--v function(self: RECRUITER_CHARACTER, unit_component_ID: string)
function RecruiterCharacter.AddToQueue(self, unit_component_ID)
    table.insert(self.QueueTable, unit_component_ID)
    self:SetCounts()
end


--v function(self: RECRUITER_CHARACTER)
function RecruiterCharacter.EvaluateArmy(self)
    RCLOG("Evaluating Army for a RECRUITER_CHARACTER with CQI ["..tostring(self.CommandQueueIndex).."]", "RecruiterCharacter.EvaluateArmy(self)")
    local army = cm:get_character_by_cqi(self.CommandQueueIndex):military_force():unit_list()
    self.ArmyTable = {}
    local outputstring = "CURRENT ARMY: "
    for i = 0, army:num_items() - 1 do
        local current_unit = army:item_at(i):unit_key()
        local final_key = current_unit.."_recruitable"
        outputstring =  outputstring..final_key
        table.insert(self.ArmyTable, final_key)
    end
    RCLOG(outputstring, "RecruiterCharacter.EvaluateArmy(self)")
end

--v function (self: RECRUITER_CHARACTER, unit_component_ID:string, restrict: boolean)
function RecruiterCharacter.SetRestriction(self, unit_component_ID, restrict)
    self.CurrentRestrictions[unit_component_ID] = restrict
end


--v function(self: RECRUITER_CHARACTER, unit_component_ID: string)
function RecruiterCharacter.ApplyRestrictionToUnit(self, unit_component_ID)
    RCLOG("Applying Restrictions for character ["..tostring(self:GetCQI()).."] and unit ["..unit_component_ID.."] ", "RecruiterCharacter.ApplyRestrictionToUnit(self, unit_component_ID)")
    local localRecruitmentTable = {"units_panel", "main_units_panel", "recruitment_docker", "recruitment_options", "recruitment_listbox", "local1", "unit_list", "listview", "list_clip", "list_box"};
    local localUnitList = find_uicomponent_from_table(core:get_ui_root(), localRecruitmentTable);
    if is_uicomponent(localUnitList) then
        local unitCard = find_uicomponent(localUnitList, unit_component_ID);	
        if is_uicomponent(unitCard) then
            if self.CurrentRestrictions[unit_component_ID] == true then
                RCLOG("Locking Unit Card ["..unit_component_ID.."]", "RecruiterCharacter.ApplyRestrictionToUnit(self, unit_component_ID)")
                unitCard:SetInteractive(false)
                unitCard:SetVisible(false)
            else
                RCLOG("Unlocking! Unit Card ["..unit_component_ID.."]", "RecruiterCharacter.ApplyRestrictionToUnit(self, unit_component_ID)")
                unitCard:SetInteractive(true)
                unitCard:SetVisible(true)
            end
        else 
            RCERROR("Unit Card isn't a component!")
        end
    else
        RCERROR("WARNING: Could not find the component for the unit list!. Is the panel closed?")
    end

    local globalRecruitmentTable = {"units_panel", "main_units_panel", "recruitment_docker", "recruitment_options", "recruitment_listbox", "global", "unit_list", "listview", "list_clip", "list_box"};
    local globalUnitList = find_uicomponent_from_table(core:get_ui_root(), globalRecruitmentTable);
    if is_uicomponent(globalUnitList) then
        local unitCard = find_uicomponent(globalUnitList, unit_component_ID);	
        if is_uicomponent(unitCard) then
            if self.CurrentRestrictions[unit_component_ID] == true then
                RCLOG("Locking Unit Card ["..unit_component_ID.."]", "RecruiterCharacter.ApplyRestrictionToUnit(self, unit_component_ID)")
                unitCard:SetInteractive(false)
                unitCard:SetVisible(false)
            else
                RCLOG("Unlocking! Unit Card ["..unit_component_ID.."]", "RecruiterCharacter.ApplyRestrictionToUnit(self, unit_component_ID)")
                unitCard:SetInteractive(true)
                unitCard:SetVisible(true)
            end
        else 
            RCERROR("Unit Card isn't a component!")
        end
    else
        RCLOG("WARNING: Could not find the component for the global recruitment list!. Is the panel closed? Does the Player not have global recruitment?", "RecruiterCharacter.ApplyRestrictionToUnit(self, unit_component_ID)")
    end 
end
    