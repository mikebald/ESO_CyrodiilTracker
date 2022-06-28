CyroTracker = CyroTracker or {}
CyroTracker.addonName = "CyrodiilTracker"
CyroTracker.updateInterval = 500 -- in ms
CyroTracker.last_worldX = 0
CyroTracker.last_worldY = 0
CyroTracker.leaderTag = nil
CyroTracker.keepRow1     = "OFFLINERS_"
CyroTracker.keepRow2     = "_POSITION_"
CyroTracker.outpostRow1  = "__SYSTEM__"
CyroTracker.crownRow1    = "0000000000"

CyroTracker.vars = {}
CyroTracker.vars.offSetX = 0
CyroTracker.vars.offSetY = 0
CyroTracker.vars.point = TOPLEFT
CyroTracker.vars.relativePoint = TOPLEFT
CyroTracker.vars.moveable = true

CyroTracker.constants = {}

function CyroTracker.OnAddOnLoaded( eventCode, addOnName )
	if addOnName == CyroTracker.addonName then

		local accountSavedVars = ZO_SavedVars:NewAccountWide(CyroTracker.addonName, 1, nil, CyroTracker.vars)

		if accountSavedVars ~= nil then
			CyroTracker.vars = accountSavedVars
		end

		CyrodiilTrackerUI:ClearAnchors()
		CyrodiilTrackerUI:SetAnchor(CyroTracker.vars.point,
			nil,
			CyroTracker.vars.relativePoint,
			CyroTracker.vars.offSetX,
			CyroTracker.vars.offSetY
		)
		
		CyrodiilTrackerUI:SetMovable(CyroTracker.vars.moveable)

		CyrodiilTrackerUI:SetClampedToScreen(true)
		CyrodiilTrackerUI:SetResizeToFitDescendents(true)
		CyrodiilTrackerUI:SetMouseEnabled(true)
		CyrodiilTrackerUI:SetHidden(false)
		
		CyrodiilTrackerUI:SetHandler("OnMoveStop", CyroTracker.OnMoveStop)
		CyrodiilTrackerUI:SetHandler("OnUpdate",   CyroTracker.OnUpdate)
		
		EVENT_MANAGER:RegisterForEvent(CyroTracker.addonName, EVENT_LEADER_UPDATE, CyroTracker.OnUpdateLeader)
		EVENT_MANAGER:RegisterForEvent(CyroTracker.addonName, EVENT_GROUP_UPDATE, CyroTracker.OnUpdateLeader)
		EVENT_MANAGER:RegisterForEvent(CyroTracker.addonName, EVENT_GROUP_MEMBER_JOINED, CyroTracker.OnUpdateLeader)
		EVENT_MANAGER:RegisterForEvent(CyroTracker.addonName, EVENT_GROUP_MEMBER_LEFT, CyroTracker.OnUpdateLeader)
		EVENT_MANAGER:RegisterForEvent(CyroTracker.addonName, EVENT_GROUP_MEMBER_CONNECTED_STATUS, CyroTracker.OnUpdateLeader)

		--EVENT_MANAGER:RegisterForUpdate(CyroTracker.addonName, CyroTracker.updateInterval, CyroTracker.OnUpdate)

		CyroTracker.WriteForExport()
		EVENT_MANAGER:UnregisterForEvent(CyroTracker.addonName, EVENT_ADD_ON_LOADED)
		zo_callLater( function() d(CyroTracker.addonName..": Loaded") end )
	end
end

EVENT_MANAGER:RegisterForEvent(CyroTracker.addonName, EVENT_ADD_ON_LOADED, CyroTracker.OnAddOnLoaded)

SLASH_COMMANDS["/ct"] = function(text)
	text = string.lower(text)
	if text == "lock" then
		CyroTracker.vars.moveable = false
		CyrodiilTrackerUI:SetMovable(false)
	elseif text == "unlock" then
		CyroTracker.vars.moveable = true
		CyrodiilTrackerUI:SetMovable(true)
	elseif text == "reload" then
		CyroTracker.OnUpdateLeader()
	else
		d(CyroTracker.addonName.." doesn't know command: "..text)
		d(" - Available args: Lock | Unlock | Reload ")
	end
end


function CyroTracker.OnUpdateLeader()
	local groupSize = GetGroupSize()

	if groupSize > 0 then
		for i = 1, groupSize do
			local unitTag = GetGroupUnitTagByIndex(i)
			if IsUnitGroupLeader(unitTag) then
				CyroTracker.leaderTag = unitTag
				d("Loaded new leader "..GetUnitDisplayName(unitTag))
				return
			end
		end
	else
		CyroTracker.leaderTag = "player"
		d("Loaded new Leader "..GetUnitDisplayName(CyroTracker.leaderTag))
	end
end

function CyroTracker.OnUpdate()
	local unitID = CyroTracker.leaderTag

	if CyroTracker.leaderTag == nil then
		return
	end
	
	-- cyrodiil map 181
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

function CyroTracker.OnMoveStop(self)
		local validAnchor,point,relativeTo, relativePoint, offSetX, offSetY = self:GetAnchor()
		
		if validAnchor then
			CyroTracker.vars.offSetX = offSetX
			CyroTracker.vars.offSetY = offSetY
			CyroTracker.vars.point 		= point
			CyroTracker.vars.relativePoint = relativePoint
		end
end