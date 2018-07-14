local mcm_mod = {} --# assume mcm_mod: MCM_MOD





--v function(model: MOD_CONFIGURATION_MANAGER, name: string, ui_name: string?, ui_tooltip: string?) --> MCM_MOD
function mcm_mod.new(model, name, ui_name, ui_tooltip)
    local self = {}
    setmetatable(self, {
        __index = mcm_mod,
        __tostring = function() return "MCM_MOD" end
    }) --# assume self: MCM_MOD

    self._name = name
    self._model = model
    self._tweakers = {} --:map<string, MCM_TWEAKER>
    self._variables = {} --:map<string, MCM_VAR> 

    self._uiName = ui_name or "unnamed mod"
    self.uiToolTip = ui_tooltip or ""

    return self
end

--v function (model: MOD_CONFIGURATION_MANAGER) --> MCM_MOD
function mcm_mod.null(model)
    local self = {}
    setmetatable(self, {
        __index = mcm_mod,
        __tostring = function() return "NULL_SCRIPT_INTERFACE" end
    }) --# assume self: MCM_MOD
    self._name = ""
    self._model = model
    self._tweakers = {}
    self._variables = {}
    self._uiName = "NULL INTERFACE"
    self._uiToolTip = "NULL_INTERFACE"
    return self
end



--v function(self: MCM_MOD) --> string
function mcm_mod.name(self) 
    return self._name
end

--v function(self: MCM_MOD) --> MOD_CONFIGURATION_MANAGER
function mcm_mod.model(self)
    return self._model
end

--v function(self: MCM_MOD, text: any)
function mcm_mod.log(self, text)
    self:model():log(text)
end


local mcm_var = require("mcm/var_object")
local mcm_tweaker = require("mcm/tweaker_object")



--v function(self: MCM_MOD) --> map<string, MCM_TWEAKER>
function mcm_mod.tweakers(self)
    return self._tweakers
end

--v function(self: MCM_MOD)--> map<string, MCM_VAR>
function mcm_mod.variables(self)
    return self._variables
end

--v function(self: MCM_MOD, key: string) --> MCM_TWEAKER
function mcm_mod.get_tweaker_with_key(self, key)
    if self:tweakers()[key] == nil then
        self:log("ERROR: Asked for tweaker ["..key.."] which does not exist for the mod ["..self:name().."]")
        return mcm_tweaker.null(self)
    end
    return self:tweakers()[key]
end

--v function(self: MCM_MOD, key: string) --> MCM_VAR
function mcm_mod.get_variable_with_key(self, key)
    if self:variables()[key] == nil then
        self:log("ERROR: Asked for tweaker ["..key.."] which does not exist for the mod ["..self:name().."]")
        return mcm_var.null(self)
    end
    return self:variables()[key]
end



--v function(self: MCM_MOD, key: string, ui_name: string?, ui_tooltip: string?) --> MCM_TWEAKER
function mcm_mod.add_tweaker(self, key, ui_name, ui_tooltip)
    if not (is_string(key) and  (is_string(ui_name) or not ui_name) and (is_string(ui_tooltip) or not ui_tooltip)) then
        self:log("ERROR: attempted to create a new tweaker for mod ["..self:name().."], but a provided key, ui_name or ui_tooltip was not a string!")
        return mcm_tweaker.null(self)
    end
    if not not self:tweakers()[key] then
        self:log("WARNING: attempted to create a tweaker with key ["..key.."] for mod ["..self:name().."], but a tweaker with that key already exists! Returning the existing tweaker instead")
        return self:tweakers()[key]
    end

    local new_tweaker = mcm_tweaker.new(self, key, ui_name, ui_tooltip)
    self:tweakers()[key] = new_tweaker
    return self:tweakers()[key]
end

--v function(self: MCM_MOD, key: string, min: number, max: number, default: number, step: number, ui_name: string?, ui_tooltip: string?) --> MCM_VAR
function mcm_mod.add_variable(self, key, min, max, default, step, ui_name, ui_tooltip)
    if (ui_name and not is_string(ui_name)) or (ui_tooltip and not is_string(ui_tooltip)) or (not is_string(key)) then
        self:log("ERROR: attempted to create a new variable for mod ["..self:name().."], but a provided key, ui_name or ui_tooltip was not a string!")
        return mcm_var.null(self)
    end
    if not (is_number(min) and is_number(max) and is_number(default) and is_number(step)) then
        self:log("ERROR: attempted to create a new variable for mod ["..self:name().."], but a provided min, max, default, or step was not a number!")
        return mcm_var.null(self)
    end
    if not not self:variables()[key] then
        self:log("WARNING: attempted to create a variable with key ["..key.."] for mod ["..self:name().."], but a variable with that key already exists! Returning the existing variable instead")
        return self:variables()[key]
    end
    local new_variable = mcm_var.new(self, key, min, max, default, step, ui_name, ui_tooltip)
    self:variables()[key] = new_variable
    return self:variables()[key]
end



return {
    new = mcm_mod.new,
    null = mcm_mod.null
}