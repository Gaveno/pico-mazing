-- Variables
units = {}
unit_path_delay = 0
next_unit_id = 0
chicken_deploy_y = 0
spawned_boss = nil
check_invalid_nodes = false

 
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
            path_index = 1,
            type = unit_type,
            health = unit_type.health(wave_number),
            lifetime = 0,
            id = next_unit_id,
            ability_cooldown = 0,
            path_invalid_node = nil,
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
            check_invalid_path(unit)
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

    -- Reset needing to check for invalid paths
    check_invalid_nodes = false
end

-- Clean up unit
function remove_unit(unit)
    grid[unit.x][unit.y].unit_id = nil
    unit.health = 0
    del(units, unit)

    if #units <= 0 then
        wave_running = false
        prep_wave()
    end

    -- Boss handling
    if unit == spawned_boss then
        spawned_boss = nil
    end
end


-- Function to move units along their paths
function move_unit_along_path(unit)
    if unit.path == nil or not wave_running then
        return
    end

    if unit.path_index > #unit.path or unit.path_invalid_node == unit.path_index then
        unit.path = nil
        return
    end

    local target_cell = unit.path[unit.path_index]
    if target_cell.x ~= unit.x or target_cell.y ~= unit.y then
        grid[unit.x][unit.y].unit_id = nil
        unit.x = target_cell.x
        unit.y = target_cell.y
    end

    if get_tower_at(target_cell.x, target_cell.y) ~= nil then
        -- Invalidate path if blocked
        unit.path = nil
        return
    end

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
            grid[unit.x][unit.y].unit_id = nil
            unit.x = next_cell.x
            unit.y = next_cell.y
            -- Claim next cell
            grid[unit.x][unit.y].unit_id = unit.id
            unit.path_index += 1
        else
            printh("Waiting for grid cell to become available: ".."("..next_cell.x..","..next_cell.y..")")
        end
    else
        unit.px += dx / dist * speed
        unit.py += dy / dist * speed
    end
end

-- Check for path being invalid and recalculate if needed
function check_invalid_path(unit)
    if not unit.path or unit.path_invalid_node ~= nil or
    unit.path_coroutine ~= nil or not check_invalid_nodes then
        -- Already looking for new path or not needed
        return
    end

    -- If already looking for a path, wipe out progess
    printh("Nilling coroutine")
    unit.path_coroutine = nil

    printh("-- Checking a path --")
    for i = unit.path_index + 1, #unit.path, 1 do
        local node = unit.path[i]
        if get_tower_at(node.x, node.y) ~= nil then
            printh("Non-diagonal node invalid: " .. i)
            unit.path_invalid_node = i
            return
        else
            -- Check diagonals
            local prev_node = unit.path[i - 1]
            if prev_node.x ~= node.x and prev_node.y ~= node.y then
                -- Is a diagonal
                if get_tower_at(prev_node.x, node.y) ~= nil or get_tower_at(node.x, prev_node.y) ~= nil then
                    printh("Diagonal node invalid: " .. i)
                    unit.path_invalid_node = i
                    return
                end
            end
        end
    end
    printh("-- Path has not been invalidated --")
end

function get_common_node(node_from_x, node_from_y, path_to)

    for i = 1, #path_to, 1 do
        local tx = path_to[i].x
        local ty = path_to[i].y
        if node_from_x == tx and node_from_y == ty then
            return i
        end
    end
    return 3
end

-- Function to move flying units
function move_flying_unit(unit)
    if not wave_running then
        return
    end

    unit.py += unit.type.speed(unit, wave_number) / 15
    if unit.px < (GRID_WIDTH - 1) / 2 * CELL_SIZE then
        unit.px += unit.type.speed(unit, wave_number) / 15
    end

    if unit.px > (GRID_WIDTH + 1) / 2 * CELL_SIZE then
        unit.px -= unit.type.speed(unit, wave_number) / 15
    end

    if unit.py >= ((GRID_HEIGHT - 1) * CELL_SIZE) then
        remove_unit(unit)
        lives -= lookup(unit.type, 'damage', 1)
        if lives <= 0 then
            game_state = 'defeat'
        end
    end
end

-- Function to move walking units with path finding
function move_walking_unit(unit, unit_path_delay)
    -- Start finding path
    if unit.path_coroutine == nil and (unit.path == nil or unit.path_invalid_node ~= nil) and unit_path_delay <= 0 then
        printh("Getting new coroutine")
        unit.path_coroutine = find_path_coroutine(
            unit.x, unit.y, EXIT_X, EXIT_Y, lookup(unit.type, 'path_iterations', 4)
        )
        unit_path_delay = 20
    end

    -- Keep processing path
    if unit.path_coroutine ~= nil then
        local new_path = nil
        printh("Processing coroutine")
        unit.path_coroutine, new_path = process_path_coroutine(unit.path_coroutine)
        if new_path ~= nil then
            printh("Found path from coroutine")
            unit.path_index = 2 -- Start at beginning of path once found
            if unit.path ~= nil then
                -- grid[unit.x][unit.y].unit_id = nil
                unit.path_index = get_common_node(unit.x, unit.y, new_path)
            end

            unit.path = new_path
            unit.path_invalid_node = nil
        end
    end
    
    move_unit_along_path(unit)
end

-- Unit Drawing
function draw_units()
    if not wave_running then
        return
    end

    for unit in all(units) do
        local x = unit.px
        local y = unit.py
        unit.type.draw(unit, x, y)
    end
end

-- Draw Boss Healthbar
function draw_boss_healthbar()
    if not spawned_boss or not wave_running or not spawned_boss.health_max then
        return
    end

    local pr = percent_range(spawned_boss.health, 0, spawned_boss.health_max)
    rectfill(0, HUD_HEIGHT, ceil(SCREEN_WIDTH * pr), HUD_HEIGHT + 4, 8)
end
