CyroTracker = CyroTracker or {}
CyroTracker.EncounterTrackerScheduler = CyroTracker.EncounterTrackerScheduler or {}

local Scheduler = CyroTracker.EncounterTrackerScheduler

Scheduler.name = "CyroTracker_EncounterTrackerScheduler"
Scheduler.CurrentDay = os.date("*t").wday
Scheduler.Schedule = {}

function Scheduler.ParseTime(timeString)
    local hour, minute = timeString:match("(%d+):(%d+)")
    return (hour * 60) + minute;
end

-- Defining the ScheduleDay Object
Scheduler.ScheduleDay = {}
function Scheduler.ScheduleDay:new(daynum, start_time, end_time)
    local newObj = {
        daynum = daynum,
        start_time = start_time,
        end_time = end_time
    }
    newObj['parsed_start_time'] = Scheduler.ParseTime(start_time)
    newObj['parsed_end_time'] = Scheduler.ParseTime(end_time)

    self.__index = self
    return setmetatable(newObj, self)
end

-- Method to check if a given time is within the range for the day
function Scheduler.ScheduleDay:isWithinSchedule()
    local current_time = Scheduler.ParseTime(GetTimeString())
    local current_day = Scheduler.CurrentDay
    return current_day == self.daynum and current_time >= self.parsed_start_time and current_time <= self.parsed_end_time
end

Scheduler.ScheduleObj = {}
function Scheduler.ScheduleObj:new()
    local newObj = {
        days = {}
    }
    self.__index = self
    return setmetatable(newObj, self)
end

function Scheduler.ScheduleObj:addDay(day)
    table.insert(self.days, day)
end

-- Method to check if a given time falls within working hours for any day of the week
function Scheduler.ScheduleObj:isWithinSchedule()
    for _, day in ipairs(self.days) do
        if day:isWithinSchedule() then
            return true
        end
    end
    return false
end