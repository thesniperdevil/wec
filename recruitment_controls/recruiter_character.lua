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
    self.QueueCount = 0 --:number
    self.CurrentArmy = {} --:vector<string>
    self.ArmyCount = 0 --:number
    self.TotalCount = 0 --:number
    self.RegionKey = "" --:string

    RCLOG("Created a RECRUITER_CHARACTER at CQI ["..tostring(cqi).."] ", "RecruiterCharacter.Create(cqi)")
    return self
end

--v function(self: RECRUITER_CHARACTER, manager: RECRUITER_MANAGER)
function RecruiterCharacter.SetManager(self, manager)
    self.RecruiterManager = manager
end










return {
    Create = RecruiterCharacter.Create
}





