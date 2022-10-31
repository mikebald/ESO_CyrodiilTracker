CyroTracker = CyroTracker or {}

local Util = CyroTracker.Util
local libGPS = LibGPS2

CyroTracker.title = "|cFF860DCyrodiiltracker|cD5D502"
CyroTracker.addonName = "CyrodiilTracker"
CyroTracker.updateInterval = 500 -- in ms
CyroTracker.worldX = "___"
CyroTracker.worldY = "___"
CyroTracker.leaderTag = nil
CyroTracker.keepRow1     = "__________"
CyroTracker.keepRow2     = "__________"
CyroTracker.scrollRow1   = "__________"
CyroTracker.crownRow1    = "__________"

CyroTracker.CrownOutput = "0000"
CyroTracker.ScrollOutput1 = "00000" -- 2 Scrolls on Crown Row

-- Tracking Crown to 3 digits resolution vs 4 digits

function CyroTracker.Message( message )
	CHAT_ROUTER:AddSystemMessage(string.format(
		"[%s]: %s", CyroTracker.title, 
		tostring(message)
	))
end

function CyroTracker.OnAddOnLoaded( eventCode, addOnName )
	if addOnName == CyroTracker.addonName then

		EVENT_MANAGER:RegisterForEvent(CyroTracker.addonName, EVENT_LEADER_UPDATE, CyroTracker.OnUpdateLeader)
		--EVENT_MANAGER:RegisterForUpdate(CyroTracker.addonName, CyroTracker.updateInterval, CyroTracker.OnUpdate)
		
		CyroTracker.WriteForExport()
		zo_callLater( function() CyroTracker.Message("Loaded") end, 100 )
		zo_callLater( function() CyroTracker.InitializeChildren() end, 500 )

		EVENT_MANAGER:UnregisterForEvent(CyroTracker.addonName, EVENT_ADD_ON_LOADED)
	end
end

function CyroTracker.InitializeChildren()
	CyroTracker.EncounterTracker.Initialize()
	CyroTracker.KeepTracker.Initialize()
end

EVENT_MANAGER:RegisterForEvent(CyroTracker.addonName, EVENT_ADD_ON_LOADED, CyroTracker.OnAddOnLoaded)

SLASH_COMMANDS["/ct"] = function(text)
	text = string.lower(text)
	if text == "reload" then
		CyroTracker.OnUpdateLeader()
		CyroTracker.EncounterTracker.Status()
	elseif text == "log" then
		CyroTracker.EncounterTracker.Toggle()
	elseif text == "test" then
		CyroTracker.KeepTracker.DebugOutput()
	elseif text == "testall" then
		CyroTracker.KeepTracker.DebugAll()
	elseif text == "scroll" then
		local _, X, Y = GetObjectivePinInfo(119, 137, 1) -- Mnem
		CyroTracker.Message("X: ".. tostring(X * 100) .. " Y:" .. tostring(Y * 100))
	else
		CyroTracker.Message("Available args: Log | Reload")
	end
end


function CyroTracker.OnUpdateLeader()
	local groupSize = GetGroupSize()

	if groupSize > 0 then
		for i = 1, groupSize do
			local unitTag = GetGroupUnitTagByIndex(i)
			if IsUnitGroupLeader(unitTag) then
				if unitTag ~= CyroTracker.leaderTag then
					CyroTracker.Message("Loaded new leader "..GetUnitDisplayName(unitTag))
					CyroTracker.leaderTag = unitTag
				end
				return
			end
		end
	else
		CyroTracker.leaderTag = "player"
		CyroTracker.Message("Loaded new Leader "..GetUnitDisplayName(CyroTracker.leaderTag))
	end
end

function CyroTracker.OnUpdate()
	local unitID = CyroTracker.leaderTag

	if CyroTracker.leaderTag == nil then
		CyroTracker.CrownOutput = "0000"
	else
		local unitX, unitY = Util.GetUnitPosition(CyroTracker.leaderTag)
		local compressedOutput = Util.BaseConverter(unitX .. unitY)
		CyroTracker.CrownOutput = Util.LeftPad(compressedOutput, 4, "_");
	end
	
	CyroTracker.WriteForExport()
end

function CyroTracker.WriteForExport()
	local resultText = ""
	
	CyroTracker.crownRow1 = Util.ReplaceStr(6, CyroTracker.crownRow1, CyroTracker.CrownOutput)
	CyroTracker.crownRow1 = Util.ReplaceStr(0, CyroTracker.crownRow1, CyroTracker.ScrollOutput1)

	resultText = resultText..CyroTracker.keepRow1.."\n"
	resultText = resultText..CyroTracker.keepRow2.."\n"
	resultText = resultText..CyroTracker.scrollRow1.."\n"
	resultText = resultText..CyroTracker.crownRow1
	
	CyrodiilTrackerUI_lblPosition:SetText(resultText)
end
