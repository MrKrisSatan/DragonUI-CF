-- Lightweight compatibility shims vendored from the ideas in !!!ClassicAPI.
-- These are intentionally tiny, low-risk fallbacks: only define what the client
-- does not already provide.

local _G = _G

-- -----------------------------------------------------------------------------
-- C_Timer
-- -----------------------------------------------------------------------------

if not _G.C_Timer then
    local timerFrame = _G.TimerFrame or CreateFrame("Frame", "DragonUICompatTimerFrame")
    local timerPool = {}

    local function PoolTimer(timer)
        timer.Ref = nil
        timer.Callback = nil
        timer.Iteration = nil
        timerPool[#timerPool + 1] = timer
    end

    local function TimerFinished(self)
        if self.Callback then
            self.Callback(self.Ref)
        end

        if self.Callback then
            local iteration = self.Iteration
            if iteration then
                if iteration == 1 then
                    self.Ref:Cancel()
                else
                    self.Iteration = iteration - 1
                end
            elseif not self.Ref then
                PoolTimer(self)
            end
        end
    end

    local function AcquireTimer()
        local timer = timerPool[#timerPool]
        if timer then
            timerPool[#timerPool] = nil
            return timer
        end

        local group = timerFrame:CreateAnimationGroup()
        timer = group:CreateAnimation("Animation")
        timer:SetScript("OnFinished", TimerFinished)
        return timer
    end

    local function CancelTimer(self)
        if self.__Timer then
            self.__Timer:Stop()
            PoolTimer(self.__Timer)
            self.__Timer = nil
        end
    end

    local function TimerIsCancelled(self)
        return not self.__Timer
    end

    local function CreateTimer(duration, callback, iteration, isTicker)
        local timer = AcquireTimer()

        if isTicker then
            timer.Ref = {
                __Timer = timer,
                Cancel = CancelTimer,
                IsCancelled = TimerIsCancelled,
            }
            timer.Iteration = iteration
        end

        timer.Callback = callback
        timer:GetParent():SetLooping((isTicker and (not iteration or iteration > 1)) and "REPEAT" or "NONE")
        timer:SetDuration(duration and duration > 0 and duration or 0.1)
        timer:Play()

        return timer.Ref
    end

    _G.C_Timer = {
        After = function(duration, callback)
            CreateTimer(duration, callback)
        end,
        NewTimer = function(duration, callback)
            return CreateTimer(duration, callback, 1, true)
        end,
        NewTicker = function(duration, callback, iteration)
            return CreateTimer(duration, callback, iteration, true)
        end,
        _version = 2,
    }
end

-- -----------------------------------------------------------------------------
-- AuraUtil
-- -----------------------------------------------------------------------------

if not _G.AuraUtil then
    local AuraUtil = {}
    local UnitAura = UnitAura

    local function FindAuraRecurse(predicate, unit, filter, auraIndex, predicateArg1, predicateArg2, predicateArg3, ...)
        if ... == nil then
            return nil
        end

        if predicate(predicateArg1, predicateArg2, predicateArg3, ...) then
            return ...
        end

        auraIndex = auraIndex + 1
        local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId =
            UnitAura(unit, auraIndex, filter)
        return FindAuraRecurse(
            predicate,
            unit,
            filter,
            auraIndex,
            predicateArg1,
            predicateArg2,
            predicateArg3,
            name,
            rank,
            icon,
            count,
            debuffType,
            duration,
            expirationTime,
            unitCaster,
            isStealable,
            shouldConsolidate,
            spellId
        )
    end

    function AuraUtil.FindAura(predicate, unit, filter, predicateArg1, predicateArg2, predicateArg3)
        local auraIndex = 1
        local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId =
            UnitAura(unit, auraIndex, filter)
        return FindAuraRecurse(
            predicate,
            unit,
            filter,
            auraIndex,
            predicateArg1,
            predicateArg2,
            predicateArg3,
            name,
            rank,
            icon,
            count,
            debuffType,
            duration,
            expirationTime,
            unitCaster,
            isStealable,
            shouldConsolidate,
            spellId
        )
    end

    function AuraUtil.FindAuraByName(auraName, unit, filter)
        local function NamePredicate(auraNameToFind, _, _, currentAuraName)
            return auraNameToFind == currentAuraName
        end

        return AuraUtil.FindAura(NamePredicate, unit, filter, auraName)
    end

    function AuraUtil.ForEachAura(unit, filter, maxCount, func)
        if maxCount and maxCount <= 0 then
            return
        end

        local index = 1
        while true do
            local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId =
                UnitAura(unit, index, filter)
            if not name then
                break
            end

            if func(name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId) then
                break
            end

            index = index + 1
            if maxCount and index > maxCount then
                break
            end
        end
    end

    _G.AuraUtil = AuraUtil
end

-- -----------------------------------------------------------------------------
-- Tiny callback helper
-- -----------------------------------------------------------------------------

if not _G.CallbackRegistryMixin then
    local ownerCounter = 0

    local function NextOwnerId()
        ownerCounter = ownerCounter + 1
        return ownerCounter
    end

    local function SafeCall(func, ...)
        if securecallfunction then
            return securecallfunction(func, ...)
        end
        return func(...)
    end

    local CallbackRegistryMixin = {}

    function CallbackRegistryMixin:OnLoad()
        self.callbackTables = self.callbackTables or {}
    end

    function CallbackRegistryMixin:SetUndefinedEventsAllowed(allowed)
        self.isUndefinedEventAllowed = allowed
    end

    function CallbackRegistryMixin:GetCallbackTables()
        if not self.callbackTables then
            self:OnLoad()
        end
        return self.callbackTables
    end

    function CallbackRegistryMixin:GetCallbacksByEvent(event)
        local callbackTables = self:GetCallbackTables()
        callbackTables[event] = callbackTables[event] or {}
        return callbackTables[event]
    end

    function CallbackRegistryMixin:HasRegistrantsForEvent(event)
        local callbacks = self:GetCallbacksByEvent(event)
        return next(callbacks) ~= nil
    end

    function CallbackRegistryMixin:RegisterCallback(event, func, owner, ...)
        if type(event) ~= "string" then
            error("CallbackRegistryMixin:RegisterCallback 'event' requires string type.")
        end
        if type(func) ~= "function" then
            error("CallbackRegistryMixin:RegisterCallback 'func' requires function type.")
        end

        owner = owner or NextOwnerId()
        local callbacks = self:GetCallbacksByEvent(event)
        local argCount = select("#", ...)

        callbacks[owner] = {
            func = func,
            owner = owner,
            args = argCount > 0 and { ... } or nil,
        }

        return owner
    end

    function CallbackRegistryMixin:RegisterCallbackWithHandle(event, func, owner, ...)
        owner = self:RegisterCallback(event, func, owner, ...)
        return {
            Unregister = function()
                self:UnregisterCallback(event, owner)
            end,
        }
    end

    function CallbackRegistryMixin:TriggerEvent(event, ...)
        if type(event) ~= "string" then
            error("CallbackRegistryMixin:TriggerEvent 'event' requires string type.")
        end
        if not self.isUndefinedEventAllowed and self.Event and not self.Event[event] then
            error(string.format("CallbackRegistryMixin:TriggerEvent event '%s' doesn't exist.", event))
        end

        local callbacks = self:GetCallbacksByEvent(event)
        for _, callback in pairs(callbacks) do
            if callback.args then
                local packed = callback.args
                local function InvokeWithArgs(...)
                    return callback.func(callback.owner, unpack(packed), ...)
                end
                SafeCall(InvokeWithArgs, ...)
            else
                SafeCall(callback.func, callback.owner, ...)
            end
        end
    end

    function CallbackRegistryMixin:UnregisterCallback(event, owner)
        if type(event) ~= "string" then
            error("CallbackRegistryMixin:UnregisterCallback 'event' requires string type.")
        end
        if owner == nil then
            error("CallbackRegistryMixin:UnregisterCallback 'owner' is required.")
        end

        local callbacks = self:GetCallbacksByEvent(event)
        callbacks[owner] = nil
    end

    function CallbackRegistryMixin:UnregisterEvents(eventTable)
        local callbackTables = self:GetCallbackTables()
        if eventTable then
            for event in pairs(eventTable) do
                callbackTables[event] = nil
            end
        else
            wipe(callbackTables)
        end
    end

    function CallbackRegistryMixin:GenerateCallbackEvents(events)
        self.Event = self.Event or {}
        for _, eventName in ipairs(events) do
            self.Event[eventName] = eventName
        end
    end

    function CallbackRegistryMixin.DoesFrameHaveEvent(frame, event)
        return frame.Event and frame.Event[event]
    end

    _G.CallbackRegistryMixin = CallbackRegistryMixin
end
