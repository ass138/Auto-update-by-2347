--        .______   ____    ____                __   ___    ____    _  _     ______   __             
--        |   _  \  \   \  /   /               |  | |__ \  |___ \  | || |   |____  | |  |            
--        |  |_)  |  \   \/   /      ______    |  |    ) |   __) | | || |_      / /  |  |     ______ 
--        |   _  <    \_    _/      |______|   |  |   / /   |__ <  |__   _|    / /   |  |    |______|
--        |  |_)  |     |  |                   |  |  / /_   ___) |    | |     / /    |  |            
--        |______/      |__|                   |  | |____| |____/     |_|    /_/     |  |            
--                                             |__|                                  |__|            

script_name('travka.lua')
script_version("0.0.1")
script_authors('TG @Qwestonsz')
script_url('https://www.blast.hk/members/464512/')

local cmd = 'travka'
local active = false

main = function()
	while not isSampAvailable() do wait(0) end
    sampAddChatMessage('Скрипт [{FF00FF}'..thisScript().filename..'{FFFFFF}] загружен Автор [{FF00FF}'..unpack(thisScript().authors)..'{FFFFFF}] Активация {FF00FF}/'..cmd, -1)
    sampRegisterChatCommand(cmd, function() active = not active sampAddChatMessage('[{FF00FF}'..thisScript().filename..'{FFFFFF}] ' .. (active and '{00FF00}Включен' or '{FF0000}Выключен'), -1) end)
	while true do wait(0)
        bs = raknetNewBitStream()
        raknetBitStreamWriteInt16(bs, 614)
        raknetEmulRpcReceiveBitStream(47, bs)
        raknetDeleteBitStream(bs)
		if active then
	        for k, v in pairs(getAllObjects()) do
                local num = getObjectModel(v)
                if isObjectOnScreen(v) then
                    if num == 874 then
                        local res, posX, posY, posZ = getObjectCoordinates(v)
						local myPos = {getCharCoordinates(1)}
                        local screenX, screenY = convert3DCoordsToScreen(posX, posY, posZ)
                        renderDrawPolygon(screenX, screenY, 10, 10, 10, 0.0, 0xFFFFFFFF)
	                    drawCircleIn3d(posX,posY,posZ,2,20,1.5,	getDistanceBetweenCoords3d(posX,posY,posZ,myPos[1],myPos[2],myPos[3]) > 2 and 0xFFFF0000 or 0xFF00FF00)
	                end
	            end
	        end
	    end
	end
end

drawCircleIn3d = function(x, y, z, radius, polygons,width,color)
    local step = math.floor(360 / (polygons or 36))
    local sX_old, sY_old
    for angle = 0, 360, step do
        local lX = radius * math.cos(math.rad(angle)) + x
        local lY = radius * math.sin(math.rad(angle)) + y
        local lZ = z
        local _, sX, sY, sZ, _, _ = convert3DCoordsToScreenEx(lX, lY, lZ)
        if sZ > 1 then
            if sX_old and sY_old then
                renderDrawLine(sX, sY, sX_old, sY_old, width, color)
            end
            sX_old, sY_old = sX, sY
        end
    end
end

