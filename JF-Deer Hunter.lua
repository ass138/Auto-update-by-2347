script_author('JustFedot')
script_name('[JF] Deer Hunter')
script_version('1.1.0')

require("moonloader")
require ("sampfuncs")
local sampev = require("samp.events")
local ffi = require("ffi")
local memory = require("memory")
local f = require 'moonloader'.font_flag
local font = renderCreateFont('Arial', 9, f.BOLD + f.SHADOW)
local font2 = renderCreateFont('Arial', 15, f.BOLD + f.SHADOW)


local getBonePosition = ffi.cast("int (__thiscall*)(void*, float*, int, bool)", 0x5E4280)

do -- Xcfg Modified
    Xcfg = {
        _version    = 2.1,
        _author     = "Double Tap Inside",
        _modified   = "JustFedot",
        _email      = "double.tap.inside@gmail.com",
        _help = [[
            Module xcfg             = Xcfg()
            Создает и возвращает новый экземпляр модуля Xcfg.
    
            nil                     = xcfg.mkpath(Str filename)
            Создает необходимые директории для указанного пути файла.
    
            Table loaded / nil      = xcfg.load(Str filename, [Bool save = false])
            Загружает конфигурационный файл. Если 'save' установлено в true, автоматически сохраняет файл после загрузки.
    
            Bool result             = xcfg.save(Str filename, Table new)
            Сохраняет данные в конфигурационный файл.
    
            Bool result             = xcfg.insert(Str filename, (Value value or Int index), [Value value])
            Вставляет значение в конфигурационный файл. Если указан индекс, вставляет по индексу.
    
            Bool result             = xcfg.remove(Str filename, [Int index])
            Удаляет значение из конфигурационного файла. Если указан индекс, удаляет значение по индексу.
    
            Bool result             = xcfg.set(Str filename, (Int index or Str key), Value value)
            Устанавливает или обновляет значение в конфигурационном файле по ключу или индексу.
    
            Bool result             = xcfg.update(Table old, (Table new or StrFilename new), [Bool overwrite = true])
            Обновляет старую таблицу новыми значениями из другой таблицы или файла. 'overwrite' определяет, перезаписывать ли существующие значения.
    
            Bool result             = xcfg.write(Str filename, Str str)
            Пишет строку в файл, перезаписывая его содержимое.
    
            Bool result             = xcfg.append(Str filename, Str str)
            Добавляет строку в конец файла.
    
            Table                   = xcfg.setupImcfg(Table cfg)
            Создает и возвращает таблицу с элементами управления imgui на основе конфигурационной таблицы 'cfg'. Поддерживает различные типы данных, включая вложенные таблицы.
        ]]
    }
	function Xcfg.__init()
		local self = {}
		
		-- draw values
		local function draw_string(str)
			return string.format("%q", str)
		end
		
		local function is_var(key_or_index)
			if type(key_or_index) == "string" and key_or_index:match("^[_%a][_%a%d]*$") then
				return true
			
			else
				return false
			end
		end
		
		local function draw_table_key(key)
			if is_var(key) then
				return key
				
			else
				return "["..draw_key(key).."]"
			end
		end
		
		local function draw_table(tbl, tab)
			local tab = tab or ""
			local result = {}
			
			for key, value in pairs(tbl) do
				if type(value) == "string" then
					if type(key) == "number" and key <= #tbl then
						table.insert(result, draw_string(value))
						
					else
						table.insert(result, draw_table_key(key).." = "..draw_string(value))
					end
					
				elseif type(value) == "number" or type(value) == "boolean" then
					if type(key) == "number" and key <= #tbl then
						table.insert(result, tostring(value))
						
					else
						table.insert(result, draw_table_key(key).." = "..tostring(value))
					end
				
				elseif type(value) == "table" then
					if type(key) == "number" and key <= #tbl then
						table.insert(result, draw_table(value, tab.."\t"))
						
					else
						table.insert(result, draw_table_key(key).." = "..draw_table(value, tab.."\t"))
					end
					
				else
					if type(key) == "number" and key <= #tbl then
						table.insert(result, draw_string(tostring(value)))
						
					else
						table.insert(result, draw_table_key(key).." = "..draw_string(tostring(value)))
					end
				end
			end
			
			if #result == 0 and tab == "" then
				return ""
				
			elseif #result == 0 then
				return "{}"
			
			elseif tab == "" then
				return table.concat(result, ",\n")..",\n"
			
			else
				return "{\n"..tab..table.concat(result, ",\n"..tab)..",\n"..tab:sub(2).."}"
			end       
		end
		
		local function draw_value(value, tab)
			if type(value) == "string" then
				return draw_string(value)
			
			elseif type(value) == "number" or type(value) == "boolean" or type(value) == "nil" then
				return tostring(value)
			
			elseif type(value) == "table" then
				return draw_table(value, tab)
				
			else
				return draw_string(tostring(value))
			end
		end
		
		local function draw_key(key)
			if "string" == type(key) then
				return draw_string(key)
			
			elseif "number" == type(key) then
				return tostring(key)
			end
		end
		
		
		local function draw_config(tbl)
			local result = {}
		
			for key, value in pairs(tbl) do
				
				if type(key) == "number" then
					table.insert(result, "table.insert(tbl, "..draw_value(value, "\t")..")")
				
				elseif type(key) == "string" then			
					if is_var(key) then
						table.insert(result, "tbl."..draw_table_key(key).." = "..draw_value(value, "\t"))
					
					else
						table.insert(result, "tbl"..draw_table_key(key).." = "..draw_value(value, "\t"))
					end
				end
			end
			
			if #result == 0 then
				return ""
				
			else
				return table.concat(result, "\n").."\n"
			end
		end

		function self.load(filename, overwrite)
			assert(type(filename)=="string", ("bad argument #1 to 'load' (string expected, got %s)"):format(type(filename)))
			
			if overwrite == nil then
				overwrite = false
			end
			
			local file = io.open(filename, "r")
			
			if file then
				local text = file:read("*all")
				file:close()
				local lua_code = loadstring("local tbl = {}\n"..text.."\nreturn tbl")
				
				if lua_code then
					local result = lua_code()
					
					if type(result) == "table" then
						if overwrite then
							self.save(filename, result)
						end
						
						return result
					end
				end
			end
		end
		
		function self.save(filename, new)
			assert(type(filename)=="string", ("bad argument #1 to 'table_save' (string expected, got %s)"):format(type(filename)))
			assert(type(new)=="table", ("bad argument #2 to 'table_save' (table expected, got %s)"):format(type(new)))
		
			self.mkpath(filename)
			local file = io.open(filename, "w+")
			
			if file then
				local text = draw_config(new)
				file:write(text)
				file:close()
				
				return true
			else
				return false
			end
		end
		
		function self.insert(filename, value_or_index, value)
			assert(type(filename)=="string", ("bad argument #1 to 'insert' (string expected, got %s)"):format(type(filename)))
			
			if value then
				assert(type(value_or_index)=="number", ("bad argument #2 to 'insert' (number expected, got %s)"):format(type(value_or_index)))
			end
			
			local result
			
			if value then
				result = "table.insert(tbl, "..value_or_index..", "..draw_value(value, "\t")..")"
				
			else
				result = "table.insert(tbl, "..draw_value(value_or_index, "\t")..")"
			end
			
			self.mkpath(filename)
			local file = io.open(filename, "a+")
			
			if file then
				file:write(result.."\n")
				file:close()
				return true
				
			else
				return false
			end
		end
		
		function self.remove(filename, index)
			assert(type(filename)=="string", ("bad argument #1 to 'remove' (string expected, got %s)"):format(type(filename)))
			assert(type(index)=="number" or index == nil, ("bad argument #2 to 'remove' (number or nil expected, got %s)"):format(type(index)))
			local result
			
			if index then
				result = "table.remove(tbl, "..index..")"
				
			else
				result = "table.remove(tbl)"
			end
			
			self.mkpath(filename)
			local file = io.open(filename, "a+")
			
			if file then
				file:write(result.."\n")
				file:close()
				return true
				
			else
				return false
			end
		end
		
		function self.set(filename, key, value)
			assert(type(filename)=="string", ("bad argument #1 to 'set' (string expected, got %s)"):format(type(filename)))
			assert(type(key)=="number" or type(key)=="string", ("bad argument #2 to 'set' (number or string expected, got %s)"):format(type(key)))
			
			local result
					
			if is_var() then
				result = "tbl."..tostring(var).." = "..draw_value(value, "\t")
			
			else
				result = "tbl["..draw_key(key).."] = "..draw_value(value, "\t")
			end
			
			self.mkpath(filename)
			local file = io.open(filename, "a+")
			
			if file then
				file:write(result.."\n")
				file:close()
				return true
				
			else
				return false
			end
		end
		
		function self.mkpath(filename)
			assert(type(filename)=="string", ("bad argument #1 to 'mkpath' (string expected, got %s)"):format(type(filename)))
		
			local sep, pStr = package.config:sub(1, 1), ""
			local path = filename:match("(.+"..sep..").+$") or filename
			
			for dir in path:gmatch("[^" .. sep .. "]+") do
				pStr = pStr .. dir .. sep
				createDirectory(pStr)
			end
		end

		function self.update(old, new, overwrite)
			assert(type(old)=="table", ("bad argument #1 to 'update' (table expected, got %s)"):format(type(old)))
			assert(type(new)=="string" or type(new)=="table", ("bad argument #2 to 'update' (string or table expected, got %s)"):format(type(new)))
			
			if overwrite == nil then
				overwrite = true
			end
		
			if type(new) == "table" then
				if overwrite then
					for key, value in pairs(new) do
						old[key] = value
					end
					
				else
					for key, value in pairs(new) do
						if old[key] == nil then
							old[key] = value
						end
					end
				end
				
				return true
				
			elseif type(new) == "string" then
				local loaded = self.load(new)
				
				if loaded then
					if overwrite then
						for key, value in pairs(loaded) do
							old[key] = value
						end
						
					else
						for key, value in pairs(loaded) do
							if old[key] == nil then
								old[key] = value
							end
						end
					end
					
					return true
				end
			end
			
			return false
		end
		
		function self.append(filename, str)
			self.mkpath(filename)
			local file = io.open(filename, "a+")
			
			if file then
				file:write(str)
				file:close()
				return true
				
			else
				return false
			end
		end
		
		function self.write(filename, str)
			self.mkpath(filename)
			local file = io.open(filename, "w+")
			
			if file then
				file:write(str)
				file:close()
				return true
				
			else
				return false
			end
		end

        function self.setupImcfg(cfg)
            assert(type(cfg) == "table", ("bad argument #1 to 'setupImcfg' (table expected, got %s)"):format(type(cfg)))
            local function setupImcfgRecursive(cfg)
                local imcfg = {}
                for k, v in pairs(cfg) do
                    if type(v) == "table" then
                        imcfg[k] = setupImcfgRecursive(v)
                    elseif type(v) == "number" then
                        if v % 1 == 0 then
                            imcfg[k] = imgui.ImInt(v)
                        else
                            imcfg[k] = imgui.ImFloat(v)
                        end
                    elseif type(v) == "string" then
                        imcfg[k] = imgui.ImBuffer(256)
                        imcfg[k].v = u8(v)
                    elseif type(v) == "boolean" then
                        imcfg[k] = imgui.ImBool(v)
                    else
                        assert(false, ("Unsupported type for imcfg: %s"):format(type(v)))
                    end
                end
                return imcfg
            end
            return setupImcfgRecursive(cfg)
        end
		
		return self
	end
	setmetatable(Xcfg, {
	__call = function(self)
		return self.__init()
	end
})
end
local xcfg = Xcfg()

local filename = getWorkingDirectory()..'\\config\\'..thisScript().name..'\\config.cfg'


local cfg = {
    aim = false,
    nospread = false,
}
xcfg.update(cfg,filename)

function saveConfig()
    xcfg.save(filename,cfg)
end

function addChat(a)
    sampAddChatMessage('{ffa500}'..thisScript().name..'{ffffff}: '..a, -1)
end

local state = {
    render = false,
	nospread = false,
}

function main()
    repeat wait(0) until isSampAvailable()
    while not isSampLoaded() do wait(0) end
    addChat('Загружен. Команда: {ffc0cb}/dhunt{ffffff}.')
    addChat("Для включения Аима на оленей: {ffc0cb}/dhunt.aim{ffffff}.")
	addChat("Для включения Антиразброса: {ffc0cb}/dhunt.ns{ffffff}.")
    sampRegisterChatCommand('dhunt',function()
        state.render = not state.render
    end)
    sampRegisterChatCommand('dhunt.aim',function()
        cfg.aim = not cfg.aim
        addChat('Аим '..(cfg.aim and '{ffa500}включен.' or '{ffa500}отключен.'))
        saveConfig()
    end)
	sampRegisterChatCommand('dhunt.ns',function()
        cfg.nospread = not cfg.nospread
        addChat('NoSpread '..(cfg.nospread and '{ffa500}включен.' or '{ffa500}отключен.'))
        saveConfig()
    end)
    while true do wait(0)

        if state.render then

			if cfg.nospread and not state.nospread then
				state.nospread = true
				set_spread(0)
			elseif not cfg.nospread and state.nospread then
				state.nospread = false
				set_spread(100)
			end

            local colvo = 0


            local mX, mY, mZ = getCharCoordinates(playerPed)
            for k,v in ipairs(getAllChars()) do
                if select(2, sampGetPlayerIdByCharHandle(v)) == -1 and v ~= PLAYER_PED and getCharModel(v) == 3150 then
                    colvo = colvo + 1
                    local x,y,z = getCharCoordinates(v)
                    local x1, y1 = convert3DCoordsToScreen(x,y,z)
                    local x2, y2 = convert3DCoordsToScreen(mX, mY, mZ)
                    if isPointOnScreen(x,y,z,0) then
                        renderDrawLine(x2, y2, x1, y1, 2.0, 0xFF00FF00)
                        renderDrawPolygon(x1, y1, 10, 10, 10, 0, 0xFFFFFFFF)
						renderDrawPolygon(x2, y2, 10, 10, 10, 0, 0xFFFFFFFF)
						renderFontDrawText(font, '{ffc0cb}Олень {ffa500}'..math.floor(getDistanceBetweenCoords3d(mX, mY, mZ, x, y, z)), x1, y1, 0xFFFFFFFF, 0x90000000)
                    end
                end
            end

            if cfg.aim then
                if memory.getint8(getCharPointer(PLAYER_PED) + 0x528, false) == 19 then
                    aimClosestDeer()
                end
            end

			local input = sampGetInputInfoPtr()
            local input = getStructElement(input, 0x8, 4)
            local PosX = getStructElement(input, 0x8, 4)
            if colvo > 0 then
				renderFontDrawText(font2, '[{ffa500}/dhunt'..(cfg.aim and '{99ff99}[A]' or '')..(cfg.nospread and '{ff0000}[N]' or '')..'{ffffff}]: Олени: {ffa500}'..colvo..'{ffffff} шт.', PosX, select(2, getScreenResolution())/2, 0xFFFFFFFF, 0x90000000)
            else
				renderFontDrawText(font2, '[{ffa500}/dhunt'..(cfg.aim and '{99ff99}[A]' or '')..(cfg.nospread and '{ff0000}[N]' or '')..'{ffffff}]: Оленей {ff0000}нет.', PosX, select(2, getScreenResolution())/2, 0xFFFFFFFF, 0x90000000)
            end

		else

			if state.nospread then
				state.nospread = false
                set_spread(100)
			end

        end

    end
end

function get_crosshair_position()
    local vec_out = ffi.new("float[3]")
    local tmp_vec = ffi.new("float[3]")
    ffi.cast(
        "void (__thiscall*)(void*, float, float, float, float, float*, float*)",
        0x514970
    )(
        ffi.cast("void*", 0xB6F028),
        15.0,
        tmp_vec[0], tmp_vec[1], tmp_vec[2],
        tmp_vec,
        vec_out
    )
    return vec_out[0], vec_out[1], vec_out[2]
end

local crossX, crossY = convert3DCoordsToScreen(get_crosshair_position())
function aimClosestDeer()

    local res = {}

    for k,v in ipairs(getAllChars()) do
        if select(2, sampGetPlayerIdByCharHandle(v)) == -1 and v ~= PLAYER_PED and getCharModel(v) == 3150 then
            local x, y = convert3DCoordsToScreen(getCharCoordinates(v))
            if res[1] == nil then
                local distance = getDistanceBetweenCoords2d(crossX, crossY, x, y)
                res = {v, distance}
            else
                local distance = getDistanceBetweenCoords2d(crossX, crossY, x, y)
                if tonumber(res[2]) > tonumber(distance) then
                    res = {v, distance}
                end
            end
        end
    end

    if res[1] and not isCharDead(res[1]) and isCharOnScreen(res[1]) then
        targetAtCoords(getBodyPartCoordinates(42,res[1]))
    end

end

function getBodyPartCoordinates(id, handle)
    local pedptr = getCharPointer(handle)
    local vec = ffi.new("float[3]")
    getBonePosition(ffi.cast("void*", pedptr), vec, id, true)
    return vec[0], vec[1], vec[2]
end

function targetAtCoords(x, y, z)
    local cx, cy, cz = getActiveCameraCoordinates()

    local vect = {
        fX = cx - x,
        fY = cy - y,
        fZ = cz - z
    }

    local screenAspectRatio = representIntAsFloat(readMemory(0xC3EFA4, 4, false))
    local crosshairOffset = {
        representIntAsFloat(readMemory(0xB6EC10, 4, false)),
        representIntAsFloat(readMemory(0xB6EC14, 4, false))
    }

    local mult = math.tan(getCameraFov() * 0.5 * 0.017453292)
    fz = 3.14159265 - math.atan2(1.0, mult * ((0.5 - crosshairOffset[1]) * (2 / screenAspectRatio)))
    fx = 3.14159265 - math.atan2(1.0, mult * 2 * (crosshairOffset[2] - 0.5))

    local camMode = readMemory(0xB6F1A8, 1, false)

    if not (camMode == 53 or camMode == 55) then -- sniper rifle etc.
        fx = math.pi / 2
        fz = math.pi / 2
    end

    local ax = math.atan2(vect.fY, -vect.fX) - math.pi / 2
    local az = math.atan2(math.sqrt(vect.fX * vect.fX + vect.fY * vect.fY), vect.fZ)

    setCameraPositionUnfixed(az - fz, fx - ax)
end
function set_spread(spread)
    local actual_spread = (spread <= 0) and (0.1) or (spread)
    local spread_for_non_shotguns = (0.75 * (spread / 100))
    local spread_for_shotguns = (0.050000001 * (actual_spread / 100))
  
    memory.setfloat(0x8D6110, spread_for_non_shotguns, true)
    memory.setfloat(0x8D611C, spread_for_shotguns, true)
end

function get3DTextPos(search)
    local array = {}
    for i = 0, 2049 do
        if sampIs3dTextDefined(i) then
            local text, color, x, y, z, distance, ignoreWalls, playerId, vehicleId = sampGet3dTextInfoById(i)
            if text:find(search) then
                table.insert(array, {x,y,z})
            end
        end
    end
    return array
end

function cyrillic(text)
    local convtbl = {[230]=155,[231]=159,[247]=164,[234]=107,[250]=144,[251]=168,[254]=171,[253]=170,[255]=172,[224]=97,[240]=112,[241]=99,[226]=162,[228]=154,[225]=151,[227]=153,[248]=165,[243]=121,[184]=101,[235]=158,[238]=111,[245]=120,[233]=157,[242]=166,[239]=163,[244]=63,[237]=174,[229]=101,[246]=36,[236]=175,[232]=156,[249]=161,[252]=169,[215]=141,[202]=75,[204]=77,[220]=146,[221]=147,[222]=148,[192]=65,[193]=128,[209]=67,[194]=139,[195]=130,[197]=69,[206]=79,[213]=88,[168]=69,[223]=149,[207]=140,[203]=135,[201]=133,[199]=136,[196]=131,[208]=80,[200]=133,[198]=132,[210]=143,[211]=89,[216]=142,[212]=129,[214]=137,[205]=72,[217]=138,[218]=167,[219]=145}
    local result = {}
    for i = 1, #text do
        local c = text:byte(i)
        result[i] = string.char(convtbl[c] or c)
    end
    return table.concat(result)
end

function onScriptTerminate(script, quit)
    if script == thisScript() then
		if state.nospread then
			state.nospread = false
			set_spread(100)
		end
	end
end