--logging


wec_ci_log = true;

function WEC_REFRESH_LOG()
    if not wec_ci_log then
        return;
    end
    
    local logTimeStamp = os.date("%d, %m %Y %X")
    --# assume logTimeStamp: string
    
    local popLog = io.open("WEC_LOG.txt","w+")
    popLog :write("NEW LOG ["..logTimeStamp.."] \n")
    popLog :flush()
    popLog :close()
end

--v function(text: string, ftext: string)
function CILOG(text, ftext)
    --sometimes I use ftext as an arg of this function, but for simple mods like this one I don't need it.

    if not wec_ci_log then
      return; --if our bool isn't set true, we don't want to spam the end user with logs. 
    end

  local logText = tostring(text)
  local logContext = tostring(ftext)
  local logTimeStamp = os.date("%d, %m %Y %X")
  local popLog = io.open("WEC_LOG.txt","a")
  --# assume logTimeStamp: string
  popLog :write("WEC:  "..logText .. "    : [" .. logContext .. "] : [".. logTimeStamp .. "]\n")
  popLog :flush()
  popLog :close()
end

--v function(textvector: vector<string>, ftext: string)
function CIVECTORLOG(textvector, ftext)
    --sometimes I use ftext as an arg of this function, but for simple mods like this one I don't need it.

    if not wec_ci_log then
      return; --if our bool isn't set true, we don't want to spam the end user with logs. 
	end
	
	local logContext = tostring(ftext)
	local logTimeStamp = os.date("%d, %m %Y %X")
	local popLog = io.open("WEC_LOG.txt","a")
	for i = 1, #textvector do 
		local text = textvector[i]
		local logText = tostring(text)
		
		--# assume logTimeStamp: string
		popLog :write("WEC:  "..logText .. "    : [" .. logContext .. "] : [".. logTimeStamp .. "]\n")
	end
	popLog :flush()
	popLog :close()
end



WEC_REFRESH_LOG()

-------script start.















chaos_invasion_manager = {} --# assume chaos_invasion_manager: CIM


--v function() --> CIM
function chaos_invasion_manager.new()
	local self = {};
	setmetatable(self, {
		__index = chaos_invasion_manager
	})
	--# assume self: CIM


	self.difficulty = cm:model():combined_difficulty_level();
	self.base_armies = 4 + self.difficulty
	self.num_armies = self.base_armies
	if cm:get_saved_value("cim_stage") == nil then
		self.stage = 0
	else
		self.stage = cm:get_saved_value("cim_stage")
	end 
	self.stage_callbacks = {} --: map<string, function>
	self.leader_armies = {} --:vector<string>
	self.minion_armies = {} --:vector<string>
	self.leader_exp = nil --:vector<number>
	self.minion_exp = nil --:vector<number>
	self.timeouts = {} --:map<number, number>
	self.imperium_triggers = {} --:map<number, number>
	self.context_triggers = {} --:map<number, function(context: WHATEVER) --> boolean>

	_G.cim = self

	return self


end







---invasions

local chaos_invasion_point = {} --# assume chaos_invasion_point: CIP

--v function(cim: CIM, area: {c1: number, c2: number, c3: number, c4: number}, size_modifier: number, stage: number, channel: number, faction: string, respawns: number?) --> CIP
function chaos_invasion_point.new(cim, area, size_modifier, stage, channel, faction, respawns)
	local self = {}
	setmetatable(self, {
		__index = chaos_invasion_point
	})
	--# assume self: CIP

	self.manager = cim
	self.area = area
	self.size_modifier = size_modifier
	self.stage = stage
	self.channel = channel
	self.faction = faction
	self.override_leader_army = false --: boolean
	self.override_minion_army = false --: boolean
	self.override_leader_exp = false --: boolean
	self.override_minion_exp = false --: boolean
	self.has_leader_character = false --: boolean

	self.leader_armies = {} --:vector<string>
	self.minion_armies = {} --:vector<string>
	self.leader_exp = nil --:number
	self.minion_exp = nil --:number
	self.leader_character = nil --:{subtype: string, forename: string, surname: string?}

	return self
end

--v function(self: CIP) --> CIM
function chaos_invasion_point.cim(self)
	return self.manager
end

--v function(self: CIP, leader_armies: vector<string>)
function chaos_invasion_point.set_leader_army_override(self, leader_armies)
	CILOG("Adding a leader army override for the invasion point at stage ["..tostring(self.stage).."] and channel ["..self.channel.."]", "chaos_invasion_point.set_leader_army_override(self, leader_armies)")
	CIVECTORLOG(leader_armies, "chaos_invasion_point.set_leader_army_override(self, leader_armies)")
	self.override_leader_army = true;
	self.leader_armies = leader_armies
end

--v function(self: CIP, minion_armies: vector<string>)
function chaos_invasion_point.set_minion_army_override(self, minion_armies)
	CILOG("Adding a minion army override for the invasion point at stage ["..tostring(self.stage).."] and channel ["..self.channel.."]", "chaos_invasion_point.set_minion_army_override(self, minion_armies)")
	CIVECTORLOG(minion_armies, "chaos_invasion_point.set_minion_army_override(self, minion_armies)")
	self.override_minion_army = true;
	self.minion_armies = minion_armies
end

--v function(self: CIP, exp: number)
function chaos_invasion_point.set_minion_exp_override(self, exp)
	CILOG("Adding minion exp override for the invasion point at stage ["..tostring(self.stage).."] and channel ["..self.channel.."]", "chaos_invasion_point.set_minion_exp_override(self, exp)")
	self.override_minion_exp = true
	self.minion_exp = exp
end

--v function(self: CIP, exp: number)
function chaos_invasion_point.set_leader_exp_override(self, exp)
	CILOG("Adding leader exp override for the invasion point at stage ["..tostring(self.stage).."] and channel ["..self.channel.."]", "chaos_invasion_point.set_leader_exp_override(self, exp)")
	self.override_leader_exp = true
	self.leader_exp = exp
end

--v function(self: CIP, character: {subtype: string, forename: string, surname: string?})
function chaos_invasion_point.set_leader_character(self, character)
	self.has_leader_character = true
	self.leader_character = character
end


