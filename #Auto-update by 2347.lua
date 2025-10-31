--        .______   ____    ____                __   ___    ____    _  _     ______   __             
--        |   _  \  \   \  /   /               |  | |__ \  |___ \  | || |   |____  | |  |            
--        |  |_)  |  \   \/   /      ______    |  |    ) |   __) | | || |_      / /  |  |     ______ 
--        |   _  <    \_    _/      |______|   |  |   / /   |__ <  |__   _|    / /   |  |    |______|
--        |  |_)  |     |  |                   |  |  / /_   ___) |    | |     / /    |  |            
--        |______/      |__|                   |  | |____| |____/     |_|    /_/     |  |            
--                                             |__|                                  |__|            

script_name('{FF0000}#Auto-update by 2347.lua')
script_version("0.0.1")
script_authors('TG @Qwestonsz')
script_url('https://www.blast.hk/members/464512/')

require("lib.moonloader")
require('encoding').default = 'CP1251'
local u8 = require('encoding').UTF8
local imgui = require('mimgui')
local lfs = require("lfs")
local sizeX, sizeY = getScreenResolution()
local MainWindow = imgui.new.bool()

local dir = getWorkingDirectory():gsub('\\','/')
local all_scripts = {}
local support_scripts = {}
local ignoreDirs = {lib=true}

function msg(text)
    sampAddChatMessage('{00ccff}[#Auto-update by 2347.lua] {ffffff}' .. text, -1)
end

local function getVersion(file)
    local f = io.open(file,"r") 
    if not f then return nil end
    local v = f:read("*a"):match('script_version%("([%d%.]+)"%)')
    f:close()
    return v
end

local function scanScripts(dirPath)
    local scripts = {}
    for f in lfs.dir(dirPath) do
        if f ~= "." and f ~= ".." then
            local full = dirPath.."/"..f
            local attr = lfs.attributes(full)
            if attr.mode == "directory" and not ignoreDirs[f] then
                local sub = scanScripts(full)
                for _, v in ipairs(sub) do table.insert(scripts, v) end
            elseif f:match("%.lua$") then
                local v = getVersion(full)
                if v then
                    table.insert(scripts, {path=full, name=f:gsub("%.lua$",""), ver=v})
                end
            end
        end
    end
    return scripts
end

local function isVersionOlder(localVer, remoteVer)
    if not localVer then return true end
    local function splitVer(ver)
        local t = {}
        for num in ver:gmatch("%d+") do table.insert(t, tonumber(num)) end
        return t
    end
    local lv, rv = splitVer(localVer), splitVer(remoteVer)
    for i = 1, math.max(#lv, #rv) do
        local l, r = lv[i] or 0, rv[i] or 0
        if l < r then return true end
        if l > r then return false end
    end
    return false
end

local function downloadFileFromUrlToPath(url, path)
    downloadUrlToFile(url, path, function(id, status)
        if status == 6 then 
            lua_thread.create(function ()
                msg('Скрипт '..path:gsub(dir.."/","")..' загружен! Перезапуск через 3 сек...')
                MainWindow[0] = false
                wait(3000)
                reloadScripts()
            end)
        end
    end)
end

local function get_all_scripts(callback)
    all_scripts = {}
    support_scripts = {}

    local url = "https://raw.githubusercontent.com/ass138/Auto-update-by-2347/main/scripts.json"

    lua_thread.create(function()
        local https = require("ssl.https")
        local ltn12 = require("ltn12")
        local response_body = {}
        local res, code = https.request{
            url = url,
            sink = ltn12.sink.table(response_body)
        }

        if not res or code ~= 200 then
            if callback then callback(false) end
            return
        end

        local content = table.concat(response_body)
        local cjson = require("cjson")
        local ok, data = pcall(cjson.decode, content)
        if not ok or type(data) ~= "table" then
            if callback then callback(false) end
            return
        end

        all_scripts = data
        support_scripts = {}
        for _, v in ipairs(all_scripts) do
            table.insert(support_scripts, v)
        end
        if callback then callback(true) end
    end)
end

local function checkScriptsForUpdate()
    local localScripts = scanScripts(dir)
    get_all_scripts(function(success)
        if not success then return end
        local updateQueue = {}

        for _, remote in ipairs(all_scripts) do
            local path = string.format("%s/%s.lua", dir, remote.name)
            if lfs.attributes(path) then
                local localVer = nil
                for _, localS in ipairs(localScripts) do
                    if localS.name == remote.name then
                        localVer = localS.ver
                        break
                    end
                end
                if isVersionOlder(localVer, remote.ver) then
                    table.insert(updateQueue, {name = remote.name, link = remote.link, path = path})
                end
            end
        end
        if #updateQueue == 0 then return end

        lua_thread.create(function()
            for _, script in ipairs(updateQueue) do
                local finished = false
                downloadUrlToFile(script.link, script.path, function(id, status)
                    if status == 6 then
                        finished = true
                    end
                end)
                repeat wait(0) until finished
            end
            msg("Все обновления завершены! Перезапуск скриптов...")
            wait(1000)
            reloadScripts()
        end)
    end)
end



function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(0) end
    sampRegisterChatCommand('scrt', function() get_all_scripts(function() MainWindow[0] = true end) end)
    repeat wait(0) until sampIsLocalPlayerSpawned()
	print('{00FF00}Для авто-установки скриптов Активация {FFFFFF}/scrt')
    msg('Для авто-установки скриптов/хелперов используйте команду {00ccff}/scrt')
    checkScriptsForUpdate()
    wait(-1)
end

imgui.OnFrame(function() return MainWindow[0] end, function()
    imgui.SetNextWindowPos(imgui.ImVec2(0,0), imgui.Cond.Always)
    imgui.SetNextWindowSize(imgui.ImVec2(sizeX, sizeY), imgui.Cond.Always)
    imgui.Begin("#Auto-update by 2347.lua", MainWindow, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove)

    local w,x = imgui.GetWindowContentRegionWidth(), imgui.GetCursorPosX()
    local pos = {ver=x+w*0.3, info=x+w*0.5, act=x+w*0.85}
    local map = {["Название"]="ver", ["Версия"]="info", ["Описание"]="act"}

    for _, h in ipairs({"Название","Версия","Описание","Действие"}) do
        imgui.Text(u8(h))
        if map[h] then imgui.SameLine(pos[map[h]]) end
    end
    imgui.Separator()

    for i,v in ipairs(support_scripts) do
        imgui.Text(u8(v.name))
        imgui.SameLine(pos.ver) imgui.Text(u8(v.ver))
        imgui.SameLine(pos.info) imgui.PushTextWrapPos(pos.act-5) imgui.Text((v.info)) imgui.PopTextWrapPos()
        imgui.SameLine(pos.act)
        local path = string.format("%s/%s.lua", dir, v.name)
        local exists = lfs.attributes(path)
        local label = exists and "Удалить##" or "Скачать##"
        if imgui.Button(u8(label..i)) then
            if exists then
                os.remove(path)
                lua_thread.create(function()
                    msg('Скрипт '..v.name..' удалён! Перезапуск через 3 сек...')
                    MainWindow[0] = false
                    wait(3000)
                    reloadScripts()
                end)
            else
                downloadFileFromUrlToPath(v.link, path)
                MainWindow[0] = false
            end
        end
        imgui.Separator()
    end

    imgui.End()
end)
