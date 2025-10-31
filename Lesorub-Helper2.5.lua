--        .______   ____    ____                __   ___    ____    _  _     ______   __             
--        |   _  \  \   \  /   /               |  | |__ \  |___ \  | || |   |____  | |  |            
--        |  |_)  |  \   \/   /      ______    |  |    ) |   __) | | || |_      / /  |  |     ______ 
--        |   _  <    \_    _/      |______|   |  |   / /   |__ <  |__   _|    / /   |  |    |______|
--        |  |_)  |     |  |                   |  |  / /_   ___) |    | |     / /    |  |            
--        |______/      |__|                   |  | |____| |____/     |_|    /_/     |  |            
--                                             |__|                                  |__|            

script_name('Lesorub-Helper2.5.lua')
script_version("0.2.6")
script_authors('TG @Qwestonsz')
script_url('https://www.blast.hk/members/464512/')

local imgui = require 'mimgui'
local encoding = require 'encoding'

local hotkey = require 'mimgui_hotkeys'
local inicfg = require 'inicfg'
local sampev = require 'lib.samp.events'
encoding.default = 'CP1251'
local u8 = encoding.UTF8
local new = imgui.new

local cfg = inicfg.load({ config = { bind = '[32]' } }, 'LesorubHelper.ini') inicfg.save(cfg, 'LesorubHelper.ini')
local Window, collision, posadka, prokachka, spilivanie, status, infobar, hotkeyq, rubka, exampleHotKey = new.bool(), new.bool(), new.bool(), new.bool(), new.bool(), new.bool(), new.bool(false), false, false, nil
local checkboxData = {{ u8'Коллизия для деревьев', u8'Включение или отключение коллизии для объектов помогает избежать\nпроваливания под текстуры при посадке и улучшении деревьев.', collision }, { u8'Посадка деревьев', u8'Вы можете назначить нужную вам клавишу, и при нажатии\nна неё будет происходить посадка деревьев.', posadka }, { u8'Прокачка деревьев', u8'Подойдите к дереву, и оно автоматически\nначнёт улучшаться.', prokachka }, { u8'Спиливание деревьев', u8'Подойдите к дереву с бензопилой, дерево\nбудет спилено автоматически.', spilivanie } }

local ffi = require("ffi")

local KEYEVENTF_KEYUP, INPUT_KEYBOARD = 0x0002, 1
ffi.cdef[[
  typedef unsigned char BYTE;
  typedef unsigned short WORD;
  typedef unsigned long DWORD;
  typedef struct { WORD wVk, wScan; DWORD dwFlags, time, dwExtraInfo; } KEYBDINPUT;
  typedef struct { DWORD type; KEYBDINPUT ki; } INPUT;
  UINT SendInput(UINT, INPUT*, int);
  void keybd_event(BYTE, BYTE, DWORD, DWORD);
  DWORD GetLastError(void);
]]

local inputBuf   = ffi.new("INPUT[1]")
local inputSize  = ffi.sizeof("INPUT")

local function sendKey(vk, down)
  inputBuf[0].type           = INPUT_KEYBOARD
  inputBuf[0].ki.wVk         = vk
  inputBuf[0].ki.wScan       = 0
  inputBuf[0].ki.dwFlags     = down and 0 or KEYEVENTF_KEYUP
  inputBuf[0].ki.time        = 0
  inputBuf[0].ki.dwExtraInfo = 0

  if ffi.C.SendInput(1, inputBuf, inputSize) ~= 1 then
    ffi.C.keybd_event(vk, 0, inputBuf[0].ki.dwFlags, 0)

  end
end

local function pressKey(vk)
  sendKey(vk, true)
  wait(1)
  sendKey(vk, false)
end

local VK_H, VK_LCONTROL = 0x48, 0xA2

if type(cfg.config.bind) ~= 'string' or cfg.config.bind == '' then cfg.config.bind = '[]' end

imgui.OnFrame(function() return Window[0] end, function()
    imgui.SetNextWindowPos(imgui.ImVec2(500, 500), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.Begin(u8'Lesorub-Helper | ' .. unpack(thisScript().authors), Window, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoCollapse)
    for i, cb in ipairs(checkboxData) do
        if imgui.Checkbox(cb[1], cb[3]) then
            if i == 3 and prokachka[0] then spilivanie[0] = false end
            if i == 4 and spilivanie[0] then prokachka[0] = false end
            if i == 5 then infobar[0] = status[0] end
        end
        imgui.SameLine()
        if i == 2 and exampleHotKey and exampleHotKey:ShowHotKey() then
            cfg.config.bind = encodeJson(exampleHotKey:GetHotKey())
            inicfg.save(cfg, 'LesorubHelper.ini')
        end     
        imgui.SameLine(); imgui.Text('(?)')
        if imgui.IsItemHovered() then imgui.BeginTooltip(); imgui.Text(cb[2]); imgui.EndTooltip() end
    end  
    imgui.End()
end)

function main()
    while not isSampAvailable() do wait(100) end
    for _, f in pairs({Collision, posadkaq, spilivanieq, treedxyetasuka, Auto_HotKey, frizzq}) do lua_thread.create(f) end
    sampAddChatMessage("{FFFFFF}[{00FF00}Lesorub-Helper{FFFFFF}]: Активация {DC143C}/les {FFFFFF}или {DC143C}F9", -1)
    sampRegisterChatCommand('les', function() Window[0] = not Window[0] end)
    cfg.config.bind = type(cfg.config.bind) == 'string' and cfg.config.bind ~= '' and cfg.config.bind or '[]'
    exampleHotKey = hotkey.RegisterHotKey('random hotkey 1', false, decodeJson(cfg.config.bind), function() end)
    hotkey.Text.NoKey, hotkey.Text.WaitForKey = u8'Пусто', u8'Ожид клавиш'
    while true do wait(0) if wasKeyPressed(0x78) and not sampIsCursorActive() then Window[0] = not Window[0] end end
end

function Collision()
    while true do wait(10)
        for id = 0, 1000 do
            local handle = sampGetObjectHandleBySampId(id)
            if doesObjectExist(handle) and tostring(getObjectModel(handle)) then
                setObjectCollision(handle, not collision[0])
            end
        end
    end
end

function posadkaq()
    while true do wait(0)
        if posadka[0] and wasKeyPressed(table.concat(exampleHotKey:GetHotKey())) then
            sampSendChat("/seat")
        end
    end
end

function sampev.onServerMessage(color, text)
    if text:match('Поздравляем! {FFFFFF}Вы собрали %d+ древесины.') then rubka = false frizz =  false end
end

function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
    if prokachka[0] then
        if text:match('{FFFFFF}Будет готов через: {52AB4A}Готово') then
            hotkeyq = false
            sampSendDialogResponse(dialogId, 1, 1, nil)
            return false
        elseif text:match('FFFFFF}Будет готов через: {52AB4A}(%d+):(%d+)') then
            sampAddChatMessage(text:match('%d+:%d+'), -1)
            sampSendDialogResponse(dialogId, 1, 1, nil)
            return false
        end
    end
end

function spilivanieq()
    while true do wait(0)     
        if rubka and isCurrentCharWeapon(PLAYER_PED, 9) then wait(150) pressKey(VK_LCONTROL) frizz = true else freezeCharPosition(PLAYER_PED, false) frizz =  false end
    end
end

function frizzq()
    while true do wait(0)
    if frizz then
            freezeCharPosition(PLAYER_PED, true)
        end
    end
end




function treedxyetasuka()
	while true do wait(0)
	local self_id = select(2, sampGetPlayerIdByCharHandle(playerPed))
	local self_name = sampGetPlayerNickname(self_id)
		for id = 0, 2048 do
			if sampIs3dTextDefined(id) then
				text, color, posX, posY, posZ, distance, ignoreWalls, playerId, vehicleId = sampGet3dTextInfoById( id )
				playerX, playerY, playerZ = getCharCoordinates(playerPed)
                distance = getDistanceBetweenCoords3d(playerX, playerY, playerZ, posX, posY, posZ)
				health, name = text:match("Здоровье: {FF0000} (%d+)\n{FFFFFF}Посадил: {CCCCCC}([%w_]+)")
                
				if name == self_name and health then
                    
					if distance <= 1.5 and prokachka[0] then pressKey(VK_H) end
                    if distance >= 1.5 and prokachka[0] then hotkeyq = false end
                    if distance <= 1.5 and spilivanie[0] then hotkeyq = false rubka = true end
				end
			end
		end
	end
end

function Auto_HotKey()
    while true do wait(0)
        if hotkeyq and prokachka[0] then pressKey(VK_H) sampAddChatMessage('1', -1) end
    end
end