local animation = false
local soundLevel = 0
local maxSoundLevel = 100
local soundIncreaseRate = 1
local soundDecreaseRate = 0.5
local soundCrouchRate = 0
robbedHouses = {}
robbedItems = {}
CreateThread(function()
    for k,v in pairs(Config.Interiors) do
        exports.ox_target:addBoxZone({
            coords = v.Door,
            size = vec3(2, 2, 2),
            rotation = 45,
            debug = false,
            options = {
                {
                    name = 'box',
                    event = 'joinInstance',
                    args = {v.Bucket, v.Interior, v.Objects, k},
                    icon = 'fas fa-home',
                    label = 'Sneaking into the house',
                }
            }
        })
        exports.ox_target:addBoxZone({
            coords = v.Interior,
            size = vec3(2, 2, 2),
            rotation = 45,
            debug = false,
            options = {
                {
                    name = 'box',
                    event = 'leaveInstance',
                    args = {v.Door, v.Objects},
                    icon = 'fas fa-home',
                    label = 'Leave house'
                }
            }
        })
    end
end)

function IsPedCrouching(ped)
    return IsControlPressed(0, 36) -- Control index 36 is for crouch
end

CreateThread(function()
    while true do
        Wait(1000) -- Check every second
        local playerPed = PlayerPedId()
        if IsPedWalking(playerPed) then
            soundLevel = math.min(soundLevel + soundIncreaseRate, maxSoundLevel)
        elseif IsPedCrouching(playerPed) then
            soundLevel = math.max(soundLevel - soundCrouchRate, 0)
        else
            soundLevel = math.max(soundLevel - soundDecreaseRate, 0)
        end

        if soundLevel >= maxSoundLevel then
            TriggerEvent('spawnNPCWithBat')
            soundLevel = 0 -- Reset sound level after NPC spawns
        end
    end
end)

AddEventHandler('spawnNPCWithBat', function()
    local playerCoords = GetEntityCoords(PlayerPedId())
    local npcHash = GetHashKey('a_m_m_hillbilly_01') -- Example NPC model
    RequestModel(npcHash)
    while not HasModelLoaded(npcHash) do
        Wait(1)
    end
    local npc = CreatePed(4, npcHash, playerCoords.x + 2, playerCoords.y + 2, playerCoords.z, 0.0, true, false)
    GiveWeaponToPed(npc, GetHashKey('WEAPON_BAT'), 1, false, true)
    TaskCombatPed(npc, PlayerPedId(), 0, 16)
end)

AddEventHandler('stoleItems', function(data)
    if data == nil then return end
    if robbedItems[data.args] == nil then
        animation = true
        robbedItems[data.args] = data.args
        StartLockpicking()
        lib.progressBar({
            duration = 10000,
            label = 'You steal things',
            useWhileDead = false,
            canCancel = false,
            disable = {
                move = true,
                car = true,
                combat = true
            },
        })
        TriggerServerEvent('crtxhouserobbery:stoleItems')
        animation = false
    else
        lib.notify({
            title = 'House Robbery',
            description = 'You have already robbed this property',
            type = 'error'
        })
    end
end)

AddEventHandler('joinInstance', function(data)
    if data == nil then return end
    if exports.ox_inventory:Search('count', 'lockpick') > 0 and robbedHouses[data.args[4]] == nil then 
        robbedHouses[data.args[4]] = data.args[4]
        TriggerServerEvent('crtxhouserobbery:removeLockpick')
        local playerPed = PlayerPedId()
        animation = true
        local success = exports['lockpick']:startLockpick()
        if success then
            lib.notify({
                title = 'House Robbery',
                description = 'You managed to lockpick the door',
                type = 'success'
            })
            lib.progressBar({
                duration = 10000,
                label = 'Youre breaking into the house',
                useWhileDead = false,
                canCancel = false,
                disable = {
                    move = true,
                    car = true,
                    combat = true
                },
                anim = {
                    dict = 'missheistfbisetup1',
                    clip = 'hassle_intro_loop_f' 
                },
            })
            alarm = math.random(0,100)
            if alarm < 30 then
                local data = exports['cd_dispatch']:GetPlayerInfo()
                TriggerServerEvent('cd_dispatch:AddNotification', {
                    job_table = {'police', 'sheriff'}, 
                    coords = data.coords,
                    title = '10-68',
                    message = 'Spustil se alarm domu', 
                    flash = 0,
                    unique_id = data.unique_id,
                    sound = 1,
                    blip = {
                        sprite = 431, 
                        scale = 1.2, 
                        colour = 3,
                        flashes = false, 
                        text = 'Alarm v domu',
                        time = 5,
                        radius = 0,
                    }
                })
                lib.notify({
                    title = 'House Robbery',
                    description = 'Alarm went off',
                    type = 'error'
                })
            end
            DoScreenFadeOut(500)
            Wait(500)
            TriggerServerEvent('crtxhouserobbery:joinInstance', data.args[1])
            ESX.Game.Teleport(playerPed, data.args[2])
            Wait(500)
            DoScreenFadeIn(1000)
            for _,l in pairs(data.args[3]) do
                exports.ox_target:addModel(l, {
                    {
                        name = _,
                        icon = "fas fa-credit-card",
                        label = "Rob the place",
                        event = "stoleItems",
                        args = _,
                        canInteract = function(entity, coords, distance)
                            return true
                        end,
                    },
                })
            end
        else
            lib.progressBar({
                duration = 10000,
                label = 'Youre trying to get the jewel out of the lock',
                useWhileDead = false,
                canCancel = false,
                disable = {
                    move = true,
                    car = true,
                    combat = true
                },
                anim = {
                    dict = 'missheistfbisetup1',
                    clip = 'hassle_intro_loop_f' 
                },
            })
            lib.notify({
                title = 'House Robbery',
                description = 'You broke the jewelers box',
                type = 'error'
            })
        end
        animation = false
        SetTimeout(3600000, function()
            robbedHouses[data.args[4]] = nil
        end)
    elseif exports.ox_inventory:Search('count', 'lockpick') < 1 then
        lib.notify({
            title = 'House Robbery',
            description = 'You dont have a lockpick',
            type = 'error'
        })
    elseif robbedHouses[data.args[4]] == nil then
        lib.notify({
            title = 'House Robbery',
            description = 'Youve already robbed/attempted to rob this house',
            type = 'error'
        })
    end
end)

AddEventHandler('leaveInstance', function(data)
    if data == nil then return end
    DoScreenFadeOut(500)
    Wait(500)
    TriggerServerEvent('crtxhouserobbery:leaveInstance')
    ESX.Game.Teleport(PlayerPedId(), data.args[1])
    Wait(500)
    DoScreenFadeIn(1000)
    for _,l in pairs(data.args[2]) do
        exports.ox_target:removeModel(l, _)
        robbedItems[_] = nil
    end
    robbedItems = {}
end)

function StartLockpicking()
    CreateThread(function()
        local lib, anim = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@', 'machinic_loop_mechandplayer'
        while animation do
            Wait(0)
            local playerPed = PlayerPedId()
            SetCurrentPedWeapon(playerPed, 'WEAPON_UNARMED')
            if IsEntityPlayingAnim(playerPed, lib, anim, 3) ~= 1 then
                ESX.Streaming.RequestAnimDict(lib, function()
                    TaskPlayAnim(playerPed, lib, anim, 8.0, -8.0, -1, 31, 0, false, false, false)
                end)
            end
        end
        local playerPed = PlayerPedId()
        StopAnimTask(playerPed, lib, anim, 1.0)
    end)
end