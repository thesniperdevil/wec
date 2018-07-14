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



return {
    new = mcm_tweaker.new,
    null = mcm_tweaker.null
}