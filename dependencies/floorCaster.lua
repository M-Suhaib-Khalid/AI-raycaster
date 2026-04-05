
-- function drawFloorFast(texture, playerX, playerY, dirX, dirY, planeX, planeY)

--     local w = screenWidth
--     local h = screenHeight

--     local texData = floorTexData
--     local texW = texture:getWidth()
--     local texH = texture:getHeight()

--     local rayDirX0 = dirX - planeX
--     local rayDirY0 = dirY - planeY
--     local rayDirX1 = dirX + planeX
--     local rayDirY1 = dirY + planeY
--     for y = h/2 + 30, h-1 do


--         local p = y - h/2
--         if p == 0 then p = 1 end

--         local posZ = 0.5 * h
--         local rowDistance = posZ / p

--         local stepX = rowDistance * (rayDirX1 - rayDirX0) / w
--         local stepY = rowDistance * (rayDirY1 - rayDirY0) / w

--         local floorX = playerX + rowDistance * rayDirX0
--         local floorY = playerY + rowDistance * rayDirY0

--     for x = 0, w-1, 2 do

--         local cellX = math.floor(floorX)
--         local cellY = math.floor(floorY)

--         local tx = math.floor((floorX - cellX) * texW)
--         local ty = math.floor((floorY - cellY) * texH)

--         local r,g,b,a = texData:getPixel(tx, ty)

--         floorBuffer:setPixel(x, y, r, g, b, a)

--         if x + 1 < w then
--             floorBuffer:setPixel(x + 1, y, r, g, b, a)
--         end

--         floorX = floorX + stepX * 2
--         floorY = floorY + stepY * 2
--     end
--     end

--     floorImage:replacePixels(floorBuffer)
--     love.graphics.draw(floorImage, 0, 0)
-- end

-- local ffi = require("ffi")

-- -- Pre-calculate some values to save time in the loop
-- local screenWidth = 1200
-- local screenHeight = 690
-- local floorImage = love.image.newImageData(screenWidth, screenHeight)
-- local floorTexture = love.graphics.newImage("assets/floor.png") -- Your texture
-- local texData = love.image.newImageData("assets/floor.png")
-- local texW, texH = texData:getDimensions()

-- -- Get a direct pointer to the memory of the image and texture
-- local pixPtr = ffi.cast("uint8_t*", floorImage:getPointer())
-- local texPtr = ffi.cast("uint8_t*", texData:getPointer())

-- function drawFloorFast(playerX, playerY, dirX, dirY, planeX, planeY)
--     local w, h = screenWidth, screenHeight
    
--     -- Pre-calculate plane vectors
--     local rayDirX0, rayDirY0 = dirX - planeX, dirY - planeY
--     local rayDirX1, rayDirY1 = dirX + planeX, dirY + planeY

--     -- Only render the bottom half (the floor)
--     for y = h / 2 + 1, h - 1 do
--         local p = y - h / 2
--         local posZ = 0.5 * h
--         local rowDistance = posZ / p

--         -- Pre-calculate steps
--         local stepX = rowDistance * (rayDirX1 - rayDirX0) / w
--         local stepY = rowDistance * (rayDirY1 - rayDirY0) / w

--         local floorX = playerX + rowDistance * rayDirX0
--         local floorY = playerY + rowDistance * rayDirY0

--         -- Row offset in the destination buffer (y * width * 4 bytes per pixel)
--         local rowOffset = y * w * 4

--         for x = 0, w - 1 do
--             -- Fast texture coordinate calculation (using bitwise or floor)
--             local tx = math.floor(floorX * texW) % texW
--             local ty = math.floor(floorY * texH) % texH

--             -- Calculate memory addresses for source and destination
--             local texIdx = (ty * texW + tx) * 4
--             local pixIdx = rowOffset + (x * 4)

--             -- Direct memory copy (R, G, B, A)
--             pixPtr[pixIdx]     = texPtr[texIdx]     -- Red
--             pixPtr[pixIdx + 1] = texPtr[texIdx + 1] -- Green
--             pixPtr[pixIdx + 2] = texPtr[texIdx + 2] -- Blue
--             pixPtr[pixIdx + 3] = 255                -- Alpha

--             floorX = floorX + stepX
--             floorY = floorY + stepY
--         end
--     end

--     -- Push the raw memory to the GPU in one go
--     local finalImage = love.graphics.newImage(floorImage)
--     love.graphics.draw(finalImage, 0, 0)
-- end
