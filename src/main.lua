-- Player class
Player = {}
Player.__index = Player

function Player:new(x, y, width, height, upKey, downKey)
    local obj = {
        x = x,
        y = y,
        width = width,
        height = height,
        speed = 300,
        upKey = upKey,
        downKey = downKey
    }
    setmetatable(obj, Player)
    return obj
end

function Player:move(dt)
    LastPositionY = self.y
    LastPositionX = self.x
    if love.keyboard.isDown(self.upKey) then
        self.y = self.y - self.speed * dt
    elseif love.keyboard.isDown(self.downKey) then
        self.y = self.y + self.speed * dt
    end

    if self.y < 0 then
        self.y = 0
    end
    if self.y + self.height > love.graphics.getHeight() then
        self.y = love.graphics.getHeight() - self.height
    end
end

-- Ball class
Ball = {}
Ball.__index = Ball

function Ball:new(x, y, radius)
    local obj = {
        x = x,
        y = y,
        radius = radius,
        speed = 400,
        vx = 0,
        vy = 0,
        waiting = false,
        waitTime = 0
    }
    setmetatable(obj, Ball)
    return obj
end

-- Initialize ball movement
function Ball:init()
    local angle = math.random() * math.pi / 4 - math.pi / 8 -- vertical angle -22.5° to 22.5°
    local dir = math.random(0,1) == 0 and -1 or 1           -- left or right
    self.vx = math.cos(angle) * self.speed * dir
    self.vy = math.sin(angle) * self.speed
    self.waiting = false
end

-- Move ball
function Ball:move(dt)
    if self.waiting then
        self.waitTime = self.waitTime - dt
        if self.waitTime <= 0 then
            self:init()
        else
            return
        end
    end

    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt
end

-- Handle collisions
function Ball:collisions()
    local w, h = love.graphics.getDimensions()

    -- Top/bottom
    if self.y - self.radius <= 0 then
        self.vy = math.abs(self.vy) * (0.8 + math.random()*0.4)
        self.y = self.radius
    elseif self.y + self.radius >= h then
        self.vy = -math.abs(self.vy) * (0.8 + math.random()*0.4)
        self.y = h - self.radius
    end

    -- Player 1 collision
    if self.x - self.radius <= player1.x + player1.width and
       self.y >= player1.y and self.y <= player1.y + player1.height then

        -- Calculate hit factor: -1 at top, 0 center, +1 bottom
        local hitPos = ((self.y - player1.y) / player1.height) * 2 - 1
        local angle = hitPos * math.pi/4  -- max 45° angle
        self.vx = math.abs(self.speed * math.cos(angle))
        self.vy = self.speed * math.sin(angle)

        -- add slight randomness
        self.vy = self.vy + (math.random() - 0.5) * 100
        self.speed = self.speed * 1.05  -- speed up slightly
        self.x = player1.x + player1.width + self.radius
    end

    -- Player 2 collision
    if self.x + self.radius >= player2.x and
       self.y >= player2.y and self.y <= player2.y + player2.height then

        local hitPos = ((self.y - player2.y) / player2.height) * 2 - 1
        local angle = hitPos * math.pi/4
        self.vx = -math.abs(self.speed * math.cos(angle))
        self.vy = self.speed * math.sin(angle)

        -- slight randomness
        self.vy = self.vy + (math.random() - 0.5) * 100
        self.speed = self.speed * 1.05
        self.x = player2.x - self.radius
    end
end


-- Reset ball
function Ball:reset()
    local w, h = love.graphics.getDimensions()
    self.x = w/2
    self.y = h/2
    self.vx, self.vy = 0, 0
    self.waiting = true
    self.waitTime = 1
    self.speed = 400
end

-- Score handling
function Ball:giveScore()
    local w, h = love.graphics.getDimensions()
    if self.x >= w then
        Player_1_score = Player_1_score + 1
        self:reset()
    elseif self.x <= 0 then
        Player_2_score = Player_2_score + 1
        self:reset()
    end
end

-- Game state
GameState = { PRE_LAUNCH = 1, PVP = 2, PVE = 3 }
GameState.current = GameState.PRE_LAUNCH

-- Scores
Player_1_score = 0
Player_2_score = 0

function displayScore()
    love.graphics.print("Player 1: "..Player_1_score, 50, 20)
    love.graphics.print("Player 2: "..Player_2_score, 700, 20)
end

-- LOVE2D load
function love.load()
    math.randomseed(os.time())
    love.window.setTitle("Pong")
    love.window.setMode(800, 600, {resizable=false, vsync=true})

    local w, h = love.graphics.getDimensions()
    local paddleWidth, paddleHeight = 30, 150

    player1 = Player:new(0, h/2 - paddleHeight/2, paddleWidth, paddleHeight, "w", "s")
    player2 = Player:new(w - paddleWidth, h/2 - paddleHeight/2, paddleWidth, paddleHeight, "up", "down")
    ball = Ball:new(w/2, h/2, 20)
    ball:init()
end

-- LOVE2D update
function love.update(dt)
    if GameState.current == GameState.PRE_LAUNCH then
        if love.keyboard.isDown("1") then
            GameState.current = GameState.PVP
        elseif love.keyboard.isDown("2") then
            GameState.current = GameState.PVE
        end
        return
    end

    player1:move(dt)
    player2:move(dt)
    ball:move(dt)
    ball:collisions()
    ball:giveScore()
end

function love.draw()
    if GameState.current == GameState.PRE_LAUNCH then
        love.graphics.print("Press 1 for PVP, 2 for PVE(NOT YET SUPPORTED)", 300, 280)
        return
    end

    love.graphics.setColor(1,1,1)
    love.graphics.rectangle("fill", player1.x, player1.y, player1.width, player1.height)
    love.graphics.rectangle("fill", player2.x, player2.y, player2.width, player2.height)
    love.graphics.circle("fill", ball.x, ball.y, ball.radius)
    displayScore()
end
