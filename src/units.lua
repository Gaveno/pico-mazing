-- Variables
units = {}
unit_path_delay = 0
next_unit_id = 0
spawned_boss = nil
check_invalid_nodes = false

-- Helper functions
function set_boss(unit)
    if (not spawned_boss) spawned_boss = unit
end

function get_flip(unit, d)
    return get_image(unit, d) == 0
end

function get_image(unit, d)
    return flr(unit.lifetime / d) % 2
end

function d_flr_m(v, d, m)
    return flr(v / d) * m
end

function unit_claim_cell(unit, x, y)
    grid[unit.x][unit.y].unit_id = nil
    unit.x = x
    unit.y = y
    -- Claim next cell
    grid[x][y].unit_id = unit.id
end

-- Main unit functions

function spawn_unit(unit_type, x, y)
    if exp_timer > 0 then
        return
    end

    local spawn_x = (x or ceil(rnd(GRID_WIDTH)))
    local spawn_y = (y or ceil(rnd(2)))

    if grid[spawn_x][spawn_y].unit_id == nil then
        local unit = {
            x = spawn_x,
            y = spawn_y,
            px = grid_to_room(spawn_x),
            py = grid_to_room(spawn_y),
            path_coroutine = nil,
            path = nil,
            path_index = 1,
            type = unit_type,
            health = unit_type.health(wave_number),
            lifetime = 0,
            id = next_unit_id,
            cooldown = 0,
            path_invalid_node = nil,
            dir = 0.75,
            tx = flr(rnd(3)),
            elite = wave_is_elite
        }
        unit.health += game_difficulty * unit.health * 0.25

        if unit.type.init then
            unit.type.init(unit)
        end

        if unit.type.movement_type == 'walk' then
            grid[spawn_x][spawn_y].unit_id = unit.id
        end

        next_unit_id += 1
        add(units, unit)

        return true -- Success
    end
    return false
    -- Failed to spawn
end

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
            if wave_is_elite then
                elites_killed += 1
            elseif unit.type.type == 'basic' then
                units_killed += 1
            elseif unit.type.type == 'boss' then
                bosses_killed += 1
            end

            diamonds += lookup(unit.type, 'reward', 1)
            sfx(4, 0, 0, 11)
            remove_unit(unit)
            return
        end

        if lookup(unit, 'movement_type', unit.type.movement_type) == 'fly' then
            move_flying_unit(unit)
        else
            if check_invalid_nodes then
                check_invalid_path(unit)
            end
            
            move_walking_unit(unit, unit_path_delay)
        end

        -- Custom unit update if it exists
        if unit.type.update then
            unit.type.update(unit)
        end

        -- Check if the unit has reached the exit
        if unit.py >= 144 and unit.px >= 48 and unit.px <= 72 then
            lives -= lookup(unit.type, 'damage', 1)
            create_explosion(unit.px + 4, unit.py + 4, 2, 0, nil)
            remove_unit(unit)

            if lives <= 0 then
                exp_timer = 60
                exp_x = 56
                exp_y = 144
            end
        end
    end

    -- Reset needing to check for invalid paths
    check_invalid_nodes = false
end

-- Function to move walking units with path finding
function move_walking_unit(unit, unit_path_delay)
    -- Start finding path
    if unit.path_coroutine == nil and (unit.path == nil or unit.path_invalid_node ~= nil) and unit_path_delay <= 0 then
        unit.path_coroutine = find_path_coroutine(
            EXIT_X + unit.tx + 1, EXIT_Y, unit.x, unit.y, lookup(unit.type, 'path_iterations', 14 - #units)
        )
        unit_path_delay = 40
        printh("starting to find path. index: "..unit.path_index)
    end

    -- Keep processing path
    if unit.path_coroutine ~= nil then
        printh("processing path")
        local new_path = nil
        unit.path_coroutine, new_path = process_path_coroutine(unit.path_coroutine)
        if new_path ~= nil then
            printh("found new path "..#new_path)
            unit.path_index = #new_path -- Start at beginning of path once found
            if unit.path ~= nil then
                unit.path_index = get_common_node(unit.x, unit.y, new_path)
                printh("after common node "..unit.path_index)
            end
            unit.path = new_path
            unit.path_invalid_node = nil
            check_invalid_path(unit)
        elseif unit.path_coroutine == nil then
            explode_tower(unit)
        end
    end

    move_unit_along_path(unit)
end

-- Function to move units along their paths
function move_unit_along_path(unit)
    if unit.path == nil or not wave_running then
        return
    end

    if unit.path_index == 1 or unit.path_invalid_node == unit.path_index then
        unit.path = nil
        return
    end

    local target_cell = unit.path[unit.path_index]
    if get_tower_at(target_cell.x, target_cell.y) ~= nil then
        -- Invalidate path if blocked
        unit.path = nil
        return
    end

    local target_px = grid_to_room(target_cell.x)
    local target_py = grid_to_room(target_cell.y)

    local dx = target_px - unit.px
    local dy = target_py - unit.py
    local dist = sqrt(dx * dx + dy * dy)
    local speed = unit.type.speed(unit, wave_number) / 15

    if dist < speed then
        unit.px = target_px
        unit.py = target_py
        local next_cell = unit.path[unit.path_index - 1]
        if next_cell and grid[next_cell.x][next_cell.y] and grid[next_cell.x][next_cell.y].unit_id == nil then
            -- Empty previous cell and update to next target
            unit_claim_cell(unit, next_cell.x, next_cell.y)
            -- Claim next cell
            unit.path_index -= 1
            printh("claiming path index "..unit.path_index)
        end
    else
        printh("moving by "..dx.." "..dist.." "..speed)
        unit.px += dx / dist * speed
        unit.py += dy / dist * speed
    end
end

function get_common_node(node_from_x, node_from_y, path_to)
    for i = #path_to, 1, -1 do
        if path_to[i].x == node_from_x and path_to[i].y == node_from_y then
            return i
        end
    end
    return #path_to
end

function explode_tower(unit)
    for i = 1, GRID_HEIGHT do
        if (explode_tower_at(unit.x - i, unit.y)) return
        if (explode_tower_at(unit.x + i, unit.y)) return
        if (explode_tower_at(unit.x, unit.y - i)) return
        if (explode_tower_at(unit.x, unit.y + i)) return
    end
end

function explode_tower_at(x, y)
    if get_tower_at(x, y) then
        tower_set(x, y, nil)
        create_explosion(x, y, 3, 0, nil)
        return true
    end
    return false
end

-- Check for path being invalid and recalculate if needed
function check_invalid_path(unit)
    if unit.path == nil then
        return
    end

    -- If already looking for a path, wipe out progess
    unit.path_coroutine = nil
    for i = unit.path_index - 1, 1, -1 do
        local node = unit.path[i]
        if get_tower_at(node.x, node.y) ~= nil then
            unit.path_invalid_node = i
            return
        else
            -- Check diagonals
            local prev_node = unit.path[i + 1]
            if prev_node.x ~= node.x and prev_node.y ~= node.y then
                -- Is a diagonal
                if get_tower_at(prev_node.x, node.y) ~= nil or get_tower_at(node.x, prev_node.y) ~= nil then
                    unit.path_invalid_node = i
                    return
                end
            end
        end
    end
end


function move_flying_unit(unit)
    if not wave_running then
        return
    end

    if unit.type.name == 'Carrier' or (unit.type.name == 'Bat' and t() % 2 == 0) then
        unit.dir = atan2(SCREEN_WIDTH / 2 - 16 + rnd(32) - unit.px, GRID_HEIGHT * CELL_SIZE - unit.py)
    end

    unit.py += sin(unit.dir) * unit.type.speed(unit, wave_number) / 15
    unit.px += cos(unit.dir) * unit.type.speed(unit, wave_number) / 15
end

-- Clean up unit
function remove_unit(unit)
    grid[unit.x][unit.y].unit_id = nil
    unit.health = 0
    del(units, unit)

    if #units <= 0 and wave_number <= 35 then
        wave_running = false
        sfx(9, 3)
        fmsc = 0
        prep_wave()
    end

    -- Boss handling
    if unit == spawned_boss then
        spawned_boss = nil
        exp_timer = 60 + d_flr_m(wave_number, 35, 90)
        exp_x = unit.px - 4
        exp_y = unit.py - 8
    end
end

-- Unit Drawing
function draw_units()
    if game_difficulty == 0 then
        for unit in all(units) do
            draw_unit_path(unit)
        end
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

function draw_unit_path(unit)
    if unit.path ~= nil then
        local c = 12
        if unit.path_coroutine ~= nil then
            c = 10
        end

        for i = 1, unit.path_index - 1, 1 do
            if unit.path[i + 1] ~= nil then
                line(
                    unit.path[i + 1].x * CELL_SIZE - 4, unit.path[i + 1].y * CELL_SIZE - 4,
                    unit.path[i].x * CELL_SIZE - 4, unit.path[i].y * CELL_SIZE - 4, c
                )
            end
        end
    end
end