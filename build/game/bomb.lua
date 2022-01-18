Bomb = Sprite:extend()

function Bomb:new(r, minRadius, maxRadius, launchSpeed, implosionSpeed, explosionSpeed)
    self.r = r
    self.minRadius = minRadius
    self.maxRadius = maxRadius
    self.launchSpeed = launchSpeed
    self.implosionSpeed = implosionSpeed
    self.explosionSpeed = explosionSpeed

    self.width = 2 * r
    self.x = 0
    self.y = screenHeight + self.r
    self.opacity = 1

    self.active = false
    self.reachedHeight = false

    self.hitbox = HC.circle(self.x, self.y, self.r)
    self.hitbox:moveTo(self.x, self.y)

    math.randomseed(os.time())
    self.maxHeight = math.random(25, 75) / 100 -- Generates random explosion point on the vertical axis

    self.elapsedSeconds = 0
end

function Bomb:update(dt)
    if self.active then
        self.hitbox:moveTo(self.x, self.y) -- Synchronize object and hitbox positions

        -- Pushes the bomb to random percentage of screen height
        if not self.reachedHeight and chaser.reachedTeleportThreshold then self:moveUp(self.launchSpeed, dt) end
        if self.y < screenHeight * self.maxHeight then self.reachedHeight = true end

        if self.reachedHeight then
            if self.r > self.minRadius and self.elapsedSeconds == 0 then -- Makes the bomb contract just before the explosion
                self.r = self.r - self.implosionSpeed * dt
                self.hitbox = HC.circle(self.x, self.y, self.r)
            elseif self.r <= self.minRadius then
                self.elapsedSeconds = self.elapsedSeconds + dt -- Counts the time since the bomb has reached its minimum size
            end

            if self.r < self.maxRadius and self.elapsedSeconds > 0.5 then -- Starts the explosion, once it has been stable for half a second
                self.r = self.r + self.explosionSpeed * dt
                self.hitbox = HC.circle(self.x, self.y, self.r)
            elseif self.r >= self.maxRadius then -- Makes the explosion fade out, once it has reached the maximum size
                self.opacity = self.opacity - 1 * dt
            end

            if self.opacity <= 0 then
                self.active = false
                self.reachedHeight = false
                self.r = 8
                self.x = 0
                self.y = screenHeight + self.r
                self.opacity = 1
                self.elapsedSeconds = 0
                self.hitbox = HC.circle(self.x, self.y, self.r)
                resetAfterAction()
            end
        end
    end
end