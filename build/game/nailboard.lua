Nailboard = Sprite:extend()


function Nailboard:new(width, height, speed, rotationSpeed)
    self.width = width
    self.height = height
    self.speed = speed
    self.rotationSpeed = rotationSpeed

    self.x = 0
    self.y = screenHeight + self.height / 2

    self.active = false
    self.reachedHeight = false

    self.hitbox = HC.rectangle(self.x, self.y, self.width, self.height)
    self.hitbox:moveTo(self.x, self.y)
end

function Nailboard:update(dt)
    
    if self.active then

        if not self.reachedHeight then self.hitbox:moveTo(self.x, self.y) end -- Synchronize object and hitbox positions


        if self.y > screenHeight / 2 and chaser.reachedTeleportThreshold then self:moveUp(self.speed, dt) -- Pushes the nailboard to the top
        elseif self.y < screenHeight / 2 then -- Makes sure that the nailboard doesn't get pushed too far out of the screen
            self:holdWithinBounds(dt) 
            self.reachedHeight = true 
        end
        

        if self.y == screenHeight / 2 then -- Initializes the nailboard rotation
            -- Defines the rotation center and rotation direction depending on if the nailboard is on the left or right side of the screen
                self.oxL = self.x - self.width / 2
                self.oxR = self.x + self.width / 2
                self.oy = self.y + screenHeight / 2

                if self.x < screenWidth / 2 then
                    self.hitbox:rotate(self.rotationSpeed * dt, self.oxL, self.oy) -- Rotate right
                else
                    self.hitbox:rotate(-self.rotationSpeed * dt, self.oxR, self.oy) -- Rotate left
                end
            
            if math.deg(self.hitbox:rotation()) > 90 or math.deg(self.hitbox:rotation()) < -90 then -- Resets the nailboard, once it has left the screen
                self.active = false
                self.reachedHeight = false
                self.hitbox:setRotation(0)
                self.y = screenHeight + screenHeight / 2
                self.hitbox:moveTo(self.x, self.y)
                resetAfterAction()
            end

        end

    end
end

function Nailboard:holdWithinBounds(dt)
     -- In HC you cannot change the rotation center of a shape after you move it. That's why a new one has to be created before it starts to rotate.
    self.hitbox = HC.rectangle(self.x - self.width / 2, self.y - self.height / 2, self.width, self.height)
    self.y = screenHeight / 2
end