--        .______   ____    ____                __   ___    ____    _  _     ______   __             
--        |   _  \  \   \  /   /               |  | |__ \  |___ \  | || |   |____  | |  |            
--        |  |_)  |  \   \/   /      ______    |  |    ) |   __) | | || |_      / /  |  |     ______ 
--        |   _  <    \_    _/      |______|   |  |   / /   |__ <  |__   _|    / /   |  |    |______|
--        |  |_)  |     |  |                   |  |  / /_   ___) |    | |     / /    |  |            
--        |______/      |__|                   |  | |____| |____/     |_|    /_/     |  |            
--                                             |__|                                  |__|            

script_name('LenAutoALT by LUK update.lua')
script_version("0.0.1")
script_authors('TG @Qwestonsz')
script_url('https://www.blast.hk/members/464512/')


local cmd = 'len'
local cmd2 = 'xlop'
local active = false
local active2 = false
local font = renderCreateFont("Arial", 12, 5)

function main()
    repeat wait(0) until isSampAvailable()
    sampAddChatMessage('Скрипт [{FF00FF}'..thisScript().filename..'{FFFFFF}] загружен Автор [{FF00FF}'..unpack(thisScript().authors)..'{FFFFFF}] Активация {FF00FF}/'..cmd..' {FFFFFF}| {FF00FF}/'..cmd2, -1)
    sampRegisterChatCommand(cmd, function() active = not active sampAddChatMessage('[{FF00FF}'..thisScript().filename..'{FFFFFF}] ' .. (active and '{00FF00}Включен' or '{FF0000}Выключен'), -1) end)
    sampRegisterChatCommand(cmd2, function() active2 = not active2 sampAddChatMessage('[{FF00FF}'..thisScript().filename..'{FFFFFF}] ' .. (active2 and '{00FF00}Включен' or '{FF0000}Выключен'), -1) end)
    while true do wait(0)
        if active then
            for id = 0, 2048 do
                local result = sampIs3dTextDefined( id )
                if result then
                    text, color, posX, posY, posZ, distance, ignoreWalls, playerId, vehicleId = sampGet3dTextInfoById( id )
                    if text:match("Лён в процессе роста %(этап 2%)\n{FFFFFF}Осталось (%d+):(%d+)") then
                        local time3, time4 = text:match("Лён в процессе роста %(этап 2%)\n{FFFFFF}Осталось (%d+):(%d+)")
                        time3, time4 = tonumber(time3), tonumber(time4)
                        if time3 == 0 and time4 <= 10 then  
                            if isPointOnScreen(posX, posY, posZ, nil) then
                                local pX, pY = convert3DCoordsToScreen(getCharCoordinates(PLAYER_PED))
                                local lX, lY = convert3DCoordsToScreen(posX, posY, posZ)
                                renderFontDrawText(font, 'time: '..time4, lX, lY, 0xFFFF0000, 0x90000000)              
                                renderDrawLine(pX, pY, lX, lY, 3, 0xFFFF0000)
                            end
                        end
                    end
                    if text:match("Лён%(%d+ из %d+%)\n{73B461}Можно собрать") then
                        local len1, len2 = text:match("Лён%((%d+) из (%d+)%)\n{73B461}Можно собрать")
                        if isPointOnScreen(posX, posY, posZ, nil) then
                            local pX, pY = convert3DCoordsToScreen(getCharCoordinates(PLAYER_PED))
                            local lX, lY = convert3DCoordsToScreen(posX, posY, posZ)
                            renderFontDrawText(font, ''..len1, lX, lY, 0xFF16C910, 0x90000000)              
                            renderDrawLine(pX, pY, lX, lY, 3, 0xFF52FF4D)
                            local myPos = {getCharCoordinates(1)}
                            local distanceToText = getDistanceBetweenCoords3d(posX, posY, posZ, myPos[1], myPos[2], myPos[3])
                            if distanceToText <= 2 then
                                local data = samp_create_sync_data('player')
                                data.keysData = data.keysData + 1024
                                data.send()  
                            end
                        end
                    end
                end
            end
        end
        if active2 then
            for id = 0, 2048 do
                local result = sampIs3dTextDefined( id )
                if result then
                    text, color, posX, posY, posZ, distance, ignoreWalls, playerId, vehicleId = sampGet3dTextInfoById( id )
                    if text:match("Хлопок в процессе роста %(этап 2%)\n{FFFFFF}Осталось (%d+):(%d+)") then
                        local time1, time2 = text:match("Хлопок в процессе роста %(этап 2%)\n{FFFFFF}Осталось (%d+):(%d+)")
                        time1, time2 = tonumber(time1), tonumber(time2)
                        if time1 == 0 and time2 <= 10 then  
                            if isPointOnScreen(posX, posY, posZ, nil) then
                                local pX, pY = convert3DCoordsToScreen(getCharCoordinates(PLAYER_PED))
                                local lX, lY = convert3DCoordsToScreen(posX, posY, posZ)
                                renderFontDrawText(font, 'time: '..time2, lX, lY, 0xFFFF0000, 0x90000000)              
                                renderDrawLine(pX, pY, lX, lY, 3, 0xFFFF0000)
                            end
                        end
                    end
                    if text:match("Хлопок%(%d+ из %d+%)\n{73B461}Можно собрать") then
                        local xlopak1, xlopak2 = text:match("Хлопок%((%d+) из (%d+)%)\n{73B461}Можно собрать")
                        if isPointOnScreen(posX, posY, posZ, nil) then
                            local pX, pY = convert3DCoordsToScreen(getCharCoordinates(PLAYER_PED))
                            local lX, lY = convert3DCoordsToScreen(posX, posY, posZ)
                            renderFontDrawText(font, ''..xlopak1, lX, lY, 0xFF16C910, 0x90000000)              
                            renderDrawLine(pX, pY, lX, lY, 3, 0xFF52FF4D)
                            local myPos = {getCharCoordinates(1)}
                            local distanceToText = getDistanceBetweenCoords3d(posX, posY, posZ, myPos[1], myPos[2], myPos[3])
                            if distanceToText <= 2 then
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