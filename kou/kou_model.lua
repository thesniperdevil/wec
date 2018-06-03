
local kou_model = {} --# assume kou_model: KOU_MODEL

--v function(info: map<string, number>, high_elven_humans: vector<string>) --> KOU_MODEL
function kou_model.new(info, high_elven_humans)
    local self = {}
    setmetatable(self, {
        __index = kou_model
    })
    --# assume self: KOU_MODEL

    self.favour_table = info 





    _G.kou = self
    return self
end
