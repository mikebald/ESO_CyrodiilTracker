CyroTracker.KeepTracker = CyroTracker.KeepTracker or {}

local KeepTracker = CyroTracker.KeepTracker
local Constants = CyroTracker.Constants

KeepTracker.updateInterval = 1000
KeepTracker.state = {}

-- BGQUERY_LOCAL -> battlegroundContext

function KeepTracker.Initialize()
    EVENT_MANAGER:RegisterForUpdate(CyroTracker.name, KeepTracker.updateInterval, KeepTracker.UpdateLoop)

    KeepTracker.InitResources()
    KeepTracker.InitTrackedObjects()
    --EVENT_MANAGER:RegisterForEvent(CrownTracker.name, EVENT_KEEP_UNDER_ATTACK_CHANGED, OnKeepUnderAttackChanged)
    --EVENT_MANAGER:RegisterForEvent(CrownTracker.name, EVENT_KEEP_ALLIANCE_OWNER_CHANGED, OnAllianceOwnerChanged)
    --EVENT_MANAGER:RegisterForEvent(CrownTracker.name, EVENT_KEEP_INITIALIZED, OnKeepInitialized)
end

function KeepTracker.InitResources()
    KeepTracker.state.resources = {}
    for index, value in pairs(CyroTracker.Constants.resources) do
        KeepTracker.state.resources[index] = {}
        KeepTracker.state.resources[index].id = index
        KeepTracker.state.resources[index].keepType = GetKeepType(index)
        KeepTracker.state.resources[index].name = value
        KeepTracker.state.resources[index].isUnderAttack = GetKeepUnderAttack(index,  BGQUERY_LOCAL)
        KeepTracker.state.resources[index].owningAlliance = GetKeepAlliance(index, BGQUERY_LOCAL)
        KeepTracker.state.resources[index].previousAlliance = GetKeepAlliance(index, BGQUERY_LOCAL)
    end
end


function KeepTracker.InitTrackedObjects(gametime)
    KeepTracker.state.trackedObjects = {}
    local counter = 1
    -- Keeps
    for index, value in pairs(CyroTracker.Constants.keeps) do
        KeepTracker.state.trackedObjects[counter] = {}
        KeepTracker.state.trackedObjects[counter].id = index
        KeepTracker.state.trackedObjects[counter].keepType = GetKeepType(index)
        KeepTracker.state.trackedObjects[counter].name = value
        KeepTracker.state.trackedObjects[counter].isUnderAttack = GetKeepUnderAttack(index,  BGQUERY_LOCAL)
        KeepTracker.state.trackedObjects[counter].owningAlliance = GetKeepAlliance(index, BGQUERY_LOCAL)
        KeepTracker.state.trackedObjects[counter].previousAlliance = GetKeepAlliance(index, BGQUERY_LOCAL)
        if( KeepTracker.state.resources ~= nil ) then
            KeepTracker.state.trackedObjects[counter].resources = {}
            KeepTracker.state.trackedObjects[counter].resources.farm = KeepTracker.state.resources[GetResourceKeepForKeep(i, RESOURCETYPE_FOOD)]
            KeepTracker.state.trackedObjects[counter].resources.lumber = KeepTracker.state.resources[GetResourceKeepForKeep(i, RESOURCETYPE_WOOD)]
            KeepTracker.state.trackedObjects[counter].resources.mine = KeepTracker.state.resources[GetResourceKeepForKeep(i, RESOURCETYPE_ORE)]
        end
        counter = counter + 1
    end
    -- Outposts
    for index, value in pairs(Constants.outposts) do
        KeepTracker.state.trackedObjects[counter] = {}
        KeepTracker.state.trackedObjects[counter].id = index
        KeepTracker.state.trackedObjects[counter].keepType = GetKeepType(index)
        KeepTracker.state.trackedObjects[counter].name = value
        KeepTracker.state.trackedObjects[counter].isUnderAttack = GetKeepUnderAttack(index,  BGQUERY_LOCAL)
        KeepTracker.state.trackedObjects[counter].owningAlliance = GetKeepAlliance(index, BGQUERY_LOCAL)
        KeepTracker.state.trackedObjects[counter].previousAlliance = GetKeepAlliance(index, BGQUERY_LOCAL)
        counter = counter + 1
    end
    -- Towns
    for index, value in pairs(Constants.towns) do
        KeepTracker.state.trackedObjects[counter] = {}
        KeepTracker.state.trackedObjects[counter].id = index
        KeepTracker.state.trackedObjects[counter].keepType = GetKeepType(index)
        KeepTracker.state.trackedObjects[counter].name = value
        KeepTracker.state.trackedObjects[counter].isUnderAttack = GetKeepUnderAttack(index,  BGQUERY_LOCAL)
        KeepTracker.state.trackedObjects[counter].owningAlliance = GetKeepAlliance(index, BGQUERY_LOCAL)
        KeepTracker.state.trackedObjects[counter].previousAlliance = GetKeepAlliance(index, BGQUERY_LOCAL)
        counter = counter + 1
    end
end

function KeepTracker.UpdateTrackedObjects(gameTime)
	if(KeepTracker.state.trackedObjects == nil) then
        return
    end

    for index, trackedObj in pairs(KeepTracker.state.trackedObjects) do
		
        local itemOfInterest = false
		local previousOwningAlliance = item.owningAlliance
		item.owningAlliance = GetKeepAlliance(key, BGQUERY_LOCAL)
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

function KeepTracker.IsInCyrodiil()
	if IsInCyrodiil() == true then
		return true
	elseif IsInCyrodiil() == false and IsPlayerInAvAWorld() == true and IsInAvAZone() == true and IsInImperialCity() == false and IsActiveWorldBattleground() == false then
		return true
	else
		return false
	end
end

function KeepTracker.UpdateLoop()
	if KeepTracker.IsInCyrodiil() == true then
		KeepTracker.UpdateTrackedObjects()
	end
end



function KeepTracker.OnKeepUnderAttackChanged(eventCode, keepId, battlegroundContext, underAttack)
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

function KeepTracker.OnAllianceOwnerChanged(eventCode, keepId, battlegroundContext, owningAlliance, oldAlliance)
	local newAlliance = GetAllianceName(owningAlliance)
	local oldAlliance = GetAllianceName(oldAlliance)
	local keepName = GetKeepName(keepId)
	local keepType = GetKeepType(keepId)

	if keepType ~= KEEPTYPE_KEEP or keepType ~= KEEPTYPE_OUTPOST or keepType ~= KEEPTYPE_TOWN then return end
end
