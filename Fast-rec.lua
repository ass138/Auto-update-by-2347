script_name('Fast-rec.lua')
script_version("0.0.2")
script_authors('TG @Qwestonsz')
script_url('https://www.blast.hk/members/464512/')

require('lib.moonloader')
local imgui = require 'mimgui'
local encoding = require 'encoding'
local sampev = require 'samp.events'
local inicfg = require 'inicfg'

encoding.default = 'CP1251'
local u8 = encoding.UTF8
local new = imgui.new

-- Инициализация mainIni
local mainIni = inicfg.load({ main = {} }, "Fast-rec.ini")

local win_mimgui = new.bool(true)
local showConfirm = new.bool(false)
local selectedPlace = nil
local plusButtonKey = nil
local buttonPositions = {} 

imgui.OnFrame(function()
    return win_mimgui[0] and sampIsChatInputActive() end, function(player)

    local sw, sh = getScreenResolution()
    imgui.SetNextWindowPos(imgui.ImVec2(sw / 25, sh / 2.3), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(0, 0, 0, 0))
    imgui.Begin(u8''..thisScript().filename, win_mimgui, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.AlwaysAutoResize)

    buttonPositions = {}

    if mainIni and mainIni.main then
        local sorted_keys = {}
        for key, _ in pairs(mainIni.main) do
            local index = tonumber(key:match("line_(%d+)"))
            if index then table.insert(sorted_keys, index) end
        end
        table.sort(sorted_keys)

        for _, index in ipairs(sorted_keys) do
            local key = "line_" .. index
            local name = mainIni.main[key]
            if name then
                local max_length = 12
                local display_name = name:sub(1, max_length)

                if plusButtonText == name then
                    display_name = display_name .. " +"
                end

                -- сохраняем позицию кнопки для ПКМ
                local cursorPos = imgui.GetCursorScreenPos()
                local size = imgui.CalcTextSize(u8(display_name))
                buttonPositions[key] = {x = cursorPos.x, y = cursorPos.y, w = size.x + 12, h = size.y + 6}

                -- ЛКМ выбирает кнопку
                if imgui.Button(u8(display_name)) then
                    selectedPlace = name
                    showConfirm[0] = true
                end
            end
        end
    end

    imgui.End()
    imgui.PopStyleColor()

    -- ПКМ toggle по тексту кнопки
    local io = imgui.GetIO()
    if io.MouseReleased[1] then
        local mx, my = io.MousePos.x, io.MousePos.y
        for key, pos in pairs(buttonPositions) do
            if mx >= pos.x and mx <= pos.x + pos.w and my >= pos.y and my <= pos.y + pos.h then
                local name = mainIni.main[key]
                if plusButtonText == name then
                    plusButtonText = nil
                else
                    plusButtonText = name
                end
                break
            end
        end
    end

    -- Окно подтверждения
    if showConfirm[0] then
        local sw, sh = getScreenResolution()
        imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.Always, imgui.ImVec2(0.5, 0.5))
        imgui.Begin(u8"", showConfirm, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.AlwaysAutoResize)
        imgui.Text(u8"Вы действительно хотите перезайти?")
        imgui.Dummy(imgui.ImVec2(0, 10))
        imgui.SetCursorPosX((imgui.GetWindowWidth() - 200) / 2)
        if imgui.Button(u8"да", imgui.ImVec2(100, 30)) then
            sampProcessChatInput('/rec')
            showConfirm[0] = false
        end
        imgui.SameLine()
        if imgui.Button(u8"нет", imgui.ImVec2(100, 30)) then
            showConfirm[0] = false
        end
        imgui.End()
    end
end).HideCursor = true


-- Главный цикл
function main()
    while not isSampAvailable() do wait(100) end
    while true do wait(0) end
end

-- Обработка диалога
function sampev.onShowDialog(id, style, title, button1, button2, text)
    if title:find('{BFBBBA}Выбор места спавна') then
        local parsed_dialog = {}
        local unique_entries = {}

        -- Парсим текст диалога и убираем дубликаты
        for n in text:gmatch('[^\r\n]+') do
            local clean_line = n:match('%[%d+%] %{ffffff%}%s*(.+)') or n
            if not unique_entries[clean_line] then
                table.insert(parsed_dialog, clean_line)
                unique_entries[clean_line] = true
            end
        end

        -- Сохраняем текущий плюс по тексту
        local oldPlusButtonText = plusButtonText

        -- Обновляем mainIni
        for key in pairs(mainIni.main) do mainIni.main[key] = nil end
        for i, line in ipairs(parsed_dialog) do
            mainIni.main["line_" .. i] = line
        end
        inicfg.save(mainIni, "Fast-rec.ini")

        -- Восстанавливаем плюс, если текст кнопки все еще существует
        if oldPlusButtonText then
            local exists = false
            for _, line in ipairs(parsed_dialog) do
                if line == oldPlusButtonText then
                    exists = true
                    break
                end
            end
            if exists then
                plusButtonText = oldPlusButtonText
            else
                plusButtonText = nil
            end
        end

        -- Авто-выбор кнопки по plusButtonText
        if plusButtonText then
            local autoIndex = nil
            for i, line in ipairs(parsed_dialog) do
                if line == plusButtonText then
                    autoIndex = i
                    break
                end
            end
            if autoIndex then
                sampSendDialogResponse(id, 1, autoIndex - 1, '')
                return false
            end
        elseif selectedPlace then
            -- выбор пользователя по ЛКМ
            for dialog_line_index = 1, #parsed_dialog do
                if parsed_dialog[dialog_line_index] == selectedPlace then
                    sampSendDialogResponse(id, 1, dialog_line_index - 1, '')
                    selectedPlace = nil
                    return false
                end
            end
        end
    end
end


-- Настройка стиля
imgui.OnInitialize(function()
    local style = imgui.GetStyle()
    local colors = style.Colors
    style.WindowPadding = imgui.ImVec2(10.00, 10.00)
    style.FramePadding = imgui.ImVec2(12.00, 3.00)
    style.FrameRounding = 8.0
    style.FrameBorderSize = 2.0
    style.GrabRounding = 8.0
    style.TabRounding = 10.0
    style.ButtonTextAlign = imgui.ImVec2(0.50, 0.50)
    colors[imgui.Col.Button] = imgui.ImVec4(0.10, 0.20, 0.30, 1.00)
    colors[imgui.Col.ButtonHovered] = imgui.ImVec4(0.20, 0.30, 0.40, 1.00)
    colors[imgui.Col.ButtonActive] = imgui.ImVec4(0.30, 0.40, 0.50, 1.00)
end)
