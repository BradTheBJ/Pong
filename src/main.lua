Player = {}
Player.__index = Player

function Player:new(x, y, width, height, upKey, downKey)
    local obj = {x = x, y = y, width = width, height = height, speed = 300, upKey = upKey, downKey = downKey}
    setmetatable(obj, Player)
    return obj
end

function Player:move(dt)
    if love.keyboard.isDown(self.upKey) then
        self.y = self.y - self.speed * dt
    elseif love.keyboard.isDown(self.downKey) then
        self.y = self.y + self.speed * dt
    end
end

function love.load()
    love.window.setTitle("Pong")
    love.window.setMode(800, 600, {resizable=false, vsync=true})

    local w, h = love.graphics.getDimensions()
    local paddleWidth, paddleHeight = 30, 150

    player1 = Player:new(0, h / 2 - paddleHeight / 2, paddleWidth, paddleHeight, "w", "s")
    player2 = Player:new(w - paddleWidth, h / 2 - paddleHeight / 2, paddleWidth, paddleHeight, "up", "down")
    players = {player1, player2}
end

function love.update(dt)
    for _, player in ipairs(players) do
        player:move(dt)
    end
end

function love.draw()
    love.graphics.setColor(1, 1, 1)
    for _, player in ipairs(players) do
        love.graphics.rectangle("fill", player.x, player.y, player.width, player.height)
    end
end
