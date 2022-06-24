local CrownTracker = {
	name = "CrownTracker",
	last_worldX = 0,
	last_worldY = 0,
	leaderTag = nil,
	debug = false
}
CrownTrackerSavedVars = {
		offSetX = 0,
		offSetY = 0,
		point = TOPLEFT,
		relativePoint = TOPLEFT,
		moveable = true,
		alpha = 0,
}


function CrownTrackerReset()
	CrownTrackerUI:ClearAnchors()
	CrownTrackerUI:SetAnchor(TOPLEFT,GuiRoot,TOPLEFT,0,0)
	CrownTrackerUnlock()
	d("reseted")
end


function CrownTrackerOnAddOnLoaded( eventCode, addOnName )
	if ( addOnName ~= CrownTracker.name ) then return end
	
	EVENT_MANAGER:UnregisterForEvent(CrownTracker.name, EVENT_ADD_ON_LOADED)
	
    local accountSavedVars = ZO_SavedVars:NewAccountWide(CrownTracker.name, 1, nil, CrownTrackerSavedVars)

    if accountSavedVars ~= nil then
        CrownTrackerSavedVars = accountSavedVars
    end
	
--[[
SetAnchor
AnchorPosition  	point	The position of the anchor on the control that is set.
object				anchorTargetControl  	The control this control shall anchor to.
AnchorPosition  	relativePoint	The position of the anchor on the anchorTargetControl.
number				offsetX	The horizontal offset relative to the point position.
number				offsetY	The vertical offset relative to the point position.
]]--


	CrownTrackerUI:ClearAnchors()
	CrownTrackerUI:SetAnchor(CrownTrackerSavedVars.point,
	nil,
	CrownTrackerSavedVars.relativePoint,
	CrownTrackerSavedVars.offSetX,
	CrownTrackerSavedVars.offSetY)
	
	CrownTrackerUI:SetMovable(CrownTrackerSavedVars.moveable)
	CrownTrackerUI_Backdrop:SetAlpha(CrownTrackerSavedVars.alpha)

	
	CrownTrackerUI:SetClampedToScreen(true)
    CrownTrackerUI:SetResizeToFitDescendents(true)
    CrownTrackerUI:SetMouseEnabled(true)
    CrownTrackerUI:SetHidden(false)
	
	
    
	CrownTrackerUI:SetHandler("OnMoveStop", CrownTrackerOnMoveStop)
	CrownTrackerUI:SetHandler("OnUpdate",   CrownTrackerOnUpdate)
	
    SLASH_COMMANDS["/ct"] = CrownTrackerSlash
	SLASH_COMMANDS["/crowntracker"] = CrownTrackerSlash
	d("CrownTracker loaded")
	
	
end
EVENT_MANAGER:RegisterForEvent( CrownTracker.name, EVENT_ADD_ON_LOADED, CrownTrackerOnAddOnLoaded )

function CrownTrackerSlash(text)
	text = string.lower(text)
	if text == "show" then
		CrownTrackerSavedVars.alpha = 1
		CrownTrackerUI_Backdrop:SetAlpha(1)
	elseif text == "lock" then
		CrownTrackerSavedVars.moveable = false
		CrownTrackerUI:SetMovable(false)
	elseif text == "unlock" then
		CrownTrackerSavedVars.moveable = true
		CrownTrackerUI:SetMovable(true)
	elseif text == "debug" then
		CrownTracker.debug = true
		CrownTracker.leaderTag = "player"
	elseif text == "reload" then
		CrownTracker.debug = false
		CrownTrackerOnUpdateLeader()
	else
		d("CrownTracker doesn't know command: "..text)
		d("available args: Show | Reload | Debug | Lock | Unlock ")
	end
end

function CrownTrackerSetLeaderUnitTag()
	if CrownTracker.debug == true then
		CrownTracker.leaderTag = "player"
	end
	
	local groupSize = GetGroupSize()

	if groupSize > 0 then
		for i = 1, groupSize do
			local unitTag = GetGroupUnitTagByIndex(i)
			if IsUnitGroupLeader(unitTag) then
				CrownTracker.leaderTag = unitTag
				d("Loaded new leader "..GetUnitDisplayName(unitTag))
				return
			end
		end
	else
		CrownTracker.leaderTag = nil
	end
end

function CrownTrackerOnUpdateLeader()
	CrownTrackerSetLeaderUnitTag()
end
EVENT_MANAGER:RegisterForEvent(CrownTracker.name, EVENT_LEADER_UPDATE, CrownTrackerOnUpdateLeader)
EVENT_MANAGER:RegisterForEvent(CrownTracker.name, EVENT_GROUP_UPDATE, CrownTrackerOnUpdateLeader)
EVENT_MANAGER:RegisterForEvent(CrownTracker.name, EVENT_GROUP_MEMBER_JOINED, CrownTrackerOnUpdateLeader)
EVENT_MANAGER:RegisterForEvent(CrownTracker.name, EVENT_GROUP_MEMBER_LEFT, CrownTrackerOnUpdateLeader)
EVENT_MANAGER:RegisterForEvent(CrownTracker.name, EVENT_GROUP_MEMBER_CONNECTED_STATUS, CrownTrackerOnUpdateLeader)


function CrownTrackerOnUpdate()
	--d("OnUpdate")
	local unitID = CrownTracker.leaderTag

	if CrownTracker.leaderTag == nil then
		return
	end
	
	-- cyrodiil map 181
	local _x, _y, heading, isShownInCurrentMap = GetMapPlayerPosition(unitID)
	local zoneId, worldX, worldZ, worldY = GetUnitWorldPosition(unitID)
	
	if (CrownTrackerlast_worldX == worldX and 
		CrownTrackerlast_worldY == worldY) then return end


	CrownTrackerlast_worldX = worldX
	CrownTrackerlast_worldY = worldY

	local result=""
	--result=result.."Unit:  "..unitName
	--result=result.."\nX:  "
	if ( worldX ~= nil ) then
	   result = result..zo_round(worldX/100)
	end
	result=result.."\n"
	if ( worldY ~= nil ) then
	   result = result..zo_round(worldY/100)
	end

	CrownTrackerUI_Label:SetText(result)
	
end
function CrownTrackerOnMoveStop(self)
	--d("OnMoveStop")
		--bool isValidAnchor, integer point, object relativeTo, integer relativePoint, number offsetX, number offsetY
		local validAnchor,point,relativeTo, relativePoint, offSetX, offSetY = self:GetAnchor()
		
		if validAnchor then
				CrownTrackerSavedVars.offSetX = offSetX
				CrownTrackerSavedVars.offSetY = offSetY
				CrownTrackerSavedVars.point 		= point
				CrownTrackerSavedVars.relativePoint = relativePoint
		end
end
