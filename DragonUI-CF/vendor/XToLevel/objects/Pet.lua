---
-- Defines the Pet functionality.
-- functionality.
-- @file XToLevel.Pet.lua
-- @release 3.3.3_13r
-- @copyright Atli Þór (atli@advefir.com)
---
XToLevel.Pet = {
	isActive = false,
	hasBeenActive = false,
	name = nil,
	level = nil,
	xp = nil,
	maxXP = nil,
	maxLevel = nil,
	killList = nil,
	killAverage = nil,
	killListLength = 100,
	
	nextMobName = nil, -- The name of the next mob to be announced... Dirty workaround :/
	
	---
	-- function description
	Initialize = function(self)
		-- Make sure the player has a pet
		if not self:IsHunterPet() then
			self.isActive = false
			return false;
		end
        
        -- Update the object with the data for the current pet
        if not self:Update() then
			self.isActive = false
			return false
		end
        self.killAverage = nil
        
        -- After a successful update, self.name should be valid.
        if not sData.pet.killList[self.name] then
            sData.pet.killList[self.name] = { }
        end
	end,
	
	-- Updates the pet xp info
	---
	-- function description
	Update = function(self)
		if not self:IsHunterPet() then
			return false;
		end
        
        local oldXP, oldLevel
        local output = {}
        
		oldXP = self.xp
        oldLevel = self.level
	
		self.name = UnitName("pet")
		-- If pet name is not available, pet data is likely not ready. Abort.
		if not self.name then
			return false
		end
		
		self.level = UnitLevel('pet')
		self.maxLevel = XToLevel.Player.level or UnitLevel('player')
		self.xp, self.maxXP = GetPetExperience()
		
		-- Ensure level is valid before comparing
		if self.level and self.maxLevel and self.level < self.maxLevel then
			self.isActive = true;
			self.hasBeenActive = true;
		else
			self.isActive = false;
		end
		
		if oldXP and self.xp then -- ensure self.xp is not nil
			output.xp = self.xp - oldXP
			-- Make sure this falls within realistic gains from a kill.
			-- Otherwise this may be an initialization update or pet swap.
			-- Also check if self.level is available, as it's needed for PetXP calculation.
			if self.level and output.xp > 0 and output.xp < (XToLevel.Lib:PetXP(XToLevel.Player.level, self.level, XToLevel.Player.level) * 3) then
				self:AddKill(output.xp)
			end
        else
            output.xp = 0
		end
        if oldLevel and self.level and oldLevel == (self.level - 1) then
            output.gainedLevel = true
        else
            output.gainedLevel = false      
        end
		
		return output
	end,
    
    -- Check whether the pet is a hunter's pet.
    ---
    -- function description
    IsHunterPet = function(self)
        local hasUI, isHunterPet = HasPetUI();
		if hasUI then 
            if isHunterPet then
                return true;
            else
                return false;
            end
		else
            return false;
        end
    end,
	
	---
	-- function description
	AddKill = function(self, xp)
		-- Add a guard here as well for robustness, in case Update logic changes.
		if not self.name then return end
		
		if not sData.pet.killList then
			sData.pet.killList = { }
		end
		if not sData.pet.killList[self.name] then
			sData.pet.killList[self.name] = {}
		end
		if xp > 0 then
			self.killAverage = nil
			table.insert(sData.pet.killList[self.name], 1, xp)
			if(# sData.pet.killList[self.name] > self.killListLength) then
				table.remove(sData.pet.killList[self.name])
			end
		end
	end,
	
	---
	-- function description
	GetAverageKillXP = function(self)
		if self.killAverage == nil then
			-- Ensure self.name is valid before proceeding
			if self.name and sData.pet.killList[self.name] and (# sData.pet.killList[self.name] > 0) then
				local total = 0
				local maxUsed = # sData.pet.killList[self.name]
				if maxUsed > sConfig.averageDisplay.petKillListLength then
					maxUsed = sConfig.averageDisplay.petKillListLength
				end
				for index, value in ipairs(sData.pet.killList[self.name]) do
					if index > maxUsed then
						break;
					end
					total = total + (value or 0)
				end
				if total > 0 then
					self.killAverage = (total / maxUsed);
				else
					-- Fallback if data is corrupted
					if self.level then
						self.killAverage = XToLevel.Lib:PetXP(XToLevel.Player.level, self.level, XToLevel.Player.level)
						sData.pet.killList[self.name] = { }
						table.insert(sData.pet.killList[self.name], tonumber(self.killAverage))
					else
						-- Can't calculate if level is unknown
						self.killAverage = 0
					end
				end
			else
				-- Fallback if no data or no pet name
				if self.level then
					self.killAverage = XToLevel.Lib:PetXP(XToLevel.Player.level, self.level, XToLevel.Player.level)
				else
					self.killAverage = 0
				end
			end
		end
		return self.killAverage
	end,
	
	---
	-- function description
	GetAverageKillsRemaining = function(self)
		local xpRemaining, killsRemaining, avgKillXp;

		xpRemaining = (self.maxXP or 0) - (self.xp or 0)
		avgKillXp = self:GetAverageKillXP()
		if avgKillXp > 0 then
			killsRemaining = ceil(xpRemaining / avgKillXp);
		else
			killsRemaining = 0 -- or some other indicator of an issue
		end
		
		return killsRemaining;
	end,
	
	---
	-- function description
	GetProgressAsPercentage = function(self, fractions)
       if type(fractions) ~= "number" or fractions <= 0 then
            fractions = 0
        end
        return XToLevel.Lib:round((self.xp or 0) / (self.maxXP or 1) * 100, fractions)
    end,
	
	---
	-- function description
	GetProgressAsBars = function(self, fractions)
	   if type(fractions) ~= "number" or fractions <= 0 then
            fractions = 0
        end
        local barsRemaining = ceil((100 - ((self.xp or 0) / (self.maxXP or 1) * 100)) / 5, fractions)
        return barsRemaining
	end,
	
	GetXpRemaining = function(self)
		return (self.maxXP or 0) - (self.xp or 0)
	end,
	
	---
	-- function description
	ClearKillList = function (self, initialValue)
		sData.pet.killList = { }
        if initialValue ~= nil and tonumber(initialValue) > 0 then
            table.insert(sData.pet.killList, tonumber(initialValue))
        end
	end,
	
	---
	-- function description
	GetMobName = function(self)
		if self.nextMobName then
			local name = self.nextMobName
			self.nextMobName = nil
			return name
		else
			return strlower(L["Kills"])
		end
	end,
	
	---
	-- function description
	GetName = function(self)
		if not self.name then
			self.name = UnitName("pet")
		end
		return self.name -- /run XToLevel.Messages:Print(XToLevel.Pet:GetName())
	end,
    
    --
    -- Clear methods
    --
    ---
    -- function description
    ClearKills = function(self)
        sData.pet.killList = { }
        self.killAverage = nil;
    end,
    
    ---
    -- Sets the number of kills used for average calculations
    SetKillAverageLength = function(self, newValue)
    	sConfig.averageDisplay.petKillListLength = newValue
    	self.killAverage = nil
    	XToLevel.Average:Update()
    	XToLevel.LDB:Update()
    end,
};