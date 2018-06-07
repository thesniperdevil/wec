local RecruiterRegion = {} --# assume RecruiterRegion: RECRUITER_REGION

--v function(region_key: string) --> RECRUITER_REGION
function RecruiterRegion.New(region_key)
local self = {}
setmetatable(self, {
    __index = RecruiterRegion,
    __tostring = function() return "RECRUITER_REGION" end
})
--# assume self: RECRUITER_REGION

self.RegionKey = region_key
self.UnitPoolsToEnforce = {} --:map<string, boolean>
self.UnitPoolQuantities = {} --:map<string, number> 
self.UnitPoolMaximums = {} --:map<string, number>

self.Manager = nil --:RECRUITER_MANAGER

return self


end;

--v function(self: RECRUITER_REGION) --> string
function RecruiterRegion.Name(self)
    return self.RegionKey
end;

--v function(self: RECRUITER_REGION, manager: RECRUITER_MANAGER)
function RecruiterRegion.SetManager(self, manager)
    self.Manager = manager
end;

--v function(self: RECRUITER_REGION, unit_component_ID: string) --> boolean
function RecruiterRegion.HasPoolEnforced(self, unit_component_ID)
    return not not self.UnitPoolsToEnforce[unit_component_ID]
end;


--v function(self: RECRUITER_REGION, unit_component_ID: string, base_pool: number)
function RecruiterRegion.SetAndEnforcePoolForUnit(self, unit_component_ID, base_pool)
    self.UnitPoolsToEnforce[unit_component_ID] = true
    self.UnitPoolQuantities[unit_component_ID] = base_pool
end;

--v function(self: RECRUITER_REGION, unit_component_ID: string, pool_cap: number)
function RecruiterRegion.SetUnitPoolMaximum(self, unit_component_ID, pool_cap)
    self.UnitPoolMaximums[unit_component_ID] = pool_cap
end;

--v function(self: RECRUITER_REGION, unit_component_ID: string) --> boolean
function RecruiterRegion.HasPoolMaximum(self, unit_component_ID)
    return not not self.UnitPoolMaximums[unit_component_ID]
end;

--v function(self: RECRUITER_REGION, unit_component_ID: string) --> number
function RecruiterRegion.GetUnitPoolMaximum(self, unit_component_ID)
    if self.UnitPoolMaximums[unit_component_ID] == nil then
        RCERROR("GetPool Maximum called but no maximum is set, used HasMaximum before using this method!")
        return nil
    end
    return self.UnitPoolMaximums[unit_component_ID]
end



--v function(self: RECRUITER_REGION, unit_component_ID: string) --> number
function RecruiterRegion.GetPoolForUnit(self, unit_component_ID)
    if not self.UnitPoolsToEnforce[unit_component_ID] then
        RCERROR("Get Pool for unit called but this unit has no enforcable pool!")
        return nil
    end
    return self.UnitPoolQuantities[unit_component_ID]
end;



--v function(self: RECRUITER_REGION, unit_component_ID: string)
function RecruiterRegion.IncrementPool(self, unit_component_ID)
    RCLOG("Incremeneting recruitment pool for region ["..self:Name().."] and unit ["..unit_component_ID.."]", "RecruiterRegion.IncrementPool(self, unit_component_ID)")
    self.UnitPoolQuantities[unit_component_ID] = self.UnitPoolQuantities[unit_component_ID] + 1;
    if self:HasPoolMaximum(unit_component_ID) then
        if self.UnitPoolQuantities[unit_component_ID] > self:GetUnitPoolMaximum(unit_component_ID) then
            RCLOG("Recruitment pool for region ["..self:Name().."] and unit ["..unit_component_ID.."] exceded maximum and was set to max", "RecruiterRegion.IncrementPool(self, unit_component_ID)")
            self.UnitPoolQuantities[unit_component_ID] = self:GetUnitPoolMaximum(unit_component_ID)
        end
    end
end;

--v function(self: RECRUITER_REGION, unit_component_ID: string)
function RecruiterRegion.DecrementPool(self, unit_component_ID)
    RCLOG("Decrementing recruitment pool for region ["..self:Name().."] and unit ["..unit_component_ID.."]", "RecruiterRegion.DecrementPool(self, unit_component_ID)")
    self.UnitPoolQuantities[unit_component_ID] = self.UnitPoolQuantities[unit_component_ID] - 1;
    if self.UnitPoolQuantities[unit_component_ID] < 0 then
        RCLOG("Recruitment pool for region ["..self:Name().."] and unit ["..unit_component_ID.."] cannot be negative! Set to zero.", "RecruiterRegion.DecrementPool(self, unit_component_ID)")
        self.UnitPoolQuantities[unit_component_ID] = 0
    end
end;

--v function(self: RECRUITER_REGION, unit_component_ID: string) --> boolean
function RecruiterRegion.HasPoolAvailable(self, unit_component_ID)
    if self:HasPoolEnforced(unit_component_ID) then
        return (self:GetPoolForUnit(unit_component_ID) > 0)
    else
        return true
    end
end