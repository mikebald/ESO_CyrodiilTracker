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

function KeepTracker.GetOutput( chunkNumber, compressed, forcedLength )
	local output = {} -- table
	local outputString = ""
	local chunkStart = (( chunkNumber - 1 ) * KeepTracker.chunkLength) + 1 -- Starts at 1
	local chunkEnd = (chunkNumber * KeepTracker.chunkLength)

	if forcedLength == nil then forcedLength = 0 end

	for i = chunkStart, chunkEnd do
		if(KeepTracker.state.trackedObjects[i] ~= nil) then
			table.insert( output, KeepTracker.state.trackedObjects[i].output )
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

function KeepTracker.GetOutputForTrackedObject( trackedObj )
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

function KeepTracker.InitTrackedObjects(gametime)
    KeepTracker.state.trackedObjects = {}
    local counter = 1
    for index, value in pairs(CyroTracker.Constants.tracking) do
        KeepTracker.state.trackedObjects[counter] = {}
        KeepTracker.state.trackedObjects[counter].id = index
        KeepTracker.state.trackedObjects[counter].keepType = GetKeepType(index)
        KeepTracker.state.trackedObjects[counter].name = value
        KeepTracker.state.trackedObjects[counter].isUnderAttack = GetKeepUnderAttack(index,  BGQUERY_LOCAL)
        KeepTracker.state.trackedObjects[counter].owningAlliance = GetKeepAlliance(index, BGQUERY_LOCAL)
		KeepTracker.state.trackedObjects[counter].allianceName = Constants.keepAlliance[GetKeepAlliance(index, BGQUERY_LOCAL)]
		KeepTracker.state.trackedObjects[counter].siegingAlliance = Util.GetSiegingAlliance(index)
		KeepTracker.state.trackedObjects[counter].totalSiege = Util.GetAttackingSiege(index)
		KeepTracker.state.trackedObjects[counter].output = KeepTracker.GetOutputForTrackedObject(KeepTracker.state.trackedObjects[counter])
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
		local _, x, y = GetObjectivePinInfo(trackedScroll.keepId, trackedScroll.scollId, BGQUERY_LOCAL)
		
		trackedScroll.x = tostring(x)
		trackedScroll.y = tostring(y)
		
		--trackedScroll.x = string.format("%02d", zo_round(x * 1000))
		--trackedScroll.y = string.format("%02d", zo_round(y * 1000))
	end
end

function KeepTracker.UpdateTrackedObjects()
	if(KeepTracker.state.trackedObjects == nil) then
        return
    end

    for index, trackedObj in pairs(KeepTracker.state.trackedObjects) do
		
		trackedObj.owningAlliance = GetKeepAlliance(trackedObj.id, BGQUERY_LOCAL)
		trackedObj.isUnderAttack = GetKeepUnderAttack(trackedObj.id,  BGQUERY_LOCAL)
		trackedObj.allianceName = Constants.keepAlliance[GetKeepAlliance(trackedObj.id, BGQUERY_LOCAL)]
		trackedObj.siegingAlliance = Util.GetSiegingAlliance(trackedObj.id)
		trackedObj.output = KeepTracker.GetOutputForTrackedObject(trackedObj)
		trackedObj.totalSiege = Util.GetAttackingSiege(trackedObj.id)

	end
end

function KeepTracker.UpdateLoop()
	if Util.IsInCyrodiil() == true then
		
		KeepTracker.UpdateTrackedObjects()
		KeepTracker.UpdateScrolls()
		
		local trackerRow1 = KeepTracker.GetOutput(2, true, 10)
		local trackerRow2 = KeepTracker.GetOutput(1, true, 10)
		CyroTracker.keepRow1 = trackerRow1
		CyroTracker.keepRow2 = trackerRow2
	end
end

function KeepTracker.Initialize()
	KeepTracker.InitTrackedObjects()
	KeepTracker.InitScrolls()

	EVENT_MANAGER:RegisterForUpdate(CyroTracker.name, KeepTracker.updateInterval, KeepTracker.UpdateLoop)
end
