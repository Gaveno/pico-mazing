 function get_flip(unit, d)
    return get_image(unit, d) == 0
 end

 function get_image(unit, d)
    return flr(unit.lifetime / d) % 2
 end

 function d_flr_m(v, d, m)
    return flr(v / d) * m
 end
 
 -- Define the unit types list
 unit_types_list = {}
 unit_types_list['Walker'] = {
     name = 'Walker',
     type = 'basic',
     health = function(wave_number) return 3 * wave_number + d_flr_m(wave_number, 5, 2) end,
     speed = function(unit, wave_number) return 5 + d_flr_m(wave_number, 5, 2) end,
     movement_type = 'walk',
     weakness = nil,
     strength = nil,
     draw = function(unit, x, y)
         palt(1, true)
         spr(20, x, y, 1, 1, get_flip(unit, 4))
         palt()
     end
 }
 unit_types_list['Knight'] = {
    name = 'Knight',
    type = 'basic',
    health = function(wave_number) return 4 * wave_number + d_flr_m(wave_number, 5, 2) end,
    speed = function(unit, wave_number)
        local base = 4
        if unit.elite then
            base += 2
        end
        return base + d_flr_m(wave_number, 5, 2)
    end,
    movement_type = 'walk',
    weakness = 'laser',
    strength = 'bomb',
    draw = function(unit, x, y)
         palt(1, true) 
         if unit.elite then
            pal({[10]=11, [4]=12})
         end

         spr(21, x, y, 1, 1, get_flip(unit, 6))
         pal()
         palt()
     end
 }
 unit_types_list['Lizard'] = {
     name = 'Lizard',
     type = 'basic',
     health = function(wave_number)
        local base = 5
        if wave_is_elite then
            base += 2
        end
        return base * wave_number / 2 + d_flr_m(wave_number, 5, 2)
    end,
     speed = function(unit, wave_number) return 6 + d_flr_m(wave_number, 5, 2) + d_flr_m(wave_number, 10, 2) end,
     movement_type = 'walk',
     weakness = 'pixel',
     strength = 'laser',
     draw = function(unit, x, y)
         -- Draw elite version
         if unit.elite then
            pal({[11]=8, [3]=4, [8]=11})
         end
 
         spr(37 + get_image(unit, 3), x, y, 1, 1, get_flip(unit, 10))
         pal()
     end
 }
 unit_types_list['Bat'] = {
     name = 'Bat',
     type = 'basic',
     health = function(wave_number) return 2 * wave_number + d_flr_m(wave_number, 5, 2) end,
     speed = function(unit, wave_number)
        local base = 4
        if unit.elite then
            base += 2
        end

        return base + d_flr_m(wave_number, 5, 2)
    end,
     movement_type = 'fly',
     weakness = 'bomb',
     strength = 'pixel',
     draw = function(unit, x, y)
         palt(15, true)
         -- Draw elite version
         if unit.elite then
            pal({[0]=3, [7]=0})
         end
 
         palt(0, false)
         spr(24 + get_image(unit, 3), x, y, 1, 1, get_flip(unit, 8))
 
         palt()
         pal()
     end
 }
 unit_types_list['Chicken'] = {
     name = 'Chicken',
     type = 'elite',
     health = function(wave_number) return 2.5 * wave_number + d_flr_m(wave_number, 5, 2) end,
     speed = function(unit, wave_number) return 5 + d_flr_m(wave_number, 5, 2) end,
     movement_type = 'walk',
     weakness = 'pixel',
     strength = 'laser',
     path_iterations = 10,
     init = function(unit)
         if rnd(100) < 33 then
            unit.is_rooster = 2
            unit.health = unit.health * 1.4
        else
            unit.is_rooster = 0
        end
 
        unit.cooldown = 0
        unit.movement_type = unit.type.movement_type
        unit.dir = 0
     end,
     draw = function(unit, x, y)
         if not unit.is_rooster then
             unit.is_rooster = 0
         end
 
         local flip = false
         local image = 80
         if unit.movement_type == 'walk' then
             image = 64
         end

         if unit.dir == 0.5 or get_flip(unit, 10) and unit.movement_type == 'walk'  then
             flip = true
         end
 
         spr(image + get_image(unit, 3) + unit.is_rooster, x, y, 1, 1, flip)
     end,
     update = function(unit)
        if unit.cooldown > 0 then
            unit.cooldown -= 1
            return
        end

        local real_cell_x = ceil((unit.px + 4) / CELL_SIZE)
        local real_cell_y = ceil((unit.py + 4) / CELL_SIZE)

        if unit.movement_type == 'walk' then
            -- Walking, ready to jump
            -- Should have a path to follow
            local tx1 = real_cell_x + 2
            local tx2 = real_cell_x - 2
            
            if real_cell_x < GRID_WIDTH-2 and get_tower_at(tx1, real_cell_y) == nil
            and get_tower_at(real_cell_x + 1, real_cell_y) ~= nil and grid[tx1][real_cell_y].unit_id == nil then
                -- Jump it
                unit.cooldown = 10
                unit.movement_type = 'fly'
                grid[unit.x][unit.y].unit_id = nil
                grid[tx1][real_cell_y].unit_id = unit.id
            elseif real_cell_x > 2 and get_tower_at(tx2, real_cell_y) == nil
            and get_tower_at(real_cell_x - 1, real_cell_y) ~= nil and grid[tx2][real_cell_y].unit_id == nil then
                -- Jump it
                unit.cooldown = 10
                unit.movement_type = 'fly'
                grid[unit.x][unit.y].unit_id = nil
                grid[tx2][real_cell_y].unit_id = unit.id
                unit.dir = 0.5
            end
        else
            -- Flying over tower
            if grid[real_cell_x][real_cell_y].unit_id == unit.id then
                unit.movement_type = 'walk'
                unit.cooldown = 180
                unit.x = real_cell_x
                unit.y = real_cell_y
                unit.path = nil
                unit.dir = 0
            end
        end
    end
 }
 
 
 -- Bosses
 unit_types_list['Carrier'] = {
     name = 'Carrier',
     type = 'boss',
     spawn_number = 1,
     damage = 6,
     health = function(wave_number) return 15 * wave_number + d_flr_m(wave_number, 5, 20) end,
     reward = 6,
     speed = function(unit, wave_number)
         if unit.cooldown < 30 then
             return 0
         end
         return 3
     end,
     movement_type = 'fly',
     weakness = 'bomb',
     strength = 'pixel',
     spawn_time = 100,
     init = function(unit)
        unit.health_max = unit.health
        spawned_boss = unit
     end,
     draw = function(unit, x, y)
         -- Next wave image
         if not unit.cooldown then
             spr(26, x, y)
             return
         end
 
         if unit.cooldown >= 30 then
             sspr(88 + get_image(unit, 15) * 16, 0, 16, 16, x - 4, y - 8, 16, 16)
         else
             sspr(88 + (flr(1.933 - unit.lifetime / 15) % 2) * 16, 16, 16, 16, x - 4, y - 8, 16, 16)
         end
     end,
     update = function(unit)
        if not wave_running then
            return
        end
        
         unit.cooldown = (unit.cooldown - 1) % unit.type.spawn_time

         -- Check for ability to spawn
         local spawn_x = flr((unit.px + 12) / CELL_SIZE)
         local spawn_y = flr((unit.py + 16) / CELL_SIZE)
         if unit.cooldown < 30 and get_tower_at(spawn_x, spawn_y) ~= nil then
             unit.cooldown = 30
         end
 
         -- Single frame spawn
         if unit.cooldown == 15 then
             spawn_unit(unit_types_list['Drone'], spawn_x, spawn_y)
         end
     end,
 }
 -- Carrier drone spawn
 unit_types_list['Drone'] = {
     name = 'Drone',
     type = 'spawn',
     health = function(wave_number) return wave_number + d_flr_m(wave_number, 5, 5) end,
     reward = 0,
     speed = function(unit, wave_number) return 8 + d_flr_m(wave_number, 5, 2) end,
     movement_type = 'walk',
     weakness = nil,
     strength = nil,
     path_iterations = 10,
     draw = function(unit, x, y)
         spr(39 + get_image(unit, 3), x, y)
     end
 }
 
 -- BigBoy
 unit_types_list['BigBoy'] = {
     name = 'BigBoy',
     type = 'boss',
     spawn_number = 1,
     damage = 6,
     health = function(wave_number) return 27.5 * wave_number + d_flr_m(wave_number, 5, 70) end,
     reward = 8,
     speed = function(unit, wave_number)
         if unit.movement_type == 'fly' then
             if unit.cooldown > 25 then
                 return 0
             else 
                 return 10
             end
         end
         
         return 2 + d_flr_m(wave_number, 5, 2)
     end,
     init = function(unit)
         unit.cooldown = 0
         unit.movement_type = unit.type.movement_type
         unit.health_max = unit.health
         spawned_boss = unit
     end,
     movement_type = 'walk',
     weakness = 'laser',
     strength = 'bomb',
     draw = function(unit, x, y)
         local flip = false
         if get_flip(unit, 16) and (not unit.movement_type or unit.movement_type == 'walk') then
             flip = true
         end
 
         -- Next wave image
         if not unit.cooldown then
             spr(74, x, y)
             return
         end
 
         local image = 68
         if unit.movement_type == 'fly' then
             if unit.cooldown > 25 then
                 image = 70
             elseif unit.cooldown <= 25 then
                 image = 72
             end
         end
 
         spr(image, unit.px - 4, unit.py - 8, 2, 2, flip)
     end,
     update = function(unit)
         if unit.cooldown > 0 then
             unit.cooldown -= 1
             return
         end

         local real_cell_x = ceil((unit.px + 4) / CELL_SIZE)
         local real_cell_y = ceil((unit.py + 4) / CELL_SIZE)
 
         if unit.movement_type == 'walk' then
            -- Walking, ready to jump
            -- Should have a path to follow
            if real_cell_y < GRID_HEIGHT-2 and get_tower_at(real_cell_x, real_cell_y + 2) == nil
            and get_tower_at(real_cell_x, real_cell_y + 1) ~= nil then
                -- Jump it
                unit.cooldown = 50
                unit.movement_type = 'fly'
                grid[unit.x][unit.y].unit_id = nil
            end
         else
            -- Flying over tower 
            if get_tower_at(real_cell_x, real_cell_y) == nil then
                unit.movement_type = 'walk'
                unit.cooldown = 180
                unit.x = real_cell_x
                unit.y = real_cell_y
                unit.path = nil
            end
         end
     end,
 }
 
 -- Squeal Team 6
 unit_types_list['ST6'] = {
    name = 'ST6',
    type = 'boss',
    damage = 6,
    spawn_number = 1,
    reward = 10,
    health = function(wave_number) return 22.5 * wave_number + d_flr_m(wave_number, 5, 65) end,
    speed = function(unit, wave_number)
        if unit.anim > 0 and unit.anim < 45 then
            return 0
        end
        return 5 + d_flr_m(wave_number, 5, 2)
    end,
    movement_type = 'walk',
    weakness = 'pixel',
    strength = 'laser',
    init = function(unit)
        unit.health_max = unit.health
        unit.invis_timer = 0
        unit.invisible = false
        unit.charges = 3
        unit.anim = 0
        spawned_boss = unit
    end,
    update = function(unit)
        if unit.health < unit.health_max / 4 * unit.charges and unit.invis_timer <= 0 and unit.anim == 0 then
            -- Go invis
            unit.invis_timer = 120
            unit.charges -= 1
        end

        if unit.invis_timer > 0 then
            if unit.anim < 45 then
                unit.anim += 1
            else
                unit.invisible = true
                unit.invis_timer -= 1
            end
        else
            if unit.anim > 0 then
                unit.invisible = false
                unit.anim -= 1
            end
        end
    end,
    draw = function(unit, x, y)
        -- Next wave image
        palt(14, true)
        palt(0, false)
        if not unit.invis_timer then
            spr(90, x, y)
            palt()
            return
        end

        palt(14, true)
        local flip = get_flip(unit, 6) and unit.anim == 0

        if not unit.invisible then
            spr(98 + 2 * flr(unit.anim * 1.08696), x - 4, y - 8, 2, 2, flip, false)
        end
        palt()
    end
}