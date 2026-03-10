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