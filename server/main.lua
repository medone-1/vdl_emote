-- Server-side handler for interactive animations
-- Syncs paired animations between two players

-- Rate limiting: Track last request time per player
local playerCooldowns = {}
local COOLDOWN_TIME = 1000 -- 1 second between requests

-- Max distance allowed between players for animation
local MAX_DISTANCE = 5.0


-- Helper: Get player ped coords from server
local function GetPlayerCoords(playerId)
    local ped = GetPlayerPed(playerId)
    if ped and ped ~= 0 then
        return GetEntityCoords(ped)
    end
    return nil
end


-- Helper: Calculate distance between two vectors
local function GetDistance(coords1, coords2)
    if not coords1 or not coords2 then return 9999 end
    return #(coords1 - coords2)
end


RegisterNetEvent('vdl:server:syncInteractiveAnim')
AddEventHandler('vdl:server:syncInteractiveAnim', function(targetServerId, animData)
    local senderServerId = source

    -- Check 1: Validate sender is a real player
    if not senderServerId or not GetPlayerName(senderServerId) then
        return
    end

    -- Check 2: Validate target is a real player
    if not targetServerId or not GetPlayerName(targetServerId) then
        return
    end

    -- Check 3: Sender cannot target themselves
    if senderServerId == targetServerId then
        return
    end

    -- Check 4: Rate limiting (prevent spam)
    local currentTime = GetGameTimer()
    if playerCooldowns[senderServerId] and (currentTime - playerCooldowns[senderServerId]) < COOLDOWN_TIME then
        return
    end
    playerCooldowns[senderServerId] = currentTime

    -- Check 5: Validate animData structure
    if type(animData) ~= 'table' then
        return
    end

    if not animData.dict2 or not animData.anim2 then
        return
    end

    -- Check 6: Validate animData values are strings (prevent injection)
    if type(animData.dict2) ~= 'string' or type(animData.anim2) ~= 'string' then
        return
    end

    -- Check 7: Distance check - players must be close to each other
    local senderCoords = GetPlayerCoords(senderServerId)
    local targetCoords = GetPlayerCoords(targetServerId)
    local distance = GetDistance(senderCoords, targetCoords)

    if distance > MAX_DISTANCE then
        return
    end

    -- All checks passed - send animation to target
    TriggerClientEvent('vdl:client:playInteractiveAnim', targetServerId, senderServerId, animData)
end)


-- Cleanup cooldowns when player disconnects
AddEventHandler('playerDropped', function()
    local playerId = source
    if playerCooldowns[playerId] then
        playerCooldowns[playerId] = nil
    end
end)
