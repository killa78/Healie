------------------------
--Special Thanks to Fuzzrig for help <3 and  Naiadra for helping me test!
------------------------
 
require "Window"
 
-----------------------------------------------------------------------------------------------
-- Healie Module Definition
-----------------------------------------------------------------------------------------------
local Healie = {} 
 
-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
-- e.g. local kiExampleVariableMax = 999
local tConfig = { }

	tConfig.option = {
		maxRange 		= 35.0,
		iKeySelected    = 86,
	}

local tKey = {}

        tKey[16] = "shift"
		tKey[17] = "ctrl"
		tKey[65] = "a"
		tKey[66] = "b"
	  	tKey[67] = "c"
	  	tKey[68] = "d"
	  	tKey[69] = "e"
	  	tKey[70] = "f"
	  	tKey[71] = "g"
	  	tKey[72] = "h"
	  	tKey[73] = "i"
		tKey[74] = "j"
		tKey[75] = "k"
		tKey[76] = "l"
		tKey[77] = "m"
		tKey[78] = "n"
		tKey[79] = "o"
		tKey[80] = "p"
		tKey[81] = "q"
		tKey[82] = "r"
		tKey[83] = "s"
		tKey[84] = "t"
		tKey[85] = "u"
		tKey[86] = "v"
		tKey[87] = "w"
		tKey[88] = "x"
		tKey[89] = "y"
		tKey[90] = "z"
		tKey[96] = "0"
		tKey[97] = "1"
		tKey[98] = "2"
		tKey[99] = "3"
		tKey[100] = "4"
		tKey[101] = "5"
		tKey[102] = "6"
		tKey[103] = "7"
		tKey[104] = "8"
		tKey[105] = "9"

-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function Healie:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

    -- initialize variables here


    return o
end



function Healie:Init()
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {
		-- "UnitOrPackageName",
	}
    Apollo.RegisterAddon(self, bHasConfigureButton, strConfigureButtonText, tDependencies)
end
 

-----------------------------------------------------------------------------------------------
-- Healie OnLoad
-----------------------------------------------------------------------------------------------
function Healie:OnLoad()
    -- load our form file
	self.xmlDoc = XmlDoc.CreateFromFile("Healie.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
end

-----------------------------------------------------------------------------------------------
-- Healie OnDocLoaded
-----------------------------------------------------------------------------------------------
function Healie:OnDocLoaded()

	if self.xmlDoc ~= nil and self.xmlDoc:IsLoaded() then
	    self.wndMain = Apollo.LoadForm(self.xmlDoc, "HealieForm", nil, self)
	    self.wndOptions = Apollo.LoadForm(self.xmlDoc, "options", nil, self)
		if self.wndMain == nil then
			Apollo.AddAddonErrorText(self, "Could not load the main window for some reason.")
			return
		end
		
	    self.wndMain:Show(false, true)
		self.wndOptions:Show(false, true)

		-- if the xmlDoc is no longer needed, you should set it to nil
		-- self.xmlDoc = nil
		
		-- Register handlers for events, slash commands and timer, etc.
		-- e.g. Apollo.RegisterEventHandler("KeyDown", "OnKeyDown", self)
		Apollo.RegisterSlashCommand("healie", "OnHealieOn", self)
		Apollo.RegisterSlashCommand("healieopts", "OnHealieOptions", self)
		Apollo.RegisterEventHandler("SystemKeyDown", "TargetLowest", self)
		-- Do additional Addon initialization here
	end
end

-----------------------------------------------------------------------------------------------
-- Healie Functions
-----------------------------------------------------------------------------------------------
-- Define general functions here

-- on SlashCommand "/healie"
function Healie:OnHealieOn()
	self.wndMain:Show(true) -- show the window
end

function Healie:OnHealieOptions()
	self.wndOptions:Show(true) -- show the window
end


-----------------------------------------------------------------------------------------------
-- HealieForm Functions
-----------------------------------------------------------------------------------------------
-- when the OK button is clicked
function Healie:OnOK()
self.wndMain:Show(false) -- hide the window
self.wndOptions:Show(true)
end

-- when the Cancel button is clicked
function Healie:OnCancel()
	self.wndMain:Show(false) -- hide the window
end

function Healie:onGotIt( wndHandler, wndControl, eMouseButton )
self.wndMain:Show(false)
end

-- Do stuff!

function Healie:LowestHP() -- in range :D
local lowestMember = 0
local lowestHP = 0
	for i=1, GroupLib.GetMemberCount() do
		if i==1 then
			lowestHP = (GroupLib.GetGroupMember(i).nHealthMax - GroupLib.GetGroupMember(i).nHealth)
			lowestMember = i
	else
		currentHP = (GroupLib.GetGroupMember(i).nHealthMax - GroupLib.GetGroupMember(i).nHealth)
		local nTarCurHealth = GroupLib.GetGroupMember(i).nHealth
		local unit2 = GameLib.GetPlayerUnit()
		local unit1 = GroupLib.GetUnitForGroupMember(i)
		local maxRange = tConfig.option.maxRange
		if unit1 == nil then
		--do nothing
		elseif nTarCurHealth ~= 0 and Healie:RangeCheck(unit1, unit2, maxRange) and (currentHP > lowestHP)  then 
			lowestMember = i
			lowestHP = currentHP
		end 
		end 
	end
		return lowestMember
	end
	
-- If X is pressed, Call the HP finder.
function Healie:TargetLowest(iKey)
	if iKey == tConfig.option.iKeySelected then -- 88 = X
	local lowestMember = Healie:LowestHP()
	GameLib.SetTargetUnit(GroupLib.GetUnitForGroupMember(lowestMember))
	end
end

function Healie:RangeCheck(unit1, unit2, maxRange)
local v1 = unit1:GetPosition()
local v2 = unit2:GetPosition()
local dx, dy, dz = v1.x - v2.x, v1.y - v2.y, v1.z - v2.z
	return dx*dx + dy*dy + dz*dz <= maxRange*maxRange
end






---------------------------------------------------------------------------------------------------
-- options Functions
---------------------------------------------------------------------------------------------------

function Healie:closeOptions( wndHandler, wndControl, eMouseButton )
self.wndOptions:Show(false)
end


function Healie:onRangeSliderChanged( wndHandler, wndControl, fNewValue, fOldValue )
local roundItUp = math.ceil(fNewValue)
self.wndOptions:FindChild("rangeDisplayBox"):SetText(roundItUp)
tConfig.option.maxRange = roundItUp
end


function Healie:onKeybindBoxChanged( wndHandler, wndControl, strText )
	local keybindLen = self.wndOptions:FindChild("bindInputBox"):GetText():len()
		if keybindLen > 1 then
			self.wndOptions:FindChild("bindInputBox"):SetText("V")
			self.wndOptions:FindChild("bindInputBox"):ClearFocus()
			tConfig.option.iKeySelected = 86
		else
			self.wndOptions:FindChild("bindInputBox"):SetText(string.upper(strText))
			self.wndOptions:FindChild("bindInputBox"):ClearFocus()
			local idx = self:inTable(tKey, string.lower(strText))
				if idx ~= false then
				tConfig.option.iKeySelected = idx
				end
		end
end

function Healie:inTable(tTable, item)
    for key, value in pairs(tTable) do
        if value == item then return key end
    end
    return false
end

--------------------------end-----------
-- Healie Instance
-----------------------------------------------------------------------------------------------
local HealieInst = Healie:new()
HealieInst:Init()







