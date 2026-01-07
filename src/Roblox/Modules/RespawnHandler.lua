--[[
    STARFALL Studios: RespawnHandler
    Lead Architect: Yomy | Owner
    Description: Manages player lifecycles with safety checks and custom delays.
]]

local RespawnHandler = {}

-- Configuration
local RESPAWN_DELAY = 4 -- Your chosen 4-second delay

function RespawnHandler.Initialize(player)
    player.CharacterAdded:Connect(function(character)
        local humanoid = character:WaitForChild("Humanoid")
        
        humanoid.Died:Connect(function()
            -- Wait safely
            task.wait(RESPAWN_DELAY) 
            
            -- PRO CHECK: Ensure the player didn't leave and isn't already respawning
            if player and player.Parent and not player:FindFirstChild("IsRespawning") then
                -- Add a temporary tag to prevent double-respawn glitches
                local tag = Instance.new("BoolValue")
                tag.Name = "IsRespawning"
                tag.Parent = player
                
                -- Force load character
                local success, err = pcall(function()
                    player:LoadCharacter()
                end)
                
                if not success then
                    warn("[ERROR]: Failed to respawn " .. player.Name .. ": " .. err)
                end
                
                tag:Destroy()
            end
        end)
    end)
end

return RespawnHandler
