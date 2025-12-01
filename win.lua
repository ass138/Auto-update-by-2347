script_name('win.lua')
script_version("0.0.1")
script_authors('TG @Qwestonsz')
script_url('https://www.blast.hk/members/464512/')

local ffi = require('ffi')
local user32 = ffi.load('user32')

ffi.cdef[[
    typedef unsigned long DWORD;
    typedef int BOOL;
    typedef unsigned long HWND;
    typedef unsigned long LPARAM;

    typedef struct _RECT {
        long left;
        long top;
        long right;
        long bottom;
    } RECT;

    typedef struct _MONITORINFO {
        DWORD cbSize;
        RECT rcMonitor;
        RECT rcWork;
        DWORD dwFlags;
    } MONITORINFO;

    typedef void* HMONITOR;
    typedef void* HDC;
    typedef BOOL (* MONITORENUMPROC)(HMONITOR, HDC, RECT*, LPARAM);

    HWND FindWindowA(const char* lpClassName, const char* lpWindowName);
    long SetWindowLongA(HWND hWnd, int nIndex, long dwNewLong);
    long GetWindowLongA(HWND hWnd, int nIndex);
    BOOL SetWindowPos(HWND hWnd, HWND hWndInsertAfter, int X, int Y, int cx, int cy, unsigned int uFlags);
    int GetSystemMetrics(int nIndex);
    BOOL ShowWindow(HWND hWnd, int nCmdShow);
    BOOL EnumDisplayMonitors(HDC hdc, RECT* lprcClip, MONITORENUMPROC lpfnEnum, LPARAM dwData);
    BOOL GetMonitorInfoA(HMONITOR hMonitor, MONITORINFO* lpmi);

    HWND GetForegroundWindow();
    int IsIconic(HWND hWnd);
]]

-- Constants
local GWL_STYLE = -16
local WS_OVERLAPPEDWINDOW = 0x00CF0000
local WS_POPUP = 0x80000000
local HWND_TOP = 0
local SWP_FRAMECHANGED = 0x0020
local SWP_SHOWWINDOW = 0x0040

local SM_CXSCREEN = 0
local SM_CYSCREEN = 1

local SW_SHOWNORMAL = 1
local SW_SHOWMAXIMIZED = 3
local SW_MINIMIZE = 6

-- Variables
local hwnd = nil                -- окно "Arizona"
local gta_hwnd = nil            -- окно GTA (класс 'Grand theft auto san andreas')
local monitors = {}
local isOnSecondMonitor = false
local block = false             -- блокировка авторазворачивания
local win = false               -- переключатель оконный/полный (второй скрипт)

-- Мониторы
local function monitorEnumProc(hMonitor, hdcMonitor, lprcMonitor, dwData)
    local info = ffi.new("MONITORINFO")
    info.cbSize = ffi.sizeof(info)
    ffi.C.GetMonitorInfoA(hMonitor, info)
    table.insert(monitors, info)
    return true
end

local function findMonitors()
    monitors = {}
    ffi.C.EnumDisplayMonitors(nil, nil, ffi.cast("MONITORENUMPROC", monitorEnumProc), 0)
end

-- Поиск окна игры Arizona
local function findGameWindow()
    hwnd = ffi.C.FindWindowA(nil, "Arizona")
end

-- Установить оконный режим
local function setWindowedMode(hwnd)
    local style = ffi.C.GetWindowLongA(hwnd, GWL_STYLE)
    ffi.C.SetWindowLongA(hwnd, GWL_STYLE, bit.bor(style, WS_OVERLAPPEDWINDOW))
    ffi.C.SetWindowPos(hwnd, HWND_TOP, 100, 100, 800, 600, SWP_FRAMECHANGED + SWP_SHOWWINDOW)
    ffi.C.ShowWindow(hwnd, SW_SHOWNORMAL)
    sampAddChatMessage("Игра переведена в оконный режим.", 0x00FF00)
end

-- Установить полноэкранный режим
local function setFullscreenMode(hwnd)
    ffi.C.SetWindowLongA(hwnd, GWL_STYLE, WS_POPUP)
    local w = ffi.C.GetSystemMetrics(SM_CXSCREEN)
    local h = ffi.C.GetSystemMetrics(SM_CYSCREEN)
    ffi.C.SetWindowPos(hwnd, HWND_TOP, 0, 0, w, h, SWP_FRAMECHANGED + SWP_SHOWWINDOW)
    ffi.C.ShowWindow(hwnd, SW_SHOWMAXIMIZED)
    sampAddChatMessage("Игра переведена в полноэкранный режим.", 0x00FF00)
end

-- Перенос окна на следующий монитор
local function moveToNextMonitor(hwnd)
    if #monitors == 0 then
        sampAddChatMessage("Мониторы не найдены!", 0xFF0000)
        return
    end

    local current = isOnSecondMonitor and 2 or 1
    local next = current % #monitors + 1
    local m = monitors[next]

    local x = m.rcMonitor.left
    local y = m.rcMonitor.top
    local w = m.rcMonitor.right - m.rcMonitor.left
    local h = m.rcMonitor.bottom - m.rcMonitor.top

    ffi.C.ShowWindow(hwnd, SW_SHOWNORMAL)
    ffi.C.SetWindowLongA(hwnd, GWL_STYLE, WS_POPUP)
    ffi.C.SetWindowPos(hwnd, HWND_TOP, x, y, w, h, SWP_FRAMECHANGED + SWP_SHOWWINDOW)
    ffi.C.ShowWindow(hwnd, SW_SHOWMAXIMIZED)

    isOnSecondMonitor = not isOnSecondMonitor
    sampAddChatMessage("Окно перенесено на следующий монитор.", 0x00FF00)
end

-- Основной поток
function main()
    repeat wait(100) until isSampAvailable()

    findMonitors()
    findGameWindow()

    gta_hwnd = user32.FindWindowA('Grand theft auto san andreas', nil)

    -- Команда /full
    sampRegisterChatCommand('full', function()
        if hwnd then setFullscreenMode(hwnd)
        else sampAddChatMessage("Окно игры не найдено!", 0xFF0000) end
    end)

    -- Команда /win (оконный)
    sampRegisterChatCommand('win', function()
        if hwnd then setWindowedMode(hwnd)
        else sampAddChatMessage("Окно игры не найдено!", 0xFF0000) end
    end)

    -- Команда /winq — перенос по мониторам
    sampRegisterChatCommand('winq', function()
        if hwnd then moveToNextMonitor(hwnd)
        else sampAddChatMessage("Окно игры не найдено!", 0xFF0000) end
    end)

    -- Команда /block — антиавторазворачивание
    sampRegisterChatCommand('block', function()
        block = not block
        sampAddChatMessage(
            (block and "{00FF00}Блокировка ON" or "{FF0000}Блокировка OFF"),
            -1
        )
    end)

    while true do
        wait(100)

        findGameWindow()

        -- Анти-авто-разворачивание
        if block and gta_hwnd and user32.GetForegroundWindow() ~= gta_hwnd and user32.IsIconic(gta_hwnd) == 0 then
            user32.ShowWindow(gta_hwnd, SW_MINIMIZE)
        end
    end
end
