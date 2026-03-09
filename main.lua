local map = require("map")

local player = {
    x = 2,
    y = 14,
    angle = 0,
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

local function checkWallCollision()

    local tileX = math.floor(player.x)
    local tileY = math.floor(player.y)

    for y = tileY - 1, tileY + 1 do
        for x = tileX - 1, tileX + 1 do

            if map.grid[y+1] and map.grid[y+1][x+1] == 1 then

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

local FOV = math.rad(45)
local numRays = 512
local maxDepth = 20
local moveSpeed = 3
local rotSpeed = 2
local mouseSensitivity = 0.003

function love.load()
    love.mouse.setRelativeMode(true)
    player:updateRect()
end

function love.mousemoved(x, y, dx, dy)
    player.angle = player.angle + dx * mouseSensitivity
end

function love.update(dt)
    
    local strafeX = math.cos(player.angle + math.pi/2) * moveSpeed * dt
    local strafeY = math.sin(player.angle + math.pi/2) * moveSpeed * dt
    local tileX = math.floor(player.x / 1) + 1
    local tileY = math.floor(player.y / 1) + 1
    local tilePixelX = (tileX - 1) *1
    local tilePixelY = (tileY - 1) *1
    
    if love.keyboard.isDown("a") then
        player.x = player.x - strafeX
        player.y = player.y - strafeY
        player:updateRect()
        if checkWallCollision() then
            player.x = player.x + strafeX
            player.y = player.y + strafeY
            player:updateRect()
        end
    end

    if love.keyboard.isDown("d") then
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

        if map.grid[mapY+1] and map.grid[mapY+1][mapX+1] == 1 then
            hit = true
        end

    end

    local perpWallDist

    if side == 0 then
        perpWallDist = (mapX - player.x + (1 - stepX) / 2) / rayDirX
    else
        perpWallDist = (mapY - player.y + (1 - stepY) / 2) / rayDirY
    end

    return perpWallDist, side
end

function love.draw()

    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()

    for i = 1, numRays do

        local rayAngle = player.angle - FOV/2 + FOV * (i/numRays)

        local dist,side = castRay(rayAngle)

        dist = dist * math.cos(rayAngle - player.angle)

        local wallHeight = height / dist

        local x = (i/numRays) * width

        if side == 1 then
            love.graphics.setColor(0.9, 0.9, 0.9) -- horizontal wall
        else
            love.graphics.setColor(1, 1, 1) -- vertical wall
        end

        love.graphics.rectangle(
            "fill",
            x,
            height/2 - wallHeight/2,
            width/numRays + 1,
            wallHeight
        )


    end
    love.graphics.setColor(0.5, 0.5, 1) 
    love.graphics.rectangle("line",width/2-10,height/2-10,20,20)
    love.graphics.circle("line",width/2,height/2,5)
    local miniscale = 10
    for y = 1, #map.grid do
        for x = 1, #map.grid[y] do

            if map.grid[y][x] == 1 then
                love.graphics.setColor(1,1,1)
            else
                love.graphics.setColor(0.2,0.2,0.2)
            end

            love.graphics.rectangle(
                "fill",
                (x-1)*miniscale,
                (y-1)*miniscale,
                miniscale,
                miniscale
            )
        end
    end
    love.graphics.setColor(0.8,0.1,0.1)
    love.graphics.rectangle(
    "fill",
    player.rectX*miniscale,
    player.rectY*miniscale,
    player.width*miniscale,
    player.height*miniscale)
end

function love.keypressed(key)
    if key == "escape" then
        love.mouse.setRelativeMode(false)
        love.event.quit()
    end
end

