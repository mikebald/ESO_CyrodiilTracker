CyroTracker = CyroTracker or {}
CyroTracker.EncounterTracker = CyroTracker.EncounterTracker or {}

local EncounterTracker = CyroTracker.EncounterTracker

EncounterTracker.name = "CyroTracker_EncounterTracker"
EncounterTracker.timerInterval = 10000
EncounterTracker.startTime = "21:00:00"
EncounterTracker.endTime = "23:00:00"
EncounterTracker.GamingDays = { 2, 4 } -- Monday & Wednesday
EncounterTracker.DayOfWeek = { "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday" }
EncounterTracker.CorrectDate = true

function EncounterTracker.OnUpdate()
    EncounterTracker.Status()
    
    if EncounterTracker.CorrectDate then
    
        if EncounterTracker.IsTime() then
            EncounterTracker.Start()
        else
            EncounterTracker.Stop()
        end
    
    end
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

function EncounterTracker.ParseTime(timeString)
    local hour, minute = timeString:match("(%d+):(%d+)")
    return (hour * 60) + minute;
end

function EncounterTracker.IsTime()
    local parsedTime = EncounterTracker.ParseTime(GetTimeString())
    local start = EncounterTracker.ParseTime(EncounterTracker.startTime)
    local stop = EncounterTracker.ParseTime(EncounterTracker.endTime)
    return parsedTime >= start and parsedTime <= stop
end

function EncounterTracker.IsDate()
    local current_date = os.date("*t")
    local current_dayOfWeek = current_date.wday
    for _, gamingDay in ipairs(EncounterTracker.GamingDays) do
        if gamingDay == current_dayOfWeek then 
            EncounterTracker.CorrectDate = true
            return true 
        end
    end
    EncounterTracker.CorrectDate = false
    return false
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
    if CyroTracker.EnableEncounterTracker then
        EncounterTracker.Status()
        EVENT_MANAGER:RegisterForUpdate(EncounterTracker.name, EncounterTracker.timerInterval, EncounterTracker.OnUpdate)
        EncounterTracker.IsDate() -- Only need to run once
    else
        CyrodiilEncounterTrackerUI:SetHidden(true)
    end
end