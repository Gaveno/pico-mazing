-- Variables
units = {}
unit_path_delay = 0
next_unit_id = 0
chicken_deploy_y = 0
spawned_boss = nil

 
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

    if grid[spawn_x][spawn_y].unit_id == nil then

        local unit = {
            x = spawn_x,
            y = spawn_y,
            px = (spawn_x - 1) * CELL_SIZE,
            py = (spawn_y - 1) * CELL_SIZE,
            path_coroutine = nil,
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
            diamonds += lookup(unit.type, 'reward', 1)
            remove_unit(unit)
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

    -- Boss handling
    if unit == spawned_boss then
        spawned_boss = nil
    end
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
        lives -= lookup(unit.type, 'damage', 1)
        if lives <= 0 then
            game_state = 'defeat'
        end
    end
end

-- Function to move walking units with path finding
function move_walking_unit(unit, unit_path_delay)
    -- Start finding path
    if unit.path_coroutine == nil and unit.path == nil and unit_path_delay <= 0 then
        unit.path_coroutine = find_path_coroutine(
            unit.x, unit.y, EXIT_X, EXIT_Y, lookup(unit.type, 'path_iterations', 4)
        )
        unit_path_delay = 3
        unit.path_index = 1 -- Start at beginning of path once found
    end

    -- Keep processing path
    if unit.path_coroutine ~= nil and unit.path == nil then
        unit.path_coroutine, unit.path = process_path_coroutine(unit.path_coroutine)
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

-- Draw Boss Healthbar
function draw_boss_healthbar()
    if not spawned_boss then
        return -- No boss spawned
    end

    if not spawned_boss.health_max then
        return -- Boss healthbar not drawn
    end

    local pr = percent_range(spawned_boss.health, 0, spawned_boss.health_max)
    rectfill(0, HUD_HEIGHT, ceil(SCREEN_WIDTH * pr), HUD_HEIGHT + 4, 8)
end
