--        .______   ____    ____                __   ___    ____    _  _     ______   __             
--        |   _  \  \   \  /   /               |  | |__ \  |___ \  | || |   |____  | |  |            
--        |  |_)  |  \   \/   /      ______    |  |    ) |   __) | | || |_      / /  |  |     ______ 
--        |   _  <    \_    _/      |______|   |  |   / /   |__ <  |__   _|    / /   |  |    |______|
--        |  |_)  |     |  |                   |  |  / /_   ___) |    | |     / /    |  |            
--        |______/      |__|                   |  | |____| |____/     |_|    /_/     |  |            
--                                             |__|                                  |__|            

script_name('Pidurok_wh_hotel.lua')
script_version("0.0.1")
script_authors('TG @Qwestonsz')
script_url('https://www.blast.hk/members/464512/')


local cmd = 'hwh'
local active = false
local font = renderCreateFont("Arial", 12, 5)

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
                    if text:match("Статус дверей: {FF6666}Открыты") then
                        if isPointOnScreen(posX, posY, posZ, nil) then
                            local pX, pY = convert3DCoordsToScreen(getCharCoordinates(PLAYER_PED))
                            local lX, lY = convert3DCoordsToScreen(posX, posY, posZ)
                            renderFontDrawText(font, 'Открыто', lX, lY, 0xFF16C910, 0x90000000)              
                            renderDrawLine(pX, pY, lX, lY, 3, 0xFF52FF4D)
                            renderDrawPolygon(pX, pY, 10, 10, 10, 0, 0xFFFFFFFF)
                            renderDrawPolygon(lX, lY, 10, 10, 10, 0, 0xFFFFFFFF)  
                        end
                    end
                    if text:match("{FF6666}Бонусный Ларец") then
                        if isPointOnScreen(posX, posY, posZ, nil) then
                            local pX, pY = convert3DCoordsToScreen(getCharCoordinates(PLAYER_PED))
                            local lX, lY = convert3DCoordsToScreen(posX, posY, posZ)
                            renderFontDrawText(font, 'Пидурок', lX, lY, 0xFF16C910, 0x90000000)              
                            renderDrawLine(pX, pY, lX, lY, 3, 0xFF52FF4D)
                            renderDrawPolygon(pX, pY, 10, 10, 10, 0, 0xFFFFFFFF)
                            renderDrawPolygon(lX, lY, 10, 10, 10, 0, 0xFFFFFFFF)  
                        end
                    end
                end
            end   
        end
    end
end

