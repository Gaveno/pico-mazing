-- Variables
projectiles = {}
explosions = {}

-- Create projectiles from tower
function create_projectile(tower, target_unit)
    local lifetime = 60
    if tower.type.attack_type == 2 then -- laser
        lifetime = 10
    end
    local projectile = {
        type = tower.type.attack_type,
        x = (tower.x - 1) * CELL_SIZE + CELL_SIZE / 2,
        y = (tower.y - 1) * CELL_SIZE + CELL_SIZE / 2,
        target = target_unit,
        speed = tower.type.projectile_speed,
        attack_power = tower.type.attack_power,
        splash = tower.type.splash,
        range = tower.type.attack_range,
        lifetime = 0,
        max_lifetime = lifetime -- Adjust as needed
    }
    add(projectiles, projectile)
end

-- Update projectiles (movement and collisions)
function update_projectiles()
    for i = #projectiles, 1, -1 do
        local proj = projectiles[i]
        proj.lifetime += 1

        if proj.type == 0 or proj.type == 1 then -- pixel shot or bomb
            move_projectile(proj)
            check_projectile_collision(proj)
        elseif proj.type == 2 then -- laser
            -- Laser is instantaneous
            if proj.lifetime % 3 == 0 then
                apply_laser_damage(proj)
            end
        end

        if proj.lifetime >= proj.max_lifetime then
            del(projectiles, proj)
        end
    end
end

-- Function to move projectiles
function move_projectile(proj)
    local dx = proj.target.px + CELL_SIZE / 2 - proj.x
    local dy = proj.target.py + CELL_SIZE / 2 - proj.y
    local dist = sqrt(dx * dx + dy * dy)
    local speed = proj.speed

    if dist > speed then
        proj.x += dx / dist * speed
        proj.y += dy / dist * speed
    else
        proj.x = proj.target.px + CELL_SIZE / 2
        proj.y = proj.target.py + CELL_SIZE / 2
    end
end

-- Function to check projectile collisions
function check_projectile_collision(proj)
    local dx = proj.target.px + CELL_SIZE / 2 - proj.x
    local dy = proj.target.py + CELL_SIZE / 2 - proj.y
    local dist = sqrt(dx * dx + dy * dy)

    if dist <= proj.speed then
        -- Collision occurred
        if proj.splash > 0 then
            create_explosion(proj.x, proj.y, proj.splash, proj.attack_power)
        else
            proj.target.health -= proj.attack_power
        end
        del(projectiles, proj)
    end
end

-- Function to apply laser damage
function apply_laser_damage(proj)
    local target_unit = proj.target
    target_unit.health -= proj.attack_power
    -- Optionally, apply effects or animations
end

-- Function to create an explosion and apply splash damage
function create_explosion(x, y, radius_cells, attack_power)
    local explosion = {
        x = x,
        y = y,
        radius = radius_cells * CELL_SIZE,
        attack_power = attack_power,
        lifetime = 0,
        max_lifetime = 15, -- Adjust duration as needed
        color = 9 -- Explosion color (red/orange)
    }
    add(explosions, explosion)

    -- Apply damage to units within the explosion radius
    for unit in all(units) do
        local dx = (unit.px + CELL_SIZE / 2) - x
        local dy = (unit.py + CELL_SIZE / 2) - y
        local dist = sqrt(dx * dx + dy * dy)
        if dist <= explosion.radius then
            local damage = calculate_splash_damage(explosion.radius, dist, attack_power, radius_cells)
            unit.health -= damage
        end
    end
end

function update_explosions()
    for i = #explosions, 1, -1 do
        local explosion = explosions[i]
        explosion.lifetime += 2
        if explosion.lifetime >= explosion.max_lifetime then
            del(explosions, explosion)
        end
    end
end

function calculate_splash_damage(max_radius, distance, attack_power, radius_cells)
    local damage = attack_power
    if radius_cells == 1 then
        damage = attack_power / 2
    elseif radius_cells == 3 then
        if distance <= CELL_SIZE then
            damage = attack_power / 2
        else
            damage = attack_power / 3
        end
    end
    -- Optionally, adjust damage based on distance
    -- For a gradual falloff:
    -- damage = attack_power * (1 - (distance / max_radius))
    -- Clamp damage to a minimum value if needed
    return damage
end

-- Drawing Projectiles
function draw_projectiles()
    for proj in all(projectiles) do
        local x = proj.x
        local y = proj.y
        if proj.type == 0 then
            -- printh("Drawing pixel shot at: ("..x..","..y..")")
            pset(x, y, 7) -- White pixel
        elseif proj.type == 1 then
            local scaler = proj.lifetime % proj.splash
            rectfill(x - 1 - scaler, y - 1 - scaler, x + 1 + scaler, y + 1 + scaler, 8) -- Red square bomb
        elseif proj.type == 2 then
            if proj.lifetime < proj.max_lifetime and proj.lifetime % 2 == 0 then
                -- Draw laser beam
                local sx = x
                local sy = y
                local ex = proj.target.px + CELL_SIZE / 2
                local ey = proj.target.py + CELL_SIZE / 2
                line(sx, sy, ex, ey, 8) -- Red color
            end
        end
    end
end

function draw_explosions()
    for explosion in all(explosions) do
        -- local alpha = 1 - (explosion.lifetime / explosion.max_lifetime)
        local radius = explosion.radius * (explosion.lifetime / explosion.max_lifetime)
        circ(
            explosion.x,
            explosion.y,
            radius,
            explosion.color
        )
        -- Optional: Add transparency or fade effect if desired
        -- Note: PICO-8 doesn't support true transparency, but you can simulate it using color palettes
    end
end