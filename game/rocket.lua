Rocket = Sprite:extend()

function Rocket:new(width, height, launchSpeed, chasingSpeed)
    self.width = width
    self.height = height
    self.launchSpeed = launchSpeed
    self.chasingSpeed = chasingSpeed

    self.x = 0
    self.y = screenHeight + self.height / 2 + 2

    self.active = false
    self.reachedHeight = false

    self.hitbox = HC.polygon(0, 24, 6, 18, 6, 6, 12, 0, 18, 6, 18, 18, 24, 24)
    self.hitbox:moveTo(self.x, self.y)

    self.elapsedSeconds = 0
end

function Rocket:update(playerPosX, playerPosY, dt)

    if self.active then
        self.hitbox:moveTo(self.x, self.y) -- Synchronize object and hitbox positions

        -- Pushes the rocket to 75 percent of screen height
        if not self.reachedHeight and chaser.reachedTeleportThreshold then self:moveUp(self.launchSpeed, dt) end
        if self.y < screenHeight * 0.25 then self.reachedHeight = true end

        if self.reachedHeight then
            self.elapsedSeconds = self.elapsedSeconds + dt

            -- Lets the rocket chase the player for two seconds

            if self.elapsedSeconds < 2 then
                self:calculateAngleToPlayer(playerPosX, playerPosY)
                self.hitbox:setRotation(self.angleToPlayer + math.rad(90))
            end

            self:moveRight(math.cos(self.angleToPlayer) * self.chasingSpeed, dt)
            self:moveDown(math.sin(self.angleToPlayer) * self.chasingSpeed, dt)

            if not self:intersects(screen) then -- Resets the rocket, once it has left the screen
                self.active = false
                self.reachedHeight = false
                self.hitbox:setRotation(0)
                self.x = 0
                self.y = screenHeight + self.height / 2 + 2
                self.hitbox:moveTo(self.x, self.y)
                self.elapsedSeconds = 0
                resetAfterAction()
            end
        end
    end
end