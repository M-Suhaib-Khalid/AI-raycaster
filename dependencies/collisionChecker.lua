function checkWallCollision()

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