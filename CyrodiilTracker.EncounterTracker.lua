CyroTracker = CyroTracker or {}
CyroTracker.EncounterTracker = CyroTracker.EncounterTracker or {}

local EncounterTracker = CyroTracker.EncounterTracker
local EncounterTrackerScheduler = CyroTracker.EncounterTrackerScheduler

EncounterTracker.name = "CyroTracker_EncounterTracker"
EncounterTracker.timerInterval = 10000
EncounterTracker.Schedule = {}
EncounterTracker.Override = false -- Set to enable the tracker

function EncounterTracker.CreateSchedule()
    -- { "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday" }
    -- {        1,        2,         3,           4,          5,        6,         7  }
    local offliners_Monday =    EncounterTrackerScheduler.ScheduleDay:new(2, "21:00", "23:00")
    local offliners_Wednesday = EncounterTrackerScheduler.ScheduleDay:new(4, "21:00", "23:00")
    local ftier_Friday = EncounterTrackerScheduler.ScheduleDay:new(6, "20:45", "23:00")
    local ftier_Sunday = EncounterTrackerScheduler.ScheduleDay:new(1, "20:45", "23:00")

    --local test = EncounterTrackerScheduler.ScheduleDay:new(7, "19:00", "23:00")

    EncounterTracker.Schedule = EncounterTrackerScheduler.ScheduleObj:new()
    EncounterTracker.Schedule:addDay(offliners_Monday)
    EncounterTracker.Schedule:addDay(offliners_Wednesday)
    EncounterTracker.Schedule:addDay(ftier_Friday)
    EncounterTracker.Schedule:addDay(ftier_Sunday)
    --EncounterTracker.Schedule:addDay(test)
end


function EncounterTracker.OnUpdate()
    if EncounterTracker.Schedule:isWithinSchedule() or EncounterTracker.Override then
        EncounterTracker.Start()
    else
        EncounterTracker.Stop()
    end
    EncounterTracker.Status()
end

function EncounterTracker.Status()
    if IsEncounterLogEnabled() then
        CyrodiilEncounterTrackerUI_lblStatus:SetText("Running")
        CyrodiilEncounterTrackerUI_lblStatus:SetColor(0,1,0,1)
    else
        CyrodiilEncounterTrackerUI_lblStatus:SetText("Stopped")
        CyrodiilEncounterTrackerUI_lblStatus:SetColor(1,0,0,1)
    end
end

function EncounterTracker.Toggle()
    if IsEncounterLogEnabled() then
        EncounterTracker.Stop()
    else 
        EncounterTracker.Start()
    end
end

function EncounterTracker.Start()
    if IsEncounterLogEnabled() == false then
        SetEncounterLogEnabled(true)
        EncounterTracker.Status()
    end
end

function EncounterTracker.Stop()
    if IsEncounterLogEnabled() then
        SetEncounterLogEnabled(false)
        EncounterTracker.Status()
    end
end

function EncounterTracker.Initialize()
    EncounterTracker.CreateSchedule()

    if CyroTracker.EnableEncounterTracker then
        EncounterTracker.Status()
        EVENT_MANAGER:RegisterForUpdate(EncounterTracker.name, EncounterTracker.timerInterval, EncounterTracker.OnUpdate)
    else
        CyrodiilEncounterTrackerUI:SetHidden(true)
    end
end