--Log script to text
--v function(text: string | number | boolean | CA_CQI)
local function LOG(text)
    ftext = "MOD_SETTINGS" 

    if not __write_output_to_logfile then
        return;
    end

    local logText = tostring(text)
    local logContext = tostring(ftext)
    local logTimeStamp = os.date("%d, %m %Y %X")
    local popLog = io.open("MOD_SETTINGS_LOG.txt","a")
    --# assume logTimeStamp: string
    popLog :write("LE:  [".. logTimeStamp .. "]:  "..logText .. "  \n")
    popLog :flush()
    popLog :close()
end

--v function()
local function GPSESSIONLOG()
    if not __write_output_to_logfile then
        return;
    end
    local logTimeStamp = os.date("%d, %m %Y %X")
    --# assume logTimeStamp: string

    local popLog = io.open("MOD_SETTINGS_LOG.txt","w+")
    popLog :write("NEW LOG ["..logTimeStamp.."] \n")
    popLog :flush()
    popLog :close() 
end
GPSESSIONLOG()




local mod_configuration_manager = {} --# assume mod_configuration_manager: MOD_CONFIGURATION_MANAGER

function mod_configuration_manager.init()
    local self = {} 
    setmetatable(self, {
        __index = mod_configuration_manager,
        __tostring = function() return "MOD_CONFIGURATION_MANAGER" end
    })--# assume self: MOD_CONFIGURATION_MANAGER

    self._modConfigStack = {} --:vector<function(context: MOD_CONFIGURATION_MANAGER)>
    self._registeredMods = {} --:map<string, MCM_MOD>

    _G.mcm = self
end

--v function(self: MOD_CONFIGURATION_MANAGER, text: any)
function mod_configuration_manager.log(self, text)
    LOG(tostring(text))
end

--v function(self: MOD_CONFIGURATION_MANAGER) --> vector<function(context: MOD_CONFIGURATION_MANAGER)>
function mod_configuration_manager.get_stack(self)
    return self._modConfigStack
end

--v function(self:MOD_CONFIGURATION_MANAGER, callback: function(context: MOD_CONFIGURATION_MANAGER) )
function mod_configuration_manager.add_callback_to_stack(self, callback)
    table.insert(self:get_stack(), callback)
end

--v function(self: MOD_CONFIGURATION_MANAGER)
function mod_configuration_manager.do_callback_on_stack(self)
    self:get_stack()[#self:get_stack()](self)
    table.remove(self:get_stack())
end




local mcm_mod = require("mcm/mods_object")

--v function(self: MOD_CONFIGURATION_MANAGER) --> map<string, MCM_MOD>
function mod_configuration_manager.get_mods(self)
    return self._registeredMods
end



--v function(self: MOD_CONFIGURATION_MANAGER, key: string, ui_name: string?, ui_tooltip: string?) --> MCM_MOD
function mod_configuration_manager.register_mod(self, key, ui_name, ui_tooltip)
    if not (is_string(key) and (is_string(ui_name) or not ui_name) and (is_string(ui_tooltip) or not ui_tooltip))then 
        self:log("ERROR: attempted to create a new mod, but a provided key, ui_text, or ui_tooltip is not a string!")
        return mcm_mod.null(self)
    end
    if not not self:get_mods()[key] then
        self:log("WARNING: attempted to create a new mod, but a mod already exists with the provided key!; returning that instead")
        return self:get_mods()[key]
    end
    local new_mod = mcm_mod.new(self, key, ui_name, ui_tooltip)
    self:get_mods()[key] = new_mod
    self:log("registered mod ["..key.."]")
    return self:get_mods()[key]
end

--v function(self: MOD_CONFIGURATION_MANAGER, key: string) --> MCM_MOD
function mod_configuration_manager.get_mod(self, key) 
    if not self:get_mods()[key] then
        self:log("ERROR: Called get mod for key ["..key.."] but no mod exists with this key!")
        return mcm_mod.null(self)
    end
    return self:get_mods()[key]
end



--v function(self: MOD_CONFIGURATION_MANAGER, variable: MCM_VAR) 
function mod_configuration_manager.handle_variable(self, variable)
    cm:set_saved_value("mcm_variable_"..variable:mod():name().."_"..variable:name().."_value", variable:current_value())
    if variable:has_callback() then
        self:add_callback_to_stack(variable:callback())
    end
    core:trigger_event("mcm_variable_"..variable:mod():name().."_"..variable:name().."_event")
end
        
--v function(self: MOD_CONFIGURATION_MANAGER, tweaker: MCM_TWEAKER)
function mod_configuration_manager.handle_tweaker(self, tweaker)
    cm:set_saved_value("mcm_tweaker_"..tweaker:mod():name().."_"..tweaker:name().."_value", tweaker:selected_option():name())
    if tweaker:selected_option():has_callback() then
        self:add_callback_to_stack(tweaker:selected_option():callback())
    end
    core:trigger_event("mcm_tweaker_"..tweaker:mod():name().."_"..tweaker:name().."_event")
end

--v function(self: MOD_CONFIGURATION_MANAGER)
function mod_configuration_manager.process_all_mods(self)
    for name, mod in pairs(self:get_mods()) do
        for tweaker_key, tweaker in pairs(mod:tweakers()) do
            self:handle_tweaker(tweaker)
        end
        for variable_key, variable in pairs(mod:variables()) do
            self:handle_variable(variable)
        end
    end
    for i = 1, #self:get_stack() do
        self:do_callback_on_stack()
    end
end


