Sprite = Object.extend(Object)

function Sprite:new(image, x, y, speed, rotationSpeed)
	self.image = image
	self.x = x
	self.y = y
	self.speed = speed
	self.rotationSpeed = rotationSpeed

	self.width = image:getWidth()
	self.height = image:getHeight()

	self.r = 0
	self.ox = image:getWidth() / 2
	self.oy = image:getHeight() / 2
end

function Sprite:moveLeft(moveBy, dt)
	self.x = self.x - moveBy * dt
end

function Sprite:moveRight(moveBy, dt)
	self.x = self.x + moveBy * dt
end

function Sprite:moveUp(moveBy, dt)
	self.y = self.y - moveBy * dt
end

function Sprite:moveDown(moveBy, dt)
	self.y = self.y + moveBy * dt
end

function Sprite:rotate(rotateBy, dt)
	self.r = self.r + rotateBy * dt
end

function Sprite:calculateAngleToPlayer(playerPosX, playerPosY)
	self.angleToPlayer = math.atan2(playerPosY - self.y, playerPosX - self.x)
end

function Sprite:intersects(rect)
	local a_left = self.x - self.width / 2
	local a_right = a_left + self.width
	local a_top = self.y - self.height / 2
	local a_bottom = a_top + self.height

	local b_left = rect.x
	local b_right = rect.x + rect.width
	local b_top = rect.y
	local b_bottom = rect.y + rect.height

	return a_left < b_right and a_right > b_left and a_top < b_bottom and a_bottom > b_top
end

function Sprite:containedWithin(rect)
	local a_left = self.x - self.width / 2
	local a_right = a_left + self.width
	local a_top = self.y - self.height / 2
	local a_bottom = a_top + self.height

	local b_left = rect.x
	local b_right = rect.x + rect.width
	local b_top = rect.y
	local b_bottom = rect.y + rect.height

	return a_left >= b_left and a_right <= b_right and a_top >= b_top and a_bottom <= b_bottom
end

function Sprite:newRandPos()
    return math.random(self.width, screenWidth - self.width)
end

function Sprite:draw()
	love.graphics.draw(self.image, self.x, self.y, self.r, 1, 1, self.ox, self.oy)
end