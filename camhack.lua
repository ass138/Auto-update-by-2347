script_name('CamHack.lua')
script_version("0.0.1")
script_authors('sanek a.k.a Maks_Fender, edited by ANIKI')
script_url('https://www.blast.hk/members/464512/')


function main()
	--sampAddChatMessage('шо?', 0xFFFFFF)
	flymode = 0  
	speed = 1.0
	radarHud = 0
	time = 0
	keyPressed = 0
	while true do
	--displayRadar(false)
		wait(0)
		time = time + 1
		if isKeyDown(VK_C) and isKeyDown(VK_1) then
			if flymode == 0 then
				--setPlayerControl(playerchar, false)
				displayRadar(false)
				displayHud(false)	    
				posX, posY, posZ = getCharCoordinates(playerPed)
				angZ = getCharHeading(playerPed)
				angZ = angZ * -1.0
				setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
				angY = 0.0
				--freezeCharPosition(playerPed, false)
				--setCharProofs(playerPed, 1, 1, 1, 1, 1)
				--setCharCollision(playerPed, false)
				lockPlayerControl(true)
				flymode = 1
			--	sampSendChat('/anim 35')
			end
		end
		if flymode == 1 and not sampIsChatInputActive() and not isSampfuncsConsoleActive() then
			offMouX, offMouY = getPcMouseMovement()  
			  
			offMouX = offMouX / 4.0
			offMouY = offMouY / 4.0
			angZ = angZ + offMouX
			angY = angY + offMouY

			if angZ > 360.0 then angZ = angZ - 360.0 end
			if angZ < 0.0 then angZ = angZ + 360.0 end

			if angY > 89.0 then angY = 89.0 end
			if angY < -89.0 then angY = -89.0 end   

			radZ = math.rad(angZ) 
			radY = math.rad(angY)             
			sinZ = math.sin(radZ)
			cosZ = math.cos(radZ)      
			sinY = math.sin(radY)
			cosY = math.cos(radY)       
			sinZ = sinZ * cosY      
			cosZ = cosZ * cosY 
			sinZ = sinZ * 1.0      
			cosZ = cosZ * 1.0     
			sinY = sinY * 1.0        
			poiX = posX
			poiY = posY
			poiZ = posZ      
			poiX = poiX + sinZ 
			poiY = poiY + cosZ 
			poiZ = poiZ + sinY      
			pointCameraAtPoint(poiX, poiY, poiZ, 2)

			curZ = angZ + 180.0
			curY = angY * -1.0      
			radZ = math.rad(curZ) 
			radY = math.rad(curY)                   
			sinZ = math.sin(radZ)
			cosZ = math.cos(radZ)      
			sinY = math.sin(radY)
			cosY = math.cos(radY)       
			sinZ = sinZ * cosY      
			cosZ = cosZ * cosY 
			sinZ = sinZ * 10.0     
			cosZ = cosZ * 10.0       
			sinY = sinY * 10.0                       
			posPlX = posX + sinZ 
			posPlY = posY + cosZ 
			posPlZ = posZ + sinY              
			angPlZ = angZ * -1.0
			--setCharHeading(playerPed, angPlZ)

			radZ = math.rad(angZ) 
			radY = math.rad(angY)             
			sinZ = math.sin(radZ)
			cosZ = math.cos(radZ)      
			sinY = math.sin(radY)
			cosY = math.cos(radY)       
			sinZ = sinZ * cosY      
			cosZ = cosZ * cosY 
			sinZ = sinZ * 1.0      
			cosZ = cosZ * 1.0     
			sinY = sinY * 1.0        
			poiX = posX
			poiY = posY
			poiZ = posZ      
			poiX = poiX + sinZ 
			poiY = poiY + cosZ 
			poiZ = poiZ + sinY      
			pointCameraAtPoint(poiX, poiY, poiZ, 2)

			if isKeyDown(VK_W) then      
				radZ = math.rad(angZ) 
				radY = math.rad(angY)                   
				sinZ = math.sin(radZ)
				cosZ = math.cos(radZ)      
				sinY = math.sin(radY)
				cosY = math.cos(radY)       
				sinZ = sinZ * cosY      
				cosZ = cosZ * cosY 
				sinZ = sinZ * speed      
				cosZ = cosZ * speed       
				sinY = sinY * speed  
				posX = posX + sinZ 
				posY = posY + cosZ 
				posZ = posZ + sinY      
				setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)      
			end 

			radZ = math.rad(angZ) 
			radY = math.rad(angY)             
			sinZ = math.sin(radZ)
			cosZ = math.cos(radZ)      
			sinY = math.sin(radY)
			cosY = math.cos(radY)       
			sinZ = sinZ * cosY      
			cosZ = cosZ * cosY 
			sinZ = sinZ * 1.0      
			cosZ = cosZ * 1.0     
			sinY = sinY * 1.0         
			poiX = posX
			poiY = posY
			poiZ = posZ      
			poiX = poiX + sinZ 
			poiY = poiY + cosZ 
			poiZ = poiZ + sinY      
			pointCameraAtPoint(poiX, poiY, poiZ, 2)

			if isKeyDown(VK_S) then  
				curZ = angZ + 180.0
				curY = angY * -1.0      
				radZ = math.rad(curZ) 
				radY = math.rad(curY)                   
				sinZ = math.sin(radZ)
				cosZ = math.cos(radZ)      
				sinY = math.sin(radY)
				cosY = math.cos(radY)       
				sinZ = sinZ * cosY      
				cosZ = cosZ * cosY 
				sinZ = sinZ * speed      
				cosZ = cosZ * speed       
				sinY = sinY * speed                       
				posX = posX + sinZ 
				posY = posY + cosZ 
				posZ = posZ + sinY      
				setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
			end 

			radZ = math.rad(angZ) 
			radY = math.rad(angY)             
			sinZ = math.sin(radZ)
			cosZ = math.cos(radZ)      
			sinY = math.sin(radY)
			cosY = math.cos(radY)       
			sinZ = sinZ * cosY      
			cosZ = cosZ * cosY 
			sinZ = sinZ * 1.0      
			cosZ = cosZ * 1.0     
			sinY = sinY * 1.0        
			poiX = posX
			poiY = posY
			poiZ = posZ      
			poiX = poiX + sinZ 
			poiY = poiY + cosZ 
			poiZ = poiZ + sinY      
			pointCameraAtPoint(poiX, poiY, poiZ, 2)
			  
			if isKeyDown(VK_A) then  
				curZ = angZ - 90.0
				radZ = math.rad(curZ)
				radY = math.rad(angY)
				sinZ = math.sin(radZ)
				cosZ = math.cos(radZ)
				sinZ = sinZ * speed
				cosZ = cosZ * speed
				posX = posX + sinZ
				posY = posY + cosZ
				setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
			end 

			radZ = math.rad(angZ) 
			radY = math.rad(angY)             
			sinZ = math.sin(radZ)
			cosZ = math.cos(radZ)      
			sinY = math.sin(radY)
			cosY = math.cos(radY)       
			sinZ = sinZ * cosY      
			cosZ = cosZ * cosY 
			sinZ = sinZ * 1.0      
			cosZ = cosZ * 1.0     
			sinY = sinY * 1.0        
			poiX = posX
			poiY = posY
			poiZ = posZ      
			poiX = poiX + sinZ 
			poiY = poiY + cosZ 
			poiZ = poiZ + sinY
			pointCameraAtPoint(poiX, poiY, poiZ, 2)       

			if isKeyDown(VK_D) then  
				curZ = angZ + 90.0
				radZ = math.rad(curZ)
				radY = math.rad(angY)
				sinZ = math.sin(radZ)
				cosZ = math.cos(radZ)       
				sinZ = sinZ * speed
				cosZ = cosZ * speed
				posX = posX + sinZ
				posY = posY + cosZ      
				setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
			end 

			radZ = math.rad(angZ) 
			radY = math.rad(angY)             
			sinZ = math.sin(radZ)
			cosZ = math.cos(radZ)      
			sinY = math.sin(radY)
			cosY = math.cos(radY)       
			sinZ = sinZ * cosY      
			cosZ = cosZ * cosY 
			sinZ = sinZ * 1.0      
			cosZ = cosZ * 1.0     
			sinY = sinY * 1.0        
			poiX = posX
			poiY = posY
			poiZ = posZ      
			poiX = poiX + sinZ 
			poiY = poiY + cosZ 
			poiZ = poiZ + sinY      
			pointCameraAtPoint(poiX, poiY, poiZ, 2)   

			if isKeyDown(VK_SPACE) then  
				posZ = posZ + speed
				setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
			end 

			radZ = math.rad(angZ) 
			radY = math.rad(angY)             
			sinZ = math.sin(radZ)
			cosZ = math.cos(radZ)      
			sinY = math.sin(radY)
			cosY = math.cos(radY)       
			sinZ = sinZ * cosY      
			cosZ = cosZ * cosY 
			sinZ = sinZ * 1.0      
			cosZ = cosZ * 1.0     
			sinY = sinY * 1.0       
			poiX = posX
			poiY = posY
			poiZ = posZ      
			poiX = poiX + sinZ 
			poiY = poiY + cosZ 
			poiZ = poiZ + sinY      
			pointCameraAtPoint(poiX, poiY, poiZ, 2) 

			if isKeyDown(VK_SHIFT) then  
				posZ = posZ - speed
				setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
			end 

			radZ = math.rad(angZ) 
			radY = math.rad(angY)             
			sinZ = math.sin(radZ)
			cosZ = math.cos(radZ)      
			sinY = math.sin(radY)
			cosY = math.cos(radY)       
			sinZ = sinZ * cosY      
			cosZ = cosZ * cosY 
			sinZ = sinZ * 1.0      
			cosZ = cosZ * 1.0     
			sinY = sinY * 1.0       
			poiX = posX
			poiY = posY
			poiZ = posZ      
			poiX = poiX + sinZ 
			poiY = poiY + cosZ 
			poiZ = poiZ + sinY      
			pointCameraAtPoint(poiX, poiY, poiZ, 2) 

			if keyPressed == 0 and isKeyDown(VK_F10) then
				keyPressed = 1
				if radarHud == 0 then
					displayRadar(true)
					displayHud(true)
					radarHud = 1
				else
					displayRadar(false)
					displayHud(false)
					radarHud = 0
				end
			end

			if wasKeyReleased(VK_F10) and keyPressed == 1 then keyPressed = 0 end

			if isKeyDown(187) then 
				speed = speed + 0.01
				printStringNow(speed, 1000)
			end 
			               
			if isKeyDown(189) then 
				speed = speed - 0.01 
				if speed < 0.01 then speed = 0.01 end
				printStringNow(speed, 1000)
			end   

			if isKeyDown(VK_C) and isKeyDown(VK_2) then
				--setPlayerControl(playerchar, true)
				displayRadar(true)
				displayHud(true)
				radarHud = 0	    
				angPlZ = angZ * -1.0
				--setCharHeading(playerPed, angPlZ)
				--freezeCharPosition(playerPed, false)
				lockPlayerControl(false)
				--setCharProofs(playerPed, 0, 0, 0, 0, 0)
				--setCharCollision(playerPed, true)
				restoreCameraJumpcut()
				setCameraBehindPlayer()
				flymode = 0     
			end
		end
	end
end

local sampev = require 'lib.samp.events'

function sampev.onPlayerChatBubble(id, col, dist, dur, msg)
	if flymode == 1 then
		return {id, col, 1488, dur, msg}
	end
end