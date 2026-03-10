function drawScene(numRays,FOV)
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