local map = require("map")


-- player stuff
local player = {
    x = 1.5,
    y = 3,
    angle = 1.5,
    width = 0.5,
    height = 0.5,
}

function player:updateRect()
    self.rectX = self.x - self.width / 2
    self.rectY = self.y - self.height / 2
end

function player:collision(x,y,w,h)

    return self.rectX < x + w and
           x < self.rectX + self.width and
           self.rectY < y + h and
           y< self.rectY + self.height

end





-- collision detector

local function checkWallCollision()

    local tileX = math.floor(player.x)
    local tileY = math.floor(player.y)

    for y = tileY - 1, tileY + 1 do
        for x = tileX - 1, tileX + 1 do

            if map.grid[y+1] and map.grid[y+1][x+1] > 0 then

                local wallX = x
                local wallY = y

                if player:collision(wallX, wallY, 1, 1) then
                    return true
                end

            end
        end
    end

    return false
end


-- constants
local FOV = math.rad(60)
local numRays = 1200
local maxDepth = 20
local moveSpeed = 2
local rotSpeed = 2
local mouseSensitivity = 0.003




-- load function
function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.mouse.setRelativeMode(true)
    player:updateRect()
    love.window.setMode(1200,690)
    textures = {
    [1] = love.graphics.newImage("wall.png"),
    [2] = love.graphics.newImage("door.png")
    }
end




-- mouse movement
function love.mousemoved(x, y, dx, dy)
    player.angle = player.angle + dx * mouseSensitivity
end





-- update function
function love.update(dt)
    -- strafing variables
    local strafeX = math.cos(player.angle + math.pi/2)* dt
    local strafeY = math.sin(player.angle + math.pi/2)* dt
    
    -- tile location variables
    local tileX = math.floor(player.x / 1) + 1
    local tileY = math.floor(player.y / 1) + 1
    local tilePixelX = (tileX - 1) *1
    local tilePixelY = (tileY - 1) *1
    


    -- movement

    -- strafe left
    if love.keyboard.isDown("a") then
        -- pos updater
        player.x = player.x - strafeX
        player.y = player.y - strafeY
        player:updateRect()
        
        -- collison check
        if checkWallCollision() then
            player.x = player.x + strafeX
            player.y = player.y + strafeY
            player:updateRect()
        end
    
    end

    -- strafe right
    if love.keyboard.isDown("d") then
        -- pos update
        player.x = player.x + strafeX
        player:updateRect()

        if checkWallCollision() then
            player.x = player.x - strafeX
            player:updateRect()
        end

        player.y = player.y + strafeY
        player:updateRect()

        if checkWallCollision() then
            player.y = player.y - strafeY
            player:updateRect()
        end
    end

    local dx = math.cos(player.angle) * moveSpeed * dt
    local dy = math.sin(player.angle) * moveSpeed * dt

    if love.keyboard.isDown("w") then
        -- pos update
        local newX = player.x + dx
        local newY = player.y + dy
        player.y = newY
        player:updateRect()

        if checkWallCollision() then
            player.y = player.y - dy
            player:updateRect()
        end

        player.x = newX
        player:updateRect()

        if checkWallCollision() then 
            player.x = player.x - dx
            player:updateRect()
        end
    end

    if love.keyboard.isDown("s") then
        -- pos update
        local newX = player.x - dx
        local newY = player.y - dy

        player.y = newY
        player:updateRect()

        
        if checkWallCollision() then
            player.y = player.y + dy
            player:updateRect()
        end

        player.x = newX
        player:updateRect()

        if checkWallCollision() then 
            player.x = player.x + dx
            player:updateRect()
        end
    end

    player:updateRect()
end

function castRay(angle)

    local rayDirX = math.cos(angle)
    local rayDirY = math.sin(angle)

    -- current map square
    local mapX = math.floor(player.x)
    local mapY = math.floor(player.y)

    -- distance to next x/y side
    local deltaDistX = math.abs(1 / rayDirX)
    local deltaDistY = math.abs(1 / rayDirY)

    local stepX, stepY
    local sideDistX, sideDistY

    -- step direction and initial sideDist
    if rayDirX < 0 then
        stepX = -1
        sideDistX = (player.x - mapX) * deltaDistX
    else
        stepX = 1
        sideDistX = (mapX + 1 - player.x) * deltaDistX
    end

    if rayDirY < 0 then
        stepY = -1
        sideDistY = (player.y - mapY) * deltaDistY
    else
        stepY = 1
        sideDistY = (mapY + 1 - player.y) * deltaDistY
    end

    local hit = false
    local side
    local wallType = 1

    while not hit do

        if sideDistX < sideDistY then
            sideDistX = sideDistX + deltaDistX
            mapX = mapX + stepX
            side = 0
        else
            sideDistY = sideDistY + deltaDistY
            mapY = mapY + stepY
            side = 1
        end

        local tile = map.grid[mapY+1] and map.grid[mapY+1][mapX+1]

        if tile and tile > 0 then
            hit = true
            wallType = tile
        end

    end

    local perpWallDist

    if side == 0 then
        perpWallDist = (mapX - player.x + (1 - stepX) / 2) / rayDirX
    else
        perpWallDist = (mapY - player.y + (1 - stepY) / 2) / rayDirY
    end

    local wallX

    if side == 0 then
        wallX = player.y + perpWallDist * rayDirY
    else
        wallX = player.x + perpWallDist * rayDirX
    end

    wallX = wallX - math.floor(wallX)

    return perpWallDist, side, wallX, wallType
end

function love.draw()

    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()

    
    for i = 1, numRays do
        
        local rayAngle = player.angle - FOV/2 + (i-1)/numRays * FOV

        local dist, side, wallX, wallType= castRay(rayAngle)
        
        dist = dist * math.cos(rayAngle - player.angle)
        
        local wallHeight = height / dist
        local columnwidth = width / numRays
        local x = (i-1) * columnwidth
        
        local tex = textures[wallType]
        local texWidth = tex:getWidth()
        local texHeight = tex:getHeight()
        local texX = math.floor(wallX * texWidth)
        
        local quad = love.graphics.newQuad(
            texX,
            0,
            1,
            texHeight,
            texWidth,
            texHeight
        )

        love.graphics.draw(
            tex,
            quad,
            x,
            height/2 - wallHeight/2,
            0,
            1,
            wallHeight / texHeight
        )

    end

end

function love.keypressed(key)
    if key == "escape" then
        love.mouse.setRelativeMode(false)
        love.event.quit()
    end
end

