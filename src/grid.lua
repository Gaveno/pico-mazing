-- Constants
GRID_WIDTH = 16
GRID_HEIGHT = 20
EXIT_X = GRID_WIDTH / 2
EXIT_Y = GRID_HEIGHT
CELL_SIZE = 8

-- Variables
grid = {} -- List of 'can build' booleans and unit ids

-- Initialize Grid
function init_grid()
    for x = 1, GRID_WIDTH do
        grid[x] = {}
        for y = 1, GRID_HEIGHT do
            grid[x][y] = {
                can_build = true,
                unit_id = nil
            }
        end
    end

    -- Set non-buildable areas (spawn and exit zones)
    for x = 1, GRID_WIDTH do
        for y = 1, 2 do
            grid[x][y].can_build = false
        end
    end
    local mid_start = flr(GRID_WIDTH / 2) - 1
    local mid_end = mid_start + 3
    for x = mid_start, mid_end do
        for y = GRID_HEIGHT - 1, GRID_HEIGHT do
            grid[x][y].can_build = false
        end
    end
end

function draw_grid()
    for x = 1, GRID_WIDTH do
        for y = 1, GRID_HEIGHT do
            local px = (x - 1) * CELL_SIZE
            local py = (y - 1) * CELL_SIZE
            local cell = grid[x][y]
            -- Draw the cell background
            -- 
            spr(3 + (x + y) % 3, px, py)
            -- Optionally, indicate buildable or non-buildable areas
            if not cell.can_build then
                spr(19, px, py)
            end
            -- if cell.unit_id ~= nil then
            --     rect(px + 2, py + 2, px + CELL_SIZE - 3, py + CELL_SIZE - 3, 6) -- Occupied cell
            -- end
        end
    end
end