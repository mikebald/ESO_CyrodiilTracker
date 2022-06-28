CyroTrackerKeeps = CyroTrackerKeeps or {}
CyroTrackerKeeps.updateInterval = 1000
CyroTrackerKeeps.state = {}

-- BGQUERY_LOCAL -> battlegroundContext

function CyroTrackerKeeps.Initialize()
    EVENT_MANAGER:RegisterForUpdate(CrownTracker.name, CyroTrackerKeeps.updateInterval, CyroTrackerKeeps.UpdateLoop)

    CyroTrackerKeeps.InitResources()
    CyroTrackerKeeps.InitTrackedObjects()
    --EVENT_MANAGER:RegisterForEvent(CrownTracker.name, EVENT_KEEP_UNDER_ATTACK_CHANGED, OnKeepUnderAttackChanged)
    --EVENT_MANAGER:RegisterForEvent(CrownTracker.name, EVENT_KEEP_ALLIANCE_OWNER_CHANGED, OnAllianceOwnerChanged)
    --EVENT_MANAGER:RegisterForEvent(CrownTracker.name, EVENT_KEEP_INITIALIZED, OnKeepInitialized)
end

function CyroTrackerKeeps.InitResources()
    CyroTrackerKeeps.state.resources = {}
    for index, value in pairs(CrownTrackerConstants.resources) do
        CyroTrackerKeeps.state.resources[index] = {}
        CyroTrackerKeeps.state.resources[index].id = index
        CyroTrackerKeeps.state.resources[index].keepType = GetKeepType(index)
        CyroTrackerKeeps.state.resources[index].name = value
        CyroTrackerKeeps.state.resources[index].isUnderAttack = GetKeepUnderAttack(index,  BGQUERY_LOCAL)
        CyroTrackerKeeps.state.resources[index].owningAlliance = GetKeepAlliance(index, BGQUERY_LOCAL)
        CyroTrackerKeeps.state.resources[index].previousAlliance = GetKeepAlliance(index, BGQUERY_LOCAL)
    end
end


function CyroTrackerKeeps.InitTrackedObjects(gametime)
    CyroTrackerKeeps.state.trackedObjects = {}
    local counter = 1
    -- Keeps
    for index, value in pairs(CrownTrackerConstants.keeps) do
        CyroTrackerKeeps.state.trackedObjects[counter] = {}
        CyroTrackerKeeps.state.trackedObjects[counter].id = index
        CyroTrackerKeeps.state.trackedObjects[counter].keepType = GetKeepType(index)
        CyroTrackerKeeps.state.trackedObjects[counter].name = value
        CyroTrackerKeeps.state.trackedObjects[counter].isUnderAttack = GetKeepUnderAttack(index,  BGQUERY_LOCAL)
        CyroTrackerKeeps.state.trackedObjects[counter].owningAlliance = GetKeepAlliance(index, BGQUERY_LOCAL)
        CyroTrackerKeeps.state.trackedObjects[counter].previousAlliance = GetKeepAlliance(index, BGQUERY_LOCAL)
        if( CyroTrackerKeeps.state.resources ~= nil ) then
            CyroTrackerKeeps.state.trackedObjects[counter].resources = {}
            CyroTrackerKeeps.state.trackedObjects[counter].resources.farm = CyroTrackerKeeps.state.resources[GetResourceKeepForKeep(i, RESOURCETYPE_FOOD)]
            CyroTrackerKeeps.state.trackedObjects[counter].resources.farm.rType = CrownTrackerConstants.resourceType.FARM
            CyroTrackerKeeps.state.trackedObjects[counter].resources.lumber = CyroTrackerKeeps.state.resources[GetResourceKeepForKeep(i, RESOURCETYPE_WOOD)]
            CyroTrackerKeeps.state.trackedObjects[counter].resources.lumber.rType =CrownTrackerConstants.resourceType.LUMBER
            CyroTrackerKeeps.state.trackedObjects[counter].resources.mine = CyroTrackerKeeps.state.resources[GetResourceKeepForKeep(i, RESOURCETYPE_ORE)]
            CyroTrackerKeeps.state.trackedObjects[counter].resources.mine.rType = CrownTrackerConstants.resourceType.MINE
        end
        counter = counter + 1
    end
    -- Outposts
    for index, value in pairs(CrownTrackerConstants.outposts) do
        CyroTrackerKeeps.state.trackedObjects[counter] = {}
        CyroTrackerKeeps.state.trackedObjects[counter].id = index
        CyroTrackerKeeps.state.trackedObjects[counter].keepType = GetKeepType(index)
        CyroTrackerKeeps.state.trackedObjects[counter].name = value
        CyroTrackerKeeps.state.trackedObjects[counter].isUnderAttack = GetKeepUnderAttack(index,  BGQUERY_LOCAL)
        CyroTrackerKeeps.state.trackedObjects[counter].owningAlliance = GetKeepAlliance(index, BGQUERY_LOCAL)
        CyroTrackerKeeps.state.trackedObjects[counter].previousAlliance = GetKeepAlliance(index, BGQUERY_LOCAL)
        counter = counter + 1
    end
    -- Towns
    for index, value in pairs(CrownTrackerConstants.towns) do
        CyroTrackerKeeps.state.trackedObjects[counter] = {}
        CyroTrackerKeeps.state.trackedObjects[counter].id = index
        CyroTrackerKeeps.state.trackedObjects[counter].keepType = GetKeepType(index)
        CyroTrackerKeeps.state.trackedObjects[counter].name = value
        CyroTrackerKeeps.state.trackedObjects[counter].isUnderAttack = GetKeepUnderAttack(index,  BGQUERY_LOCAL)
        CyroTrackerKeeps.state.trackedObjects[counter].owningAlliance = GetKeepAlliance(index, BGQUERY_LOCAL)
        CyroTrackerKeeps.state.trackedObjects[counter].previousAlliance = GetKeepAlliance(index, BGQUERY_LOCAL)
        counter = counter + 1
    end
end

function CyroTrackerKeeps.UpdateTrackedObjects(gameTime)
	if(CyroTrackerKeeps.state.trackedObjects == nil) then
        return
    end

    for index, trackedObj in pairs(CyroTrackerKeeps.state.trackedObjects) do
		
        local itemOfInterest = false
		local previousOwningAlliance = item.owningAlliance
		item.owningAlliance = GetKeepAlliance(key, BGQUERY_LOCAL)
		if item.previousOwningAllianceTimestamp == nil or item.previousOwningAllianceTimestamp + RdKGToolCyro.config.previousOwnerThreshold < gameTime then
			item.previousOwningAlliance = previousOwningAlliance
			item.previousOwningAllianceTimestamp = gameTime
		end
		local previousAttackState = item.isUnderAttack
		item.isUnderAttack = GetKeepUnderAttack(key,  BGQUERY_LOCAL)
		item.underAttackFor = 0
		item.isCoolingDown = true
		
		if item.owningAlliance ~= previousOwningAlliance and RdKGToolCyro.state.destructibles[key] == nil then
			itemOfInterest = true
			--d("keep switched")
			if item.interestingSince == nil then
				item.interestingSince = gameTime
			end
			item.underAttackFor = gameTime - item.interestingSince
			if item.objectives ~= nil then
				for i = 1, #item.objectives do
					item.objectives[i].state = 100
					item.objectives[i].holdingAlliance = item.owningAlliance
				end
			end
			item.flipsAt = nil
			local eventData = {}
			eventData.event = RdKGToolCyro.constants.events.KEEP_OWNER_CHANGED
			eventData.keepId = key
			eventData.keepName = zo_strformat("<<1>>", GetKeepName(key))
			eventData.alliance = item.owningAlliance
			eventData.previousOwningAlliance = previousOwningAlliance
			RdKGToolCyro.NotifyMessageConsumers(eventData)
		end
		if previousAttackState == false and item.isUnderAttack == true then
			--throw isUaMessage
			local eventData = {}
			eventData.event = RdKGToolCyro.constants.events.STATUS_UA
			eventData.keepId = key
			eventData.keepName = zo_strformat("<<1>>", GetKeepName(key))
			eventData.alliance = item.owningAlliance
			eventData.previousOwningAlliance = previousOwningAlliance
			RdKGToolCyro.NotifyMessageConsumers(eventData)
			if item.attackStatusLostAt ~= 0 and item.attackStatusLostAt + RdKGToolCyro.config.siegeTimeout < gameTime then
				item.underAttackSince = gameTime
			end
		elseif previousAttackState == true and item.isUnderAttack == false then
			--throw isUaLostMessage
			local eventData = {}
			eventData.event = RdKGToolCyro.constants.events.STATUS_UA_LOST
			eventData.keepId = key
			eventData.keepName = zo_strformat("<<1>>", GetKeepName(key))
			eventData.alliance = item.owningAlliance
			eventData.previousOwningAlliance = previousOwningAlliance
			RdKGToolCyro.NotifyMessageConsumers(eventData)
			item.attackStatusLostAt = gameTime
		end
		if item.isUnderAttack == true then
			itemOfInterest = true
			--d("is under attack")
			if item.interestingSince == nil then
				item.interestingSince = gameTime
			end
			item.underAttackFor = gameTime - item.interestingSince
			item.isCoolingDown = false
		else
			if item.attackStatusLostAt ~= 0 and item.attackStatusLostAt + RdKGToolCyro.config.siegeTimeout > gameTime then
				itemOfInterest = true
				--d("not under attack")
				if item.interestingSince == nil then
					item.interestingSince = gameTime
				end
				item.underAttackFor = gameTime - item.interestingSince
			end
		end
		if RdKGToolCyro.state.destructibles[key] == nil then
			item.siegeWeapons.AD = GetNumSieges(key, BGQUERY_LOCAL, ALLIANCE_ALDMERI_DOMINION)
			item.siegeWeapons.DC = GetNumSieges(key, BGQUERY_LOCAL, ALLIANCE_DAGGERFALL_COVENANT)
			item.siegeWeapons.EP = GetNumSieges(key, BGQUERY_LOCAL, ALLIANCE_EBONHEART_PACT)
		
			if item.siegeWeapons.AD > 0 or item.siegeWeapons.DC > 0 or item.siegeWeapons.EP > 0 then
				itemOfInterest = true
				item.isCoolingDown = false
				--d("siege weapons deployed")
				if item.interestingSince == nil then
					item.interestingSince = gameTime
				end
				item.underAttackFor = gameTime - item.interestingSince
				item.lastSiegeWeaponSeen = gameTime
			elseif item.lastSiegeWeaponSeen ~= nil and item.lastSiegeWeaponSeen + RdKGToolCyro.config.siegeTimeout > gameTime then
				itemOfInterest = true
				if item.interestingSince == nil then
					item.interestingSince = gameTime
				end
				item.underAttackFor = gameTime - item.interestingSince
			else
				item.lastSiegeWeaponSeen = nil
			end
		end
		
		if item.keepType == KEEPTYPE_BRIDGE or item.keepType == KEEPTYPE_MILEGATE then
			item.isPassable = IsKeepPassable(key, BGQUERY_LOCAL)
			item.directionalAccess = GetKeepDirectionalAccess(key, BGQUERY)
		end
		if itemOfInterest == true then
			--d(key)
			table.insert(itemsOfInterest, item)
		else
			item.interestingSince = nil
		end
	end
	return itemsOfInterest
end

function CyroTrackerKeeps.IsInCyrodiil()
	if IsInCyrodiil() == true then
		return true
	elseif IsInCyrodiil() == false and IsPlayerInAvAWorld() == true and IsInAvAZone() == true and IsInImperialCity() == false and IsActiveWorldBattleground() == false then
		return true
	else
		return false
	end
end

function CyroTrackerKeeps.UpdateLoop()
	if CyroTrackerKeeps.IsInCyrodiil() == true then
		local itemsOfInterest = {}
		local gameTime = GetGameTimeMilliseconds()
		itemsOfInterest = RdKGToolCyro.AdjustItemsOfInterest(itemsOfInterest, RdKGToolCyro.UpdateItem(RdKGToolCyro.state.resources, gameTime))
		itemsOfInterest = RdKGToolCyro.AdjustItemsOfInterest(itemsOfInterest, RdKGToolCyro.UpdateItem(RdKGToolCyro.state.keeps, gameTime))
		itemsOfInterest = RdKGToolCyro.AdjustItemsOfInterest(itemsOfInterest, RdKGToolCyro.UpdateItem(RdKGToolCyro.state.outposts, gameTime))
		itemsOfInterest = RdKGToolCyro.AdjustItemsOfInterest(itemsOfInterest, RdKGToolCyro.UpdateItem(RdKGToolCyro.state.villages, gameTime))
		itemsOfInterest = RdKGToolCyro.AdjustItemsOfInterest(itemsOfInterest, RdKGToolCyro.UpdateItem(RdKGToolCyro.state.destructibles, gameTime))
		itemsOfInterest = RdKGToolCyro.AdjustItemsOfInterest(itemsOfInterest, RdKGToolCyro.UpdateItem(RdKGToolCyro.state.temples, gameTime))
		--d("Sort: " .. #itemsOfInterest)
		if #itemsOfInterest > 1 then
			table.sort(itemsOfInterest, RdKGToolCyro.SortItemsOfInterest)
		end
		RdKGToolCyro.UpdateItemsOfInterest(itemsOfInterest)
	end
end



function CyroTrackerKeeps.OnKeepUnderAttackChanged(eventCode, keepId, battlegroundContext, underAttack)
	local keepAlliance = GetKeepAlliance(keepId, battlegroundContext)
	local keepName = GetKeepName(keepId)
	local keepType = GetKeepType(keepId)

	if keepType ~= KEEPTYPE_KEEP or keepType ~= KEEPTYPE_OUTPOST or keepType ~= KEEPTYPE_TOWN then return end

	d(keepName.." under attack")

	-- local defendSiege = GetNumSieges(keepId, battlegroundContext, keepAlliance)
	-- local allSiege = GetNumSieges(keepId, battlegroundContext, ALLIANCE_ALDMERI_DOMINION)
	-- allSiege = allSiege + GetNumSieges(keepId, battlegroundContext, ALLIANCE_DAGGERFALL_COVENANT)
	-- allSiege = allSiege + GetNumSieges(keepId, battlegroundContext, ALLIANCE_EBONHEART_PACT)
	-- local adSiege = GetNumSieges(keepId, battlegroundContext, ALLIANCE_ALDMERI_DOMINION)
	-- local dcSiege = GetNumSieges(keepId, battlegroundContext, ALLIANCE_DAGGERFALL_COVENANT)
	-- local epSiege = GetNumSieges(keepId, battlegroundContext, ALLIANCE_EBONHEART_PACT)
	-- local mySiege = GetNumSieges(keepId, battlegroundContext, CA.myAlliance)
	-- local attackSiege = allSiege - defendSiege

end

function CyroTrackerKeeps.OnAllianceOwnerChanged(eventCode, keepId, battlegroundContext, owningAlliance, oldAlliance)
	local newAlliance = GetAllianceName(owningAlliance)
	local oldAlliance = GetAllianceName(oldAlliance)
	local keepName = GetKeepName(keepId)
	local keepType = GetKeepType(keepId)

	if keepType ~= KEEPTYPE_KEEP or keepType ~= KEEPTYPE_OUTPOST or keepType ~= KEEPTYPE_TOWN then return end
end
