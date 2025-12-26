script_name('Chat-Calculator.lua')
script_version("0.0.2")
script_authors('Adrian G.')
script_url('https://www.blast.hk/members/464512/')
----------------------------------------------------------------------------------------------------------------
local imgui = require 'imgui'
local window = imgui.ImBool(false)
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8
imgui.ShowCursor = false

function main()
    repeat wait(100) until isSampAvailable()
    while true do wait(0)
        text = sampGetChatInputText()
    
        if text:find('%d') and text:find('[-+/*^%%]') and text ~= nil then
            local number = calculate_expression(text)
            if number then
                result = 'Результат: '..number
                ok = true
                if not isKeyDown(0x08) then
                    --setClipboardText(number)
                end
            else
                result = 'Ошибка в выражении'
                ok = false
            end
        end


        

        if text:find('%d+%%%*%d+') then
            number1, number2 = text:match('(%d+)%%%*(%d+)')
            number = number1*number2/100
            ok, number = pcall(load('return '..number))
            result = 'Результат: '..number
            if not isKeyDown(0x08) and ok then
            --setClipboardText(number)
            end
        end

        if text:find('%d+%%%/%d+') then
            number1, number2 = text:match('(%d+)%%%/(%d+)')
            number = number2/number1*100
            ok, number = pcall(load('return '..number))
            result = 'Результат: '..number
            if not isKeyDown(0x08) and ok then
            --setClipboardText(number)
            end
        end

        if text:find('%d+/%d+%%') then
            number1, number2 = text:match('(%d+)/(%d+)%%')
            number = number1*100/number2
            ok, number = pcall(load('return '..number))
            result = 'Результат: '..number..'%'
            if not isKeyDown(0x08) and ok then
                --setClipboardText(number..'%')
            end
        end


        
        if text == 'calc' then
            help = true
        else
            help = false
        end


        if text == '' then
            ok = false
        end

        imgui.Process = ok or help
    end
end

-- Преобразует строку вида "15.4ккк", "1,5кк" или "123к" в число
function parse_number(str)
    str = str:gsub(',', '.')  -- поддержка запятых
    local multiplier = 1

    if str:find('[кК][кК][кК]') then  -- "ккк" = 1 000 000 000
        multiplier = 1000000000
        str = str:gsub('[кК][кК][кК]', '')
    elseif str:find('[кК][кК]') then  -- "кк" = 1 000 000
        multiplier = 1000000
        str = str:gsub('[кК][кК]', '')
    elseif str:find('[кК]') then      -- "к" = 1 000
        multiplier = 1000
        str = str:gsub('[кК]', '')
    end

    local number = tonumber(str)
    if not number then return nil end
    return number * multiplier
end

-- Вычисляет выражение с числами и суффиксами
function calculate_expression(expr)
    -- Заменяем все числа с "ккк", "кк" или "к" на обычные числа
    expr = expr:gsub('(%d+[.,]?%d*[кК]?[кК]?[кК]?)', function(n)
        return parse_number(n) or n
    end)
    
    -- Используем load для вычисления
    local ok, result = pcall(load('return ' .. expr))
    if ok then
        return result
    else
        return nil
    end
end



function imgui.OnDrawFrame()
    local input = sampGetInputInfoPtr()
    local input = getStructElement(input, 0x8, 4)
    local windowPosX = getStructElement(input, 0x8, 4)
    local windowPosY = getStructElement(input, 0xC, 4)
    
    if sampIsChatInputActive() and ok then
        imgui.SetNextWindowPos(imgui.ImVec2(windowPosX, windowPosY + 30 + 15), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowSize(imgui.ImVec2(result:len()*10, 30))
        imgui.Begin('Solve', window, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove)
        imgui.CenterText(u8(number_separator(result)))

        if imgui.IsItemClicked() then
            -- Находит только цифры (и точку/запятую, если нужно)
            local clean_number = tostring(result):match("%d+%.?%d*")
            if clean_number then
                sampAddChatMessage('Результат скопирован в буфер обмена', -1)
                setClipboardText(clean_number)
            end
        end
        imgui.End()
    end
end

function imgui.CenterText(text)
    local width = imgui.GetWindowWidth()
    local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( width / 2 - calc.x / 2 )
    imgui.Text(text)
end

function number_separator(n) 
    local left, num, right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
    return left..(num:reverse():gsub('(%d%d%d)','%1.'):reverse())..right
end
