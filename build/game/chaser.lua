Chaser = Sprite:extend()


function Chaser:new(x, y, speed, rotationSpeed, jumpingSpeed)
	self.x = x
	self.y = y
	self.r = 0
	self.speed = speed
	self.rotationSpeed = rotationSpeed
	self.jumpingSpeed = jumpingSpeed
	self.movingClockwise = true
	self.jumping = false
	self.teleporting = false
	self.reachedTeleportThreshold = false

	self.teleportOrigin = 0
	self.teleportDestination = 0

	--self.hitbox = HC.rectangle(self.x, self.y, self.width, self.height)
	self.hitbox = HC.polygon(8, 0, 9, 0, 9, 1, 10, 1, 10, 3, 13, 3, 13, 2, 15, 2, 15, 4, 14, 4, 14, 7, 16, 7, 16, 8, 17, 8, 17, 9, 16, 9, 16, 10, 14, 10, 14, 13, 15, 13, 15, 15, 13, 15, 13, 14, 10, 14, 10, 16, 9, 16, 9, 17, 8, 17, 8, 16, 7, 16, 7, 14, 4, 14, 4, 15, 2, 15, 2, 13, 3, 13, 3, 10, 1, 10, 1, 9, 0, 9, 0, 8, 1, 8, 1, 7, 3, 7, 3, 4, 2, 4, 2, 2, 4, 2, 4, 3, 7, 3, 7, 1, 8, 1)
	self.hitbox:moveTo(self.x, self.y)

	self.width = 18
	self.height = 18

	self.chaserBounds = {
	Rectangle(0, 0, screenWidth, self.height),
	Rectangle(0, screenHeight - self.height, screenWidth, self.height),
	Rectangle(0, 0, self.width, screenHeight),
	Rectangle(screenWidth - self.width, 0, self.width, screenHeight),
}
end

function Chaser:update(playerPosX, playerPosY, dt)
	self:moveAutomatically(dt)

	if not self.teleporting then self:holdWithinBounds(dt) end

	if not self.jumping then self:calculateAngleToPlayer(playerPosX, playerPosY)
	elseif self.jumping then self:jump(dt) end

	if self.teleporting then self:teleport(dt) end
end

function Chaser:moveAutomatically(dt)

	if self.movingClockwise then self.hitbox:rotate(-math.pi/self.rotationSpeed)
	elseif not self.movingClockwise then self.hitbox:rotate(math.pi/self.rotationSpeed)
	end

	if not self.jumping and not self.teleporting then

		if self:containedWithin(self.chaserBounds[1]) then

			if self.movingClockwise then self:moveRight(self.speed, dt)
			elseif not self.movingClockwise then self:moveLeft(self.speed, dt) end
		end

		if self:containedWithin(self.chaserBounds[2]) then

			if self.movingClockwise then self:moveLeft(self.speed, dt)
			elseif not self.movingClockwise then self:moveRight(self.speed, dt) end
		end

		if self:containedWithin(self.chaserBounds[3]) then

			if self.movingClockwise then self:moveUp(self.speed, dt)
			elseif not self.movingClockwise then self:moveDown(self.speed, dt) end
		end

		if self:containedWithin(self.chaserBounds[4]) then

			if self.movingClockwise then self:moveDown(self.speed, dt)
			elseif not self.movingClockwise then self:moveUp(self.speed, dt) end
		end
	end


	self.hitbox:moveTo(self.x, self.y)
end

function Chaser:jump(dt)
	self:moveRight(math.cos(self.angleToPlayer) * self.jumpingSpeed, dt)
	self:moveDown(math.sin(self.angleToPlayer) * self.jumpingSpeed, dt)
end

function Chaser:holdWithinBounds(dt) -- Makes sure that the chaser doesn't get stuck in the wall
	if self.x > screenWidth - self.width / 2 then self.x = screenWidth - self.width / 2

	    self:endJump()
	    if self.movingClockwise then self:moveDown(240, dt)
	    elseif not self.movingClockwise then self:moveUp(240, dt)
	    end

	end

	if self.x < self.width / 2 then self.x = self.width / 2

	    self:endJump()
	    if self.movingClockwise then self:moveUp(240, dt)
	    elseif not self.movingClockwise then self:moveDown(240, dt)
	    end

	end

	if self.y > screenHeight - self.height / 2 then self.y = screenHeight - self.height / 2

	    self:endJump()
	    if self.movingClockwise then self:moveLeft(240, dt)
	    elseif not self.movingClockwise then self:moveRight(240, dt)
	    end

	end

	if self.y < self.height / 2 then self.y = self.height / 2

	    self:endJump()
	    if self.movingClockwise then self:moveRight(240, dt)
	    elseif not self.movingClockwise then self:moveLeft(240, dt)
	    end

	end
end

function Chaser:endJump()
	if self.jumping then 
		self.jumping = false
		resetAfterAction()
	end
end

function Chaser:moveIntoWall(dt)

	if self:containedWithin(self.chaserBounds[1]) or self.y < self.height / 2 + 1 then
		self.teleportOrigin = 1
		self:moveUp(60, dt)
	elseif self:containedWithin(self.chaserBounds[2]) or self.y > screenHeight - self.height / 2 - 1 then
		self.teleportOrigin = 2
		self:moveDown(60, dt)
	elseif self:containedWithin(self.chaserBounds[3]) or self.x < self.width / 2 + 1 then
		self.teleportOrigin = 3
		self:moveLeft(60, dt)
	elseif self:containedWithin(self.chaserBounds[4]) or self.x > screenWidth - self.width / 2 - 1 then
		self.teleportOrigin = 4
		self:moveRight(60, dt)
	end

	if self.y <= -self.height / 2 or self.y >= screenHeight + self.height / 2 -- Check if the chaser has left the screen
	or self.x <= -self.width / 2 or self.x >= screenWidth + self.width then 
		self.reachedTeleportThreshold = true
		self:newRandPos()
	end
end

function Chaser:teleport(dt)
	if not self.reachedTeleportThreshold then self:moveIntoWall(dt) end
	if self.reachedTeleportThreshold and not nailboard.active and not rocket.active and not bomb.active then self:moveOutOfWall(dt) end

	for i=1,#self.chaserBounds do
		if self:containedWithin(self.chaserBounds[i]) then -- Check if the chaser is back within its bounds and the teleporting process, if that's the case
			self.teleporting = false
			self.reachedTeleportThreshold = false

			resetAfterAction()
		end
	end
end

function Chaser:newRandPos()
	self.teleportDestination = love.math.random(1, 4) -- Picks a random screen side that the chaser is going to teleport to

	if self.teleportOrigin == self.teleportDestination then self:newRandPos() end -- Makes sure that the chaser doesn't teleport to the wall it is currently on

	if self.teleportDestination == 1 then

		self.x = love.math.random(self.width / 2, screenWidth - self.width / 2)
		self.y = -self.height / 2

	elseif self.teleportDestination == 2 then

		self.x = love.math.random(self.width / 2, screenWidth - self.width / 2)
		self.y = screenHeight + self.height / 2

	elseif self.teleportDestination == 3 then
		
		self.x = -self.width / 2
		self.y = love.math.random(self.height / 2, screenHeight - self.height / 2)

	elseif self.teleportDestination == 4 then
		
		self.x = screenWidth + self.width / 2
		self.y = love.math.random(self.height / 2, screenHeight - self.height / 2)
	end
end

function Chaser:moveOutOfWall(dt)

	if self.y < self.height / 2 then -- Checks if the chaser has fully returned to the screen
		
		self:moveDown(60, dt)
		if self.y > self.height / 2 then self.y = self.height / 2 end -- Makes sure that the chaser doesn't get pushed beyond its bounds

	elseif self.y > screenHeight - self.height / 2 then 
		
		self:moveUp(60, dt)
		if self.y < screenHeight - self.height / 2 then self.y = screenHeight - self.height / 2 end

	elseif self.x < self.width / 2 then 
		
		self:moveRight(60, dt)
		if self.x > self.width / 2 then self.x = self.width / 2 end

	elseif self.x > screenWidth - self.width / 2 then 
		
		self:moveLeft(60, dt)
		if self.x < screenWidth - self.width / 2 then self.x = screenWidth - self.width / 2 end

	end

end