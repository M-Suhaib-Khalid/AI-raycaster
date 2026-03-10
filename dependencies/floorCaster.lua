
function drawFloorFast(texture, playerX, playerY, dirX, dirY, planeX, planeY)

    local w = screenWidth
    local h = screenHeight

    local texData = floorTexData
    local texW = texture:getWidth()
    local texH = texture:getHeight()

    local rayDirX0 = dirX - planeX
    local rayDirY0 = dirY - planeY
    local rayDirX1 = dirX + planeX
    local rayDirY1 = dirY + planeY
    for y = h/2 + 40, h-1 do

        local p = y - h/2
        if p == 0 then p = 1 end

        local posZ = 0.5 * h
        local rowDistance = posZ / p

        local stepX = rowDistance * (rayDirX1 - rayDirX0) / w
        local stepY = rowDistance * (rayDirY1 - rayDirY0) / w

        local floorX = playerX + rowDistance * rayDirX0
        local floorY = playerY + rowDistance * rayDirY0

        for x = 0, w-1, 2 do

            local cellX = floorX - floorX % 1
            local cellY = floorY - floorY % 1

            local tx = math.floor((floorX - cellX) * texW)
            local ty = math.floor((floorY - cellY) * texH)

            local r,g,b,a = texData:getPixel(tx, ty)

            floorBuffer:setPixel(x, y, r, g, b, a)

            if x+1 < w then
                floorBuffer:setPixel(x+1, y, r,g,b,a)
            end

            floorX = floorX + stepX * 2
            floorY = floorY + stepY * 2
        end
    end

    floorImage:replacePixels(floorBuffer)
    love.graphics.draw(floorImage, 0, 0)
end