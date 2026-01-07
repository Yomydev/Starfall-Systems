--[[
    [STARFALL CORE SYSTEMS]
    Module: RoundHandler
    Architecture: Event-Driven Lifecycle Management
    
    Description: 
    Main server loop controlling game states. Communicates with Clients via RemoteEvents 
    and handles internal server logic via BindableEvents.
]]

local PlayersService = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Networking: Event Handlers
local MatchTimerUpdate = ReplicatedStorage:WaitForChild("MatchTimerUpdate")
local StatusUpdate = ReplicatedStorage:WaitForChild("StatusUpdate")
local MatchStatusChanged = ReplicatedStorage:WaitForChild("MatchStatusChanged") 

-- Configuration: Game Logic Constants
local MATCH_TIME = 600 
local INTERMISSION_TIME = 30 
local MIN_PLAYERS = 1 

-- Internal: Dispatches state changes to both Network (Clients) and Logic (Server)
local function setStatus(status, value)
	StatusUpdate:FireAllClients(status, value)
	MatchStatusChanged:Fire(status) 
end

-- [MAIN LIFECYCLE LOOP]
while true do
	local waitingCycle = 1 

	-- Phase 1: Connection Verification (Polls for minimum player count)
	while #PlayersService:GetPlayers() < MIN_PLAYERS do
		setStatus("WAITING", waitingCycle)

		waitingCycle = (waitingCycle % 3) + 1 -- Clean cycle logic (1-2-3)
		task.wait(1)
	end

	-- Phase 2: Staging / Intermission
	local intermissionTimeLeft = INTERMISSION_TIME
	setStatus("INTERMISSION", intermissionTimeLeft) 

	while intermissionTimeLeft >= 0 do
		StatusUpdate:FireAllClients("INTERMISSION", intermissionTimeLeft)
		task.wait(1)
		intermissionTimeLeft -= 1
	end

	-- Phase 3: Transition to Active Match
	StatusUpdate:FireAllClients("ROUND_START", 2) 
	task.wait(2)
	setStatus("STARTED", 0) 

	-- Phase 4: Match Execution (Active Gameplay Duration)
	local timeLeft = MATCH_TIME
	while timeLeft >= 0 do
		MatchTimerUpdate:FireAllClients(timeLeft)
		task.wait(1)
		timeLeft -= 1
        
        -- Optimization: Exit early if server becomes empty
        if #PlayersService:GetPlayers() == 0 then break end
	end

	-- Phase 5: Result Processing & Cleanup
	setStatus("ENDED", 0)
	task.wait(5)
end
