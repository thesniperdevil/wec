local mcm_tweaker = {} --# assume mcm_tweaker: MCM_TWEAKER

--v function(mod: MCM_MOD, name: string, ui_title: string?, ui_tooltip: string?) --> MCM_TWEAKER
function mcm_tweaker.new(mod, name, ui_title, ui_tooltip)
    local self = {}
    setmetatable(self, {
        __index = mcm_tweaker,
        __tostring =  function() return "MCM_TWEAKER" end
    })--# assume self: MCM_TWEAKER
    self._mod = mod
    self._name = name
    self._uiTitle = ui_title or "Un-named tweaker"
    self._uiToolTip = ui_tooltip or ""

    return self
end

--v function(mod: MCM_MOD) --> MCM_TWEAKER
function mcm_tweaker.null(mod)
    local self = {}
    setmetatable(self, {
        __index = mcm_tweaker,
        __tostring =  function() return "NULL_SCRIPT_INTERFACE" end
    })--# assume self: MCM_TWEAKER
    self._mod = mod
    self._name = ""
    self._uiTitle = ""
    self._uiToolTip = ""

    self._options = {} --:map<string, MCM_OPTION>
    self._selectedOption = nil --:MCM_OPTION

    return self
end





--v function(self: MCM_TWEAKER) --> boolean
function mcm_tweaker.is_null_interface(self)
    return tostring(self) == "NULL_SCRIPT_INTERFACE"
end

--v function(self: MCM_TWEAKER) --> MCM_MOD
function mcm_tweaker.mod(self)
    return self._mod
end

--v function(self: MCM_TWEAKER) --> string
function mcm_tweaker.name(self)
    return self._name
end

--v function(self: MCM_TWEAKER, text: any)
function mcm_tweaker.log(self, text)
    self:mod():log(text)
end


local mcm_option = require("mcm/option_object")


--v function(self: MCM_TWEAKER, option: MCM_OPTION)
function mcm_tweaker.set_selected_option(self, option)
    self._selectedOption = option
end


--v function(self: MCM_TWEAKER) --> MCM_OPTION
function mcm_tweaker.selected_option(self)
    return self._selectedOption
end



--v function(self: MCM_TWEAKER) --> map<string, MCM_OPTION>
function mcm_tweaker.options(self)
    return self._options
end

--v function(self: MCM_TWEAKER, key: string) --> MCM_OPTION
function mcm_tweaker.get_option_with_key(self, key)
    if self:options()[key] == nil then
        self:log("ERROR: Asked for option ["..key.."] which does not exist for the tweaker ["..self:name().."] in the mod ["..self:mod():name().."] ")
        return mcm_option.null(self)
    end
    return self:options()[key]
end




--v function(self: MCM_TWEAKER, key: string, ui_name: string?, ui_tooltip: string?) --> MCM_OPTION
function mcm_tweaker.add_option(self, key, ui_name, ui_tooltip)
    if not (is_string(key) and  (is_string(ui_name) or not ui_name) and (is_string(ui_tooltip) or not ui_tooltip)) then
        self:log("ERROR: attempted to create a new option for tweaker ["..self:name().."] in mod ["..self:mod():name().."], but a provided key, ui_name or ui_tooltip was not a string!")
        return mcm_option.null(self)
    end
    if not not self:options()[key] then
        self:log("WARNING: attempted to create an option with key ["..key.."] for tweaker ["..self:name().."] in mod ["..self:mod():name().."], but an option with that key already exists! Returning the existing option instead")
        return self:options()[key]
    end

    local new_option = mcm_option.new(self, key, ui_name, ui_tooltip)
    self:options()[key] = new_option
    self:log("Created Option with key ["..key.."] for tweaker ["..self:name().."] in mod ["..self:mod():name().."]")
    if self:selected_option() == nil then
        self:set_selected_option(new_option)
        self:log("Created Option is the first option for this tweaker, setting it to be the default!")
    end
    return self:options()[key]
end

--v function(self: MCM_TWEAKER, text: string)
function mcm_tweaker.set_ui_name(self, text)
    self._uiName = text
end

--v function(self: MCM_TWEAKER, text: string)
function mcm_tweaker.set_ui_tooltip(self, text)
    self._uiToolTip = text
end

--v function(self: MCM_TWEAKER) --> string
function mcm_tweaker.ui_name(self)
    return self._uiName
end

--v function (self: MCM_TWEAKER) --> string
function mcm_tweaker.ui_tooltip(self)
    return self._uiToolTip
end
    
    




return {
    new = mcm_tweaker.new,
    null = mcm_tweaker.null
}