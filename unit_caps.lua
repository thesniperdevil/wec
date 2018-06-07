RECRUITMENT_CONTROLS_LOG = true --:boolean


-- Vanish's Error Checking Wrappers.
--Modified slightly for use with my custom log.
--require("test")
--[[
    --v [NO_CHECK] function(func: function) --> any
        function safeCall(func)
            --RCDEBUG("safeCall start");
            local status, result = pcall(func)
            if not status then
                RCDEBUG(tostring(result))
                RCDEBUG(debug.traceback());
            end
            --RCDEBUG("safeCall end");
            return result;
        end
        
        --local oldTriggerEvent = core.trigger_event;
        
        --v [NO_CHECK] function(...: any)
        function pack2(...) return {n=select('#', ...), ...} end
        --v [NO_CHECK] function(t: vector<WHATEVER>) --> vector<WHATEVER>
        function unpack2(t) return unpack(t, 1, t.n) end
        
        --v [NO_CHECK] function(f: function(), argProcessor: function()) --> function()
        function wrapFunction(f, argProcessor)
            return function(...)
                --RCDEBUG("start wrap ");
                local someArguments = pack2(...);
                if argProcessor then
                    safeCall(function() argProcessor(someArguments) end)
                end
                local result = pack2(safeCall(function() return f(unpack2( someArguments )) end));
                --for k, v in pairs(result) do
                --    RCDEBUG("Result: " .. tostring(k) .. " value: " .. tostring(v));
                --end
                --RCDEBUG("end wrap ");
                return unpack2(result);
              end
        end
        
        -- function myTriggerEvent(event, ...)
        --     local someArguments = { ... }
        --     safeCall(function() oldTriggerEvent(event, unpack( someArguments )) end);
        -- end
        
        --v [NO_CHECK] function(fileName: string)
        function tryRequire(fileName)
            local loaded_file = loadfile(fileName);
            if not loaded_file then
                RCDEBUG("Failed to find mod file with name " .. fileName)
            else
                RCDEBUG("Found mod file with name " .. fileName)
                RCDEBUG("Load start")
                local local_env = getfenv(1);
                setfenv(loaded_file, local_env);
                loaded_file();
                RCDEBUG("Load end")
            end
        end
        
        core:add_listener(
            "LaunchRuntimeScript",
            "ShortcutTriggered",
            function(context) return context.string == "camera_bookmark_view1"; end, --default F10
            function(context)
                tryRequire("test");
            end,
            true
        );
        
        --v [NO_CHECK] function(f: function(), name: string)
        function logFunctionCall(f, name)
            return function(...)
                RCDEBUG("function called: " .. name);
                return f(...);
            end
        end
        
        --v [NO_CHECK] function(object: any)
        function logAllObjectCalls(object)
            local metatable = getmetatable(object);
            for name,f in pairs(getmetatable(object)) do
                if is_function(f) then
                    RCDEBUG("Found " .. name);
                    if name == "Id" or name == "Parent" or name == "Find" or name == "Position" or name == "CurrentState"  or name == "Visible"  or name == "Priority" or "Bounds" then
                        --Skip
                    else
                        metatable[name] = logFunctionCall(f, name);
                    end
                end
                if name == "__index" and not is_function(f) then
                    for indexname,indexf in pairs(f) do
                        RCDEBUG("Found in index " .. indexname);
                        if is_function(indexf) then
                            f[indexname] = logFunctionCall(indexf, indexname);
                        end
                    end
                    RCDEBUG("Index end");
                end
            end
        end
        
        -- logAllObjectCalls(core);
        -- logAllObjectCalls(cm);
        -- logAllObjectCalls(game_interface);
        
        core.trigger_event = wrapFunction(
            core.trigger_event,
            function(ab)
                --RCDEBUG("trigger_event")
                --for i, v in pairs(ab) do
                --    RCDEBUG("i: " .. tostring(i) .. " v: " .. tostring(v))
                --end
                --RCDEBUG("Trigger event: " .. ab[1])
            end
        );
        
        cm.check_callbacks = wrapFunction(
            cm.check_callbacks,
            function(ab)
                --RCDEBUG("check_callbacks")
                --for i, v in pairs(ab) do
                --    RCDEBUG("i: " .. tostring(i) .. " v: " .. tostring(v))
                --end
            end
        )
        
        local currentAddListener = core.add_listener;
        --v [NO_CHECK] function(core: any, listenerName: any, eventName: any, conditionFunc: any, listenerFunc: any, persistent: any)
        function myAddListener(core, listenerName, eventName, conditionFunc, listenerFunc, persistent)
            local wrappedCondition = nil;
            if is_function(conditionFunc) then
                --wrappedCondition =  wrapFunction(conditionFunc, function(arg) RCDEBUG("Callback condition called: " .. listenerName .. ", for event: " .. eventName); end);
                wrappedCondition =  wrapFunction(conditionFunc);
            else
                wrappedCondition = conditionFunc;
            end
            currentAddListener(
                core, listenerName, eventName, wrappedCondition, wrapFunction(listenerFunc), persistent
                --core, listenerName, eventName, wrappedCondition, wrapFunction(listenerFunc, function(arg) RCDEBUG("Callback called: " .. listenerName .. ", for event: " .. eventName); end), persistent
            )
        end
        core.add_listener = myAddListener;
    
--]]






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


--v function(text: string)
function RCDEBUG(text)
    ftext = "debugger"
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
    self.LocalQueueInsertPosition = 1;
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

--v function(self: RECRUITER_CHARACTER) --> RECRUITER_MANAGER
function RecruiterCharacter.GetManager(self)
    if self.RecruiterManager == nil then
        RCERROR("NO MANAGER COULD BE FOUND?! Something has gone horribly wrong")
        return nil
    end
    return self.RecruiterManager
end


--v function(self: RECRUITER_CHARACTER) --> boolean
function RecruiterCharacter.IsQueueEmpty(self)
    RCLOG("Queue Empty returning ["..tostring(self.QueueEmpty).."] for a RECRUITER_CHARACTER with CQI ["..tostring(self.cqi).."]", "RecruiterCharacter.IsQueueEmpty(self)")
    return self.QueueEmpty
end

--v function(self: RECRUITER_CHARACTER) --> number
function RecruiterCharacter.GetLocalInsertPosition(self)
    return self.LocalQueueInsertPosition
end

--v function(self: RECRUITER_CHARACTER)
function RecruiterCharacter.IncrementLocalInsert(self)
    self.LocalQueueInsertPosition = self.LocalQueueInsertPosition + 1;
end

--v function(self: RECRUITER_CHARACTER)
function RecruiterCharacter.DecrementLocalInsert(self)
    self.LocalQueueInsertPosition = self.LocalQueueInsertPosition - 1;
end


--v function(self: RECRUITER_CHARACTER)
function RecruiterCharacter.EmptyQueue(self)
    RCLOG("Emptying the Queue for a RECRUITER_CHARACTER with CQI ["..tostring(self.cqi).."]", "RecruiterCharacter.EmptyQueue(self)")
    self.QueueEmpty = true;
    self.QueueTable = {}
    self.LocalQueueInsertPosition = 1;
end

--v function(self:RECRUITER_CHARACTER) --> CA_CQI
function RecruiterCharacter.GetCqi(self)
    return self.cqi
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
    if self.RegionKey == nil then
        RCERROR("RegionKey was never set! something has gone horribly wrong!")
        return nil
    end

    return self.RegionKey
end

--v function(self: RECRUITER_CHARACTER)
function RecruiterCharacter.EvaluateArmy(self)
    RCLOG("Evaluating Army for a RECRUITER_CHARACTER with CQI ["..tostring(self.cqi).."]", "RecruiterCharacter.EvaluateArmy(self)")
    local army = cm:get_character_by_cqi(self.cqi):military_force():unit_list()
    self.CurrentArmy = {}
    local outputstring = "CURRENT ARMY: "
    for i = 0, army:num_items() - 1 do
        local current_unit = army:item_at(i):unit_key()
        local final_key = current_unit.."_recruitable"
        outputstring =  outputstring..final_key
        table.insert(self.CurrentArmy, final_key)
    end
    RCLOG(outputstring, "RecruiterCharacter.EvaluateArmy(self)")
end

--v function(self: RECRUITER_CHARACTER)
function RecruiterCharacter.SetCounts(self)
    RCLOG("Setting counts for selected a RECRUITER_CHARACTER with CQI ["..tostring(self.cqi).."]", "RecruiterCharacter.SetCounts(self)")

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
    RCLOG("Retrieving total unit count of ["..unit_component_ID.."] for a RECRUITER_CHARACTER with CQI ["..tostring(self.cqi).."]", "RecruiterCharacter.GetTotalCountForUnit(self, unit_component_ID)")
    if not self.TotalCount[unit_component_ID] then
        RCLOG("Returning 0", "RecruiterCharacter.GetTotalCountForUnit(self, unit_component_ID)" )
        return 0
    end
    RCLOG("Returning ["..tostring(self.TotalCount[unit_component_ID]).."] ", "RecruiterCharacter.GetTotalCountForUnit(self, unit_component_ID)")
    return self.TotalCount[unit_component_ID];
end


--v function(self: RECRUITER_CHARACTER, unit_component_ID: string, isGlobal: boolean)
function RecruiterCharacter.AddToQueue(self, unit_component_ID, isGlobal)
    RCLOG("Adding ["..unit_component_ID.."] to the queue of a RECRUITER_CHARACTER with CQI ["..tostring(self.cqi).."]", "function RecruiterCharacter.AddToQueue(self, unit_component_ID)")
    if isGlobal then
        table.insert(self.QueueTable, unit_component_ID)
    else 
        
        table.insert(self.QueueTable, self:GetLocalInsertPosition(), unit_component_ID) 
        self:IncrementLocalInsert()
    end
    self.QueueEmpty = false;
    self:SetCounts()
end


--v function(self: RECRUITER_CHARACTER, unit_component_ID: string)
function RecruiterCharacter.RemoveUnitFromQueue(self, unit_component_ID)
    RCLOG("Removing ["..unit_component_ID.."] from the queue for a RECRUITER_CHARACTER with CQI ["..tostring(self.cqi).."]", "RecruiterCharacter.RemoveFromQueue(self, unit_component_ID)")
    for i = 1, #self.QueueTable do
        if self.QueueTable[i] == unit_component_ID then
            RCLOG("unit_component_ID is ["..unit_component_ID.."], while ["..tostring(i).."] is QID", "RecruiterCharacter.RemoveFromQueue(self, unit_component_ID)")
            table.remove(self.QueueTable, i)
            if i < self:GetLocalInsertPosition() then
                self:DecrementLocalInsert()
            end
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
    RCLOG("Unit ID is ["..self.QueueTable[queueID].."], while ["..tostring(queueID).."] is QID", "RecruiterCharacter.RemoveFromQueue(self, queue_component_ID)")
    local cached_unit = self.QueueTable[queueID]
    table.remove(self.QueueTable, queueID)
    if queueID < self:GetLocalInsertPosition() then
        self:DecrementLocalInsert()
    end
    self:SetCounts()
    return cached_unit
end


--v function (self: RECRUITER_CHARACTER, unit_component_ID:string, restrict: boolean)
function RecruiterCharacter.SetRestriction(self, unit_component_ID, restrict)
    self.CurrentRestrictions[unit_component_ID] = restrict
end

--v function(self: RECRUITER_CHARACTER, unit_component_ID: string)
function RecruiterCharacter.ApplyRestrictionToUnit(self, unit_component_ID)
    RCLOG("Applying Restrictions for character ["..tostring(self:GetCqi()).."] and unit ["..unit_component_ID.."] ", "RecruiterCharacter.ApplyRestrictionToUnit(self, unit_component_ID)")
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
    self.EvaluatedCSC = false;
    self.RegionRestrictions = {} --:map<string, map<string, boolean>>
    self.UnitQuantityRestrictions = {} --:map<string, number>


    RCLOG("Init Complete, adding the manager to the Gamespace!", "RecruiterManager.Init()")
    _G.rm = self
end

--v function(self: RECRUITER_MANAGER) --> RECRUITER_CHARACTER
function RecruiterManager.GetCurrentlySelectedCharacter(self)
    return self.CurrentlySelectedCharacter 
end

--v function(self: RECRUITER_MANAGER, cqi: CA_CQI)
function RecruiterManager.SetCurrentlySelectedCharacter(self, cqi)
    RCLOG("Set the CurrentlySelectedCharacter to ["..tostring(cqi).."]", "RecruiterManager.SetCurrentlySelectedCharacter(self, cqi)")
    if not self.CurrentlySelectedCharacter == self.Characters[cqi] then
        self.EvaluatedCSC = false;
    end
    self.CurrentlySelectedCharacter = self.Characters[cqi]
    
end


--v function(self: RECRUITER_MANAGER, cqi: CA_CQI)
function RecruiterManager.CreateCharacter(self, cqi)
    if not cm:get_character_by_cqi(cqi):has_military_force() then
        RCLOG("Selected  ["..tostring(cqi).."] does not have a military force, aborting ", "RecruiterManager.CreateCharacter(self, cqi)")
        return
    end
    RCLOG("Model calling for a new character with CQI ["..tostring(cqi).."]", "RecruiterManager.CreateCharacter(self, cqi)")
    local character = RecruiterCharacter.Create(cqi)
    self.Characters[cqi] = character
    character:SetManager(self)
    self:SetCurrentlySelectedCharacter(cqi)

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
        local character = RecruiterCharacter.Load(k, v)
        self.Characters[cqi] = character
        character:SetManager(self)
    end
end

--v function(self: RECRUITER_MANAGER, unit_key: string, region_key: string)
function RecruiterManager.AddRegionRestrictionToUnit(self, unit_key, region_key)
    RCLOG("Region Restriction set for unit ["..unit_key.."] and region ["..region_key.."]", "RecruiterManager.AddRegionRestrictionToUnit(self, unit_key, region_key)")
    if self.RegionRestrictions[region_key] == nil then
        RCLOG("RegionRestrictions table for this region has not been initialised yet, initialising it now!", "RecruiterManager.AddRegionRestrictionToUnit(self, unit_key, region_key)")
        self.RegionRestrictions[region_key] = {} 
    end
    self.RegionRestrictions[region_key][unit_key] = true
end

--v function(self: RECRUITER_MANAGER, unit_key: string, region_key: string)
function RecruiterManager.RemoveRegionRestrictionFromUnit(self, unit_key, region_key)
    RCLOG("Region Restriction removed for unit ["..unit_key.."] and region ["..region_key.."]", "RecruiterManager.RemoveRegionRestrictionFromUnit(self, unit_key, region_key)")
    if self.RegionRestrictions[region_key] == nil then
        RCLOG("RegionRestrictions table for this region has not been initialised yet, initialising it now!", "RecruiterManager.RemoveRegionRestrictionFromUnit(self, unit_key, region_key)")
        self.RegionRestrictions[region_key] = {} 
    end
    self.RegionRestrictions[region_key][unit_key] = false
end

--v function(self: RECRUITER_MANAGER, unit_key: string, region_key: string) --> boolean
function RecruiterManager.GetIsRegionRestricted(self, unit_key, region_key)
    if self.RegionRestrictions[region_key] == nil then
        RCLOG("RegionRestrictions table for this region has not been initialised yet, initialising it now!", "RecruiterManager.GetIsRegionRestricted(self, unit_key, region_key)")
        self.RegionRestrictions[region_key] = {} 
    end
    if self.RegionRestrictions[region_key][unit_key] == nil then
        RCLOG("Region Restriction for unit ["..unit_key.."] and region ["..region_key.."] is [false] ", "RecruiterManager.GetIsRegionRestricted(self, unit_key, region_key)")
        return false
    end
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
    if self.UnitQuantityRestrictions[unit_key] == nil then 
        RCLOG("No restriction set, returning a high enough number that it wont matter", "RecruiterManager.GetUnitQuantityRestriction(self, unit_key)")
        return 41;
    end
    RCLOG("unit restriction for unit ["..unit_key.."] is quantity ["..tostring(self.UnitQuantityRestrictions[unit_key]).."]","RecruiterManager.GetUnitQuantityRestriction(self, unit_key)")
    return self.UnitQuantityRestrictions[unit_key];
end




--v function(self: RECRUITER_MANAGER)
function RecruiterManager.EvaluateAllRestrictions(self)
    if self.EvaluatedCSC == true then
        return 
    end
    self.EvaluatedCSC = true
    local character = self:GetCurrentlySelectedCharacter()
    local region = character:GetRegion()

    local recruitmentList = find_uicomponent(core:get_ui_root(), 
    "units_panel", "main_units_panel", "recruitment_docker", "recruitment_options", "recruitment_listbox",
    "local1", "unit_list", "listview", "list_clip", "list_box");
    for i = 0, recruitmentList:ChildCount() - 1 do	
        local recruitmentOption = UIComponent(recruitmentList:Find(i));
        local unit_component_ID = recruitmentOption:Id()
        local count = character:GetTotalCountForUnit(unit_component_ID)
        local _should_restrict = false
        if self:GetIsRegionRestricted(unit_component_ID, region) then
            RCLOG("Unit is region restricted for this character", "RecruiterManager.EvaluateAllRestrictions(self)")
            _should_restrict = true
            RCDEBUG("3")
        elseif
            count > self:GetUnitQuantityRestriction(unit_component_ID) then
                RCLOG("Unit is at quantity limit and restricted for this character", "RecruiterManager.EvaluateAllRestrictions(self)")
                _should_restrict = true
        end
        RCLOG("Sending ["..tostring(_should_restrict).."] to the SetRestriction Method", "RecruiterManager.EvaluateAllRestrictions(self)")
        character:SetRestriction(unit_component_ID, _should_restrict)
        character:ApplyRestrictionToUnit(unit_component_ID)
    end
end

--v function(self: RECRUITER_MANAGER, unit_component_ID: string)
function RecruiterManager.EvaluateSingleUnitRestriction(self, unit_component_ID)
    RCLOG("Evaluating single unit restriction for ["..unit_component_ID.."]", "RecruiterManager.EvaluateSingleUnitRestriction(self, unit_component_ID)")
    local character = self:GetCurrentlySelectedCharacter()
    local region = character:GetRegion()
    local count = character:GetTotalCountForUnit(unit_component_ID)

    local _should_restrict = false
    if self:GetIsRegionRestricted(unit_component_ID, region) then
        RCLOG("Unit is region restricted for this character", "RecruiterManager.EvaluateSingleUnitRestriction(self, unit_component_ID)")
        _should_restrict = true
    elseif
        count > self:GetUnitQuantityRestriction(unit_component_ID) then
            RCLOG("Unit is at quantity limit and restricted for this character", "RecruiterManager.EvaluateSingleUnitRestriction(self, unit_component_ID)")
            _should_restrict = true
    end
    RCLOG("Sending ["..tostring(_should_restrict).."] to the SetRestriction Method", "RecruiterManager.EvaluateSingleUnitRestriction(self, unit_component_ID)")
    character:SetRestriction(unit_component_ID, _should_restrict)
    character:ApplyRestrictionToUnit(unit_component_ID)
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
    RCLOG("Selected Character with CQI ["..tostring(cqi).."]", "RecruiterManager.OnCharacterSelected(self, cqi)")
    if self.Characters[cqi] == nil then
        self:CreateCharacter(cqi)
        local character = self:GetCurrentlySelectedCharacter()

        character:EvaluateArmy()

        character:SetCounts()

        character:SetRegion()

    end
    if self:GetCurrentlySelectedCharacter():GetCqi() ~= cqi then
        
        self:SetCurrentlySelectedCharacter(cqi)

        local character = self:GetCurrentlySelectedCharacter()
        character:EvaluateArmy()
        character:SetCounts()
        character:SetRegion()
    else
        RCLOG("Selected Character with CQI ["..tostring(cqi).."] was already the currently selected character!", "RecruiterManager.OnCharacterSelected(self, cqi)")
    end
end

--v function(self: RECRUITER_MANAGER)
function RecruiterManager.OnRecruitmentPanelOpened(self)
    self:EvaluateAllRestrictions()
end

--v function(self: RECRUITER_MANAGER, context: CA_UIContext)
function RecruiterManager.OnQueuedUnitClicked(self, context)
    local unit = self:GetCurrentlySelectedCharacter():RemoveFromQueueAndReturnUnit(tostring(context.string))
    RCLOG("Removed unit ["..unit.."], sending it to be evaluated!", "RecruiterManager.OnQueuedUnitClicked(self, context)")
    local unit_card_table = {"units_panel", "main_units_panel", "recruitment_docker", "recruitment_options", "recruitment_listbox", "local1", "unit_list", "listview", "list_clip", "list_box"};
    local unitList = find_uicomponent_from_table(core:get_ui_root(), unit_card_table);
	if is_uicomponent(unitList) then
        local unitCard = find_uicomponent(unitList, unit);	
        if is_uicomponent(unitCard) then
         self:EvaluateSingleUnitRestriction(unit)
        else 
            RCERROR("Unit Card isn't a component!")
        end
    else
        RCERROR("WARNING: Could not find the component for the unit list!. Is the panel closed?")
    end
end

--v function(self: RECRUITER_MANAGER, unit_component_ID: string, isGlobal: boolean)
function RecruiterManager.OnRecruitableUnitClicked(self,unit_component_ID, isGlobal)
    self:GetCurrentlySelectedCharacter():AddToQueue(unit_component_ID, isGlobal)
    self:EvaluateSingleUnitRestriction(unit_component_ID)
end



--listeners.

--v function(self: RECRUITER_MANAGER)
function RecruiterManager.Listen(self)

    core:add_listener(
        "RecruiterManagerOnRecruitOptionClicked",
        "ComponentLClickUp",
        true,
        function(context--: CA_UIContext
        )
            local unit_component_ID = tostring(UIComponent(context.component):Id())
            if string.find(unit_component_ID, "_recruitable") and UIComponent(context.component):CurrentState() == "active" then
                UIComponent(context.component):SetInteractive(false)
                RCLOG("Locking recruitment button for ["..unit_component_ID.."] temporarily", "RecruiterManager.Listen(self).core.add_listener.RecruiterManagerOnRecruitOptionClicked");
                local isGlobal = uicomponent_descended_from(UIComponent(context.component), "global")
                self:OnRecruitableUnitClicked(unit_component_ID, isGlobal)
            end
        end,
        true);

    core:add_listener(
        "RecruiterManagerOnQueuedUnitClicked",
        "ComponentLClickUp",
        true,
        function(context--: CA_UIContext
        )
            local queue_component_ID = tostring(UIComponent(context.component):Id())
            if string.find(queue_component_ID, "QueuedLandUnit") then
                RCLOG("Component Clicked was a Queued Unit!", "RecruiterManager.Listen(self).core.add_listener.RecruiterManagerOnQueuedUnitClicked")
                self:OnQueuedUnitClicked(context)
            end
        end,
        true);

    core:add_listener(
        "RecruiterManagerPlayerCharacterMoved",
        "CharacterFinishedMovingEvent",
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

    core:add_listener(
        "RecruitmentManagerOnPanelOpened",
        "PanelOpenedCampaign",
        function(context)
            return context.string == "units_recruitment"; 
        end,
        function(context)
            RCLOG("Recruitment Panel Opened by the Player!", "RecruiterManager.Listen(self).core.add_listener.RecruitmentManagerOnPanelOpened")
            cm:callback( function()
                self:OnRecruitmentPanelOpened();
            end, 0.1);
        end,
        true);	


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
        rm:Listen()
    end
)

