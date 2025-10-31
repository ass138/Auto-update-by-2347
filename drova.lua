script_name('drova.lua')
script_version("0.0.1")
script_authors('TG @Qwestonsz')
script_url('https://www.blast.hk/members/464512/')

local cmd = 'drova'
local active = false

function main()
    repeat wait(0) until isSampAvailable()
    sampAddChatMessage('Скрипт [{FF00FF}'..thisScript().filename..'{FFFFFF}] загружен Автор [{FF00FF}'..unpack(thisScript().authors)..'{FFFFFF}] Активация {FF00FF}/'..cmd, -1)
    sampRegisterChatCommand(cmd, function() active = not active sampAddChatMessage('[{FF00FF}'..thisScript().filename..'{FFFFFF}] ' .. (active and '{00FF00}Включен' or '{FF0000}Выключен'), -1) end)
    while true do wait(0)        
        if active then
            for id = 0, 2048 do
                local result = sampIs3dTextDefined( id )
                if result then
                    local text, color, posX, posY, posZ, distance, ignoreWalls, playerId, vehicleId = sampGet3dTextInfoById( id )
                    if text:match('Срубить дерево') or text:match('Склад с древесиной') then
                        if isPointOnScreen(posX, posY, posZ, 3.0) then
                            local wposX, wposY = convert3DCoordsToScreen(posX,posY,posZ)
                            local resX, resY = getScreenResolution()
                            if wposX < resX and wposY < resY and isPointOnScreen (posX,posY,posZ,1) then
                                x2,y2,z2 = getCharCoordinates(PLAYER_PED)
                                x1, y2 = convert3DCoordsToScreen(posX, posY, posZ)
                                x10, y10 = convert3DCoordsToScreen(x2,y2,z2)
                                p3, p4 = convert3DCoordsToScreen(x2,y2,z2)
                                renderDrawPolygon(x1, y2, 10, 10, 10, 0, 0xFFFF0000)
                            end
                            playerX, playerY, playerZ = getCharCoordinates(playerPed)
                            distance = getDistanceBetweenCoords3d(playerX, playerY, playerZ, posX, posY, posZ)
                            if distance < 2 then 
                                local data = samp_create_sync_data('player')
                                data.keysData = data.keysData + 1024
                                data.send()
                            end         
                        end
                    end
                end
            end
        end
    end   
end
                       
function samp_create_sync_data(sync_type, copy_from_player)
    local ffi = require 'ffi'
    local sampfuncs = require 'sampfuncs'
    local raknet = require 'samp.raknet'
    require 'samp.synchronization'
    copy_from_player = copy_from_player or true
    local sync_traits = {
        player = {'PlayerSyncData', raknet.PACKET.PLAYER_SYNC, sampStorePlayerOnfootData},
        vehicle = {'VehicleSyncData', raknet.PACKET.VEHICLE_SYNC, sampStorePlayerIncarData},
        passenger = {'PassengerSyncData', raknet.PACKET.PASSENGER_SYNC, sampStorePlayerPassengerData},
        aim = {'AimSyncData', raknet.PACKET.AIM_SYNC, sampStorePlayerAimData},
        trailer = {'TrailerSyncData', raknet.PACKET.TRAILER_SYNC, sampStorePlayerTrailerData},
        unoccupied = {'UnoccupiedSyncData', raknet.PACKET.UNOCCUPIED_SYNC, nil},
        bullet = {'BulletSyncData', raknet.PACKET.BULLET_SYNC, nil},
        spectator = {'SpectatorSyncData', raknet.PACKET.SPECTATOR_SYNC, nil}
    }
    local sync_info = sync_traits[sync_type]
    local data_type = 'struct ' .. sync_info[1]
    local data = ffi.new(data_type, {})
    local raw_data_ptr = tonumber(ffi.cast('uintptr_t', ffi.new(data_type .. '*', data)))
    if copy_from_player then
        local copy_func = sync_info[3]
        if copy_func then
            local _, player_id
            if copy_from_player == true then
                _, player_id = sampGetPlayerIdByCharHandle(PLAYER_PED)
            else
                player_id = tonumber(copy_from_player)
            end
            copy_func(player_id, raw_data_ptr)
        end
    end
    local func_send = function()
        local bs = raknetNewBitStream()
        raknetBitStreamWriteInt8(bs, sync_info[2])
        raknetBitStreamWriteBuffer(bs, raw_data_ptr, ffi.sizeof(data))
        raknetSendBitStreamEx(bs, sampfuncs.HIGH_PRIORITY, sampfuncs.UNRELIABLE_SEQUENCED, 1)
        raknetDeleteBitStream(bs)
    end
    local mt = {
        __index = function(t, index)
            return data[index]
        end,
        __newindex = function(t, index, value)
            data[index] = value
        end
    }
    return setmetatable({send = func_send}, mt)
end