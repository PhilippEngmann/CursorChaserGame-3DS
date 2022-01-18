highScore = 0

function love.load()

	Object = require "classic"
	HC = require "HC"

	screenWidth = 400
	screenHeight = 240

	require "rectangle"
	screen = Rectangle(0, 0, screenWidth, screenHeight)

	require "sprite"
	require "chaser"
	require "nailboard"
	require "rocket"
	require "bomb"
	chaser = Chaser(screenWidth / 2, 231, 350, 20, 1000)
	nailboard = Nailboard(16, 240, 480, 3)
	rocket = Rocket(25, 25, 250, 750)
	bomb = Bomb(8, 2, 190, 250, 50, 500)


	cursor = HC.polygon(0, 0, 0, 15, 7, 8, 14, 15, 15, 14, 8, 7, 15, 0) -- Player hitbox
	
	playerPosX = 100
	playerPosY = 100
	
	cursor:moveTo(playerPosX, playerPosX)

	score = 0
	playerAlive = true

	math.randomseed(os.time())
	actionRandomizer = math.random(1, 7)
	elapsedSeconds = 0
end

function love.update(dt)

	function love.gamepadpressed(joystick, button)
		love.event.quit()
	end

	function love.touchpressed( id, x, y, dx, dy, pressure )
        playerPosX = x * 1.25
        playerPosY = y
    end

    function love.touchmoved( id, x, y, dx, dy, pressure )
        playerPosX = x * 1.25
        playerPosY = y
    end

	cursor:moveTo(playerPosX, playerPosY)

	if playerAlive then

		elapsedSeconds = elapsedSeconds + dt

		if actionRandomizer ~= 0 then
			math.randomseed(os.time())
			actionRandomizer = math.random(2, 9)
		end


		chaser:update(playerPosX, playerPosY, dt)
		nailboard:update(dt)
		rocket:update(playerPosX, playerPosY, dt)
		bomb:update(dt)


		if cursor:collidesWith(chaser.hitbox) and chaser:intersects(screen) or
		cursor:collidesWith(nailboard.hitbox) and nailboard.active or
		cursor:collidesWith(rocket.hitbox) and rocket.active or
		cursor:collidesWith(bomb.hitbox) and bomb.active and bomb.opacity > 0.1 then 
			playerAlive = false
		end

		
		score = score + dt
		highScore = math.max(score, highScore)

--[[ 		function love.keypressed (key) -- Manual activation of attacks
			if key == 'c' then
				chaser.movingClockwise = not chaser.movingClockwise
			end
			if key == 'z' then
				chaser.jumping = not chaser.jumping
			end
			if key == 't' then
				chaser.teleporting = not chaser.teleporting
			end
			if key == 'n' then
				nailboard.active = not nailboard.active
				chaser.teleporting = true
				nailboard.x = nailboard:newRandPos()
			end
			if key == 'r' then
				rocket.active = not rocket.active
				chaser.teleporting = true
				rocket.x = rocket:newRandPos()
			end
			if key == 'b' then
				bomb.active = not bomb.active
				chaser.teleporting = true
				bomb.x = bomb:newRandPos()
			end
		end ]]

		if elapsedSeconds > 0.5 then -- Triggers random action every 0.5 seconds
			if actionRandomizer == 2 then

				actionRandomizer = 0
				chaser.movingClockwise = true
				resetAfterAction()

			elseif actionRandomizer == 3 or actionRandomizer == 4 or actionRandomizer == 5 then
				
				actionRandomizer = 0
				chaser.jumping = true

			elseif actionRandomizer == 6 then
				
				actionRandomizer = 0
				chaser.teleporting = true

			elseif actionRandomizer == 7 then
				
				actionRandomizer = 0
				nailboard.active = true
				chaser.teleporting = true
				nailboard.x = nailboard:newRandPos()

			elseif actionRandomizer == 8 then
				
				actionRandomizer = 0
				rocket.active = true
				chaser.teleporting = true
				rocket.x = rocket:newRandPos()

			elseif actionRandomizer == 9 then
				
				actionRandomizer = 0
				bomb.active = true
				chaser.teleporting = true
				bomb.x = bomb:newRandPos()
				
			end
		end

	elseif not playerAlive then
		function love.touchpressed( id, x, y, dx, dy, pressure )
			love.load() -- Restarts the game on touch
		end
	end
end

function love.draw(screen)
	if screen ~= "bottom" then
		love.graphics.setColor(1, 1, 1)
		cursor:draw("fill")
		if playerAlive then

			love.graphics.print("Score: " .. math.floor(score * 10))
			chaser.hitbox:draw("fill")
			rocket.hitbox:draw("fill")
			nailboard.hitbox:draw("fill")
			love.graphics.setColor(1, 1, 1, bomb.opacity)
			bomb.hitbox:draw("fill")

		elseif not playerAlive then

			love.graphics.printf("Score: " .. math.floor(score * 10), 0, screenHeight / 2 - 90, screenWidth, "center")
			love.graphics.printf("Highscore: " .. math.floor(highScore * 10), 0, screenHeight / 2 - 50, screenWidth, "center")
			love.graphics.printf("You died!", 0, screenHeight / 2 + 40, screenWidth, "center")
			love.graphics.printf("Touch to restart", 0, screenHeight / 2 + 80, screenWidth, "center")

		end
	end
end

function resetAfterAction()
	math.randomseed(os.time())
	actionRandomizer = math.random(2, 7)
	elapsedSeconds = 0
end