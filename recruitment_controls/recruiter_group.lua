local RecruiterGroup = {} --# assume RecruiterGroup: RECRUITER_GROUP

--v function(name: string, unit_set: vector<string>, grouped_quantity_cap: number) --> RECRUITER_GROUP
function RecruiterGroup.New(name, unit_set, grouped_quantity_cap)
    local self = {}
    setmetatable(self, {
        __index = RecruiterGroup,
        __tostring = function() return "RECRUITER_GROUP" end
    })
    --# assume self: RECRUITER_GROUP

    self.Name = name
    self.UnitSet = unit_set
    self.GroupedQuantityCap = grouped_quantity_cap
    self.MembershipRegistry = {} --: map<string, boolean>
    self.Manager = nil --:RECRUITER_MANAGER

    return self
end

--v function(self: RECRUITER_GROUP, manager: RECRUITER_MANAGER)
function RecruiterGroup.Initialise(self, manager)
    self.Manager = manager
    for i = 1, #self.UnitSet do
        if not string.find(self.UnitSet[i], "_recruitable") then
            self.UnitSet[i] = self.UnitSet[i].."_recruitable"
            RCLOG("Item in unit set lacked component name format, modified it to ["..self.UnitSet[i].."]", "function RecruiterGroup.Initialise(self, manager)")
        end 
        self.MembershipRegistry[self.UnitSet[i]] = true
    end
end

--v function(self: RECRUITER_GROUP, unit_component_ID: string) --> boolean
function RecruiterGroup.HasUnit(self, unit_component_ID)
        return self.MembershipRegistry[unit_component_ID]
end

--v function(self: RECRUITER_GROUP) --> string
function RecruiterGroup.GetName(self)
    return self.Name
end

--v function(self: RECRUITER_GROUP) --> number
function RecruiterGroup.GetGroupedQuantityCap(self)
    return self.GroupedQuantityCap
end

--v function(self: RECRUITER_GROUP, character: RECRUITER_CHARACTER) --> number
function RecruiterGroup.CountGroupForCharacter(self, character)
    local count = 0 --: number
    for i = 1, #self.UnitSet do
        count = count + character:GetTotalCountForUnit(self.UnitSet[i])
    end
    return count
end

--v function(self: RECRUITER_GROUP, character: RECRUITER_CHARACTER) --> boolean
function RecruiterGroup.ShouldRestrictGroup(self, character)
    return not (self:CountGroupForCharacter(character) < self:GetGroupedQuantityCap())
end



--v function(self: RECRUITER_GROUP, character: RECRUITER_CHARACTER)
function RecruiterGroup.SetRestrictionForGroup(self, character)
    if self:CountGroupForCharacter(character) < self:GetGroupedQuantityCap() then
        for i = 1, #self.UnitSet do
            character:SetRestriction(self.UnitSet[i], false)
        end
    else
        for i = 1, #self.UnitSet do
            character:SetRestriction(self.UnitSet[i], true)
        end
    end
end

--v function(self: RECRUITER_GROUP, character: RECRUITER_CHARACTER)
function RecruiterGroup.ApplyRestrictionForGroup(self, character)
    for i = 1, #self.UnitSet do
        character:ApplyRestrictionToUnit(self.UnitSet[i])
    end
end


--v function(self: RECRUITER_GROUP, character: RECRUITER_CHARACTER)
function RecruiterGroup.LimitAllInGroup(self, character)
    for i = 1, #self.UnitSet do
        character:SetRestriction(self.UnitSet[i], true)
        character:ApplyRestrictionToUnit(self.UnitSet[i])
    end
end




return {
    New = RecruiterGroup.New
}