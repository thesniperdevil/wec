local RecruiterCharacter = {} --# assume RecruiterCharacter: RECRUITER_CHARACTER

--v function(cqi: CA_CQI) --> RECRUITER_CHARACTER
function RecruiterCharacter.Create(cqi)
    local self = {}
    setmetatable(self, {
        __index = RecruiterCharacter,
        __tostring = function() return "RECRUITER_CHARACTER" end
    })
    --# assume self: RECRUITER_CHARACTER

    self.cqi = cqi
    self.RecruiterManager = nil --:RECRUITER_MANAGER
    self.QueueTable = {} --:vector<string>
    self.CurrentRestrictions = {} --:map<string, boolean>
    self.QueueEmpty = true --:boolean
    self.CurrentArmy = {} --:vector<string>
    self.TotalCount = {} --:map<string, number>
    self.RegionKey = "" --:string

    RCLOG("Created a RECRUITER_CHARACTER at CQI ["..tostring(cqi).."] ", "RecruiterCharacter.Create(cqi)")
    return self
end

--v function(cqi: CA_CQI, queuetable: vector<string>) --> RECRUITER_CHARACTER
function RecruiterCharacter.Load(cqi, queuetable)
    local self = {}
    setmetatable(self, {
        __index = RecruiterCharacter,
        __tostring = function() return "RECRUITER_CHARACTER" end
    })
    --# assume self: RECRUITER_CHARACTER

    self.cqi = cqi
    self.RecruiterManager = nil 
    self.QueueTable = queuetable
    self.CurrentRestrictions = {} 
    self.QueueEmpty = false
    self.CurrentArmy = {} 
    self.TotalCount = {} 
    self.RegionKey = "" 

    RCLOG("Loaded a RECRUITER_CHARACTER at CQI ["..tostring(cqi).."] ", "RecruiterCharacter.Load(cqi, queuetable)")
    return self
end

--v function(self: RECRUITER_CHARACTER) --> (CA_CQI, vector<string>)
function RecruiterCharacter.Save(self)
    RCLOG("Saving a RECRUITER_CHARACTER from CQI ["..tostring(self.cqi).."] ", "RecruiterCharacter.Save()")
    return self.cqi, self.QueueTable
end



--v function(self: RECRUITER_CHARACTER, manager: RECRUITER_MANAGER)
function RecruiterCharacter.SetManager(self, manager)
    RCLOG("Set the Manager for a RECRUITER_CHARACTER with CQI ["..tostring(self.cqi).."]", "RecruiterCharacter.SetManager(self, manager)")
    self.RecruiterManager = manager
end


--v function(self: RECRUITER_CHARACTER) --> boolean
function RecruiterCharacter.IsQueueEmpty(self)
    RCLOG("Queue Empty returning ["..tostring(self.QueueEmpty).."] for a RECRUITER_CHARACTER with CQI ["..tostring(self.cqi).."]", "RecruiterCharacter.IsQueueEmpty(self)")
    return self.QueueEmpty
end





--v function(self: RECRUITER_CHARACTER)
function RecruiterCharacter.EmptyQueue(self)
    RCLOG("Emptying the Queue for a RECRUITER_CHARACTER with CQI ["..tostring(self.cqi).."]", "RecruiterCharacter.EmptyQueue(self)")
    self.QueueEmpty = true;
    self.QueueTable = {}
end

--v function(self: RECRUITER_CHARACTER)
function RecruiterCharacter.SetRegion(self)
    local character = cm:get_character_by_cqi(self.cqi)
    self.RegionKey = character:region():name()
    RCLOG("Set Region to ["..self.RegionKey.."] a RECRUITER_CHARACTER with CQI ["..tostring(self.cqi).."]", "RecruiterCharacter.SetRegion(self)" )
end

--v function(self: RECRUITER_CHARACTER) --> string
function RecruiterCharacter.GetRegion(self)
    RCLOG("Retrieved the Region ["..self.RegionKey.."] from a RECRUITER_CHARACTER with CQI ["..tostring(self.cqi).."]", "RecruiterCharacter.GetRegion(self)")
    return self.RegionKey
end

--v function(self: RECRUITER_CHARACTER)
function RecruiterCharacter.EvaluateArmy(self)
    RCLOG("Evaluating Army for a RECRUITER_CHARACTER with CQI ["..tostring(self.cqi).."]", "RecruiterCharacter.EvaluateArmy(self)")
    local army = cm:get_character_by_cqi(self.cqi):military_force():unit_list()
    self.CurrentArmy = {}
    for i = 0, army:num_items() do
        local current_unit = army:item_at(i):unit_key()
        local final_key = current_unit.."_recruitable"
        table.insert(self.CurrentArmy, final_key)
    end

end

--v function(self: RECRUITER_CHARACTER)
function RecruiterCharacter.SetCounts(self)

    self.TotalCount = {}
    for i = 1, #self.QueueTable do
        local current_unit = self.QueueTable[i]
        if self.TotalCount[current_unit] == nil then self.TotalCount[current_unit] = 0 end
        self.TotalCount[current_unit] = self.TotalCount[current_unit] + 1;
    end
    for i = 1, #self.CurrentArmy do
        local current_unit = self.CurrentArmy[i]
        if self.TotalCount[current_unit] == nil then self.TotalCount[current_unit] = 0 end
        self.TotalCount[current_unit] = self.TotalCount[current_unit] + 1;
    end
end

--v function(self: RECRUITER_CHARACTER, unit_component_ID: string) --> number
function RecruiterCharacter.GetTotalCountForUnit(self, unit_component_ID)
    return self.TotalCount[unit_component_ID]
end


--v function(self: RECRUITER_CHARACTER, unit_component_ID: string)
function RecruiterCharacter.AddToQueue(self, unit_component_ID)
    table.insert(self.QueueTable, unit_component_ID)
    self:SetCounts()
end

--v function(self: RECRUITER_CHARACTER, unit_component_ID: string)
function RecruiterCharacter.RemoveUnitFromQueue(self, unit_component_ID)
    RCLOG("Removing ["..unit_component_ID.."] from the queue for a RECRUITER_CHARACTER with CQI ["..tostring(self.cqi).."]", "RecruiterCharacter.RemoveFromQueue(self, unit_component_ID)")
    for i = 1, #self.QueueTable do
        if self.QueueTable[i] == unit_component_ID then
            RCLOG("unit_component_ID is ["..unit_component_ID.."], while ["..tostring(i).."] is QID", "RecruiterCharacter.RemoveFromQueue(self, unit_component_ID)")
            table.remove(self.QueueTable, i)
        end
    end
    self:SetCounts()
end

--v function(self: RECRUITER_CHARACTER, queue_component_ID: string) --> string
function RecruiterCharacter.RemoveFromQueueAndReturnUnit(self, queue_component_ID)
    RCLOG("Removing ["..queue_component_ID.."] from the queue for a RECRUITER_CHARACTER with CQI ["..tostring(self.cqi).."]", "RecruiterCharacter.RemoveFromQueue(self, queue_component_ID)")
    local queue_string = string.gsub(queue_component_ID, "QueuedLandUnit ", "")
    queueID = tonumber(queue_string) + 1;
    --# assume queueID: integer
    RCLOG("queue_component_ID is ["..queue_component_ID.."], while ["..tostring(queueID).."] is QID", "RecruiterCharacter.RemoveFromQueue(self, queue_component_ID)")
    local cached_unit = self.QueueTable[queueID]
    table.remove(self.QueueTable, queueID)
    self:SetCounts()
    return cached_unit
end


--v function (self: RECRUITER_CHARACTER, unit_component_ID:string, restrict: boolean)
function RecruiterCharacter.SetRestriction(self, unit_component_ID, restrict)
    self.CurrentRestrictions[unit_component_ID] = restrict
end

--v function(self: RECRUITER_CHARACTER, unit_component_ID: string, component: CA_UIC)
function RecruiterCharacter.ApplyRestrictionToUnit(self, unit_component_ID, component)


    if self.CurrentRestrictions[unit_component_ID] == true then
        RCLOG("Locking Unit Card ["..unit_component_ID.."]", "RecruiterCharacter.ApplyRestrictionToUnit(self, unit_component_ID)")
    else
        RCLOG("Unlocking! Unit Card ["..unit_component_ID.."]", "RecruiterCharacter.ApplyRestrictionToUnit(self, unit_component_ID)")
    end
end





return {
    Create = RecruiterCharacter.Create,
    Load = RecruiterCharacter.Load
}





