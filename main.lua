local map = require("dependencies/map")
player = require("dependencies/player")
require("dependencies/collisionChecker")
require("dependencies/raycaster")
require("dependencies/sceneRenderer")
require("dependencies/floorCaster")

-- constants
local FOV = math.rad(60)
local numRays = 600
local maxDepth = 20
local moveSpeed = 2
local rotSpeed = 2
local mouseSensitivity = 0.003

-- load function
function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.mouse.setRelativeMode(true)
    player:updateRect()
    love.window.setMode(1200,690,{vsync = 0})
    textures = {
    [1] = love.graphics.newImage("assets/wall.png"),
    [2] = love.graphics.newImage("assets/door.png")
    }

    floorTexture = love.graphics.newImage("assets/floor.png")
    floorTexData = love.image.newImageData("assets/floor.png")

    screenWidth = love.graphics.getWidth()
    screenHeight = love.graphics.getHeight()

    floorBuffer = love.image.newImageData(screenWidth, screenHeight)
    floorImage = love.graphics.newImage(floorBuffer)

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



function love.draw()

    local dirX = math.cos(player.angle)
local dirY = math.sin(player.angle)

local planeX = -dirY * math.tan(FOV / 2)
local planeY =  dirX * math.tan(FOV / 2)

    drawFloorFast(
        player.x,
        player.y,
        dirX,
        dirY,
        planeX,
        planeY
    )
    drawScene(numRays,FOV)
    love.graphics.print(
"FPS: "..love.timer.getFPS()..
"\nMemory: "..math.floor(collectgarbage("count")/1024).." MB",
10,10)
end

function love.keypressed(key)
    if key == "escape" then
        love.mouse.setRelativeMode(false)
        love.event.quit()
    end
end

