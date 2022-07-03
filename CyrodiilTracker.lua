CyroTracker = CyroTracker or {}
CyroTracker.title = "|cFF860DCyrodiiltracker|cD5D502"
CyroTracker.addonName = "CyrodiilTracker"
CyroTracker.updateInterval = 500 -- in ms
CyroTracker.last_worldX = 0
CyroTracker.last_worldY = 0
CyroTracker.leaderTag = nil
CyroTracker.keepRow1     = "OFFLINERS_"
CyroTracker.keepRow2     = "_POSITION_"
CyroTracker.outpostRow1  = "__SYSTEM__"
CyroTracker.crownRow1    = "0000000000"


CyroTracker.constants = {}

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
		zo_callLater( function() CyroTracker.EncounterTracker.Initialize() end, 500 )

		EVENT_MANAGER:UnregisterForEvent(CyroTracker.addonName, EVENT_ADD_ON_LOADED)
	end
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
		CyroTracker.Message(CyroTracker.EncounterTracker.IsTime())
		CyroTracker.Message(CyroTracker.EncounterTracker.IsDate())
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
		return
	end
	
	local _x, _y, heading, isShownInCurrentMap = GetMapPlayerPosition(unitID)
	local zoneId, worldX, worldZ, worldY = GetUnitWorldPosition(unitID)
	
	if (CyroTracker.last_worldX == worldX and CyroTracker.last_worldY == worldY) then return end

	CyroTracker.last_worldX = worldX
	CyroTracker.last_worldY = worldY

	local result=""
	if ( worldX ~= nil ) then
	   result = result..string.format("%04d", zo_round(worldX/100))
	end

	if ( worldY ~= nil ) then
	   result = result..string.format("%04d", zo_round(worldY/100))
	end

	CyroTracker.crownRow1 = string.format("%010d", result)
	
	CyroTracker.WriteForExport()

end

function CyroTracker.WriteForExport()
	local resultText = ""
	resultText = resultText..CyroTracker.keepRow1.."\n"
	resultText = resultText..CyroTracker.keepRow2.."\n"
	resultText = resultText..CyroTracker.outpostRow1.."\n"
	resultText = resultText..CyroTracker.crownRow1
	
	CyrodiilTrackerUI_lblPosition:SetText(resultText)
end
