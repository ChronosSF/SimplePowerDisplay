local cPointDisplay = LibStub("AceAddon-3.0"):NewAddon("cPointDisplay", "AceConsole-3.0", "AceEvent-3.0", "AceBucket-3.0")
local LSM = LibStub("LibSharedMedia-3.0")
local db

cPointDisplay.Types = {
	["GENERAL"] = {
		name = "General",
		points = {
			[1] = { name = "Combo Points", id = "cp", barcount = 5, fullcount = 5 },
			[2] = { name = "Combo Points with Deeper Stratagem", id = "cp6", barcount = 6, fullcount = 6 },
		}
	},
	["PALADIN"] = {
		name = "Paladin",
		points = {
			[1] = { name = "Holy Power", id = "hp", barcount = 5, fullcount = 5 },
		}
	},
	["WARLOCK"] = {
		name = "Warlock",
		points = {
			[1] = { name = "Soul Shards", id = "ss", barcount = 5, fullcount = 5 },
			[2] = { name = "Soul Shards Precise", id = "ssf", barcount = 5, fullcount = 5 },
		}
	},
	["MAGE"] = {
		name = "Mage",
		points = {
			[1] = { name = "Arcane Charges", id = "ac", barcount = 4, fullcount = 4},
			[2] = { name = "Icicles", id = "ic", barcount = 5, fullcount = 5}
		}
	},
	["MONK"] = {
		name = "Monk",
		points = {
			[1] = { name = "Chi", id = "c5",  barcount = 5, fullcount = 5 },
			[2] = { name = "Chi with Ascension", id = "c6",  barcount = 6, fullcount = 6 }
		}
	},
	["SHAMAN"] = {
		name = "Shaman",
		points = {
			[1]	= { name = "Maelstrom Weapon", id = "mw", barcount = 10, fullcount = 5 }
		}
	},
	["DEMONHUNTER"] = {
		name = "Demon Hunter",
		points = {
			[1]	= { name = "Soul Fragments", id = "sf", barcount = 5, fullcount = 5 }
		}
	}
}
local Types = cPointDisplay.Types

---- Spell Info table
local SpellInfo = {
	["si"] = nil,
	["bs"] = nil,
	["lus"] = nil,
	["lac"] = nil,
	["al"] = nil,
	["rsa"] = nil,
	["fe"] = nil,
	["ab"] = nil,
	["ff"] = nil,
	["sz"] = nil,
	["vm"] = nil,
	["eva"] = nil,
	["deva"] = nil,
	["ser"] = nil,
	["bg"] = {[1] = nil, [2] = nil, [3] = nil},
	["ant"] = nil,
	["mw"] = nil,
	["ls"] = nil,
	["tw"] = nil,
	["ws"] = nil,
	["mco"] = nil,
	["ts"] = nil,
	["mc"] = nil,
	["sa"] = nil,
	["tb"] = nil,
}

---- Defaults
local defaults = {
	profile = {
		updatespeed = 8,
		classcolor = {
			enabled = false,
			bg = {
				empty = 0.15,
				normal = 0.7,
				max = 1,
			},
			border = {
				empty = 0,
				normal = 0,
				max = 0,
			},
			spark = {
				normal = 0.8,
				max = 1,
			},
		},
	-- CLASS/ID
		["*"] = {
			types = {
			-- Point Display type
				["*"] = {
					enabled = true,
					configmode = {
						enabled = false,
						count = 2,
					},
					general = {
						hideui = false,
						hideempty = false,
						hidein = {
							vehicle = false,
							spec = 1,
						},
						direction = {
							vertical = false,
							reverse = false,
						},
						showatzero = false,
					},
					position = {
						parent = "UIParent",
						anchorto = "CENTER",
						anchorfrom = "CENTER",
						x = 0,
						y = 0,
						framelevel = {
							strata = "MEDIUM",
							level = 2,
						},
					},
					bgpanel = {
						enabled = false,
						size = {
							width = 150,
							height = 12,
						},
						bg = {
							texture = "Solid",
							color = {r = 0.37, g = 0.37, b = 0.37, a = 1},
						},
						border = {
							texture = "Solid",
							edgesize = 1,
							inset = 0,
							color = {r = 0, g = 0, b = 0, a = 1},
						},
					},
					bars = {
						["*"] = {
							position = {
								gap = -1,
								xofs = 0,
								yofs = 0,
							},
							size = {
								width = 25,
								height = 8,
							},
							bg = {
								empty = {
									texture = "Solid",
									color = {r = 0.14, g = 0.14, b = 0.14, a = 1},
								},
								full = {
									texture = "Solid",
									color = {r = 0.7, g = 0.7, b = 0.7, a = 1},
									maxcolor = {r = 1, g = 1, b = 1, a = 1},
								},
							},
							border = {
								empty = {
									texture = "Solid",
									edgesize = 1,
									inset = 0,
									color = {r = 0, g = 0, b = 0, a = 1},
								},
								full = {
									texture = "Solid",
									edgesize = 1,
									inset = 0,
									color = {r = 0, g = 0, b = 0, a = 1},
									maxcolor = {r = 0, g = 0, b = 0, a = 1},
								},
							},
							spark = {
								enabled = false,
								position = {
									x = 0,
									y = 0,
								},
								size = {
									width = 32,
									height = 18,
								},
								bg = {
									texture = "",
									color = {r = 0.8, g = 0.8, b = 0.8, a = 1},
									maxcolor = {r = 1, g = 1, b = 1, a = 1},
								},
							},
						},
					},
					combatfader = {
						enabled = false,
						opacity = {
							incombat = 1,
							hurt = .7,
							target = .7,
							outofcombat = .3,
						},
					},
				},
			},
		},
	},
}

-- Point Display tables
local Frames = {}
local Borders = {}
local BG = {}

-- Points
local Points = {}
local PointsChanged = {}
local ClassColors
local ClassColorBarTable = {}

local LoggedIn = false
local PlayerClass
local PlayerSpec

local ValidClasses

-- Combat Fader
local CFFrame = CreateFrame("Frame")
local FadeTime = 0.25
local CFStatus = nil

-- Power 'Full' check
local power_check = {
	MANA = function()
		return UnitPower("player", 0) < UnitPowerMax("player", 0)
	end,
	RAGE = function()
		return UnitPower("player", 1) > 0
	end,
	ENERGY = function()
		return UnitPower("player", 3) < UnitPowerMax("player", 3)
	end,
	RUNICPOWER = function()
		return UnitPower("player", 6) > 0
	end,
}

-- Fade frame
local function FadeIt(self, NewOpacity)
	local CurrentOpacity = self:GetAlpha()
	if NewOpacity > CurrentOpacity then
		UIFrameFadeIn(self, FadeTime, CurrentOpacity, NewOpacity)
	elseif NewOpacity < CurrentOpacity then
		UIFrameFadeOut(self, FadeTime, CurrentOpacity, NewOpacity)
	end
end

-- Determine new opacity values for frames
function cPointDisplay:FadeFrames()
	for ic,vc in pairs(Types) do
		for it,vt in ipairs(Types[ic].points) do
			local NewOpacity
			local tid = Types[ic].points[it].id
			-- Retrieve opacity/visibility for current status
			NewOpacity = 1
			if db[ic].types[tid].combatfader.enabled then
				if CFStatus == "DISABLED" then
					NewOpacity = 1
				elseif CFStatus == "INCOMBAT" then
					NewOpacity = db[ic].types[tid].combatfader.opacity.incombat
				elseif CFStatus == "TARGET" then
					NewOpacity = db[ic].types[tid].combatfader.opacity.target
				elseif CFStatus == "HURT" then
					NewOpacity = db[ic].types[tid].combatfader.opacity.hurt
				elseif CFStatus == "OUTOFCOMBAT" then
					NewOpacity = db[ic].types[tid].combatfader.opacity.outofcombat
				end

				-- Fade Frame
				FadeIt(Frames[ic][tid].bgpanel.frame, NewOpacity)
			else
				-- Combat Fader disabled for this frame
				if Frames[ic][tid].bgpanel.frame:GetAlpha() < 1 then
					FadeIt(Frames[ic][tid].bgpanel.frame, NewOpacity)
				end
			end
		end
	end
	cPointDisplay:UpdatePointDisplay("ENABLE")
end

function cPointDisplay:UpdateCFStatus()
	local OldStatus = CFStatus

	-- Combat Fader based on status
	if UnitAffectingCombat("player") then
		CFStatus = "INCOMBAT"
	elseif UnitExists("target") then
		CFStatus = "TARGET"
	elseif UnitHealth("player") < UnitHealthMax("player") then
		CFStatus = "HURT"
	else
		local _, power_token = UnitPowerType("player")
		local func = power_check[power_token]
		if func and func() then
			CFStatus = "HURT"
		else
			CFStatus = "OUTOFCOMBAT"
		end
	end
	if CFStatus ~= OldStatus then cPointDisplay:FadeFrames() end
end

function cPointDisplay:UpdateCombatFader()
	CFStatus = nil
	cPointDisplay:UpdateCFStatus()
end

-- On combat state change
function cPointDisplay:CombatFaderCombatState()
	-- If in combat, then don't worry about health/power events
	if UnitAffectingCombat("player") then
		CFFrame:UnregisterEvent("UNIT_HEALTH")
		CFFrame:UnregisterEvent("UNIT_POWER_UPDATE")
		CFFrame:UnregisterEvent("UNIT_DISPLAYPOWER")
	else
		CFFrame:RegisterEvent("UNIT_HEALTH")
		CFFrame:RegisterEvent("UNIT_POWER_UPDATE")
		CFFrame:RegisterEvent("UNIT_DISPLAYPOWER")
	end
end

-- Register events for Combat Fader status
function cPointDisplay:UpdateCombatFaderEnabled()
	CFFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	CFFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
	CFFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
	CFFrame:RegisterEvent("PLAYER_REGEN_DISABLED")

	CFFrame:SetScript("OnEvent", function(self, event, ...)
		if event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_REGEN_DISABLED" then
			cPointDisplay:CombatFaderCombatState()
			cPointDisplay:UpdateCFStatus()
		elseif event == "UNIT_HEALTH" or event == "UNIT_POWER_UPDATE" or event == "UNIT_DISPLAYPOWER" then
			local unit = ...
			if unit == "player" then
				cPointDisplay:UpdateCFStatus()
			end
		elseif event == "PLAYER_TARGET_CHANGED" then
			cPointDisplay:UpdateCFStatus()
		elseif event == "PLAYER_ENTERING_WORLD" then
			cPointDisplay:CombatFaderCombatState()
			cPointDisplay:UpdateCombatFader()
		end
	end)

	cPointDisplay:UpdateCombatFader()
	cPointDisplay:FadeFrames()
end

local function SetEmptyBarTextures(ic, it, tid, i)
	local cc = ClassColorBarTable[ic]
	local dbc = db[ic].types[tid].bars[i]
	Frames[ic][tid].bars[i].bg:SetTexture(BG[ic][tid].bars[i].empty)
	Frames[ic][tid].bars[i].border:SetBackdrop({bgFile = "", edgeFile = Borders[ic][tid].bars[i].empty, edgeSize = dbc.border.empty.edgesize, tile = false, tileSize = 0, insets = {left = 0, right = 0, top = 0, bottom = 0}})
	Frames[ic][tid].bars[i].border:SetHeight(dbc.size.height - dbc.border.empty.inset)
	Frames[ic][tid].bars[i].border:SetWidth(dbc.size.width - dbc.border.empty.inset)

	if db.classcolor.enabled then
		Frames[ic][tid].bars[i].bg:SetVertexColor(cc.bg.empty.r, cc.bg.empty.g, cc.bg.empty.b, dbc.bg.empty.color.a)
		Frames[ic][tid].bars[i].border:SetBackdropBorderColor(cc.border.empty.r, cc.border.empty.g, cc.border.empty.b, dbc.border.empty.color.a)
	else
		Frames[ic][tid].bars[i].bg:SetVertexColor(dbc.bg.empty.color.r, dbc.bg.empty.color.g, dbc.bg.empty.color.b, dbc.bg.empty.color.a)
		Frames[ic][tid].bars[i].border:SetBackdropBorderColor(dbc.border.empty.color.r, dbc.border.empty.color.g, dbc.border.empty.color.b, dbc.border.empty.color.a)
	end
end

local function SetPartialBarTextures(ic, it, tid, i, partial)
	local cc = ClassColorBarTable[ic]
	local dbc = db[ic].types[tid].bars[i]
	local toColorize = partial

	for j = 0, 8 do
		Frames[ic][tid].bars[i].subbars[j].frame:Show()

		-- BG
		Frames[ic][tid].bars[i].subbars[j].bg:SetTexture(BG[ic][tid].bars[i].full)

		-- Colors
		if j < toColorize then
			Frames[ic][tid].bars[i].subbars[j].frame:Show()
			if db.classcolor.enabled then Frames[ic][tid].bars[i].subbars[j].bg:SetVertexColor(cc.bg.normal.r, cc.bg.normal.g, cc.bg.normal.b, dbc.bg.full.color.a)
			else Frames[ic][tid].bars[i].subbars[j].bg:SetVertexColor(dbc.bg.full.color.r, dbc.bg.full.color.g, dbc.bg.full.color.b, dbc.bg.full.color.a) end
		else
			Frames[ic][tid].bars[i].subbars[j].frame:Hide()
			if db.classcolor.enabled then Frames[ic][tid].bars[i].subbars[j].bg:SetVertexColor(cc.bg.max.r, cc.bg.max.g, cc.bg.max.b, dbc.bg.full.maxcolor.a)
			else Frames[ic][tid].bars[i].subbars[j].bg:SetVertexColor(dbc.bg.full.maxcolor.r, dbc.bg.full.maxcolor.g, dbc.bg.full.maxcolor.b, dbc.bg.full.maxcolor.a) end
		end
	end
end

local function SetPointBarTextures(ic, it, tid, i, points)
	local cc = ClassColorBarTable[ic]
	local dbc = db[ic].types[tid].bars[i]
	-- BG
	Frames[ic][tid].bars[i].bg:SetTexture(BG[ic][tid].bars[i].full)

	-- Border
	Frames[ic][tid].bars[i].border:SetBackdrop({bgFile = "", edgeFile = Borders[ic][tid].bars[i].full, edgeSize = dbc.border.full.edgesize, tile = false, tileSize = 0, insets = {left = 0, right = 0, top = 0, bottom = 0}})
	Frames[ic][tid].bars[i].border:SetHeight(dbc.size.height - dbc.border.full.inset)
	Frames[ic][tid].bars[i].border:SetWidth(dbc.size.width - dbc.border.full.inset)

	-- Colors
	if points < Types[ic].points[it].fullcount then
		if db.classcolor.enabled then
			Frames[ic][tid].bars[i].bg:SetVertexColor(cc.bg.normal.r, cc.bg.normal.g, cc.bg.normal.b, dbc.bg.full.color.a)
			Frames[ic][tid].bars[i].border:SetBackdropBorderColor(cc.border.normal.r, cc.border.normal.g, cc.border.normal.b, dbc.border.full.color.a)
		else
			Frames[ic][tid].bars[i].bg:SetVertexColor(dbc.bg.full.color.r, dbc.bg.full.color.g, dbc.bg.full.color.b, dbc.bg.full.color.a)
			Frames[ic][tid].bars[i].border:SetBackdropBorderColor(dbc.border.full.color.r, dbc.border.full.color.g, dbc.border.full.color.b, dbc.border.full.color.a)
		end
	else
		if db.classcolor.enabled then
			Frames[ic][tid].bars[i].bg:SetVertexColor(cc.bg.max.r, cc.bg.max.g, cc.bg.max.b, dbc.bg.full.maxcolor.a)
			Frames[ic][tid].bars[i].border:SetBackdropBorderColor(cc.border.max.r, cc.border.max.g, cc.border.max.b, dbc.bg.full.maxcolor.a)
		else
			Frames[ic][tid].bars[i].bg:SetVertexColor(dbc.bg.full.maxcolor.r, dbc.bg.full.maxcolor.g, dbc.bg.full.maxcolor.b, dbc.bg.full.maxcolor.a)
			Frames[ic][tid].bars[i].border:SetBackdropBorderColor(dbc.border.full.maxcolor.r, dbc.border.full.maxcolor.g, dbc.border.full.maxcolor.b, dbc.border.full.maxcolor.a)
		end
	end

	-- Spark
	if dbc.spark.enabled then
		Frames[ic][tid].bars[i].spark.frame:Show()
		Frames[ic][tid].bars[i].spark.bg:SetTexture(BG[ic][tid].bars[i].spark)
		if points < Types[ic].points[it].barcount then
			-- Normal color
			if db.classcolor.enabled then
				Frames[ic][tid].bars[i].spark.bg:SetVertexColor(cc.spark.normal.r, cc.spark.normal.g, cc.spark.normal.b, dbc.spark.bg.color.a)
			else
				Frames[ic][tid].bars[i].spark.bg:SetVertexColor(dbc.spark.bg.color.r, dbc.spark.bg.color.g, dbc.spark.bg.color.b, dbc.spark.bg.color.a)
			end
		else
			-- Max color
			if db.classcolor.enabled then
				Frames[ic][tid].bars[i].spark.bg:SetVertexColor(cc.spark.max.r, cc.spark.max.g, cc.spark.max.b, dbc.spark.bg.maxcolor.a)
			else
				Frames[ic][tid].bars[i].spark.bg:SetVertexColor(dbc.spark.bg.maxcolor.r, dbc.spark.bg.maxcolor.g, dbc.spark.bg.maxcolor.b, dbc.spark.bg.maxcolor.a)
			end
		end
	else
		Frames[ic][tid].bars[i].spark.frame:Hide()
	end
end

-- Update Point Bars
local function HideAtIndex(ic, it, tid, i)
	if db[ic].types[tid].general.hideempty then
	-- Hide "empty" bar
		Frames[ic][tid].bars[i].frame:Hide()
	else
	-- Show bar and set textures to "Empty"
		Frames[ic][tid].bars[i].frame:Show()
		SetEmptyBarTextures(ic, it, tid, i)
	end
	-- Hide the "Spark"
	Frames[ic][tid].bars[i].spark.frame:Hide()
	if #Frames[ic][tid].bars[i].subbars > 0 then
		for j = 0, 8 do Frames[ic][tid].bars[i].subbars[j].frame:Hide() end
	end
end

function cPointDisplay:UpdatePointDisplay(...)
	local UpdateList
	if ... == "ENABLE" then
		-- Update everything
		UpdateList = Types
	else
		UpdateList = ValidClasses
	end

	-- Cycle through all Types that need updating
	for ic,vc in pairs(UpdateList) do
		-- Cycle through all Point Displays in current Type
		if Types[ic] then
			for it,vt in ipairs(Types[ic].points) do
				local tid = Types[ic].points[it].id

				-- Do we hide the Display
				if ((Points[tid] == 0 and not db[ic].types[tid].general.showatzero)
					or (Points[tid] == nil)
					or (ic ~= PlayerClass and ic ~= "GENERAL") 	-- Not my class
					or ((PlayerClass ~= "ROGUE" and (PlayerClass ~= "DRUID" and PlayerSpec ~= 1)) and (ic == "GENERAL") and not UnitHasVehicleUI("player"))	-- Impossible to have Combo Points
					or (db[ic].types[tid].general.hidein.vehicle and UnitHasVehicleUI("player")) -- Hide in vehicle
					or ((db[ic].types[tid].general.hidein.spec - 1) == PlayerSpec))	-- Hide in spec
					and not db[ic].types[tid].configmode.enabled then	-- Not in config mode
						-- Hide Display
						Frames[ic][tid].bgpanel.frame:Hide()
				else
				-- Update the Display
					-- Update Bars if their Points have changed
					if PointsChanged[tid] then
						if Points[tid] == nil then Points[tid] = 0 end
						local points = Points[tid];
						if tid == "ssf" then points = points / 10 end
						for i = 1, Types[ic].points[it].barcount do
							if points > i - 1 and points < i and tid == "ssf" then
							--- Show bar and set texture to "Partial"
								HideAtIndex(ic, it, tid, i)
								Frames[ic][tid].bars[i].frame:Show()
								SetPartialBarTextures(ic, it, tid, i, Points[tid] - (10 * (i - 1)))
							elseif points >= i then
							-- Show bar and set textures to "Full"
								Frames[ic][tid].bars[i].frame:Show()
								SetPointBarTextures(ic, it, tid, i, points)
								if #Frames[ic][tid].bars[i].subbars > 0 then
									for j = 0, 8 do Frames[ic][tid].bars[i].subbars[j].frame:Hide() end
								end
							else
								HideAtIndex(ic, it, tid, i)
							end
						end
						-- Show the Display
						Frames[ic][tid].bgpanel.frame:Show()

						-- Flag as having been changed
						PointsChanged[tid] = false
					end
				end
			end
		end
	end
end

local function GetBuffCount(Spell, ...)
	if not Spell then return end
	local unit = ... or "player"
	for i = 1, 255 do
		local name, _, count, _, _, _, _, _, _, id = UnitAura(unit, i, "HELPFUL")
		if not name then return end
		if Spell == id or Spell == name then
			if (count == nil) then count = 0 end
			return count
		end
	end
	return 0
end

function cPointDisplay:GetPoints(CurClass, CurType)
	local NewPoints
	-- General
	if CurClass == "GENERAL" then
		-- Combo Points
		if (CurType == "cp") or (CurType == "cp6") then
			if (UnitHasVehicleUI("player") and UnitHasVehiclePlayerFrameUI("player")) then
				NewPoints = GetComboPoints("vehicle")
				if (NewPoints == 0) then
					NewPoints = GetComboPoints("vehicle", "vehicle")
				end
			else
				local maxcp = UnitPowerMax("player", 4)
				if (CurType == "cp" and maxcp == 5) or
					(CurType == "cp6" and maxcp == 6) then
					NewPoints = UnitPower("player", 4)
				end
			end
		end
	-- Paladin
	elseif CurClass == "PALADIN" then
		-- Holy Power
		if CurType == "hp" then
			NewPoints = UnitPower("player", Enum.PowerType.HolyPower)
		end
	-- Monk
	elseif CurClass == "MONK" and PlayerSpec == 3 then -- chi is only for windwalkers
		-- Chi
		local maxchi = UnitPowerMax("player", Enum.PowerType.Chi)
		if (CurType == "c5" and maxchi == 5) or
			(CurType == "c6" and maxchi == 6) then
			NewPoints = UnitPower("player", Enum.PowerType.Chi)
		end
	-- Warlock
	elseif CurClass == "WARLOCK" then
		-- Soul Shards
		NewPoints = UnitPower("player", Enum.PowerType.SoulShards, CurType == "ssf")
	-- Mage
	elseif CurClass == "MAGE" then
		-- Arcane Charges
		if CurType == "ac" and PlayerSpec == SPEC_MAGE_ARCANE then
			NewPoints = UnitPower("player", Enum.PowerType.ArcaneCharges)
		-- Icicles
		elseif CurType == "ic" and PlayerSpec == 3 then
			NewPoints = GetBuffCount(205473) -- Icicle buff id
		end
	-- Shaman
	elseif CurClass == "SHAMAN" then
		if CurType == "mw" and PlayerSpec == 2 then
			NewPoints = GetBuffCount(344179) -- Maelstrom Weapon buff id
		end
	-- Demon Hunter
	elseif CurClass == "DEMONHUNTER" then
		if CurType == "sf" and PlayerSpec == 2 then
			NewPoints = GetBuffCount(203981) -- Soul Fragments buff id
		end
	end
	Points[CurType] = NewPoints
end

-- Update all valid Point Displays
function cPointDisplay:UpdatePoints(...)
	if not LoggedIn then return end

	local HasChanged = false
	local Enable = ...

	local UpdateList
	if ... == "ENABLE" then
		-- Update everything
		UpdateList = Types
	else
		UpdateList = ValidClasses
	end

	-- ENABLE update: Config Mode / Reset displays
	if Enable == "ENABLE" then
		HasChanged = true
		for ic,vc in pairs(Types) do
			for it,vt in ipairs(Types[ic].points) do
				local tid = Types[ic].points[it].id
				PointsChanged[tid] = true
				if ( db[ic].types[tid].enabled and db[ic].types[tid].configmode.enabled ) then
					-- If Enabled and Config Mode is on, then set points
					Points[tid] = db[ic].types[tid].configmode.count
				else
					Points[tid] = 0
				end
			end
		end
	end

	-- Normal update: Cycle through valid classes
	for ic,vc in pairs(UpdateList) do
		-- Cycle through point types for current class
		if Types[ic] then
			for it,vt in ipairs(Types[ic].points) do
				local tid = Types[ic].points[it].id
				if (db[ic].types[tid].enabled and not db[ic].types[tid].configmode.enabled) then
					-- Retrieve new point count
					local OldPoints = Points[tid]
					cPointDisplay:GetPoints(ic, tid)
					if Points[tid] ~= OldPoints then
						-- Points have changed, flag for updating
						HasChanged = true
						PointsChanged[tid] = true
					end
				end
			end
		end
	end

	-- Update Point Displays
	if HasChanged then cPointDisplay:UpdatePointDisplay(Enable) end
end

-- Enable a Point Display
function cPointDisplay:EnablePointDisplay(c, t)
	cPointDisplay:UpdatePoints("ENABLE")
end

-- Disable a Point Display
function cPointDisplay:DisablePointDisplay(c, t)
	-- Set to 0 points
	Points[t] = 0
	PointsChanged[t] = true

	-- Update Point Displays
	cPointDisplay:UpdatePointDisplay("ENABLE")
end

-- Update frame positions/sizes
function cPointDisplay:UpdatePosition()
	for ic,vc in pairs(Types) do
		for it,vt in ipairs(Types[ic].points) do
			local tid = Types[ic].points[it].id
			---- BG Panel
			local Parent = _G[db[ic].types[tid].position.parent]
			if not Parent then Parent = UIParent end

			Frames[ic][tid].bgpanel.frame:SetParent(Parent)
			Frames[ic][tid].bgpanel.frame:ClearAllPoints()
			Frames[ic][tid].bgpanel.frame:SetPoint(db[ic].types[tid].position.anchorfrom, Parent, db[ic].types[tid].position.anchorto, db[ic].types[tid].position.x, db[ic].types[tid].position.y)
			Frames[ic][tid].bgpanel.frame:SetFrameStrata(db[ic].types[tid].position.framelevel.strata)
			Frames[ic][tid].bgpanel.frame:SetFrameLevel(db[ic].types[tid].position.framelevel.level)
			Frames[ic][tid].bgpanel.frame:SetWidth(db[ic].types[tid].bgpanel.size.width)
			Frames[ic][tid].bgpanel.frame:SetHeight(db[ic].types[tid].bgpanel.size.height)

			Frames[ic][tid].bgpanel.border:SetFrameStrata(db[ic].types[tid].position.framelevel.strata)
			Frames[ic][tid].bgpanel.border:SetFrameLevel(db[ic].types[tid].position.framelevel.level + 1)
			Frames[ic][tid].bgpanel.border:SetHeight(db[ic].types[tid].bgpanel.size.height - db[ic].types[tid].bgpanel.border.inset)
			Frames[ic][tid].bgpanel.border:SetWidth(db[ic].types[tid].bgpanel.size.width - db[ic].types[tid].bgpanel.border.inset)

			---- Anchor
			Frames[ic][tid].anchor.frame:SetParent(Parent)
			Frames[ic][tid].anchor.frame:ClearAllPoints()
			Frames[ic][tid].anchor.frame:SetPoint(db[ic].types[tid].position.anchorfrom, Parent, db[ic].types[tid].position.anchorto, db[ic].types[tid].position.x, db[ic].types[tid].position.y)
			Frames[ic][tid].anchor.frame:SetFrameStrata(db[ic].types[tid].position.framelevel.strata)
			Frames[ic][tid].anchor.frame:SetFrameLevel(db[ic].types[tid].position.framelevel.level)
			Frames[ic][tid].anchor.frame:SetWidth(db[ic].types[tid].bgpanel.size.width)
			Frames[ic][tid].anchor.frame:SetHeight(db[ic].types[tid].bgpanel.size.height)

			---- Point Bars
			local IsVert, IsRev = db[ic].types[tid].general.direction.vertical, db[ic].types[tid].general.direction.reverse
			local XPos, YPos, CPRatio, TWidth, THeight
			local Positions = {}
			local CPSize = {}

			-- Get total Width and Height of Point Display, and the size of each Bar
			TWidth = 0
			THeight = 0
			for i = 1, Types[ic].points[it].barcount do
				if IsVert then
					CPSize[i] = db[ic].types[tid].bars[i].size.height + db[ic].types[tid].bars[i].position.gap
					THeight = THeight + db[ic].types[tid].bars[i].size.height + db[ic].types[tid].bars[i].position.gap
				else
					CPSize[i] = db[ic].types[tid].bars[i].size.width + db[ic].types[tid].bars[i].position.gap
					TWidth = TWidth + db[ic].types[tid].bars[i].size.width + db[ic].types[tid].bars[i].position.gap
				end
			end

			-- Calculate position of each Bar
			for i = 1, Types[ic].points[it].barcount do
				local CurPos = 0
				local TVal

				-- Get appropriate total to compare each Bar against
				if IsVert then
					TVal = THeight
				else
					TVal = TWidth
				end

				-- Add up position of each Bar in sequence
				if i == 1 then
					CurPos = (CPSize[i] / 2) - (TVal / 2)
				else
					for j = 1, i-1 do
						CurPos = CurPos + CPSize[j]
					end
					CurPos = CurPos + (CPSize[i] / 2) - (TVal / 2)
				end

				-- Found Position of Bar
				Positions[i] = CurPos
			end

			-- Position each Bar
			for i = 1, Types[ic].points[it].barcount do
				local XOfs = db[ic].types[tid].bars[i].position.xofs
				local YOfs = db[ic].types[tid].bars[i].position.yofs

				local RevMult = 1
				if IsRev then RevMult = -1 end

				Frames[ic][tid].bars[i].frame:SetParent(Frames[ic][tid].bgpanel.frame)
				Frames[ic][tid].bars[i].frame:ClearAllPoints()

				if IsVert then
					XPos = 0
					YPos = Positions[i] * RevMult
				else
					XPos = Positions[i] * RevMult
					YPos = 0
				end

				Frames[ic][tid].bars[i].frame:SetPoint("CENTER", Frames[ic][tid].bgpanel.frame, "CENTER", XPos + XOfs, YPos + YOfs)

				Frames[ic][tid].bars[i].frame:SetFrameStrata(db[ic].types[tid].position.framelevel.strata)
				Frames[ic][tid].bars[i].frame:SetFrameLevel(db[ic].types[tid].position.framelevel.level + 2)
				Frames[ic][tid].bars[i].frame:SetWidth(db[ic].types[tid].bars[i].size.width)
				Frames[ic][tid].bars[i].frame:SetHeight(db[ic].types[tid].bars[i].size.height)

				Frames[ic][tid].bars[i].border:SetFrameStrata(db[ic].types[tid].position.framelevel.strata)
				Frames[ic][tid].bars[i].border:SetFrameLevel(db[ic].types[tid].position.framelevel.level + 4)

				Frames[ic][tid].bars[i].spark.frame:SetParent(Frames[ic][tid].bars[i].frame)
				Frames[ic][tid].bars[i].spark.frame:ClearAllPoints()
				Frames[ic][tid].bars[i].spark.frame:SetPoint("CENTER", Frames[ic][tid].bars[i].frame, "CENTER", db[ic].types[tid].bars[i].spark.position.x, db[ic].types[tid].bars[i].spark.position.y)
				Frames[ic][tid].bars[i].spark.frame:SetFrameStrata(db[ic].types[tid].position.framelevel.strata)
				Frames[ic][tid].bars[i].spark.frame:SetFrameLevel(db[ic].types[tid].position.framelevel.level + 5)
				Frames[ic][tid].bars[i].spark.frame:SetWidth(db[ic].types[tid].bars[i].spark.size.width)
				Frames[ic][tid].bars[i].spark.frame:SetHeight(db[ic].types[tid].bars[i].spark.size.height)

				if #Frames[ic][tid].bars[i].subbars > 0 then
					for j = 0, 8 do
						local XSOfs = 0
						local YSOfs = 0
						local fillStart = { "LEFT", "RIGHT", "TOP", "BOTTOM" }
						if IsVert then
							YSOfs = j * (db[ic].types[tid].bars[i].size.height / 9) * RevMult
							if IsRev then fillStart = "TOP" else fillStart = "BOTTOM" end
						else 
							XSOfs = j * (db[ic].types[tid].bars[i].size.width / 9) * RevMult
							if IsRev then fillStart = "RIGHT" else fillStart = "LEFT" end
						end
						Frames[ic][tid].bars[i].subbars[j].frame:SetParent(Frames[ic][tid].bars[i].frame)
						Frames[ic][tid].bars[i].subbars[j].frame:ClearAllPoints()

						Frames[ic][tid].bars[i].subbars[j].frame:SetPoint(fillStart, Frames[ic][tid].bars[i].frame, fillStart, XSOfs, YSOfs)

						Frames[ic][tid].bars[i].subbars[j].frame:SetFrameStrata(Frames[ic][tid].bars[i].frame:GetFrameStrata())
						Frames[ic][tid].bars[i].subbars[j].frame:SetFrameLevel(Frames[ic][tid].bars[i].frame:GetFrameLevel() + 1)
						if IsVert then
							Frames[ic][tid].bars[i].subbars[j].frame:SetWidth(db[ic].types[tid].bars[i].size.width)
							Frames[ic][tid].bars[i].subbars[j].frame:SetHeight(db[ic].types[tid].bars[i].size.height / 9)
						else 
							Frames[ic][tid].bars[i].subbars[j].frame:SetWidth(db[ic].types[tid].bars[i].size.width / 9)
							Frames[ic][tid].bars[i].subbars[j].frame:SetHeight(db[ic].types[tid].bars[i].size.height)
						end
					end
				end
			end
		end
	end
end

-- Update BG Panel textures
function cPointDisplay:UpdateBGPanelTextures()
	local BorderA
	local BGA

	for ic,vc in pairs(Types) do
		for it,vt in ipairs(Types[ic].points) do
			local tid = Types[ic].points[it].id
			-- Border
			if db[ic].types[tid].bgpanel.enabled then BorderA = db[ic].types[tid].bgpanel.border.color.a else BorderA = 0 end
			Frames[ic][tid].bgpanel.border:SetBackdrop({bgFile = "", edgeFile = Borders[ic][tid].bgpanel, edgeSize = db[ic].types[tid].bgpanel.border.edgesize, tile = false, tileSize = 0, insets = {left = 0, right = 0, top = 0, bottom = 0}})
			Frames[ic][tid].bgpanel.border:SetBackdropBorderColor(db[ic].types[tid].bgpanel.border.color.r, db[ic].types[tid].bgpanel.border.color.g, db[ic].types[tid].bgpanel.border.color.b, BorderA)

			-- BG
			if db[ic].types[tid].bgpanel.enabled then BGA = db[ic].types[tid].bgpanel.bg.color.a else BGA = 0 end
			Frames[ic][tid].bgpanel.bg:SetTexture(BG[ic][tid].bgpanel)
			Frames[ic][tid].bgpanel.bg:SetVertexColor(db[ic].types[tid].bgpanel.bg.color.r, db[ic].types[tid].bgpanel.bg.color.g, db[ic].types[tid].bgpanel.bg.color.b, BGA)
		end
	end
end

-- Retrieve SharedMedia backgound
local function RetrieveBackground(background)
	background = LSM:Fetch("background", background, true)
	return background
end

local function VerifyBackground(background)
	local newbackground = ""
	if background and strlen(background) > 0 then
		newbackground = RetrieveBackground(background)
		if background ~= "None" then
			if not newbackground then
				print("Background "..background.." was not found in SharedMedia.")
				newbackground = ""
			end
		end
	end
	return newbackground
end

-- Retrieve SharedMedia border
local function RetrieveBorder(border)
	border = LSM:Fetch("border", border, true)
	return border
end

local function VerifyBorder(border)
	local newborder = ""
	if border and strlen(border) > 0 then
		newborder = RetrieveBorder(border)
		if border ~= "None" then
			if not newborder then
				print("Border "..border.." was not found in SharedMedia.")
				newborder = ""
			end
		end
	end
	return newborder
end

-- Retrieve Border/Background textures and store in tables
function cPointDisplay:GetTextures()
	for ic,vc in pairs(Types) do
		for it,vt in ipairs(Types[ic].points) do
			local tid = Types[ic].points[it].id

			Borders[ic][tid].bgpanel = VerifyBorder(db[ic].types[tid].bgpanel.border.texture)
			BG[ic][tid].bgpanel = VerifyBackground(db[ic].types[tid].bgpanel.bg.texture)

			for i = 1, Types[ic].points[it].barcount do
				Borders[ic][tid].bars[i].empty = VerifyBorder(db[ic].types[tid].bars[i].border.empty.texture)
				Borders[ic][tid].bars[i].full = VerifyBorder(db[ic].types[tid].bars[i].border.full.texture)

				BG[ic][tid].bars[i].empty = VerifyBackground(db[ic].types[tid].bars[i].bg.empty.texture)
				BG[ic][tid].bars[i].full = VerifyBackground(db[ic].types[tid].bars[i].bg.full.texture)
				BG[ic][tid].bars[i].spark = VerifyBackground(db[ic].types[tid].bars[i].spark.bg.texture)
			end
		end
	end
end

function cPointDisplay:GetClassColors()
	local CurClassColor
	for k,v in pairs(Types) do
		tinsert(ClassColorBarTable, k)
		if k == "GENERAL" then
			CurClassColor = {r = 1, g = 1, b = 1}
		else
			CurClassColor = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[k] or RAID_CLASS_COLORS[k]
		end
		ClassColorBarTable[k] = {
			bg = {
				empty = {r = db.classcolor.bg.empty * CurClassColor.r, g = db.classcolor.bg.empty * CurClassColor.g, b = db.classcolor.bg.empty * CurClassColor.b},
				normal = {r = db.classcolor.bg.normal * CurClassColor.r, g = db.classcolor.bg.normal * CurClassColor.g, b = db.classcolor.bg.normal * CurClassColor.b},
				max = {r = db.classcolor.bg.max * CurClassColor.r, g = db.classcolor.bg.max * CurClassColor.g, b = db.classcolor.bg.max * CurClassColor.b},
			},
			border = {
				empty = {r = db.classcolor.border.empty * CurClassColor.r, g = db.classcolor.border.empty * CurClassColor.g, b = db.classcolor.border.empty * CurClassColor.b},
				normal = {r = db.classcolor.border.normal * CurClassColor.r, g = db.classcolor.border.normal * CurClassColor.g, b = db.classcolor.border.normal * CurClassColor.b},
				max = {r = db.classcolor.border.max * CurClassColor.r, g = db.classcolor.border.max * CurClassColor.g, b = db.classcolor.border.max * CurClassColor.b},
			},
			spark = {
				normal = {r = db.classcolor.spark.normal * CurClassColor.r, g = db.classcolor.spark.normal * CurClassColor.g, b = db.classcolor.spark.normal * CurClassColor.b},
				max = {r = db.classcolor.spark.max * CurClassColor.r, g = db.classcolor.spark.max * CurClassColor.g, b = db.classcolor.spark.max * CurClassColor.b},
			},
		}
	end
end

-- Frame Creation
local function CreateFrames()
	for ic,vc in pairs(Types) do
		for it,vt in ipairs(Types[ic].points) do
			local tid = Types[ic].points[it].id

			-- BG Panel
			local FrameName = "cPointDisplay_Frames_"..tid
			Frames[ic][tid].bgpanel.frame = CreateFrame("Frame", FrameName, UIParent, BackdropTemplateMixin and "BackdropTemplate")

			Frames[ic][tid].bgpanel.bg = Frames[ic][tid].bgpanel.frame:CreateTexture(nil, "ARTWORK")
			Frames[ic][tid].bgpanel.bg:SetAllPoints(Frames[ic][tid].bgpanel.frame)

			Frames[ic][tid].bgpanel.border = CreateFrame("Frame", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate")
			Frames[ic][tid].bgpanel.border:SetParent(Frames[ic][tid].bgpanel.frame)
			Frames[ic][tid].bgpanel.border:ClearAllPoints()
			Frames[ic][tid].bgpanel.border:SetPoint("CENTER", Frames[ic][tid].bgpanel.frame, "CENTER", 0, 0)

			Frames[ic][tid].bgpanel.frame:Hide()

			-- Anchor Panel
			local AnchorFrameName = "cPointDisplay_Frames_"..tid.."_avAanchor"
			Frames[ic][tid].anchor.frame = CreateFrame("Frame", AnchorFrameName, UIParent, BackdropTemplateMixin and "BackdropTemplate")

			-- Point bars
			for i = 1, Types[ic].points[it].barcount do
				local BarFrameName = "cPointDisplay_Frames_"..tid.."_bar"..tostring(i)
			
				Frames[ic][tid].bars[i].frame = CreateFrame("Frame", BarFrameName, UIParent, BackdropTemplateMixin and "BackdropTemplate")

				Frames[ic][tid].bars[i].bg = Frames[ic][tid].bars[i].frame:CreateTexture(nil, "ARTWORK")
				Frames[ic][tid].bars[i].bg:SetAllPoints(Frames[ic][tid].bars[i].frame)

				Frames[ic][tid].bars[i].border = CreateFrame("Frame", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate")
				Frames[ic][tid].bars[i].border:SetParent(Frames[ic][tid].bars[i].frame)
				Frames[ic][tid].bars[i].border:ClearAllPoints()
				Frames[ic][tid].bars[i].border:SetPoint("CENTER", Frames[ic][tid].bars[i].frame, "CENTER", 0, 0)

				Frames[ic][tid].bars[i].frame:Show()
				if tid == "ssf" then
					for j = 0, 8 do
						local SubBarSubFrameName = "cPointDisplay_Frames_"..tid.."_bar"..tostring(i).."_sub"..tostring(j)
						Frames[ic][tid].bars[i].subbars[j] = {frame = nil, bg = nil}
						
						Frames[ic][tid].bars[i].subbars[j].frame = CreateFrame("Frame", SubBarSubFrameName, UIParent, BackdropTemplateMixin and "BackdropTemplate")

						Frames[ic][tid].bars[i].subbars[j].bg = Frames[ic][tid].bars[i].subbars[j].frame:CreateTexture(nil, "ARTWORK")
						Frames[ic][tid].bars[i].subbars[j].bg:SetAllPoints(Frames[ic][tid].bars[i].subbars[j].frame)

						Frames[ic][tid].bars[i].subbars[j].frame:Show()
					end
				end

				-- Spark
				Frames[ic][tid].bars[i].spark.frame = CreateFrame("Frame", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate")

				Frames[ic][tid].bars[i].spark.bg = Frames[ic][tid].bars[i].spark.frame:CreateTexture(nil, "ARTWORK")
				Frames[ic][tid].bars[i].spark.bg:SetAllPoints(Frames[ic][tid].bars[i].spark.frame)

				Frames[ic][tid].bars[i].spark.frame:Show()
			end
		end
	end
end

-- Table creation
local function CreateTables()
	-- Frames
	wipe(Frames)
	wipe(Borders)
	wipe(BG)
	wipe(Points)
	wipe(PointsChanged)

	for ic,vc in pairs(Types) do
		-- Insert Class header
		tinsert(Frames, ic); Frames[ic] = {};
		tinsert(Borders, ic); Borders[ic] = {};
		tinsert(BG, ic); BG[ic] = {};

		for it,vt in ipairs(Types[ic].points) do
			local tid = Types[ic].points[it].id

			-- Frames
			tinsert(Frames[ic], tid)
			tinsert(Borders[ic], tid)
			tinsert(BG[ic], tid)

			Frames[ic][tid] = {
				anchor = {frame = nil},
				bgpanel = {frame = nil, bg = nil, border = nil},
				bars = {},
			}
			Borders[ic][tid] = {
				bgpanel = "",
				bars = {},
			}
			BG[ic][tid] = {
				bgpanel = "",
				bars = {},
			}
			for i = 1, Types[ic].points[it].barcount do
				Frames[ic][tid].bars[i] = {frame = nil, bg = nil, border = nil, spark = {frame = nil, bg = nil}, subbars = {}}
				Borders[ic][tid].bars[i] = {empty = "", full = ""}
				BG[ic][tid].bars[i] = {empty = "", full = "", spark = ""}
			end

			-- Points
			Points[tid] = 0

			-- Points Changed table
			PointsChanged[tid] = false
		end
	end
end

function cPointDisplay:ProfChange()
	if not LoggedIn then return end

	db = self.db.profile
	cPointDisplay:ConfigRefresh()
	cPointDisplay:Refresh()
end

-- Refresh cPointDisplay
function cPointDisplay:Refresh()
	if not LoggedIn then return end

	cPointDisplay:UpdateSpec()
	cPointDisplay:UpdateCombatFaderEnabled()
	cPointDisplay:GetTextures()
	cPointDisplay:UpdateBGPanelTextures()
	cPointDisplay:UpdatePosition()
	cPointDisplay:UpdatePoints("ENABLE")
end

-- Hide default UI frames
function cPointDisplay:HideUIElements()
	if db["GENERAL"].types["cp"].enabled and db["GENERAL"].types["cp"].general.hideui then
		local CPF = ComboPointPlayerFrame
		if CPF then
			CPF:Hide()
			CPF:SetScript("OnShow", function(self) self:Hide() end)
		end
	end

	if db["PALADIN"].types["hp"].enabled and db["PALADIN"].types["hp"].general.hideui then
		local HPF = PaladinPowerBarFrame
		if HPF then
			HPF:Hide()
			HPF:SetScript("OnShow", function(self) self:Hide() end)
		end
	end

	if db["MONK"].types["c5"].enabled and db["MONK"].types["c5"].general.hideui then
		local CB = MonkHarmonyBarFrame
		if CB then
			CB:Hide()
			CB:SetScript("OnShow", function(self) self:Hide() end)
		end
	end

	if db["WARLOCK"].types["ss"].enabled and db["WARLOCK"].types["ss"].general.hideui then
		local SSF = WarlockPowerFrame
		if SSF then
			SSF:Hide()
			SSF:SetScript("OnShow", function(self) self:Hide() end)
		end
	end

	if db["MAGE"].types["ac"].enabled and db["MAGE"].types["ac"].general.hideui then
		local APF = MageArcaneChargesFrame
		if APF then
			APF:Hide()
			APF:SetScript("OnShow", function(self) self:Hide() end)
		end
	end
end

function cPointDisplay:UpdateSpec()
	PlayerSpec = GetSpecialization()
end

function cPointDisplay:PLAYER_ENTERING_WORLD()
	cPointDisplay:UpdateSpec()
	cPointDisplay:UpdatePoints("ENABLE")
	cPointDisplay:UpdatePosition()
end

local function ClassColorsUpdate()
	ClassColors = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[PlayerClass] or RAID_CLASS_COLORS[PlayerClass]
	cPointDisplay:GetClassColors()
	cPointDisplay:UpdatePoints("ENABLE")
end

function cPointDisplay:PLAYER_LOGIN()
	PlayerClass = select(2, UnitClass("player"))

	-- Build Class list to run updates on
	ValidClasses = {
		["GENERAL"] = true,
		[PlayerClass] = true,
	},

	-- Register Media
	LSM:Register("border", "Solid", [[Interface\Addons\cPointDisplay\Media\SolidBorder]])
	LSM:Register("background", "Round-Small", [[Interface\Addons\cPointDisplay\Media\Round-Small]])
	LSM:Register("background", "Round-Smaller", [[Interface\Addons\cPointDisplay\Media\Round-Smaller]])
	LSM:Register("background", "Arrow", [[Interface\Addons\cPointDisplay\Media\Arrow]])
	LSM:Register("background", "Holy Power 1", [[Interface\Addons\cPointDisplay\Media\HolyPower1]])
	LSM:Register("background", "Holy Power 2", [[Interface\Addons\cPointDisplay\Media\HolyPower2]])
	LSM:Register("background", "Holy Power 3", [[Interface\Addons\cPointDisplay\Media\HolyPower3]])
	LSM:Register("background", "Soul Shard", [[Interface\Addons\cPointDisplay\Media\SoulShard]])

	-- Hide Elements
	cPointDisplay:HideUIElements()

	-- Register Events
	-- Throttled Events
	local EventList = {
	--	"UNIT_COMBO_POINTS",
		"VEHICLE_UPDATE",
		"UNIT_AURA",
	}
	if (PlayerClass == "PALADIN") then
		tinsert(EventList, "UNIT_POWER_UPDATE")
	end
	if (PlayerClass == "MONK") then
		tinsert(EventList, "UNIT_POWER_UPDATE")
		tinsert(EventList, "PLAYER_TALENT_UPDATE")
	end
	if (PlayerClass == "WARLOCK") then
		tinsert(EventList, "UNIT_POWER_UPDATE")
		tinsert(EventList, "UNIT_DISPLAYPOWER")
	end
	if (PlayerClass == "MAGE") then
		tinsert(EventList, "UNIT_POWER_UPDATE")
	end
	local UpdateSpeed = (1 / db.updatespeed)
	self:RegisterBucketEvent(EventList, UpdateSpeed, "UpdatePoints")
	-- Instant Events
	self:RegisterEvent("PLAYER_TARGET_CHANGED", "UpdatePoints")
	if (PlayerClass == "HUNTER") then
		self:RegisterEvent("SPELL_UPDATE_CHARGES", "UpdatePoints")
	end
	if (PlayerClass == "ROGUE" or PlayerClass == "DRUID") then
		self:RegisterEvent("UNIT_POWER_UPDATE", "UpdatePoints")
	end

	-- Class Colors
	if CUSTOM_CLASS_COLORS then
		CUSTOM_CLASS_COLORS:RegisterCallback(ClassColorsUpdate)
	end
	ClassColorsUpdate()

	-- Flag as Logged In
	LoggedIn = true

	-- Refresh Addon
	cPointDisplay:Refresh()
end

function cPointDisplay:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("cPointDisplayDB", defaults, "Default")

	self.db.RegisterCallback(self, "OnProfileChanged", "ProfChange")
	self.db.RegisterCallback(self, "OnProfileCopied", "ProfChange")
	self.db.RegisterCallback(self, "OnProfileReset", "ProfChange")

	cPointDisplay:SetUpInitialOptions()

	db = self.db.profile

	CreateTables()
	CreateFrames()

	-- Turn off Config Mode
	for ic,vc in pairs(Types) do
		for it,vt in ipairs(Types[ic].points) do
			local tid = Types[ic].points[it].id
			db[ic].types[tid].configmode.enabled = false
		end
	end

	self:RegisterEvent("PLAYER_LOGIN")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", "UpdateSpec")
end