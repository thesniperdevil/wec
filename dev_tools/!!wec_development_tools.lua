core:add_ui_created_callback( function()
end)


local dev_tool_manager = {} --# assume dev_tool_manager: DEV_TOOL_MANAGER

function dev_tool_manager.init()
    local self = {}
    setmetatable(self, {
        __index = dev_tool_manager
    }) --# assume self: DEV_TOOL_MANAGER
    --uic
    self.ComponentsPanel = nil --:FRAME
    self.ComponentParentsPanel = nil --:FRAME
    self.ComponentChildrenPanel = nil --:FRAME
    self.LogPanel = nil --:FRAME
    self.ComponentsPanelName = "dtm_components_tracker"
    self.ComponentParentsPanelName = "dtm_component_ancestry"
    self.ComponentChildrenPanelName = "dtm_component_tree"


    --component viewer
    self._lastHoveredComponent = nil --:CA_UIC
    self._lastHoveredId = "No component hovered yet" --:string
    self._lastClickedComponent = nil --:CA_UIC
    self._lastClickedId = "No component clicked yet" --: string

    --log 
    self._logLines = {} --:vector<string>
    self._logVerb = 1 --: number
    self._logContext = "No Context Set" --:string
    self._logTitle = "WEC_DEV_TOOL_LOG.txt"

    _G.modder_dev_tool = self
    _G.dtm = self
end

--UIC TRACKER

--v function(self: DEV_TOOL_MANAGER) --> CA_UIC
function dev_tool_manager.last_hovered_component(self)
    return self._lastHoveredComponent
end


--v function(self: DEV_TOOL_MANAGER) --> CA_UIC
function dev_tool_manager.last_clicked_component(self)
    return self._lastClickedComponent
end


--v function(self: DEV_TOOL_MANAGER, component: CA_UIC)
function dev_tool_manager.set_hovered_component(self, component)
    self._lastHoveredComponent = component
end

--v function(self: DEV_TOOL_MANAGER, component: CA_UIC)
function dev_tool_manager.set_clicked_component(self, component)
    self._lastClickedComponent = component
end

--v function(self: DEV_TOOL_MANAGER) --> string
function dev_tool_manager.last_hovered_id(self)
    return self._lastHoveredId
end


--v function(self: DEV_TOOL_MANAGER) --> string
function dev_tool_manager.last_clicked_id(self)
    return self._lastClickedId
end


--v function(self: DEV_TOOL_MANAGER, id: string)
function dev_tool_manager.set_hovered_id(self, id)
    self._lastHoveredId = id
end

--v function(self: DEV_TOOL_MANAGER, id: string)
function dev_tool_manager.set_clicked_id(self, id)
    self._lastClickedId = id
end

--v function(self: DEV_TOOL_MANAGER)
function dev_tool_manager.track_uic(self)
    core:add_listener(
        "DEVTOOLSUICLICKED",
        "ComponentLClickUp",
        true,
        function(context)
            local component = UIComponent(context.component)
            self:set_clicked_component(component)
            self:set_clicked_id(component:Id())
        end,
        true)

    core:add_listener(
        "DEVTOOLSUIHOVER",
        "ComponentMouseOn",
        true,
        function(context)
            local component = UIComponent(context.component)
            self:set_hovered_component(component)
            self:set_hovered_id(component:Id())
        end,
        true)
end

--UIC TRACKER ADDITIONAL FUNCTIONS



--UIC_TRACKER MAIN UI

--v function(self: DEV_TOOL_MANAGER)
function dev_tool_manager.show_uic_tracker(self)
    local existingView = Util.getComponentWithName(self.ComponentsPanelName)
    if not existingView then
        local ScreenX, ScreenY = core:get_screen_resolution()
        ComponentsFrame = Frame.new(self.ComponentsPanelName)
        self.ComponentsPanel = ComponentsFrame
        ComponentsFrame:Resize((ScreenX/3), (ScreenY/8))
        ComponentsFrame:MoveTo(ScreenX/4, ScreenY/4)

    else

    end
end
