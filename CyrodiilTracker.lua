CyroTracker = CyroTracker or {}
CyroTracker.addonName = "CrownTracker"
CyroTracker.stopped = true
CyroTracker.debug = false
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

		CyroTracker.WriteForExport()

		EVENT_MANAGER:UnregisterForEvent(CyroTracker.addonName, EVENT_ADD_ON_LOADED)

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
	elseif text == "player" then
		CyroTracker.debug = true
		CyroTracker.leaderTag = "player"
	elseif text == "stop" then
		CyroTracker.stopped = true
		CyroTracker.crownRow1    = "0000000000"
		CyroTracker.keepRow1     = "0000000000"
		CyroTracker.keepRow2     = "0000000000"
		CyroTracker.outpostRow1  = "0000000000"
		CyroTracker.WriteForExport()
	elseif text == "start" then
		CyroTracker.debug = false
		CyroTracker.stopped = false
		CyroTracker.OnUpdateLeader()
	else
		d("CrownTracker doesn't know command: "..text)
		d("available args: Start | Stop | Player | Lock | Unlock ")
	end
end

function CyroTracker.SetLeaderUnitTag()
	if CyroTracker.debug == true then
		CyroTracker.leaderTag = "player"
	end
	
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
		CyroTracker.leaderTag = nil
	end
end

function CyroTracker.OnUpdateLeader()
	CyroTracker.SetLeaderUnitTag()
end

function CyroTracker.OnUpdate()
	local unitID = CyroTracker.leaderTag

	if CyroTracker.leaderTag == nil or CyroTracker.stopped == false then
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