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


