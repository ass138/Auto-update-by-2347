script_name('AutoShar.lua')
script_version("0.0.1")
script_authors('TG @Qwestonsz')
script_url('https://www.blast.hk/members/464512/')

-- by Cosmo with <3
local state = false

function onReceivePacket(id, bs)
	if id == 220 then
		raknetBitStreamIgnoreBits(bs, 8)
		local p_type = raknetBitStreamReadInt8(bs)
		if p_type == 17 then
			raknetBitStreamIgnoreBits(bs, 32)
			local len = raknetBitStreamReadInt16(bs)
			local enc = raknetBitStreamReadInt8(bs)

			local command = (enc ~= 0)
				and raknetBitStreamDecodeString(bs, len + enc)
				or raknetBitStreamReadString(bs, len)

			local event_name, event_data = string.match(command, "^window%.executeEvent%('(.-)', [`'](%b[])[`']%);$")
			if event_name == "event.setActiveView" then
				state = false
				local data = decodeJson(event_data)
				if type(data) == "table" then
					for _, veiw in ipairs(data) do
						if veiw == "Clicker" then
							state = true
							break
						end
					end
				end
			end
		end
	end
end

function main()
	while true do
		if state then
			local command = "clickMinigame"
			local bs = raknetNewBitStream()
			raknetBitStreamWriteInt8(bs, 220)
			raknetBitStreamWriteInt8(bs, 18)
			raknetBitStreamWriteInt16(bs, #command)
			raknetBitStreamWriteString(bs, command)
			raknetBitStreamWriteInt32(bs, 0)
			raknetSendBitStream(bs)
			raknetDeleteBitStream(bs)
		end
		wait(0)
	end
end
