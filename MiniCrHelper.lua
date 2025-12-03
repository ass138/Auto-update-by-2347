script_name('ЗАЛУПА HELPER.lua')
script_version('0.4.5')
script_url('TG @IIzIIIzIVzVII')

require 'lib.moonloader'
local imgui, encoding, ffi, effil = require 'mimgui', require 'encoding', require 'ffi', require 'effil'
local sampev, Memory, json, inicfg = require 'samp.events', require 'memory', require 'dkjson', require 'inicfg'

encoding.default = 'CP1251'
u8 = encoding.UTF8

local mainIni = inicfg.load({
    main = { nickrecons = '', serverrecon = '', speedrunning = false, autoeat = false, fastrunm = false, autospawnbot = false}
}, 'MiniCrHelper/MiniHelper-CR.ini')

local new, str = imgui.new, ffi.string
local font = renderCreateFont('Arial', 15, 14)
local window, speedrunning, autoeat, autospawnbot, showdebug, debugwh3d = new.bool(), new.bool(mainIni.main.speedrunning), new.bool(mainIni.main.autoeat), new.bool(mainIni.main.autospawnbot), imgui.new.bool(), new.bool()
local fastrunm = new.bool(mainIni.main.fastrunm)
local sw, sh = getScreenResolution()
local nickrecons, serverrecon, piska, recentMessages, onShowDialogwqq, recentMessages = '', '', 0, {}, '', {}

local newinv = false
local spawnbot = false

function sms(text)
    sampAddChatMessage(string.format('{FFFFFF}• {00FF00}%s {FFFFFF}%s {FFFFFF}•', thisScript().name, tostring(text):gsub('{mc}', '{00FF00}'):gsub('{%-1}', '{FFFFFF}')), 0x00FF00)
end

ffi.cdef[[
    typedef void* HCURSOR;
    HCURSOR GetCursor(void);
]]

imgui.OnFrame(function() return window[0] end, function(player)
    imgui.SetNextWindowPos(imgui.ImVec2(sw / 2.5, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.Begin(u8'Залупа Helper | v' .. thisScript().version, window, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.AlwaysAutoResize)

    if imgui.Checkbox(u8'Авто-Еда', autoeat) then
        mainIni.main.autoeat = autoeat[0]
        inicfg.save(mainIni, "MiniCrHelper/MiniHelper-CR")
    end

    if imgui.Checkbox(u8'Быстрый бег', speedrunning) then
        mainIni.main.speedrunning = speedrunning[0]
        inicfg.save(mainIni, "MiniCrHelper/MiniHelper-CR")
    end

    if imgui.Checkbox(u8'Бег если сытость ниже 20%', fastrunm) then
        mainIni.main.fastrunm = fastrunm[0]
        inicfg.save(mainIni, "MiniCrHelper/MiniHelper-CR")
    end

    if imgui.Checkbox(u8'Авто спавн охран при спавне (новый инв)', autospawnbot) then
        mainIni.main.autospawnbot = autospawnbot[0]
        inicfg.save(mainIni, "MiniCrHelper/MiniHelper-CR")
    end

    imgui.End()
end)


imgui.OnFrame(function() return showdebug[0] end, function()
    imgui.SetNextWindowPos(imgui.ImVec2(sw/2, sh/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.Begin('Debug', showdebug, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.AlwaysAutoResize)

    imgui.Checkbox(u8'3D text-key Q', debugwh3d)
    --imgui.SameLine()
    --imgui.Button(u8'Коды клавиш')
    imgui.Separator()

    local function textList(label, list)
        if #list == 0 then
            imgui.Text(u8(label .. ': Пусто'))
        else
            for _, msg in ipairs(list) do
                imgui.Text(u8(msg))
                if imgui.IsItemHovered() then imgui.SetTooltip(u8'Клик чтобы скопировать') end
                if imgui.IsItemClicked() then setClipboardText(msg) sms('Сохранен в буфер') end
            end
        end
        imgui.Separator()
    end

    textList('Chat', recentMessages)

    local dialog = onShowDialogwqq ~= '' and onShowDialogwqq or 'Пусто'
    imgui.Text(u8('Dialog: ' .. dialog))
    if imgui.IsItemHovered() then imgui.SetTooltip(u8'Клик чтобы скопировать') end
    if imgui.IsItemClicked() then setClipboardText(onShowDialogwqq) sms('Сохранен в буфер') end
    imgui.Separator()

    local x, y, z = getCharCoordinates(PLAYER_PED)
    local coords = string.format('%.2f, %.2f, %.2f', x, y, z)
    imgui.Text(u8'Координаты: ' .. coords)
    if imgui.IsItemHovered() then imgui.SetTooltip(u8'Клик чтобы скопировать') end
    if imgui.IsItemClicked() then setClipboardText(coords) sms('Сохранен в буфер') end

    imgui.End()
end)

imgui.OnFrame(
function()
    return ffi.C.GetCursor() ~= nil
end,
function()
    local pos = imgui.GetMousePos()
    local draw = imgui.GetBackgroundDrawList()

    -- Красный цвет через ImVec4
    local col = imgui.GetColorU32Vec4(imgui.ImVec4(1.0, 0.0, 0.0, 1.0))

    draw:AddCircleFilled(pos, 4, col, 16)
end).HideCursor = true



function main()
    while not isSampAvailable() do wait(0) end
    
    sms('{FFFFFF} Активация: {7FFF00}F2{FFFFFF} или {7FFF00}/hl', -1)
    sampRegisterChatCommand('hl', function() window[0] = not window[0] end)
    sampRegisterChatCommand('call', getnumber)

    lua_thread.create(bike)
    lua_thread.create(timekalashnik)
    lua_thread.create(autoreconectrandom)
    lua_thread.create(wh3dtext)
    lua_thread.create(whplay)
    lua_thread.create(spawnbot)
    lua_thread.create(fastrun)
    lua_thread.create(updatevc)



    while true do wait(0)
        if wasKeyPressed(VK_F2) and not sampIsCursorActive() then
            window[0] = not window[0]
        end
        if wasKeyPressed(VK_F12) and not sampIsCursorActive() then
            showdebug[0] = not showdebug[0]
        end
        cameraSetLerpFov(90, 90, 1000, 1)
        Memory.setint8(0xB7CEE4, 1)
    end
end

function evalanon(c) evalcef(("(()=>{%s})()"):format(c)) end
function evalcef(c,e)
    local bs=raknetNewBitStream()
    raknetBitStreamWriteInt8(bs,17)
    raknetBitStreamWriteInt32(bs,0)
    raknetBitStreamWriteInt16(bs,#c)
    raknetBitStreamWriteInt8(bs,e or 0)
    raknetBitStreamWriteString(bs,c)
    raknetEmulPacketReceiveBitStream(220,bs)
    raknetDeleteBitStream(bs)
end

function addTextRightFromOnline(t)
    evalanon(([[ 
        let b=document.querySelector('.player-info__users-online');
        if(!b)return;
        let e=b.querySelector('.custom-online-right');
        let parts=`%s`.split(" ");
        if(e){e.querySelector('.caption').innerText=parts[0]+":"; e.querySelector('.value').innerText=parts[1]||""; return;}
        let s=document.createElement('span');
        s.className='custom-online-right';
        s.style.marginLeft='10px';
        s.style.whiteSpace='nowrap';
        s.innerHTML='<span class="player-info__user-id-caption caption">'+parts[0]+':</span> <span class="player-info__user-id-value value">'+(parts[1]||"")+'</span>';
        b.querySelector('.player-info__users-online-count').after(s);
    ]]):format(t))
end

function asyncHttpRequest(m,u,a,r,j)
    local thr=effil.thread(function(m,u,a)
        local ok,res=pcall(require'requests'.request,m,u,a)
        if ok then if res then res.json,res.xml=nil,nil end; return true,res else return false,res end
    end)(m,u,a)
    r=r or function() end j=j or function() end
    lua_thread.create(function()
        while true do
            local s,err=thr:status()
            if err then j(err); return end
            if s=='completed' then local ok,res=thr:get(); if ok then r(res) else j(res) end; return end
            if s=='canceled' then j(s); return end
            wait(0)
        end
    end)
end

function updatevc()
    while true do
        wait(10000)
        asyncHttpRequest('GET',"https://n-api.arizona-rp.com/api/servers/vc/online",{headers={["Referer"]="https://arizona-rp.com/"}},
        function(resp) if resp and resp.text then addTextRightFromOnline("VC "..resp.text) end end)
    end
end

function fastrun()
    local m_bLookingAtPlayer = ffi.cast("uint8_t*", 0xB6F028 + 0x2B)
	local m_pPlayerPed = ffi.cast("uintptr_t*", 0xB6F5F0)
    while true do wait(0)
        if fastrunm[0] then
            if m_bLookingAtPlayer[0] == 1 then
                if not isCharSittingInAnyCar(PLAYER_PED) and isButtonPressed(PLAYER_HANDLE, 16) then
                    local m_pPlayerData = ffi.cast("uintptr_t*", m_pPlayerPed[0] + 0x480)
                    local m_fSprintEnergy = ffi.cast("float*", m_pPlayerData[0] + 0x1C)
                    if m_fSprintEnergy[0] < 1 then
                        m_fSprintEnergy[0] = 1
                    end
                end
            end
        end
    end
end

function spawnbot()
    while true do wait(0)
        if spawnbot == true then
            sampSendChat("/invent")
            sendCEF('requestShowingInventory|28')  
            sendCEF('clickOnMenu|{"id": 0}')  
            sendCEF('inventoryClose') 
            wait(5000)
            spawnbot = false
        end
    end
end


function whplay()
    while true do wait(0)
        for id = 0, sampGetPlayerCount(false) do
            local streamed, hn = sampGetCharHandleBySampPlayerId(id)
            if streamed then  
                local xx,yy,zz = getCharCoordinates(hn)
                if isPointOnScreen(xx,yy,zz, nil) then
                    local x,y,z = getCharCoordinates(playerPed)
                    local lX, lY = convert3DCoordsToScreen(xx,yy,zz)
                    if sampGetPlayerNickname(id) == "Angel_Forbes" or sampGetPlayerNickname(id) == "Dmitriy_Rise" or sampGetPlayerNickname(id) == "Morty_Forbes" then
                        if isCharOnScreen(hn) then
                            renderDrawPolygon(lX, lY, 5, 5, 10, 0, 0xFFFF0000)
                        end
                    end
                end
            end
        end
    end
end

function wh3dtext()
    while true do
        wait(200)
        for id = 0, 2048 do
            if sampIs3dTextDefined(id) then
                local text3d, color3d, posX3d, posY3d, posZ3d, distance3d, ignoreWalls3d, playerId3d, vehicleId3d = sampGet3dTextInfoById(id)
                if debugwh3d[0] then
                    local wposX, wposY = convert3DCoordsToScreen(posX3d, posY3d, posZ3d)
                    local resX, resY = getScreenResolution()
                    local playerX, playerY, playerZ = getCharCoordinates(PLAYER_PED)
                    if getDistanceBetweenCoords3d(playerX, playerY, playerZ, posX3d, posY3d, posZ3d) <= 2 and wposX < resX and wposY < resY and isPointOnScreen(posX3d, posY3d, posZ3d, 1) then
                        if isKeyDown(81) then
                            setClipboardText(string.format('%s %s %.2f %.2f %.2f %d %d %d %d', text3d, color3d, posX3d, posY3d, posZ3d, distance3d, ignoreWalls3d and 1 or 0, playerId3d or -1, vehicleId3d or -1))
                            sms('3D-Text Найден, сохранен в буфер')
                        end
                    end
                end
            end
        end
    end
end

function random(min, max)
    local kf = math.random(min, max)
    math.randomseed(os.time() * kf)
    local rand = math.random(min, max)
    return tonumber(rand)
end

function autoreconectrandom()
    while true do wait(0)
        if autorec then
            delaychectqaq = os.time() +  random(1,5) * 60
            local wwwwwwwwwwwad = delaychectqaq - os.time()
            local minuawdawdatessa = math.floor(wwwwwwwwwwwad / 60)
            sms('Автоматический перезаход через: '..minuawdawdatessa.. ' мин.', -1)
            while os.time() < delaychectqaq do
                wait(0)
                local timeRemainingsa = delaychectqaq - os.time()
                local minutessa = math.floor(timeRemainingsa / 60)
                local secondssa = timeRemainingsa % 60
                local rtimea  = string.format("%02d:%02d", minutessa, secondssa)
                renderFontDrawText(font,''..rtimea,sw/2-renderGetFontDrawTextLength(font,'текст!')/2,sh/2,0xFFFF0000 )             
            end           
            sampSetLocalPlayerName(mainIni.main.nickrecons)
            wait(200)
            sampConnectToServer(mainIni.main.serverrecon, 7777)
            autorec = false
         end
    end
end

function timekalashnik()
	while true do wait(50) 
        oXcurrenttime = 250
        oYcurrenttime = 430
	    local current_time = os.time() + piska
		local milliseconds = math.floor(os.clock() * 1000) % 1000
		time_with_ms = os.date("%H:%M:%S", current_time) .. string.format(".%03d", milliseconds)
		sampTextdrawCreate(222, time_with_ms, oXcurrenttime + 32, oYcurrenttime)
		sampTextdrawSetLetterSizeAndColor(222, 0.3, 1.7, 0xFFe1e1e1)
		sampTextdrawSetOutlineColor(222, 0.5, 0xFFFF0000)
		sampTextdrawSetAlign(222, 1)
		sampTextdrawSetStyle(222, 2)
	end
end

function getnumber(id)   
    sms('[Информация] {FFFFFF}Введите {00FF00}/call id {FFFFFF}игрока.')
    sampSendChat("/number " .. id)
end

function bike()
    while true do wait(0)
        if isKeyDown(0x45) and speedrunning[0] and isCharOnFoot(playerPed) then
            setGameKeyState(16, 256)
            wait(10)
            setGameKeyState(16, 0)  
        end
    end
end



function onReceivePacket(id,bs)
    if id == 32 then autorec = true end
    if id == 33 then autorec = true end
    if id == 34 then autorec = false delaychectqaq = os.time() end
    if id == 220 then
        raknetBitStreamIgnoreBits(bs, 8)
        if (raknetBitStreamReadInt8(bs) == 17) then
            raknetBitStreamIgnoreBits(bs, 32)
            local length = raknetBitStreamReadInt16(bs)
            local encoded = raknetBitStreamReadInt8(bs)
            local str = (encoded ~= 0) and raknetBitStreamDecodeString(bs, length + encoded) or raknetBitStreamReadString(bs, length)
            if str ~= nil then
                if str:find('event%.setActiveView\', `%["Inventory"%]') then
                    newinv = true
                end
                if str:find('event.rewardBanner.initializeRewards') or str:find('event.rewardBanner.initializeData') then
                    sendCEF('rewardBanner.close')
                end
                if str:find("event%.arizonahud%.playerSatiety', `%[(%d+)%]`") and autoeat[0] then
                    satiety = tonumber(str:match("(%d+)"))
                    if satiety <= 20 then
                        sampSendChat('/jmeat')
                    end
                end
            end
        end
    end
end
--window.executeEvent('event.setActiveView', `["Inventory"]`); | 220, 17, 60, 0, window.executeEvent('event.setActiveView', `["Inventory"]`);
sendCEF = function(str)
    local bs = raknetNewBitStream()
    raknetBitStreamWriteInt8(bs, 220)
    raknetBitStreamWriteInt8(bs, 18)
    raknetBitStreamWriteInt16(bs, #str)
    raknetBitStreamWriteString(bs, str)
    raknetBitStreamWriteInt32(bs, 0)
    raknetSendBitStream(bs)
    raknetDeleteBitStream(bs)
end

function formatNumber(num)
    local formatted = tostring(num)
    while true do  
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1.%2')
        if (k==0) then
            break
        end
    end
    return formatted
end



function sampev.onSendSpawn()
    mainIni.main.nickrecons = u8:decode(str(sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))))
    local ip, port = sampGetCurrentServerAddress()
    mainIni.main.serverrecon = u8:decode(str(ip))
    inicfg.save(mainIni, "MiniCrHelper/MiniHelper-CR")
    autorec = false
    delaychectqaq = os.time()
    if autospawnbot[0] and newinv then
        spawnbot = true
    end
end



function sampev.onServerMessage(color, text)
    if text:match("%a+_%a+%[%d+%]:    {......}%d+$") then
        local number = text:match("%a+_%a+%[%d+%]:    {......}(%d+)$")
        lua_thread.create(function()
            sms('Calling: {aa0000}' .. number)
            wait(500)
            sampSendChat("/call " .. number)
        end)
        return false
    end

    if text:find('Нельзя так быстро открывать инвентарь, подождите еще (.+) сек.') then
        return false
    end

    if text:find('Призыв личного охранника отменён!') then

    end

    if text:find('Этот транспорт зарегистрирован на жителя {......}(.+)') then
        local nikc = text:match('Этот транспорт зарегистрирован на жителя {......}(.+)')
        local result, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
        if sampGetPlayerNickname(id) == nikc then
            sampSendChat("/lock")
        end
    end
    table.insert(recentMessages, 1, text)
    if #recentMessages > 30 then
        table.remove(recentMessages, #recentMessages)
    end

end

function sampev.onDisplayGameText(style, time, text)
    if text:match("ENGINE ~r~OFF") then
        sampSendChat("/engine")
    end
end

function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
    onShowDialogwqq = string.format("Текущая информация о диалоге:\nДиалог ID: %d \nДиалог тип: %d \nЗаголовок диалогового окна:\n%s\nТекст диалогового окна:\n%s", dialogId, style, title, text)

    if title:find('{BFBBBA}{73B461}Аренда семейного авто') then
        sampSendDialogResponse(dialogId, 1, 0, nil)
        sampSendChat('/lock')
        return false
    end

    if title:find('{BFBBBA}{73B461}Лифт') and text:find('{cccccc}Холл') then
        sampSendDialogResponse(dialogId, 1, 1, nil)
        return false
    end

    if title:find('Акции на Arizona Role Play') then
        sampSendDialogResponse(dialogId, 1, 1, nil)
        return false
    end

    if text:find("{FFFFFF}Удача! При использовании сундука с рулеткой") or text:find("{FFFFFF}Удача! При использовании платинового сундука с рулеткой")  then
        return false
    end

    if text:find("Заспавнить рядом с собой") and spawnbot == true then
        sampSendDialogResponse(dialogId, 1, 0, nil)
        return false
    end

    if text:find("Спрятать") and spawnbot == true then
        sampSendDialogResponse(dialogId, 0, 0, nil)
        spawnbot = false
        return false
    end
    
    if title:find('Призыв охранника') and spawnbot == true then
        spawnbot = false
        return false
    end




    if text:match("Текущее время") then
        local chislo, mesyac, god = text:match("Сегодняшняя дата: 	{2EA42E}(%d+):(%d+):(%d+)")
        local chas, minuti, sekundi = text:match("Текущее время: 	{345690}(%d+):(%d+):(%d+)")
        local datetime = {year = god, month = mesyac, day = chislo, hour = chas, min = minuti, sec = sekundi}
        piska = tostring(os.time(datetime)) - os.time()
    end

    local bankAmount = 0
    local depositAmount = 0
    local newText = ""
    for line in text:gmatch("[^\r\n]+") do
        newText = newText .. line .. "\n"
        if line:find('Деньги в банке:') then
            local bankStr = line:match('%$([%d%.]+)')
            if bankStr then
                bankStr = bankStr:gsub("%.", "")
                bankAmount = tonumber(bankStr) or 0
            end
        end
        if line:find('Деньги на депозите:') then
            local depositStr = line:match('%$([%d%.]+)')
            if depositStr then         
                depositStr = depositStr:gsub("%.", "")
                depositAmount = tonumber(depositStr) or 0
            end
            local totalAmount = bankAmount + depositAmount - 306000000
            newText = newText .. "{FFFFFF}Общая сумма ДБ + ДД: {B83434}[$" .. formatNumber(totalAmount) .. "]\n"
        end
    end

    if button1 and button1 ~= '' then
        button1 = '{32d137}' .. button1
    end
    if button2 and button2 ~= '' then
        button2 = '{d0595d}' .. button2
    end

    return {dialogId, style, title, button1, button2, newText}
end