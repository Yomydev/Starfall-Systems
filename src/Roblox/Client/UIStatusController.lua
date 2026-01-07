--[[
    [STARFALL CORE SYSTEMS]
    Module: UIStatusController (Local)
    Description: Synchronizes client-side UI elements with the global match lifecycle.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StatusUpdate = ReplicatedStorage:WaitForChild("StatusUpdate")

-- Internal UI References
local label = script.Parent
if not label:IsA("TextLabel") then 
    warn("[Starfall] UIStatusController must be parented to a TextLabel.") 
    return 
end

-- Formatting: Converts raw seconds into standardized MM:SS timestamp
local function formatTime(seconds)
	local safeSeconds = math.max(0, tonumber(seconds) or 0)
	local minutes = math.floor(safeSeconds / 60)
	local remainingSeconds = safeSeconds % 60
	return string.format("%02i:%02i", minutes, remainingSeconds)
end

-- UI State Management: Instant visibility toggles
local function updateDisplay(text, color, isVisible)
	if isVisible then
		label.Text = text
		label.TextColor3 = color or Color3.new(1, 1, 1)
		label.TextTransparency = 0
	else
		label.TextTransparency = 1
	end
end

-- Listener: Handles lifecycle state changes dispatched from the server
StatusUpdate.OnClientEvent:Connect(function(mode, value)
	local WHITE = Color3.new(1, 1, 1)
	local BLUE = Color3.fromRGB(150, 200, 255)
	local GOLD = Color3.fromRGB(255, 200, 0)
	local RED = Color3.fromRGB(255, 0, 0)

	if mode == "WAITING" then
		local dots = string.rep(".", value) -- Cleaner way to repeat the dots
		updateDisplay("Waiting for more players" .. dots, WHITE, true)

	elseif mode == "INTERMISSION" then
		updateDisplay("Intermission | Next match in " .. formatTime(value), BLUE, true)

	elseif mode == "ROUND_START" then
		updateDisplay("Match starting in " .. formatTime(value), GOLD, true)

	elseif mode == "STARTED" then
		updateDisplay("", nil, false)

	elseif mode == "ENDED" then
		updateDisplay("Match ended!", RED, true)
	end
end)
