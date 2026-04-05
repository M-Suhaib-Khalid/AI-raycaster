local player = {
    x = 1.5,
    y = 3,
    angle = 1.5,
    width = 0.5,
    height = 0.5,
    pitch = 0
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
 
return player