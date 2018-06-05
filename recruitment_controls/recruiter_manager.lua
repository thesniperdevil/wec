RECRUITMENT_CONTROLS_LOG = true --:boolean

--v function(text: string, ftext: string)
function RCLOG(text, ftext)
    --sometimes I use ftext as an arg of this function, but for simple mods like this one I don't need it.

    if not RECRUITMENT_CONTROLS_LOG then
      return; --if our bool isn't set true, we don't want to spam the end user with logs. 
    end

  local logText = tostring(text)
  local logContext = tostring(ftext)
  local logTimeStamp = os.date("%d, %m %Y %X")
  local popLog = io.open("RCLOG.txt","a")
  --# assume logTimeStamp: string
  popLog :write("WEC:  "..logText .. "    : [" .. logContext .. "] : [".. logTimeStamp .. "]\n")
  popLog :flush()
  popLog :close()
end

function RCREFRESHLOG()
    if not RECRUITMENT_CONTROLS_LOG then
        return;
    end

    local logTimeStamp = os.date("%d, %m %Y %X")
    --# assume logTimeStamp: string

    local popLog = io.open("RCLOG.txt","w+")
    popLog :write("NEW LOG ["..logTimeStamp.."] \n")
    popLog :flush()
    popLog :close()
end
RCREFRESHLOG()

--v function(msg: string)
function RCERROR(msg)
	local ast_line = "********************";
	
	-- do output
	print(ast_line);
	print("SCRIPT ERROR, timestamp " .. get_timestamp());
	print(msg);
	print("");
	print(debug.traceback("", 2));
	print(ast_line);
	-- assert(false, msg .. "\n" .. debug.traceback());
	
	-- logfile output
		local file = io.open("RCLOG.txt", "a");
		
		if file then
			file:write(ast_line .. "\n");
			file:write("SCRIPT ERROR, timestamp " .. get_timestamp() .. "\n");
			file:write(msg .. "\n");
			file:write("\n");
			file:write(debug.traceback("", 2) .. "\n");
			file:write(ast_line .. "\n");
			file:close();
		end;
end;


local rc = require("recruitment_controls/recruiter_character")

local RecruiterManager = {} --# assume RecruiterManager: RECRUITER_MANAGER

--v function()
function RecruiterManager.Init()
    local self = {}
    setmetatable(self, {
        __index = RecruiterManager,
        __tostring = function() return "RECRUITER_MANAGER" end
    })
    --# assume self: RECRUITER_MANAGER

    self.Characters = {} --:map<CA_CQI, RECRUITER_CHARACTER>
    self.CurrentlySelectedCharacter = nil --:RECRUITER_CHARACTER
    self.RegionRestrictions = {} --:map<string, map<string, boolean>>
    self.UnitQuantityRestrictions = {} --:map<string, number>


    RCLOG("Init Complete, adding the manager to the Gamespace!", "RecruiterManager.Init()")
    _G.rm = self
end

--v function(self: RECRUITER_MANAGER, cqi: CA_CQI)
function RecruiterManager.CreateCharacter(self, cqi)
    if not cm:get_character_by_cqi(cqi):has_military_force() then
        RCLOG("Selected  ["..tostring(cqi).."] does not have a military force, aborting ", "RecruiterManager.CreateCharacter(self, cqi)")
        return
    end
    RCLOG("Model calling for a new character with CQI ["..tostring(cqi).."]", "RecruiterManager.CreateCharacter(self, cqi)")
    local character = rc.Create(cqi)
    self.Characters[cqi] = character
    character:SetManager(self)
end

--v function(self: RECRUITER_MANAGER) --> map<CA_CQI, vector<string>>
function RecruiterManager.Save(self)
    local save_table = {} --:map<CA_CQI, vector<string>>
    for k, v in pairs(self.Characters) do
        if v:IsQueueEmpty() == false then
            cqi, queuetable = v:Save()
            save_table[cqi] = queuetable
        end
    end

    return save_table
end

--v function(self: RECRUITER_MANAGER, save_table: map<CA_CQI, vector<string>>)
function RecruiterManager.Load(self, save_table)
    for k, v in pairs(save_table) do
        local character = rc.Load(k, v)
        self.Characters[cqi] = character
        character:SetManager(self)
    end
end

--v function(self: RECRUITER_MANAGER, unit_key: string, region_key: string)
function RecruiterManager.AddRegionRestrictionToUnit(self, unit_key, region_key)
    RCLOG("Region Restriction set for unit ["..unit_key.."] and region ["..region_key.."]", "RecruiterManager.AddRegionRestrictionToUnit(self, unit_key, region_key)")
    self.RegionRestrictions[region_key][unit_key] = true
end

--v function(self: RECRUITER_MANAGER, unit_key: string, region_key: string)
function RecruiterManager.RemoveRegionRestriction(self, unit_key, region_key)
    RCLOG("Region Restriction removed for unit ["..unit_key.."] and region ["..region_key.."]", "RecruiterManager.RemoveRegionRestriction(self, unit_key, region_key)")
    self.RegionRestrictions[region_key][unit_key] = false
end

--v function(self: RECRUITER_MANAGER, unit_key: string, region_key: string) --> boolean
function RecruiterManager.GetIsRegionRestricted(self, unit_key, region_key)
    RCLOG("Region Restriction for unit ["..unit_key.."] and region ["..region_key.."] is ["..tostring(self.RegionRestrictions[region_key][unit_key]).."] ", "RecruiterManager.GetIsRegionRestricted(self, unit_key, region_key)")
    return self.RegionRestrictions[region_key][unit_key]
end

--v function(self: RECRUITER_MANAGER, unit_key: string, count: number) 
function RecruiterManager.SetUnitQuantityRestriction(self, unit_key, count)
    RCLOG("Set a unit restriction for unit ["..unit_key.."] and quantity ["..tostring(count).."]","RecruiterManager.SetUnitQuantityRestriction(self, unit_key, count)")
    self.UnitQuantityRestrictions[unit_key] = count
end

--v function(self: RECRUITER_MANAGER, unit_key: string)
function RecruiterManager.RemoveUnitQuantityRestriction(self, unit_key)
    RCLOG("removed a unit restriction for unit ["..unit_key.."]","RecruiterManager.RemoveUnitQuantityRestriction(self, unit_key)")
    self.UnitQuantityRestrictions[unit_key] = nil
end

--v function(self: RECRUITER_MANAGER, unit_key: string) --> number
function RecruiterManager.GetUnitQuantityRestriction(self, unit_key)
    RCLOG("unit restriction for unit ["..unit_key.."] is quantity ["..tostring(self.UnitQuantityRestrictions[unit_key]).."]","RecruiterManager.GetUnitQuantityRestriction(self, unit_key)")
    return self.UnitQuantityRestrictions[unit_key]
end

--v function(self: RECRUITER_MANAGER, cqi: CA_CQI)
function RecruiterManager.SetCurrentlySelectedCharacter(self, cqi)
    RCLOG("Set the CurrentlySelectedCharacter to ["..tostring(cqi).."]", "RecruiterManager.SetCurrentlySelectedCharacter(self, cqi)")
    self.CurrentlySelectedCharacter = self.Characters[cqi]
end

--v function(self: RECRUITER_MANAGER) --> RECRUITER_CHARACTER
function RecruiterManager.GetCurrentlySelectedCharacter(self)
    return self.CurrentlySelectedCharacter
end

--v function(self: RECRUITER_MANAGER)
function RecruiterManager.EvaluateAllRestrictions(self)

end

--v function(self: RECRUITER_MANAGER, unit_component_ID: string)
function RecruiterManager.EvaluateSingleUnitRestriction(self, unit_component_ID)
    local character = self:GetCurrentlySelectedCharacter()
    local region = character:GetRegion()
    local count = character:GetTotalCountForUnit(unit_component_ID)
    character:SetRestriction(unit_component_ID, (self.RegionRestrictions[region][unit_component_ID] or (count > self.UnitQuantityRestrictions[unit_component_ID]) ))
end


---Events


--v function(self: RECRUITER_MANAGER, cqi: CA_CQI)
function RecruiterManager.OnCharacterFinishedMoving(self, cqi)
    if not self.Characters[cqi] then
        RCLOG("Character with cqi ["..tostring(cqi).."] moved but is not contained in the model", "OnCharacterFinishedMoving(self, cqi)")
        return
    end
    if self.Characters[cqi]:IsQueueEmpty() == false then
        self.Characters[cqi]:EmptyQueue()
        RCLOG("Character with cqi ["..tostring(cqi).."] moved, but had units in Queue. Wiping his units!", "RecruiterManager.OnCharacterFinishedMoving(self, cqi)")
    end
end

--v function(self: RECRUITER_MANAGER, context: WHATEVER)
function RecruiterManager.OnUnitTrained(self, context)
    local unit = context:unit()
    --# assume unit: CA_UNIT
    local char_cqi = unit:force_commander():command_queue_index();
    local unit_key = unit:unit_key();
    RCLOG("Recruitment Completed for unit ["..unit_key.."] by character ["..tostring(char_cqi).."]", "RecruiterManager.OnUnitTrained(self, context)")
    self.Characters[char_cqi]:RemoveUnitFromQueue(unit_key.."_recruitable")
end

--v function(self: RECRUITER_MANAGER, cqi: CA_CQI)
function RecruiterManager.OnCharacterSelected(self, cqi)
    RCLOG("Selected Character with CQI ["..tostring(cqi).."] ", "RecruiterManager.OnCharacterSelected(self, cqi)")
    if self.Characters[cqi] == nil then
        self:CreateCharacter(cqi)
    end
    if not self.Characters[cqi] == self.CurrentlySelectedCharacter then
        self:SetCurrentlySelectedCharacter(cqi)
        local character = self:GetCurrentlySelectedCharacter()
        character:EvaluateArmy()
        character:SetCounts()
        character:SetRegion()
    end
end

--v function(self: RECRUITER_MANAGER)
function RecruiterManager.OnRecruitmentPanelOpened(self)
    self:EvaluateAllRestrictions()
end

--v function(self: RECRUITER_MANAGER, context: CA_UIContext)
function RecruiterManager.OnQueuedUnitClicked(self, context)
    local unit = self:GetCurrentlySelectedCharacter():RemoveFromQueueAndReturnUnit(tostring(UIComponent(context.component):Id()))
    self:EvaluateSingleUnitRestriction(unit)
end

--v function(self: RECRUITER_MANAGER, context: CA_UIContext)
function RecruiterManager.OnRecruitableUnitClicked(self, context)
    local unit = tostring(UIComponent(context.component):Id())
    self:GetCurrentlySelectedCharacter():AddToQueue(unit)
    self:EvaluateSingleUnitRestriction(unit)
end



--listeners.

--v function(self: RECRUITER_MANAGER)
function RecruiterManager.Listen(self)

    core:add_listener(
        "RecruiterManagerOnRecruitOptionClicked",
        "ComponentLClickUp",
        true,
        function(context)
            --# assume context: CA_UIContext
            local unit_component_ID = tostring(UIComponent(context.component):Id())
            if string.find(unit_component_ID, "_recruitable") then
                RCLOG("Locking recruitment button for ["..unit_component_ID.."] temporarily", "RecruiterManager.Listen(self).core.add_listener.RecruiterManagerOnRecruitOptionClicked");
                self:OnRecruitableUnitClicked(context)
            end
        end,
        true);

    core:add_listener(
        "RecruiterManagerOnQueuedUnitClicked",
        "ComponentLClickUp",
        true,
        function(context)
            --# assume context: CA_UIContext
            local queue_component_ID = tostring(UIComponent(context.component):Id())
            if string.find(queue_component_ID, "QueuedLandUnit") then
                RCLOG("Component Clicked was a Queued Unit!", "RecruiterManager.Listen(self).core.add_listener.RecruiterManagerOnQueuedUnitClicked")
                self:OnQueuedUnitClicked(context)
            end
        end,
        true);

    core:add_listener(
        "RecruiterManagerPlayerCharacterMoved",
        "CharacterFinishedMoving",
        function(context)
            return context:character():faction():is_human()
        end,
        function(context)
            RCLOG("Player Character moved!", "RecruiterManager.Listen(self).core.add_listener.RecruiterManagerPlayerFactionRecruitedUnit")
            local character = context:character()
            --# assume character: CA_CHAR
            self:OnCharacterFinishedMoving(character:command_queue_index())
        end,
        true)

    core:add_listener(
        "RecruiterManagerPlayerFactionRecruitedUnit",
        "UnitTrained",
        function(context)
            return context:unit():faction():is_human()
        end,
        function(context)
            RCLOG("Player faction recruited a unit!", "RecruiterManager.Listen(self).core.add_listener.RecruiterManagerPlayerFactionRecruitedUnit")
            self:OnUnitTrained(context)
        end,
        true)

    core:add_listener(
        "RecruiterManagerOnCharacterSelected",
        "CharacterSelected",
        function(context)
        return context:character():faction():is_human() and context:character():has_military_force()
        end,
        function(context)
            RCLOG("Human Character Selected by player!", "RecruiterManager.Listen(self).core.add_listener.RecruiterManagerOnCharacterSelected")
            local character = context:character()
            --# assume character: CA_CHAR
            self:OnCharacterSelected(character:command_queue_index())
        end,
        true)



end

cm:add_saving_game_callback(
    function(context)
        --# assume rm: RECRUITER_MANAGER
        if rm then
            local save_table = rm:Save()
            cm:save_named_value("recruiter_manager", save_table, context)
        end
    end
)

cm:add_loading_game_callback(
    function(context)
        RecruiterManager.Init()
        --# assume rm: RECRUITER_MANAGER
        if not cm:is_new_game() then
            load_table = cm:load_named_value("recruiter_manager", {}, context)
            rm:Load(load_table)
        end
    end
)

