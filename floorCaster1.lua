local numRays = 5

for ray = 1, numRays do
    local rayX = 0
    local rayY = 0

    local stepX = ray        -- each ray moves farther in X
    local stepY = 1          -- all rays move upward

    while rayY < 10 do
        rayX = rayX + stepX
        rayY = rayY + stepY
        print("ray:", ray, rayX, rayY)
    end
end