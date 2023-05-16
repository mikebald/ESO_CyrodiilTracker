CyroTracker = CyroTracker or {}
CyroTracker.KeepTracker = CyroTracker.KeepTracker or {}

local KeepTracker = CyroTracker.KeepTracker
local Constants = CyroTracker.Constants
local Util = CyroTracker.Util

KeepTracker.updateInterval = 1000
KeepTracker.chunkLength = 14
KeepTracker.compressChunks = { -- Right to Left
	[1] = 14,
	[2] = 13
}
KeepTracker.state = {}

----------------------------------
-- 2 Chunks for each outputState
-- [1] -- 14 Non-compressed
-- [2] -- 13 Non-compressed
----------------------------------
KeepTracker.outputState = {
	[1] = { [1] = "", [2] = "" },
	[2] = { [1] = "", [2] = "" }
}

-- test = "999222 1221212 1211112 2221113"
--                                      ^ Warden
function KeepTracker.DebugOutput()
	CyroTracker.Message("[1]: " .. KeepTracker.GetOutput(1, false, 0) )
	CyroTracker.Message("[2]: " .. KeepTracker.GetOutput(2, false, 0) )
	CyroTracker.Message("[1]: " .. KeepTracker.GetOutput(1, true, 0) )
	CyroTracker.Message("[2]: " .. KeepTracker.GetOutput(2, true, 0) )
end

function KeepTracker.DebugAll()
	for index, trackedObj in pairs(KeepTracker.state.trackedScrolls) do
		CyroTracker.Message("[".. trackedObj.name .."]  X: " .. trackedObj.x .. " Y:" .. trackedObj.y )
	end
end

function KeepTracker.LoadOutput ()
	
	local output = {} -- table
	local outputString = ""
	local chunkStart = (( chunkNumber - 1 ) * KeepTracker.chunkLength) + 1 -- Starts at 1
	local chunkEnd = (chunkNumber * KeepTracker.chunkLength)

	if forcedLength == nil then forcedLength = 0 end

	for i = chunkStart, chunkEnd do
		if(KeepTracker.state.trackedObjects[i] ~= nil) then
			table.insert( output, KeepTracker.state.trackedObjects[i].keepStatusOutput )
		end
	end
end

function KeepTracker.GetOutput( chunkNumber, compressed, forcedLength )
	local output = {} -- table
	local outputString = ""
	local chunkStart = (( chunkNumber - 1 ) * KeepTracker.chunkLength) + 1 -- Starts at 1
	local chunkEnd = (chunkNumber * KeepTracker.chunkLength)

	if forcedLength == nil then forcedLength = 0 end

	for i = chunkStart, chunkEnd do
		if(KeepTracker.state.trackedObjects[i] ~= nil) then
			table.insert( output, KeepTracker.state.trackedObjects[i].keepStatusOutput)
		end
	end

	if compressed == true then
		outputString = Util.BaseConverter(table.concat(output,""))
	else
		outputString = table.concat(output,"")
	end

	while string.len(outputString) < forcedLength do
		outputString = "_" .. outputString
	end

	return outputString
end

function KeepTracker.GetResourceStatusOutputForTrackedObject( trackedObj )
	local alliance = trackedObj.owningAlliance
	local keepID = trackedObj.id
	
	-- Farm [1], Mine [2], Lumber [3]
	if(trackedObj.keepType == KEEPTYPE_KEEP) then
		return 1
	end
	
	return 0
end

function KeepTracker.GetKeepStatusOutputForTrackedObject( trackedObj )
	local alliance = trackedObj.owningAlliance
	local siege = trackedObj.totalSiege
	
	if siege ~= 0 then
		if alliance == ALLIANCE_ALDMERI_DOMINION then
			if siege < 10 then return 4 else return 5 end
		end
		if alliance == ALLIANCE_EBONHEART_PACT then
			if siege < 10 then return 6 else return 7 end
		end
		if alliance == ALLIANCE_DAGGERFALL_COVENANT then
			if siege < 10 then return 8 else return 9 end
		end
	else
		return alliance
	end
end

local function GetBGContext()
    local bgQuery = BGQUERY_UNKNOWN
    if IsPlayerInAvAWorld() then
        bgQuery = BGQUERY_LOCAL
    elseif false then  -- TODO: Is map displaying white keeps
        bgQuery = BGQUERY_UNKNOWN
    elseif GetAssignedCampaignId() ~= NONE then
        bgQuery = BGQUERY_ASSIGNED_CAMPAIGN
    end
    return bgQuery
end


function KeepTracker.InitTrackedObjects(gametime)
    KeepTracker.state.trackedObjects = {}
    local counter = 1
    for index, value in pairs(CyroTracker.Constants.tracking) do
        KeepTracker.state.trackedObjects[counter] = {}
        KeepTracker.state.trackedObjects[counter].id = index
        KeepTracker.state.trackedObjects[counter].keepType = GetKeepType(index)
        KeepTracker.state.trackedObjects[counter].name = value
        KeepTracker.state.trackedObjects[counter].isUnderAttack = GetKeepUnderAttack(index,  GetBGContext())
        KeepTracker.state.trackedObjects[counter].owningAlliance = GetKeepAlliance(index, GetBGContext())
		KeepTracker.state.trackedObjects[counter].allianceName = Constants.keepAlliance[GetKeepAlliance(index, GetBGContext())]
		KeepTracker.state.trackedObjects[counter].siegingAlliance = Util.GetSiegingAlliance(index)
		KeepTracker.state.trackedObjects[counter].totalSiege = Util.GetAttackingSiege(index)
		KeepTracker.state.trackedObjects[counter].canTravel = GetKeepHasResourcesForTravel(index, GetBGContext())
		
		if GetKeepType(index) == KEEPTYPE_KEEP then
			KeepTracker.state.trackedObjects[counter].farmID = GetResourceKeepForKeep(index, RESOURCETYPE_FOOD)
			KeepTracker.state.trackedObjects[counter].lumberID = GetResourceKeepForKeep(index, RESOURCETYPE_WOOD)
			KeepTracker.state.trackedObjects[counter].mineID = GetResourceKeepForKeep(index, RESOURCETYPE_ORE)
			
			KeepTracker.state.trackedObjects[counter].farmOwner = GetKeepAlliance(GetResourceKeepForKeep(index, RESOURCETYPE_FOOD), GetBGContext())
			KeepTracker.state.trackedObjects[counter].lumberOwner = GetKeepAlliance(GetResourceKeepForKeep(index, RESOURCETYPE_WOOD), GetBGContext())
			KeepTracker.state.trackedObjects[counter].mineOwner = GetKeepAlliance(GetResourceKeepForKeep(index, RESOURCETYPE_ORE), GetBGContext())
		end
		
		KeepTracker.state.trackedObjects[counter].keepStatusOutput = KeepTracker.GetKeepStatusOutputForTrackedObject(KeepTracker.state.trackedObjects[counter])
		KeepTracker.state.trackedObjects[counter].resourceStatusOutput = KeepTracker.GetResourceStatusOutputForTrackedObject(KeepTracker.state.trackedObjects[counter])
        counter = counter + 1
    end
end

function KeepTracker.InitScrolls()
	KeepTracker.state.trackedScrolls = {}
	local counter = 1

    for index, value in pairs(CyroTracker.Constants.scrolls) do
		KeepTracker.state.trackedScrolls[counter] = {}
        KeepTracker.state.trackedScrolls[counter].keepId = index
        KeepTracker.state.trackedScrolls[counter].scrollId = value
		KeepTracker.state.trackedScrolls[counter].name = Constants.scrolls[index]
		KeepTracker.state.trackedScrolls[counter].x = "0"
		KeepTracker.state.trackedScrolls[counter].y = "0"
		counter = counter + 1
    end
end

function KeepTracker.UpdateScrolls()
	if(KeepTracker.state.trackedScrolls == nil) then
        return
    end

	for index, trackedScroll in pairs(KeepTracker.state.trackedScrolls) do
		local _, x, y = GetObjectivePinInfo(trackedScroll.keepId, trackedScroll.scollId, GetBGContext())
		
		trackedScroll.x = tostring(x)
		trackedScroll.y = tostring(y)

	end
end

function KeepTracker.UpdateTrackedObjects()
	if(KeepTracker.state.trackedObjects == nil) then
        return
    end

    for index, trackedObj in pairs(KeepTracker.state.trackedObjects) do
		trackedObj.owningAlliance = GetKeepAlliance(trackedObj.id, GetBGContext())
		trackedObj.isUnderAttack = GetKeepUnderAttack(trackedObj.id,  GetBGContext())
		trackedObj.allianceName = Constants.keepAlliance[GetKeepAlliance(trackedObj.id, GetBGContext())]
		trackedObj.siegingAlliance = Util.GetSiegingAlliance(trackedObj.id)
		trackedObj.totalSiege = Util.GetAttackingSiege(trackedObj.id)
		trackedObj.canTravel = GetKeepHasResourcesForTravel(trackedObj.id, GetBGContext())
		trackedObj.keepStatusOutput = KeepTracker.GetKeepStatusOutputForTrackedObject(trackedObj)
		if GetKeepType(index) == KEEPTYPE_KEEP then
			trackedObj.farmOwner = GetKeepAlliance(GetResourceKeepForKeep(trackedObj.id, RESOURCETYPE_FOOD), GetBGContext())
			trackedObj.lumberOwner = GetKeepAlliance(GetResourceKeepForKeep(trackedObj.id, RESOURCETYPE_WOOD), GetBGContext())
			trackedObj.mineOwner = GetKeepAlliance(GetResourceKeepForKeep(trackedObj.id, RESOURCETYPE_ORE), GetBGContext())
		end
		trackedObj.resourceStatusOutput = KeepTracker.GetResourceStatusOutputForTrackedObject(trackedObj)
	end
end

function KeepTracker.UpdateLoop()
	--if Util.IsInCyrodiil() == true then
		
		KeepTracker.UpdateTrackedObjects()
		KeepTracker.UpdateScrolls()
		
		local trackerRow1 = KeepTracker.GetOutput(2, true, 10)
		local trackerRow2 = KeepTracker.GetOutput(1, true, 10)
		CyroTracker.keepRow1 = trackerRow1
		CyroTracker.keepRow2 = trackerRow2
	--end
end

function KeepTracker.Initialize()
	KeepTracker.InitTrackedObjects()
	KeepTracker.InitScrolls()

	EVENT_MANAGER:RegisterForUpdate(CyroTracker.name, KeepTracker.updateInterval, KeepTracker.UpdateLoop)
end
