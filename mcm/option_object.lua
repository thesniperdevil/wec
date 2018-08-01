local mcm_option = {} --# assume mcm_option: MCM_OPTION

--v function(tweaker: MCM_TWEAKER, key: string, ui_name: string?, ui_tooltip: string?) --> MCM_OPTION
function mcm_option.new(tweaker, key, ui_name, ui_tooltip)
    local self = {}
    setmetatable(self, {
        __index = mcm_option,
        __tostring = function() return "MCM_OPTION" end
    }) --# assume self: MCM_OPTION
    self._tweaker = tweaker
    self._name = key
    self._uiName = ui_name or "Unnamed Option"
    self._uiToolTip = ui_tooltip or ""
    self._callback = nil --: function(context: MOD_CONFIGURATION_MANAGER)
    return self

end

--v function(tweaker: MCM_TWEAKER) --> MCM_OPTION
function mcm_option.null(tweaker)
    local self = {}
    setmetatable(self, {
        __index = mcm_option,
        __tostring = function() return "NULL_SCRIPT_INTERFACE" end
    }) --# assume self: MCM_OPTION
    self._tweaker = tweaker
    self._name = "NULL_OPTION"
    self._uiName = ""
    self._uiToolTip = ""
    return self
end

--v function(self: MCM_OPTION) --> boolean
function mcm_option.is_null_interface(self)
    return tostring(self) == "NULL_SCRIPT_INTERFACE"
end

--v function(self: MCM_OPTION) --> string
function mcm_option.name(self)
    return self._name
end

--v function(self: MCM_OPTION) --> MCM_TWEAKER
function mcm_option.tweaker(self)
    return self._tweaker
end

--v function(self: MCM_OPTION, text: any)
function mcm_option.log(self, text)
    self:tweaker():log(text)
end

--v function(self: MCM_OPTION) --> function(context: MOD_CONFIGURATION_MANAGER)
function mcm_option.callback(self)
    return self._callback
end


--v function(self: MCM_OPTION) --> boolean
function mcm_option.has_callback(self)
    return not not self:callback()
end

--v function(self: MCM_OPTION, callback: function(context: MOD_CONFIGURATION_MANAGER))
function mcm_option.add_callback(self, callback)
    self:log("added callback to option ["..self:name().."] ")
    self._callback = callback
end


--v function(self: MCM_OPTION, text: string)
function mcm_option.set_ui_name(self, text)
    self._uiName = text
end

--v function(self: MCM_OPTION, text: string)
function mcm_option.set_ui_tooltip(self, text)
    self._uiToolTip = text
end

--v function(self: MCM_OPTION) --> string
function mcm_option.ui_name(self)
    return self._uiName
end

--v function (self: MCM_OPTION) --> string
function mcm_option.ui_tooltip(self)
    return self._uiToolTip
end






return {
    new = mcm_option.new,
    null = mcm_option.null
}