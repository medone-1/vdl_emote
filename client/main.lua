-- Tracks whether the menu is currently open
local menuOpen    = false

-- Key used to open the menu (fallback value if config missing)
local openKey     = Config.OpenKey or 0xD9D0E1C0

-- Chat command used to open the menu
local OpenCommand = Config.OpenCommand or "vdl"

-- Enables or disables command usage based on config
local UseCommand  = Config.UseCommand ~= false

-- Command name for emotes if enabled
local CommandName = Config.CommandName or "e"


-- THREAD: Handles menu opening/closing by key press
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        -- Open menu key
        if IsControlJustPressed(0, openKey) then
            if not menuOpen then
                menuOpen = true
                SetNuiFocus(true, true)
                SetNuiFocusKeepInput(true)
                SendNUIMessage({ action = "open" })
            end
        end

        -- Close key (usually BACK / ESC)
        if menuOpen and IsControlJustPressed(0, 0x156F7119) then
            SendNUIMessage({ action = "close" })
        end
    end
end)


-- Command to open the UI manually via chat
RegisterCommand(OpenCommand, function()
    if not menuOpen then
        menuOpen = true
        SetNuiFocus(true, true)
        SetNuiFocusKeepInput(true)
        SendNUIMessage({ action = "open" })
    end
end)


-- NUI Callback: Close menu
RegisterNUICallback("closeMenu", function(_, cb)
    menuOpen = false
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    SendNUIMessage({ action = "close" })
    cb("ok")
end)


-- NUI Callback: Send lists (Animations, Emotes, Clothes, etc.)
RegisterNUICallback('getList', function(data, cb)
    local list = {}

    if data.type == "animations" then
        list = Config.AnimPack or {}
    elseif data.type == "scenarios" then
        list = Config.ScenarioList or {}
    elseif data.type == "emotes" then
        list = Config.EmotesList or {}
    elseif data.type == "clothes" then
        list = Config.ClothesList or {}
    elseif data.type == "walkstyle" then
        list = Config.WalkStyles or {}
    elseif data.type == "walkstyle2" then
        list = Config.WalkStyles2 or {}
    elseif data.type == "interactive" then
        list = Config.InteractiveAnim or {}
    end

    SendNUIMessage({ action = "open", list = list })
    cb('ok')
end)


-- Mapping clothing parts to VORP commands
local VorpCommands = {
    hat       = "hat",
    mask      = "mask",
    shirt     = "shirt",
    vest      = "vest",
    coat      = "coat",
    ccoat     = "coat",
    pant      = "pant",
    boots     = "boots",
    armor     = "armor",
    glove     = "glove",
    gauntlets = "glove",
    bandana   = "bandana",
    neckwear  = "neckwear",
    neckties  = "neckties",
    eyewear   = "eyewear",
    belt      = "belt",
    buckle    = "buckle",
    poncho    = "poncho",
    cloack    = "cloack",
    spurs     = "spurs",
    rings     = "ringsL",
    bracelet  = "ringsR",
    chap      = "chap",
    suspender = "suspender",
}


-- Helper function: Play animation on local ped
local function PlayLocalAnim(dict, anim, time, flag)
    local ped = PlayerPedId()
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do Citizen.Wait(10) end
    local animFlag = (flag == 1 or flag == true) and 1 or 49
    TaskPlayAnim(ped, dict, anim, 8.0, -8.0, time or -1, animFlag, 0, false, false, false)
end


-- Event: Receive sync request from another player to play animation
RegisterNetEvent('vdl:client:playInteractiveAnim')
AddEventHandler('vdl:client:playInteractiveAnim', function(senderServerId, animData)
    local ped = PlayerPedId()
    local senderPed = GetPlayerPed(GetPlayerFromServerId(senderServerId))

    if not DoesEntityExist(senderPed) then return end

    -- Load animation dictionary
    RequestAnimDict(animData.dict2)
    while not HasAnimDictLoaded(animData.dict2) do Citizen.Wait(10) end

    -- Face the sender
    local myCoords = GetEntityCoords(ped)
    local senderCoords = GetEntityCoords(senderPed)
    local dx = senderCoords.x - myCoords.x
    local dy = senderCoords.y - myCoords.y
    local heading = math.deg(math.atan2(dy, dx)) - 90.0

    SetEntityHeading(ped, heading)
    Citizen.Wait(100)

    -- Play the receiving animation
    TaskPlayAnim(ped, animData.dict2, animData.anim2, 8.0, -8.0, animData.time or -1, animData.flag or 1, 0, false, false,
        false)
end)


-- NUI Callback: Play animation, scenario, emote or clothing action
RegisterNUICallback('play', function(item, cb)
    local ped = PlayerPedId()

    -- Simple emote (native)
    if item.emote then
        Citizen.InvokeNative(0xB31A277C1AC7B7FF, ped, 0, 0, item.emote, true, -1, false, false, false, false, false)
        cb('ok')
        return
    end

    -- Paired animation (player + nearest ped)
    if item.dict2 and item.anim2 then
        local coords = GetEntityCoords(ped)
        local closestTarget, closestDistance = nil, 1.5
        local closestServerId = nil
        local isPlayer = false

        -- Try to find nearest player
        local players = GetActivePlayers()
        for _, player in ipairs(players) do
            local targetPed = GetPlayerPed(player)
            if targetPed ~= ped and DoesEntityExist(targetPed) then
                local distance = #(coords - GetEntityCoords(targetPed))
                if distance < closestDistance then
                    closestTarget = targetPed
                    closestDistance = distance
                    closestServerId = GetPlayerServerId(player)
                    isPlayer = true
                end
            end
        end

        -- If not found, search world NPCs
        if not closestTarget then
            local peds = GetGamePool('CPed')
            for _, targetPed in ipairs(peds) do
                if targetPed ~= ped and DoesEntityExist(targetPed) and not IsPedDeadOrDying(targetPed, true) then
                    local distance = #(coords - GetEntityCoords(targetPed))
                    if distance < closestDistance then
                        closestTarget = targetPed
                        closestDistance = distance
                        isPlayer = false
                    end
                end
            end
        end

        -- If a partner found
        if closestTarget then
            RequestAnimDict(item.dict)
            while not HasAnimDictLoaded(item.dict) do Citizen.Wait(10) end

            -- Rotate player to face target
            local targetCoords = GetEntityCoords(closestTarget)
            local dx = targetCoords.x - coords.x
            local dy = targetCoords.y - coords.y
            local playerHeading = math.deg(math.atan2(dy, dx)) - 90.0

            SetEntityHeading(ped, playerHeading)
            Citizen.Wait(100)

            -- Play initiator animation
            TaskPlayAnim(ped, item.dict, item.anim, 8.0, -8.0, item.time or -1, item.flag or 1, 0, false, false, false)

            if isPlayer and closestServerId then
                -- Send event to server to sync with the other player
                TriggerServerEvent('vdl:server:syncInteractiveAnim', closestServerId, {
                    dict2 = item.dict2,
                    anim2 = item.anim2,
                    time = item.time,
                    flag = item.flag
                })
            else
                -- NPC: We can control them directly
                RequestAnimDict(item.dict2)
                while not HasAnimDictLoaded(item.dict2) do Citizen.Wait(10) end

                SetEntityHeading(closestTarget, playerHeading - 180.0)
                Citizen.Wait(100)

                TaskPlayAnim(closestTarget, item.dict2, item.anim2, 8.0, -8.0, item.time or -1, item.flag or 1, 0, false,
                    false, false)
            end
        end

        cb('ok')
        return
    end

    -- Clothing animations: dress / undress / or other wearable changes
    if item.info then
        -- Dress action
        if item.info == 'dress' then
            if item.dict and item.anim then
                RequestAnimDict(item.dict)
                while not HasAnimDictLoaded(item.dict) do Citizen.Wait(10) end
                TaskPlayAnim(ped, item.dict, item.anim, 8.0, -8.0, -1, 1, 0, false, false, false)
            end

            Citizen.SetTimeout(1000, function()
                ExecuteCommand("dress")
                ClearPedTasks(ped)
            end)

            cb('ok')
            return
        end

        -- Undress action
        if item.info == 'undress' then
            if item.dict and item.anim then
                RequestAnimDict(item.dict)
                while not HasAnimDictLoaded(item.dict) do Citizen.Wait(10) end
                TaskPlayAnim(ped, item.dict, item.anim, 8.0, -8.0, -1, 1, 0, false, false, false)
            end

            Citizen.SetTimeout(1000, function()
                ExecuteCommand("undress")
                ClearPedTasks(ped)
            end)

            cb('ok')
            return
        end

        -- Other clothing parts (hat, mask, coat...)
        if item.dict and item.anim then
            RequestAnimDict(item.dict)
            while not HasAnimDictLoaded(item.dict) do Citizen.Wait(10) end
            TaskPlayAnim(ped, item.dict, item.anim, 8.0, -8.0, -1, 1, 0, false, false, false)
        end

        Citizen.SetTimeout(1000, function()
            local vorpCmd = VorpCommands[item.info]
            if vorpCmd then ExecuteCommand(vorpCmd) end
            ClearPedTasks(ped)
        end)
    elseif item.dict and item.anim then
        -- Simple animation
        RequestAnimDict(item.dict)
        while not HasAnimDictLoaded(item.dict) do Citizen.Wait(10) end
        local flag = (item.flag == 1 or item.flag == true) and 1 or 49
        TaskPlayAnim(ped, item.dict, item.anim, 8.0, -8.0, -1, flag, 0, false, false, false)
    elseif item.scene then
        -- Scenario animation
        TaskStartScenarioInPlace(ped, GetHashKey(item.scene), -1, true, false, false, false)
    elseif item.style then
        -- Walk styles / movement styles
        if item.style == "default" or item.style == "noanim" then
            Citizen.InvokeNative(0xD710A5007C2AC539, ped, 0.0)
            Citizen.InvokeNative(0x923583741DC87BCE, ped, "arthur_healthy")
            Citizen.InvokeNative(0x89F5E7ADECCCB49C, ped, "normal", 1.0)
        else
            if not string.find(item.style, "MP_Style_") then
                if item.bases then
                    Citizen.InvokeNative(0x923583741DC87BCE, ped, item.bases)
                    Citizen.Wait(50)
                end
                Citizen.InvokeNative(0x89F5E7ADECCCB49C, ped, item.style, 1.0)
            end
        end
    end

    cb('ok')
end)


-- Chat command to play an emote or animation ("/e wave")
if UseCommand then
    RegisterCommand(CommandName, function(_, args)
        if #args == 0 then return end
        local name = args[1]:lower()

        -- Check AnimPack commands
        for _, anim in pairs(Config.AnimPack or {}) do
            if anim.cmd and anim.cmd:lower() == name then
                local ped = PlayerPedId()
                RequestAnimDict(anim.dict)
                while not HasAnimDictLoaded(anim.dict) do Citizen.Wait(10) end
                local flag = (anim.flag == 1 or anim.flag == true) and 1 or 49
                TaskPlayAnim(ped, anim.dict, anim.anim, 8.0, -8.0, -1, flag, 0, false, false, false)
                return
            end
        end

        -- Check EmotesList commands
        for _, emote in pairs(Config.EmotesList or {}) do
            if emote.cmd and emote.cmd:lower() == name then
                local ped = PlayerPedId()
                Citizen.InvokeNative(0xB31A277C1AC7B7FF, ped, 0, 0, emote.emote, true, -1, false, false, false, false,
                    false)
                return
            end
        end
    end, false)
end


-- Cancel any animation via NUI
RegisterNUICallback('cancelAnim', function(_, cb)
    ClearPedTasksImmediately(PlayerPedId())
    cb('ok')
end)