CyroTracker = CyroTracker or {}
CyroTracker.Util = CyroTracker.Util or {}

local Util = CyroTracker.Util
local Constants = CyroTracker.Constants

function Util.BaseConverter(number) -- For converting between numerical bases
    local digits = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
    local base =  string.len(digits)
    local t = {}
    repeat
        local d = (number % base) + 1
        number = math.floor(number / base)
        table.insert(t, 1, digits:sub(d,d))
    until number == 0
    return table.concat(t,"")
end

function Util.GetAttackingSiege( keepId )
	local ad = GetNumSieges(keepId, BGQUERY_LOCAL, ALLIANCE_ALDMERI_DOMINION)
	local ep = GetNumSieges(keepId, BGQUERY_LOCAL, ALLIANCE_EBONHEART_PACT)
	local dc = GetNumSieges(keepId, BGQUERY_LOCAL, ALLIANCE_DAGGERFALL_COVENANT)
	local owner = GetKeepAlliance(keepId, BGQUERY_LOCAL)
	
	if ad + ep + dc == 0 then 
		if GetKeepUnderAttack(keepId,  BGQUERY_LOCAL) == true then return 1 end -- Special for towns
		return 0 
	end

	if owner == ALLIANCE_ALDMERI_DOMINION then
		return math.max(ep, dc)
	end

	if owner == ALLIANCE_EBONHEART_PACT then
		return math.max(ad, dc)
	end

	if owner == ALLIANCE_DAGGERFALL_COVENANT then
		return math.max(ad, ep)
	end

	if GetKeepUnderAttack(keepId,  BGQUERY_LOCAL) == true then return 1 end

	return 0
end

function Util.GetSiegingAlliance( keepId ) 
	local ad = GetNumSieges(keepId, BGQUERY_LOCAL, ALLIANCE_ALDMERI_DOMINION)
	local ep = GetNumSieges(keepId, BGQUERY_LOCAL, ALLIANCE_EBONHEART_PACT)
	local dc = GetNumSieges(keepId, BGQUERY_LOCAL, ALLIANCE_DAGGERFALL_COVENANT)
	local owner = GetKeepAlliance(keepId, BGQUERY_LOCAL)

	if ad + ep + dc == 0 then 
		if GetKeepUnderAttack(keepId,  BGQUERY_LOCAL) == 1 then return 1 end -- Special for towns
		return 0 
	end

	if owner == ALLIANCE_ALDMERI_DOMINION then
		local maxSieges = math.max(ep, dc)
		if maxSieges == ep then return ALLIANCE_EBONHEART_PACT end
		if maxSieges == dc then return ALLIANCE_DAGGERFALL_COVENANT end
	end

	if owner == ALLIANCE_EBONHEART_PACT then
		local maxSieges = math.max(ad, dc)
		if maxSieges == ad then return ALLIANCE_ALDMERI_DOMINION end
		if maxSieges == dc then return ALLIANCE_DAGGERFALL_COVENANT end
	end

	if owner == ALLIANCE_DAGGERFALL_COVENANT then
		local maxSieges = math.max(ad, ep)
		if maxSieges == ad then return ALLIANCE_ALDMERI_DOMINION end
		if maxSieges == ep then return ALLIANCE_EBONHEART_PACT end
	end

	return 0
end

function Util.LeftPad ( str, len, char )
	if char == nil then char = '_' end
	return string.rep(char, len - #str) .. str
end

function Util.RightPad ( str, len, char )
	if char == nil then char = '_' end
	return str .. string.rep(char, len - #str)
end

function Util.ReplaceStr(pos, str, replace)
    return string.sub(str, 1, pos) .. replace .. str:sub(pos + #replace + 1)
end

function Util.GetUnitPosition( tag ) 
	local zoneId, worldX, worldZ, worldY = GetUnitWorldPosition(tag)
	local unitX, unitY

	local result=""
	if ( worldX ~= nil ) then
		unitX = string.format("%03d", zo_round(worldX/1000))
	end

	if ( worldY ~= nil ) then
		unitY = string.format("%03d", zo_round(worldY/1000))
	end

	return unitX, unitY
end

function Util.IsInCyrodiil()
	if IsInCyrodiil() == true then
		return true
	elseif IsInCyrodiil() == false and IsPlayerInAvAWorld() == true and IsInAvAZone() == true and IsInImperialCity() == false and IsActiveWorldBattleground() == false then
		return true
	else
		return false
	end
end
