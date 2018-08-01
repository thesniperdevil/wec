function LLRLOGRESET()
    if not __write_output_to_logfile then
        return;
    end
    
    local logTimeStamp = os.date("%d, %m %Y %X")
    --# assume logTimeStamp: string
    
    local popLog = io.open("warhammer_expanded_log.txt","w+")
    popLog :write("NEW LOG ["..logTimeStamp.."] \n")
    popLog :flush()
    popLog :close()
end
LLRLOGRESET()
--v function(text: string)
function LLRLOG(text)
    if not __write_output_to_logfile then
      return; 
    end

  local logText = tostring(text)
  local logTimeStamp = os.date("%d, %m %Y %X")
  local popLog = io.open("warhammer_expanded_log.txt","a")
  --# assume logTimeStamp: string
  popLog :write("OWR:  [".. logTimeStamp .. "]:  "..logText .. "  \n")
  popLog :flush()
  popLog :close()
end

--v [NO_CHECK] function() 
function LLR_ERROR_FINDER()
    --Vanish's PCaller
    --All credits to vanish
    --v function(func: function) --> any
        function safeCall(func)
            --output("safeCall start");
            local status, result = pcall(func)
            if not status then
                RCLOG(tostring(result), "ERROR CHECKER")
                RCLOG(debug.traceback(), "ERROR CHECKER");
            end
            --output("safeCall end");
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
                --output("start wrap ");
                local someArguments = pack2(...);
                if argProcessor then
                    safeCall(function() argProcessor(someArguments) end)
                end
                local result = pack2(safeCall(function() return f(unpack2( someArguments )) end));
                --for k, v in pairs(result) do
                --    output("Result: " .. tostring(k) .. " value: " .. tostring(v));
                --end
                --output("end wrap ");
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
                output("Failed to find mod file with name " .. fileName)
            else
                output("Found mod file with name " .. fileName)
                output("Load start")
                local local_env = getfenv(1);
                setfenv(loaded_file, local_env);
                loaded_file();
                output("Load end")
            end
        end
        
        --v [NO_CHECK] function(f: function(), name: string)
        function logFunctionCall(f, name)
            return function(...)
                output("function called: " .. name);
                return f(...);
            end
        end
        
        --v [NO_CHECK] function(object: any)
        function logAllObjectCalls(object)
            local metatable = getmetatable(object);
            for name,f in pairs(getmetatable(object)) do
                if is_function(f) then
                    output("Found " .. name);
                    if name == "Id" or name == "Parent" or name == "Find" or name == "Position" or name == "CurrentState"  or name == "Visible"  or name == "Priority" or "Bounds" then
                        --Skip
                    else
                        metatable[name] = logFunctionCall(f, name);
                    end
                end
                if name == "__index" and not is_function(f) then
                    for indexname,indexf in pairs(f) do
                        output("Found in index " .. indexname);
                        if is_function(indexf) then
                            f[indexname] = logFunctionCall(indexf, indexname);
                        end
                    end
                    output("Index end");
                end
            end
        end
        
        -- logAllObjectCalls(core);
        -- logAllObjectCalls(cm);
        -- logAllObjectCalls(game_interface);
        
        core.trigger_event = wrapFunction(
            core.trigger_event,
            function(ab)
                --output("trigger_event")
                --for i, v in pairs(ab) do
                --    output("i: " .. tostring(i) .. " v: " .. tostring(v))
                --end
                --output("Trigger event: " .. ab[1])
            end
        );
        
        cm.check_callbacks = wrapFunction(
            cm.check_callbacks,
            function(ab)
                --output("check_callbacks")
                --for i, v in pairs(ab) do
                --    output("i: " .. tostring(i) .. " v: " .. tostring(v))
                --end
            end
        )
        
        local currentAddListener = core.add_listener;
        --v [NO_CHECK] function(core: any, listenerName: any, eventName: any, conditionFunc: any, listenerFunc: any, persistent: any)
        function myAddListener(core, listenerName, eventName, conditionFunc, listenerFunc, persistent)
            local wrappedCondition = nil;
            if is_function(conditionFunc) then
                --wrappedCondition =  wrapFunction(conditionFunc, function(arg) output("Callback condition called: " .. listenerName .. ", for event: " .. eventName); end);
                wrappedCondition =  wrapFunction(conditionFunc);
            else
                wrappedCondition = conditionFunc;
            end
            currentAddListener(
                core, listenerName, eventName, wrappedCondition, wrapFunction(listenerFunc), persistent
                --core, listenerName, eventName, wrappedCondition, wrapFunction(listenerFunc, function(arg) output("Callback called: " .. listenerName .. ", for event: " .. eventName); end), persistent
            )
        end
        core.add_listener = myAddListener;
end
LLR_ERROR_FINDER()





--blank savetable
--# type LLR_RECORDS = {
--# _movedLords: map<string, string>, _questSubtypes: map<string, {_mission: string, _level: string}>}


llr_records = {_movedLords = {}, _questSubtypes = {}} --: LLR_RECORDS
--this line is unncessary to the script working, it exists to make kailua happy


llr_manager = {} --# assume llr_manager: LLR_MANAGER
llr_lord = {} --# assume llr_lord: LLR_LORD
--prototypes for our objects

--instantiate the manager
--v function()
function llr_manager.init()
    local self = {}
    setmetatable(self, {
        __index = llr_manager,
        __tostring = function() return "LLR_MANAGER" end
    }) --# assume self: LLR_MANAGER

    self._humans = cm:get_human_factions()
    self._subculture = {} --:map<string, boolean>
    for i = 1, #self._humans do
        self._subculture[cm:get_faction(self._humans[i]):subculture()] = true
    end

    self._factions = {} --:map<string, boolean>
    self._lords = {} --:map<string, vector<LLR_LORD>>
    _G.llr = self
end

--tunnel to log
--v method(text: any)
function llr_manager:log(text)
    LLRLOG(tostring(text))
end

-----------------------
-----------------------
-----------------------
-----------------------
--LLR_LORD SUB OBJECT--

--v [NO_CHECK] function() --> LLR_LORD
function llr_lord.null_interface()
    null_interface = {}
    null_interface.is_null_interface = function(self) return true end
    return null_interface
end

--v function(model: LLR_MANAGER, faction_key: string, subtype: string, forename: string, surname: string) --> LLR_LORD
function llr_lord.new(model, faction_key, subtype,forename,surname)
    local self = {}
    if not tostring(model) == "LLR_MANAGER" then
        LLRLOG("tried to create a lord but did not provide a valid manager!")
        return llr_lord.null_interface()
    end
    local self = {}
    setmetatable(self, {
        __index = llr_lord,
        __tostring = function() return "LLR_LORD" end
    }) --# assume self: LLR_LORD
    --access to model
    self._model = model
    --basic info
    self._factionKey = faction_key
    self._subtypeKey = subtype
    self._forenameKey = forename
    self._surnameKey = surname
    --traits and already completed quests
    self._questItemLevels = {} --:map<string, number>
    self._questMissionLevels = {} --:map<string, number>
    self._immortalityTraits = {} --:vector<string>
    -- value storage for respecs
    self._respawnX = nil --:number
    self._respawnY = nil --:number
    self._respawnRank = nil --:number
    self._respawnArmyString = nil --:string

    return self
end

--return the linked model
--v function(self: LLR_LORD) --> LLR_MANAGER
function llr_lord.model(self)
    return self._model
end

--tunnel to log
--v function(self: LLR_LORD, text: any)
function llr_lord.log(self, text)
    self:model():log(text)
end


--return the faction name
--v function(self: LLR_LORD) --> string
function llr_lord.faction(self)
    return self._factionKey
end

--return the subtype
--v function(self: LLR_LORD) --> string
function llr_lord.subtype(self)
    return self._subtypeKey
end

--return the forename
--v function(self: LLR_LORD) --> string
function llr_lord.forename(self)
    return self._forenameKey
end

--return the surname
--v function(self: LLR_LORD) --> string
function llr_lord.surname(self)
    return self._surnameKey
end

--change the faction set on the lord
--warning, this won't change their faction in model. NOT FOR USE EXTERNAL TO MODEL
--v function(self: LLR_LORD, faction: string)
function llr_lord.set_faction(self, faction)
    self._factionKey = faction
end

--change the subtype key of the lord
--v function(self: LLR_LORD, subtype: string)
function llr_lord.set_subtype(self, subtype)
    self._subtypeKey = subtype
end

--change the forename key of the lord
--v function(self: LLR_LORD, forename: string)
function llr_lord.set_forename(self, forename)
    self._forenameKey = forename
end

--change the surname key of the lord
--v function(self: LLR_LORD, surname: string)
function llr_lord.set_surname(self, surname)
    self._surnameKey = surname
end

--get the table of quest items
--v function(self: LLR_LORD) --> map<string, number>
function llr_lord.quest_items(self)
    return self._questItemLevels
end

--add a quest at a level
--v function(self: LLR_LORD, item: string, level: number)
function llr_lord.add_quest_item(self, item, level)
    if not is_string(item) then
        self:log("ERROR: Tried to add a quest item, but the provided ancillary key is not a string!")
        return
    end
    if not is_number(level) then
        self:log("ERROR: Tried to add a quest item, but the required level is not a number!")
        return
    end

    self._questItemLevels[item] = level
end

--get quests from below or equal to a certain level
--v function(self: LLR_LORD, current_level: number) --> vector<string>
function llr_lord.get_completed_quests(self, current_level)
    local quests = {} --:vector<string>
    for item, level in pairs(self:quest_items()) do
        if level <= current_level then
            table.insert(quests, item)
        end
    end
    return quests
end

--get the table of quests to missions
--v function(self: LLR_LORD) --> map<string, number>
function llr_lord.quest_missions(self)
    return self._questMissionLevels
end

--add a quest mission
--v function(self: LLR_LORD, mission: string, level: number)
function llr_lord.add_quest_mission(self, mission, level)
    if not is_string(mission) then
        self:log("ERROR: Tried to add a quest mission, but the suplied mission is not a string!")
        return
    end
    if not is_number(level) then
        self:log("ERROR: Tried to add a quest mission, but the supplied level is not a number!")
        return
    end
    self._questMissionLevels[mission] = level
end

--get all quest missions over the current level
--v function(self: LLR_LORD, current_level: number) --> vector<string>
function llr_lord.get_future_quests(self, current_level)
    local quests = {} --:vector<string>
    for mission, level in pairs(self:quest_missions()) do
        if level > current_level then
            table.insert(quests, mission)
        end
    end
    return quests
end



















cm:add_saving_game_callback(
    function(context)
        cm:save_named_value("llr_records", llr_records, context)
    end
)

cm:add_loading_game_callback(
    function(context)
        llr_records = cm:load_named_value("llr_records", {_movedLords = {}, _questSubtypes = {}}, context)
        llr_manager.init()
    end
)

















