-- Variables
units = {}
unit_path_delay = 0
next_unit_id = 0
chicken_deploy_y = 0

 -- Define the unit types list
unit_types_list = {}
unit_types_list['Circle'] = {
    name = 'Circle',
    type = 'basic',
    health = function(wave_number) return 6 * wave_number / 2 + flr(wave_number / 5) * 2 end,
    speed = function(unit, wave_number) return 5 + flr(wave_number / 5) * 2 end,
    movement_type = 'walk',
    draw = function(unit, x, y)
        -- Draw Walker
        palt(1, true)
        local flip = false
        if flr(unit.lifetime / 4) % 2 == 0 then
            flip = true
        end

        spr(20, x, y, 1, 1, flip, false)
        palt()
    end
}
unit_types_list['Square'] = {
    name = 'Square',
    type = 'basic',
    health = function(wave_number) return 8 * wave_number / 2 + flr(wave_number / 5) * 2 end,
    speed = function(unit, wave_number) return 4 + flr(wave_number / 5) * 2 end,
    movement_type = 'walk',
    draw = function(unit, x, y)
        -- Draw Knight Walker
        palt(1, true)
        local flip = false
        if flr(unit.lifetime / 6) % 2 == 0 then
            flip = true
        end

        spr(21, x, y, 1, 1, flip, false)
        palt()
    end
}
unit_types_list['Triangle'] = {
    name = 'Triangle',
    type = 'basic',
    health = function(wave_number) return 5 * wave_number / 2 + flr(wave_number / 5) * 2 end,
    speed = function(unit, wave_number) return 6 + flr(wave_number / 5) * 2 + flr(wave_number / 10) * 2 end,
    movement_type = 'walk',
    draw = function(unit, x, y)
        -- Draw Lizard
        local flip = false
        if flr(unit.lifetime / 10) % 2 == 0 then
            flip = true
        end

        spr(37 + flr(unit.lifetime / 3) % 2, x, y, 1, 1, flip, false)
    end
}
unit_types_list['Star'] = {
    name = 'Star',
    type = 'basic',
    health = function(wave_number) return 4 * wave_number / 2 + flr(wave_number / 5) * 2 end,
    speed = function(unit, wave_number) return 4 + flr(wave_number / 5) * 2 end,
    movement_type = 'fly',
    draw = function(unit, x, y)
        -- Draw bat
        palt(15, true)

        -- Flip sprite
        local flip = false
        if flr(unit.lifetime / 8) % 2 == 0 then
            flip = true
        end

        palt(0, false)
        spr(24 + flr(unit.lifetime / 3) % 2, x, y, 1, 1, flip, false)

        palt()
    end
}
unit_types_list['Chicken'] = {
    name = 'Chicken',
    type = 'elite',
    spawn_rate = 30,
    health = function(wave_number) return 4 * wave_number / 2 + flr(wave_number / 5) * 2 end,
    speed = function(unit, wave_number) return 5 + flr(wave_number / 5) * 2 end,
    movement_type = 'fly',
    init = function(unit)
        printh("Initializing chicken")
        if rnd(100) < 33 then unit.is_rooster = 1 else unit.is_rooster = 0 end
        if unit.is_rooster then
            unit.health = unit.health * 1.4
        end

        unit.fly_duration = 30 + flr(rnd(90))
        unit.flying = true
    end,
    draw = function(unit, x, y)
        if not unit.is_rooster then
            unit.is_rooster = 0
        end

        local image = 64
        if unit.flying then
            image = 80
        end

        local flip = false
        if flr(unit.lifetime / 10) % 2 == 0 then
            flip = true
        end

        spr(image + flr(unit.lifetime / 3) % 2 + unit.is_rooster * 2, x, y)
    end,
    update = function(unit, x, y)
        if unit.fly_duration > 0 and unit.px / CELL_SIZE < GRID_WIDTH / 2 then
            printh("chicken still flying")
            unit.py = chicken_deploy_y * CELL_SIZE
            unit.fly_duration -= 1
        else
            if unit.flying then
                local land_x = ceil((unit.px) / CELL_SIZE) + 1
                local land_y = ceil((unit.py) / CELL_SIZE)
                printh("chicken trying to land at: "..land_x..", "..land_y)

                if get_tower_at(land_x, land_y) == nil and grid[land_x][land_y].unit_id == nil then
                    printh("chicken landing")
                    unit.flying = false
                    unit.movement_type = 'walk'
                    unit.x = land_x
                    unit.y = land_y
                end
            end
        end

        -- TO-DO: How to land this sucker?

    end
}


-- Bosses
-- Carrier - Flies to exit and spawns drones on the way
unit_types_list['Carrier'] = {
    name = 'Carrier',
    type = 'boss',
    spawn_number = 1,
    damage = 6,
    health = function(wave_number) return 30 * wave_number / 2 + flr(wave_number / 5) * 20 end,
    speed = function(unit, wave_number)
        if unit.ability_cooldown < 30 then
            return 0
        end
        return 3
    end,
    movement_type = 'fly',
    spawn_time = 120, -- 4 seconds
    draw = function(unit, x, y)
        -- Draw Carrier next wave image
        if not unit.ability_cooldown then
            spr(26, x, y)
            return
        end

        -- Flip sprite
        local flip = false
        -- if flr(unit.lifetime / 16) % 2 == 0 then
        --     flip = true
        -- end

        if unit.ability_cooldown >= 30 then
            sspr(88 + (flr(unit.lifetime / 15) % 2) * 16, 0, 16, 16, x - 4, y - 8, 16, 16, flip)
        else
            -- Spawning animation
            sspr(88 + (flr((29 - unit.lifetime) / 15) % 2) * 16, 16, 16, 16, x - 4, y - 8, 16, 16, flip)
        end
        -- rect(x, y, x + 7, y + 7, 2)
    end,
    update = function(unit)
        unit.ability_cooldown = (unit.ability_cooldown - 1) % unit.type.spawn_time
        -- printh("Ability cooldown: "..unit.ability_cooldown)

        -- Check for ability to spawn
        local spawn_x = flr((unit.px + 12) / CELL_SIZE)
        local spawn_y = flr((unit.py + 16) / CELL_SIZE)
        if unit.ability_cooldown < 30 and get_tower_at(spawn_x, spawn_y) ~= nil then
            unit.ability_cooldown = 30
        end

        -- Single frame spawn
        if unit.ability_cooldown == 15 then
            spawn_unit(unit_types_list['Drone'], spawn_x, spawn_y)
        end
    end,
}
-- Carrier drone spawn
unit_types_list['Drone'] = {
    name = 'Drone',
    type = 'spawn',
    health = function(wave_number) return 1 * wave_number / 2 + flr(wave_number / 5) * 5 end,
    speed = function(unit, wave_number) return 8 + flr(wave_number / 5) * 2 end,
    movement_type = 'walk',
    draw = function(unit, x, y)
        -- Draw Drone
        spr(39 + flr(unit.lifetime / 3) % 2, x, y)
    end
}
 
 -- Update paths for existing units
 function update_unit_paths()
    for unit in all(units) do
        unit.path = nil
    end
end

-- Unit Initialization
function spawn_unit(unit_type, x, y)
    local spawn_x = (x or ceil(rnd(GRID_WIDTH)))
    local spawn_y = (y or ceil(rnd(2)))


    if unit_type.name == 'Chicken' then
        spawn_y = chicken_deploy_y
        spawn_x = 1
    end

    printh("unit type: "..unit_type.name.." spawn y: "..spawn_y.." spawn x: "..spawn_x)

    if grid[spawn_x][spawn_y].unit_id == nil then

        local unit = {
            x = spawn_x,
            y = spawn_y,
            px = (spawn_x - 1) * CELL_SIZE,
            py = (spawn_y - 1) * CELL_SIZE,
            path = nil, -- path,
            path_index = 2,
            type = unit_type,
            health = unit_type.health(wave_number),
            lifetime = 0,
            id = next_unit_id,
            ability_cooldown = 0,
        }

        -- Initialize if has init function
        if unit.type.init then
            unit.type.init(unit)
        end

        if unit.type.movement_type == 'walk' then
            grid[spawn_x][spawn_y].unit_id = unit.id
        end

        next_unit_id += 1
        add(units, unit)

        return true -- Success
    else
        return false -- Failed to spawn
    end
end

-- Update units (movement and removal)
function update_units()
    if unit_path_delay > 0 then
        unit_path_delay -= 1
    end

    for i = #units, 1, -1 do
        local unit = units[i]
        unit.lifetime += 1

        -- Check life and terminate early if a unit dies
        -- Should be fine because every unit doesn't have to update each frame
        if unit.health <= 0 then
            remove_unit(unit)
            diamonds += 1
            return
        end

        -- Move the unit according to it's movement_type
        if lookup(unit, 'movement_type', unit.type.movement_type) == 'fly' then
            move_flying_unit(unit)
        else
            move_walking_unit(unit, unit_path_delay)
        end

        -- Custom unit update if it exists
        if unit.type.update then
            unit.type.update(unit)
        end

        -- Check if the unit has reached the exit
        if unit.y >= GRID_HEIGHT and unit.x > GRID_WIDTH/2 - 1 and unit.x <= GRID_WIDTH/2 + 1 then
            -- if unit.type.damage then
            --     lives -= unit.type.damage
            -- else
            --     lives -= 1
            -- end
            lives -= lookup(unit.type, 'damage', 1)
            remove_unit(unit)

            if lives <= 0 then
                game_state = 'defeat'
            end
        end
    end
end

-- Clean up unit
function remove_unit(unit)
    grid[unit.x][unit.y].unit_id = nil
    unit.health = 0
    del(units, unit)
end


-- Function to move units along their paths
function move_unit_along_path(unit)
    if unit.path == nil then
        return
    end

    if unit.path_index > #unit.path then
        return
    end

    local target_cell = unit.path[unit.path_index]
    local target_px = (target_cell.x - 1) * CELL_SIZE
    local target_py = (target_cell.y - 1) * CELL_SIZE

    local dx = target_px - unit.px
    local dy = target_py - unit.py
    local dist = sqrt(dx * dx + dy * dy)
    local speed = unit.type.speed(unit, wave_number) / 15

    if dist < speed then
        unit.px = target_px
        unit.py = target_py
        local next_cell = unit.path[unit.path_index + 1]
        if grid[next_cell.x][next_cell.y].unit_id == nil then
            -- Empty previous cell and update to next target
            -- printh("unit "..unit.id.." arrived at ("..target_cell.x..","..target_cell.y.."), moving to ("..next_cell.x..","..next_cell.y..")")
            grid[target_cell.x][target_cell.y].unit_id = nil
            unit.x = next_cell.x
            unit.y = next_cell.y
            -- Claim next cell
            grid[next_cell.x][next_cell.y].unit_id = unit.id
            unit.path_index += 1
        end
    else
        unit.px += dx / dist * speed
        unit.py += dy / dist * speed
    end
end

-- Function to move flying units
function move_flying_unit(unit)
    unit.py += unit.type.speed(unit, wave_number) / 15
    if unit.px < (GRID_WIDTH - 1) / 2 * CELL_SIZE then
        unit.px += unit.type.speed(unit, wave_number) / 15
    end

    if unit.px > (GRID_WIDTH + 1) / 2 * CELL_SIZE then
        unit.px -= unit.type.speed(unit, wave_number) / 15
    end

    if unit.py >= ((GRID_HEIGHT - 1) * CELL_SIZE) then
        del(units, unit)
        lives -= 1
        if lives <= 0 then
            game_state = 'defeat'
        end
    end
end

-- Function to move walking units with path finding
function move_walking_unit(unit, unit_path_delay)
    if unit.path == nil and unit_path_delay <= 0 then
        local unit_path = find_path(unit.x, unit.y, EXIT_X, EXIT_Y)
        if unit_path then
            unit.path = unit_path
            unit.path_index = 1
            unit_path_delay = 10
        end
    end
    
    move_unit_along_path(unit)
end

-- Unit Drawing
function draw_units()
    for unit in all(units) do
        local x = unit.px
        local y = unit.py
        unit.type.draw(unit, x, y)
    end
end