-- Implementing A* Pathfinding

function find_path_coroutine(start_x, start_y, goal_x, goal_y)
    return cocreate(function()
        local open_list = {}
        local closed_list = {}
        local came_from = {}

        local start_node = {
            x = start_x,
            y = start_y,
            g = 0,
            h = heuristic(start_x, start_y, goal_x, goal_y),
            f = 0
        }
        start_node.f = start_node.g + start_node.h
        add(open_list, start_node)

        while #open_list > 0 do
            -- Find node in open_list with lowest f
            local current_node = open_list[1]
            for i, node in ipairs(open_list) do
                if node.f < current_node.f then
                    current_node = node
                end
            end

            del(open_list, current_node)
            add(closed_list, current_node)

            if current_node.x == goal_x and current_node.y == goal_y then
                -- Reconstruct path
                local path = {}
                local current = current_node
                while current do
                    add(path, {x = current.x, y = current.y}, 1)
                    current = came_from[current.x .. ',' .. current.y]
                end
                yield(path) -- Yield the path
                return
            end

            -- Get neighbors
            local neighbors = get_neighbors(current_node.x, current_node.y)
            for _, neighbor in ipairs(neighbors) do
                if not in_list(closed_list, neighbor.x, neighbor.y) then
                    local movement_cost = (neighbor.dx == 0 or neighbor.dy == 0) and 1 or 1.4142
                    local tentative_g = current_node.g + movement_cost
                    local neighbor_in_open = in_open_list(open_list, neighbor.x, neighbor.y)
                    if not neighbor_in_open or tentative_g < neighbor_in_open.g then
                        came_from[neighbor.x .. ',' .. neighbor.y] = current_node
                        neighbor.g = tentative_g
                        neighbor.h = heuristic(neighbor.x, neighbor.y, goal_x, goal_y)
                        neighbor.f = neighbor.g + neighbor.h
                        if not neighbor_in_open then
                            add(open_list, neighbor)
                        end
                    end
                end
            end

            yield() -- Yield control back to the main loop
        end

        -- No path found
        yield(nil)
    end)
end

-- Returns the path coroutine and the result
function process_path_coroutine(path_co)
    if not path_co then
        return nil, nil
    end

    local status, result = coresume(path_co)
    if not status then
        -- error handling
        printh("Pathfinding error")
        return nil, nil
    elseif result ~= nil then
        -- Coroutine yielded a result (the path)
        return nil, result
    elseif costatus(path_co) == "dead" then
        -- Coroutine finished without finding a path
        return nil, nil
    end

    return path_co, nil
end

function heuristic(x1, y1, x2, y2)
    local dx = abs(x1 - x2)
    local dy = abs(y1 - y2)
    local F = 1.0
    local D = 1.2--1.4142
    return F * (dx + dy) + (D - 2 * F) * min(dx, dy)
end

function get_neighbors(x, y)
    local neighbors = {}
    local directions = {
        {dx = -1, dy = -1}, -- up-left
        {dx =  0, dy = -1}, -- up
        {dx =  1, dy = -1}, -- up-right
        {dx = -1, dy =  0}, -- left
        {dx =  1, dy =  0}, -- right
        {dx = -1, dy =  1}, -- down-left
        {dx =  0, dy =  1}, -- down
        {dx =  1, dy =  1}, -- down-right
    }

    for _, dir in ipairs(directions) do
        local nx = x + dir.dx
        local ny = y + dir.dy

        -- Check if the new position is within grid boundaries
        if nx >= 1 and nx <= GRID_WIDTH and ny >= 1 and ny <= GRID_HEIGHT then
            local tower = get_tower_at(nx, ny)
            if tower == nil then
                local valid = true

                -- If moving diagonally, check for diagonal cuts
                if dir.dx ~= 0 and dir.dy ~= 0 then
                    -- Check if adjacent cells are blocked
                    local cell1 = get_tower_at(x + dir.dx, y)
                    local cell2 = get_tower_at(x, y + dir.dy)
                    if cell1 ~= nil or cell2 ~= nil then
                        -- One or both adjacent cells are blocked; cannot move diagonally
                        valid = false
                    end
                end

                -- Add the neighbor if movement is valid
                if valid then
                    add(neighbors, {x = nx, y = ny, dx = dir.dx, dy = dir.dy})
                end
            end
        end
    end

    return neighbors
end



function in_list(list, x, y)
    for _, node in ipairs(list) do
        if node.x == x and node.y == y then
            return true
        end
    end
    return false
end

function in_open_list(list, x, y)
    for _, node in ipairs(list) do
        if node.x == x and node.y == y then
            return node
        end
    end
    return nil
end

-- Draw paths for debugging
function draw_path(path_index, path)
    if path ~= nil then
        for i = path_index, #path do
            local node = path[i]
            local x = (node.x - 1) * CELL_SIZE + CELL_SIZE / 2
            local y = (node.y - 1) * CELL_SIZE + CELL_SIZE / 2
            circfill(x, y, 2, 12)
        end
    end
end

function draw_unit_paths()
    for unit in all(units) do
        draw_path(unit.path_index, unit.path)
    end
end
