RECRUITMENT_CONTROLS_LOG = true --:boolean

--v function(text: string, ftext: string)
function RCLOG(text, ftext)
    --sometimes I use ftext as an arg of this function, but for simple mods like this one I don't need it.

    if not RECRUITMENT_CONTROLS_LOG then
      return; --if our bool isn't set true, we don't want to spam the end user with logs. 
    end

  local logText = tostring(text)
  local logContext = tostring(ftext)
  local logTimeStamp = os.date("%d, %m %Y %X")
  local popLog = io.open("RCLOG.txt","a")
  --# assume logTimeStamp: string
  popLog :write("WEC:  "..logText .. "    : [" .. logContext .. "] : [".. logTimeStamp .. "]\n")
  popLog :flush()
  popLog :close()
end

function RCREFRESHLOG()
    if not RECRUITMENT_CONTROLS_LOG then
        return;
    end

    local logTimeStamp = os.date("%d, %m %Y %X")
    --# assume logTimeStamp: string

    local popLog = io.open("RCLOG.txt","w+")
    popLog :write("NEW LOG ["..logTimeStamp.."] \n")
    popLog :flush()
    popLog :close()
end
RCREFRESHLOG()

--v function(msg: string)
function RCERROR(msg)
	local ast_line = "********************";
	
	-- do output
	print(ast_line);
	print("SCRIPT ERROR, timestamp " .. get_timestamp());
	print(msg);
	print("");
	print(debug.traceback("", 2));
	print(ast_line);
	-- assert(false, msg .. "\n" .. debug.traceback());
	
	-- logfile output
		local file = io.open("RCLOG.txt", "a");
		
		if file then
			file:write(ast_line .. "\n");
			file:write("SCRIPT ERROR, timestamp " .. get_timestamp() .. "\n");
			file:write(msg .. "\n");
			file:write("\n");
			file:write(debug.traceback("", 2) .. "\n");
			file:write(ast_line .. "\n");
			file:close();
		end;
end;


local rc = require("recruitment_controls/recruiter_character")

local RecruiterManager = {} --# assume rm: RECRUITER_MANAGER

--v function() --> RECRUITER_MANAGER
function RecruiterManager.Init()
    local self = {}
    setmetatable(self, {
        __index = RecruiterManager,
        __tostring = function() return "RECRUITER_MANAGER" end
    })
    --# assume self: RECRUITER_MANAGER

    self.Characters = {} --:map<CA_CQI, RECRUITER_CHARACTER>
    self.CurrentlySelectedCharacter = nil --:RECRUITER_CHARACTER
    self.RegionRestrictions = {} --:map<string, map<string, boolean>>
    self.UnitQuantityRestrictions = {} --:map<string, number>


    RCLOG("Init Complete, adding the manager to the Gamespace!", "RecruiterManager.Init()")
    _G.rm = self
    return self
end

--v function(self: RECRUITER_MANAGER, cqi: CA_CQI)
function RecruiterManager.CreateCharacter(self, cqi)
    local character = rc.Create(cqi)
    self.Characters[cqi] = character
    character:SetManager(self)
end

--v function(self: RECRUITER_MANAGER) --> map<CA_CQI, vector<string>>
function RecruiterManager.Save(self)
    local save_table = {} --:map<CA_CQI, vector<string>>
    for k, v in pairs(self.Characters) do
        if v:IsQueueEmpty() == false then
            cqi, queuetable = v:Save()
            save_table[cqi] = queuetable
        end
    end

    return save_table
end

--v function(self: RECRUITER_MANAGER, save_table: map<CA_CQI, vector<string>>)
function RecruiterManager.Load(self, save_table)
    for k, v in pairs(save_table) do
        local character = rc.Load(k, v)
        self.Characters[cqi] = character
        character:SetManager(self)
    end
end