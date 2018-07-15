local mcm_var = {}--# assume mcm_var: MCM_VAR

--v function(mod: MCM_MOD, name: string, min: number, max: number, default: number, step: number, ui_name: string?, ui_tooltip: string?) --> MCM_VAR
function mcm_var.new(mod, name, min, max, default, step, ui_name, ui_tooltip)
    local self = {}
    setmetatable(self, {
        __index = mcm_var,
        __tostring = function() return "MCM_VAR" end
    }) --# assume self: MCM_VAR

    self._mod = mod
    self._name = name
    self._minValue = min
    self._maxValue = max
    self._stepValue = step
    self._uiName = ui_name
    self._uiToolTip = ui_tooltip

    self._currentValue = default
    

    return self
end

--v function(mod: MCM_MOD) --> MCM_VAR
function mcm_var.null(mod)
    local self = {}
    setmetatable(self, {
        __index = mcm_var,
        __tostring = function() return "NULL_SCRIPT_INTERFACE" end
    }) --# assume self: MCM_VAR

    self._mod = mod
    self._name = ""
    self._minValue = 0
    self._maxValue = 0
    self._currentValue = 0
    self._stepValue = 0
    self._uiName = ""
    self._uiToolTip = ""
    self._callback = nil --:function(mcm: MOD_CONFIGURATION_MANAGER)
    return self
end


--v function(self: MCM_VAR) --> boolean
function mcm_var.is_null_interface(self)
    return tostring(self) == "NULL_SCRIPT_INTERFACE"
end

--v function(self: MCM_VAR) --> string
function mcm_var.name(self)
    return self._name
end

--v function(self: MCM_VAR) --> MCM_MOD
function mcm_var.mod(self)
    return self._mod
end

--v function(self: MCM_VAR, text: any)
function mcm_var.log(self, text)
    self:mod():log(text)
end
    


--v function(self: MCM_VAR) --> number
function mcm_var.current_value(self)
    return self._currentValue
end

--v function(self: MCM_VAR) --> number
function mcm_var.maximum(self)
    return self._maxValue
end

--v function(self: MCM_VAR) --> number
function mcm_var.minimum(self)
    return self._minValue
end

--v function(self: MCM_VAR) --> boolean
function mcm_var.at_max(self)
    return self._currentValue == self:maximum()
end

--v function(self: MCM_VAR) --> boolean
function mcm_var.at_min(self)
    return self._currentValue == self:minimum()
end



--v function(self: MCM_VAR, value: number)
function mcm_var.set_current_value(self, value)
    self:log("Set the value of var ["..self:name().."] in mod ["..self:mod():name().."] to ["..value.."]")
    if value > self:maximum() then
        value = self:maximum()
        self:log("value was over the maximum, lowered it!")
    elseif value < self:minimum() then
        value = self:minimum()
        self:log("value was under the minimum, raised it!")
    end
    self._currentValue = value
end

--v function(self: MCM_VAR) --> number
function mcm_var.step(self)
    return self._stepValue
end




--v function(self: MCM_VAR)
function mcm_var.increment_value(self)
    self:set_current_value(self:current_value() + self:step())
end

--v function(self: MCM_VAR)
function mcm_var.decrement_value(self)
    self:set_current_value(self:current_value() - self:step())
end

--v function(self: MCM_VAR) --> function(mcm: MOD_CONFIGURATION_MANAGER)
function mcm_var.callback(self)
    return self._callback
end

--v function(self: MCM_VAR) --> boolean
function mcm_var.has_callback(self)
    return not not self:callback()
end

--v function(self: MCM_VAR, callback: function(mcm: MOD_CONFIGURATION_MANAGER))
function mcm_var.add_callback(self, callback)
    self:log("added callback to variable ["..self:name().."] ")
    self._callback = callback
end

--v function(self: MCM_VAR, text: string)
function mcm_var.set_ui_name(self, text)
    self._uiName = text
end

--v function(self: MCM_VAR, text: string)
function mcm_var.set_ui_tooltip(self, text)
    self._uiToolTip = text
end

--v function(self: MCM_VAR) --> string
function mcm_var.ui_name(self)
    return self._uiName
end

--v function (self: MCM_VAR) --> string
function mcm_var.ui_tooltip(self)
    return self._uiToolTip
end


return {
    new = mcm_var.new,
    null = mcm_var.null
}