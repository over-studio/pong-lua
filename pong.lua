-- pong game v1.0

-- main game class 
local game = {
    gameOver = false,
    largeur = love.graphics.getWidth(),
    hauteur = love.graphics.getHeight(),
    nbreBriquesParLigne = 15,
    nbreBriquesParColonne = 6,
}

-- Pad object
local pad = {
    x = 0,          -- position horizontale du Pad
    y = 0,          -- position verticale du Pad
    largeur = 80,   -- largeur du Pad
    hauteur = 20    -- hauteur du Pad
}

-- ball object
local balle = {
    x = 0,          -- position de la balle sur l'axe X
    y = 0,          -- position de la balle sur l'axe Y
    vx = 0,         -- vélocité sur l'axe X 
    vy = 0,         -- vélocité sur l'axe Y
    rayon = 10,     -- rayon de la balle
    coller = true   -- spécifie si la balle est collée au Pad ou non
}

local brique = {
    largeur = game.largeur / game.nbreBriquesParLigne,  -- largeur d'une brique
    hauteur = 25                                        -- hauteur d'une brique
}

local niveaux = {}

function initGame()
    game.gameOver = false
    balle.coller = true
    game.briquesRestantes = game.nbreBriquesParLigne * game.nbreBriquesParColonne
    initPad()
    initBalle()
    initNiveau()
end

-- init Pad
function initPad()
    pad.y = game.hauteur - pad.hauteur/2
end

-- init ball
function initBalle()
    balle.x = pad.x
    balle.y = pad.y - pad.hauteur/2 - balle.rayon
end

-- init level
function initNiveau()
    local l, c
    for l=1, game.nbreBriquesParColonne do
        niveaux[l] = {}
        for c=1, game.nbreBriquesParLigne do
            niveaux[l][c] = 1
        end
    end
end

-- move ball
function moveBalle(vx, vy)
    balle.x = balle.x + vx
    balle.y = balle.y + vy

    if balle.x > game.largeur then balle.x=game.largeur; balle.vx = 0-balle.vx end
    if balle.x < 0 then balle.x=0; balle.vx = 0-balle.vx end
    if balle.y < 0 then balle.y=0; balle.vy = 0-balle.vy end
    if balle.y > game.hauteur then balle.coller = true end
end

-- collision with Pad
function collisionWithPad()
    local posCollisionPad = pad.y - pad.hauteur/2 - balle.rayon
    if balle.y > posCollisionPad  and math.abs(pad.x-balle.x)<pad.largeur/2 then
        balle.vy = 0 - balle.vy
        balle.y = posCollisionPad
    end 
end

-- collision avec les riques
function collisionWithBriques()
    local c = math.floor(balle.x / brique.largeur) + 1
    local l = math.floor(balle.y / brique.hauteur) + 1

    if l >= 1 and l <= #niveaux and c >=1 and c <=game.nbreBriquesParLigne then 
        if niveaux[l][c] == 1 then
            balle.vy = 0 - balle.vy
            niveaux[l][c] = 0
            game.briquesRestantes = game.briquesRestantes - 1
        end
    end
end

-- dessiner lesbriques
function dessinerBriques()
    local px = 0
    local py = 0
    local l, c
    for l=1, game.nbreBriquesParColonne do
        px = 0
        for c=1, game.nbreBriquesParLigne do
            if niveaux[l][c] == 1 then
                love.graphics.rectangle("fill", px+1, py+1, brique.largeur-2, brique.hauteur-2)
            end
            px = px + brique.largeur
        end
        py = py + brique.hauteur
    end
end

function love.load()
    initGame()
    pad.x = (game.largeur - pad.largeur) / 2
end

-- update function
function love.update(dt)
    --pad.x = love.mouse.getX()
    if love.keyboard.isDown("left") then
        if pad.x > pad.largeur/2 then
            pad.x = pad.x - 20
        end
    end

    if love.keyboard.isDown("right") then
        if pad.x < game.largeur - pad.largeur/2 then
            pad.x = pad.x + 20
        end
    end

    if love.keyboard.isDown("up") then
        if balle.coller == true then
            balle.coller = false
            balle.vx = 500
            balle.vy = -500
        end
    end

    if game.gameOver then 
        initGame()
    else
        if balle.coller == true then
            initBalle()
        else
            moveBalle(balle.vx*dt, balle.vy*dt)
            collisionWithPad()
            collisionWithBriques()
        end
        
        if game.briquesRestantes == 0 then game.gameOver = true end
    end
end

function love.draw()
    -- dessiner les briques
    dessinerBriques()
    -- dessiner le PAD
    love.graphics.rectangle("fill", 
                            pad.x - pad.largeur/2, 
                            pad.y - pad.hauteur/2, 
                            pad.largeur, 
                            pad.hauteur)

    -- dessiner la balle
    love.graphics.circle("fill", 
                        balle.x, 
                        balle.y, 
                        balle.rayon)

    -- Console de Debug
    --[[
    local sDebug = "\n\n\n\n\n\n"
    sDebug = sDebug .. "balle.coller = " .. tostring(balle.coller) .. "\n"
    sDebug = sDebug .. "balle.y = " .. tostring(balle.y) .. "\n"
    sDebug = sDebug .. "hauteur = " .. tostring(game.hauteur) .. "\n"
    sDebug = sDebug .. "gameOver = " .. tostring(game.gameOver)
    love.graphics.print(sDebug)
    --]]
end

-- touche
function love.mousepressed(x, y, button)
    if balle.coller == true then
        balle.coller = false
        balle.vx = 500
        balle.vy = -500
    end
end

function love.keypressed(key)
    
end
