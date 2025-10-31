script_name('FastOpenRoulette.lua')
script_version("0.0.1")
script_authors('TG @Qwestonsz')
script_url('https://www.blast.hk/members/464512/')

local sampev = require('lib.samp.events')
local roulette = 0
local state = false
function main()
    while not isSampAvailable() do wait(0) end
    sampRegisterChatCommand('roulette', function (params)
        if #params > 0 then
            if state then
                if tonumber(params) == roulette then
                    state = false
                else
                    roulette = tonumber(params)
                end
            else
                state = true
                roulette = tonumber(params)
            end
        end
        msg((state and 'ON' or 'OFF')..' // Roulette: '..roulette)
    end)
    msg('Загружен. Активация /roulette [кол-во]')
    wait(-1)
end

function onSendPacket(id, bs, priority, reliability, orderingChannel)
    if id == 220 and state and roulette > 0 then
        raknetBitStreamReadInt8(bs)
        if raknetBitStreamReadInt8(bs) == 18 then
            local strlen = raknetBitStreamReadInt16(bs)
            local str = raknetBitStreamReadString(bs, strlen)
            if str == 'onActiveViewChanged|CrateRoulette' then
                sendcef('crate.roulette.open')
                sendcef('crate.roulette.takePrize')
                roulette = roulette - 1
            end
        end
    end
end
function onReceivePacket(id, bs)
    if id == 220 then
        raknetBitStreamReadInt8(bs);
        if raknetBitStreamReadInt8(bs) == 17 then
            raknetBitStreamReadInt32(bs)
            local length = raknetBitStreamReadInt16(bs)
            local encoded = raknetBitStreamReadInt8(bs)
            if length > 0 then
                local text = (encoded ~= 0) and raknetBitStreamDecodeString(bs, length + encoded) or raknetBitStreamReadString(bs, length)
                local event, data = text:match('window%.executeEvent%(\'(.+)\',%s*`%[(.+)%]`%);');
                if event == 'event.crate.roulette.onCrateOpen' then
                    if roulette > 0 then
                        lua_thread.create(function ()
                            wait(1000)
                            sendcef('crate.roulette.open')
                            sendcef('crate.roulette.takePrize')
                            roulette = roulette - 1
                        end)
                    else
                        sendcef('crate.roulette.exit')
                        state = false
                    end
                end
            end
        end
    end
end

function sampev.onShowDialog(id, style, title, button1, button2, text)
    if text:find('%{......%}\n\nПоздравляем с получением: %{97FC9A%}(.+)%{FFFFFF%}%.\nПриятной игры на arizona%-rp%.com') then
        local prize = text:match('%{......%}\n\nПоздравляем с получением: %{97FC9A%}(.+)%{FFFFFF%}%.\nПриятной игры на arizona%-rp%.com')
        msg('Вы получили: '..prize)
        sampfuncsLog('{b844db}[FastRoulette] {FFFFFF}Вы получили: '..prize)
        if not doesDirectoryExist(getWorkingDirectory()..'\\Roulette') then createDirectory(getWorkingDirectory()..'\\Roulette') end
        local file = io.open(getWorkingDirectory()..'\\Roulette\\'..os.date('%d %m %y')..'.txt', 'a+')
        if file then
            file:write('['..os.date('%H:%M:%S')..'] '..prize..'\n')
            file:close()
        end
    end
end
function bitStreamStructure(bs)
    local text, array = '', {}
    for i = 1, raknetBitStreamGetNumberOfBytesUsed(bs) do
        local byte = raknetBitStreamReadInt8(bs)
        if byte >= 32 and byte <= 255 and byte ~= 37 then text = text .. string.char(byte) end
        table.insert(array, byte)
    end
    raknetBitStreamResetReadPointer(bs)
    return text, array
end
function sendcef(code)
    local bs = raknetNewBitStream()
    raknetBitStreamWriteInt8(bs, 220)
    raknetBitStreamWriteInt8(bs, 18)
    raknetBitStreamWriteInt16(bs, #code)
    raknetBitStreamWriteString(bs, code)
    raknetBitStreamWriteInt32(bs, 0)
    raknetBitStreamWriteInt16(bs, 0)
    raknetSendBitStreamEx(bs, 2, 9, 6)
    raknetDeleteBitStream(bs)
end
function msg(text)
    return sampAddChatMessage('[FastRoulette] {FFFFFF}'..text, 0xb844db)
end