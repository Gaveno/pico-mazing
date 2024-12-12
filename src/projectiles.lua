-- Variables
projectiles = {}
explosions = {}

function create_projectile(tower, target_unit)
    local lifetime = 60
    if tower.type.attack_type == 'laser' then
        lifetime = 10
    else
        sfx(1, 0, 0, 4)
    end
    local projectile = {
        type = tower.type.attack_type,
        x = (tower.x - 1) * CELL_SIZE + lookup(tower, 'proj_launch_x', tower.type.proj_launch_x),
        y = (tower.y - 1) * CELL_SIZE + lookup(tower, 'proj_launch_y', tower.type.proj_launch_y),
        target = target_unit,
        speed = tower.type.projectile_speed,
        attack_power = tower.type.attack_power,
        splash = tower.type.splash,
        range = tower.type.attack_range,
        lifetime = 0,
        max_lifetime = lifetime,
        xto = 2 + flr(rnd(4)),
        yto = 2 + flr(rnd(4))
    }
    add(projectiles, projectile)
end

function update_projectiles()
    for i = #projectiles, 1, -1 do
        local proj = projectiles[i]
        proj.lifetime += 1

        if proj.type == 'pixel' or proj.type == 'bomb' then
            move_projectile(proj)
            -- check_projectile_collision(proj)
        elseif proj.type == 'laser' then
            -- 'laser' is instantaneous
            if proj.lifetime % 3 == 0 then
                apply_unit_damage(proj)
                sfx(2, 0, 0, 2)
            end
        end

        if proj.lifetime >= proj.max_lifetime then
            del(projectiles, proj)
        end
    end
end

function move_projectile(proj)
    local dx = proj.target.px - proj.x + proj.xto
    local dy = proj.target.py - proj.y + proj.yto
    local dist = sqrt(dx * dx + dy * dy)
    local speed = proj.speed

    if dist > speed then
        proj.x += dx / dist * speed
        proj.y += dy / dist * speed
    else
        proj.x = proj.target.px + proj.xto
        proj.y = proj.target.py + proj.yto
        projectile_collision(proj)
    end
end

function projectile_collision(proj)
    apply_unit_damage(proj)
    if proj.splash > 0 then
        create_explosion(proj.x, proj.y, proj.splash, proj.attack_power, proj.target)
    end
    del(projectiles, proj)
end

function apply_unit_damage(proj)
    local target_unit = proj.target
    local multiplier = 1
    if target_unit.type.strength == proj.type then
        multiplier = 0.75
    elseif target_unit.type.weakness == proj.type then
        multiplier = 1.5
    end

    target_unit.health -= proj.attack_power * multiplier
end

function create_explosion(x, y, radius_cells, attack_power, exclude)
    local so = 0
    if radius_cells == 1 then
        so = 1
    end
    sfx(3, 1, so+so, 3 - so)
    
    local explosion = {
        x = x,
        y = y,
        radius = radius_cells * CELL_SIZE,
        attack_power = attack_power,
        lifetime = 0,
        max_lifetime = 15,
        color = 10,
    }
    add(explosions, explosion)

    -- Apply damage to units within the explosion radius
    for unit in all(units) do
        if unit ~= exclude then
            local dx = (unit.px + CELL_SIZE / 2) - x
            local dy = (unit.py + CELL_SIZE / 2) - y
            local dist = sqrt(dx * dx + dy * dy)
            if dist <= explosion.radius then
                local damage = calculate_splash_damage(explosion.radius, dist, attack_power, radius_cells)
                apply_unit_damage({target = unit, type = 'bomb', attack_power = damage})
            end
        end
    end
end

function update_explosions()
    for i = #explosions, 1, -1 do
        local explosion = explosions[i]
        explosion.lifetime += 2
        explosion.color = 10 - flr(percent_range(explosion.lifetime, 0, explosion.max_lifetime) * 2.5)
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
    return damage
end

function draw_projectiles()
    for proj in all(projectiles) do
        local x = proj.x
        local y = proj.y
        if proj.type == 'pixel' then
            pset(x, y, 7)
        elseif proj.type == 'bomb' then
            local yimage = proj.splash - 1
            palt(0, false)
            palt(1, true)
            sspr(48 + (flr(proj.lifetime / 4) % 2) * 4, 8 + yimage * 4, 4, 4, x-1, y-1)
            palt()
        elseif proj.type == 'laser' then
            local ex = proj.target.px + proj.xto
            local ey = proj.target.py + proj.yto

            if proj.lifetime < proj.max_lifetime and proj.lifetime % 2 == 0 then
                line(x, y, ex, ey, 8)
                local r_base = 0

                if proj.range == 40 then
                    r_base = 1
                end

                circfill(ex, ey, 1 + r_base, 8)
                circfill(ex, ey, 0 + r_base, 7)
            end

            -- More powerful laser gets added effect
            if proj.range == 40 then
                local dx = ex - x
                local dy = ey - y
                local distance = sqrt(dx * dx + dy * dy)
                local line_angle = atan2(dx, dy)

                for i = 0, ceil(distance / 7), 1 do
                    local offset = i * (distance / 8) + proj.lifetime % 8
                    local ix = x + cos(line_angle) * offset
                    local iy = y + sin(line_angle) * offset
                    circfill(ix, iy, 1, 8)
                    pset(ix, iy, 7)
                end
            end
        end
    end
end

function draw_explosions()
    for explosion in all(explosions) do
        local radius = explosion.radius * (explosion.lifetime / explosion.max_lifetime)
        circ(
            explosion.x,
            explosion.y,
            radius,
            explosion.color
        )
    end
end