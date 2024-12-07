 -- Define the unit types list
 unit_types_list = {}
 unit_types_list['Walker'] = {
     name = 'Walker',
     type = 'basic',
     health = function(wave_number) return 6 * wave_number / 2 + flr(wave_number / 5) * 2 end,
     speed = function(unit, wave_number) return 5 + flr(wave_number / 5) * 2 end,
     movement_type = 'walk',
     weakness = nil,
     strength = nil,
     draw = function(unit, x, y)
         palt(1, true)
         local flip = false
         if flr(unit.lifetime / 4) % 2 == 0 then
             flip = true
         end
 
         spr(20, x, y, 1, 1, flip, false)
         palt()
     end
 }
 unit_types_list['Knight'] = {
    name = 'Knight',
    type = 'basic',
    health = function(wave_number) return 8 * wave_number / 2 + flr(wave_number / 5) * 2 end,
    speed = function(unit, wave_number)
        local base = 4
        if wave_is_elite then
            base += 2
        end
        return base + flr(wave_number / 5) * 2
    end,
    movement_type = 'walk',
    weakness = 'laser',
    strength = 'bomb',
    draw = function(unit, x, y)
         palt(1, true)
         local flip = false
         if flr(unit.lifetime / 6) % 2 == 0 then
             flip = true
         end
 
         if wave_is_elite then
            pal({[10]=11, [4]=12})
         end

         spr(21, x, y, 1, 1, flip, false)
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
        return base * wave_number / 2 + flr(wave_number / 5) * 2
    end,
     speed = function(unit, wave_number) return 6 + flr(wave_number / 5) * 2 + flr(wave_number / 10) * 2 end,
     movement_type = 'walk',
     weakness = 'pixel',
     strength = 'laser',
     draw = function(unit, x, y)
         local flip = false
         if flr(unit.lifetime / 10) % 2 == 0 then
             flip = true
         end

         -- Draw elite version
         if wave_is_elite then
            pal({[11]=8, [3]=4, [8]=11})
         end
 
         spr(37 + flr(unit.lifetime / 3) % 2, x, y, 1, 1, flip, false)
         pal()
     end
 }
 unit_types_list['Bat'] = {
     name = 'Bat',
     type = 'basic',
     health = function(wave_number) return 4 * wave_number / 2 + flr(wave_number / 5) * 2 end,
     speed = function(unit, wave_number)
        local base = 4
        if wave_is_elite then
            base += 2
        end

        return base + flr(wave_number / 5) * 2
    end,
     movement_type = 'fly',
     weakness = 'bomb',
     strength = 'pixel',
     draw = function(unit, x, y)
         palt(15, true)
 
         local flip = false
         if flr(unit.lifetime / 8) % 2 == 0 then
             flip = true
         end

         -- Draw elite version
         if wave_is_elite then
            pal({[0]=3, [7]=0})
         end
 
         palt(0, false)
         spr(24 + flr(unit.lifetime / 3) % 2, x, y, 1, 1, flip, false)
 
         palt()
         pal()
     end
 }
--  unit_types_list['Chicken'] = {
--      name = 'Chicken',
--      type = 'elite',
--      spawn_rate = 20,
--      health = function(wave_number) return 5 * wave_number / 2 + flr(wave_number / 5) * 2 end,
--      speed = function(unit, wave_number) return 5 + flr(wave_number / 5) * 2 end,
--      movement_type = 'fly',
--      weakness = 'pixel',
--      strength = 'laser',
--      path_iterations = 10,
--      init = function(unit)
--          if rnd(100) < 33 then unit.is_rooster = 1 else unit.is_rooster = 0 end
--          if unit.is_rooster then
--              unit.health = unit.health * 1.4
--          end
 
--          unit.fly_duration = 30 + rnd(30)
--          unit.flying = true
--      end,
--      draw = function(unit, x, y)
--          if not unit.is_rooster then
--              unit.is_rooster = 0
--          end
 
--          local flip = false
--          local image = 80
--          if not unit.flying then
--              image = 64
--              if flr(unit.lifetime / 12) % 2 == 0 then
--                  flip = true
--              end
--          end
 
--          local flip = false
--          if flr(unit.lifetime / 10) % 2 == 0 and not unit.flying then
--              flip = true
--          end
 
--          spr(image + flr(unit.lifetime / 3) % 2 + unit.is_rooster * 2, x, y, 1, 1, flip)
--      end,
--      update = function(unit, x, y)
--          if unit.fly_duration > 0 and unit.px / CELL_SIZE < GRID_WIDTH / 2 then
--              unit.py = chicken_deploy_y * CELL_SIZE
--              unit.fly_duration -= 1
--          else
--              if unit.flying then
--                  local land_x = ceil((unit.px) / CELL_SIZE) + 1
--                  local land_y = ceil((unit.py) / CELL_SIZE)
 
--                  if get_tower_at(land_x, land_y) == nil and grid[land_x][land_y].unit_id == nil then
--                      unit.flying = false
--                      unit.movement_type = 'walk'
--                      unit.x = land_x
--                      unit.y = land_y
--                  end
--              end
--          end
 
--      end
--  }
 
 
 -- Bosses
 unit_types_list['Carrier'] = {
     name = 'Carrier',
     type = 'boss',
     spawn_number = 1,
     damage = 6,
     health = function(wave_number) return 30 * wave_number / 2 + flr(wave_number / 5) * 20 end,
     reward = 6,
     speed = function(unit, wave_number)
         if unit.ability_cooldown < 30 then
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
         if not unit.ability_cooldown then
             spr(26, x, y)
             return
         end
 
         if unit.ability_cooldown >= 30 then
             sspr(88 + (flr(unit.lifetime / 15) % 2) * 16, 0, 16, 16, x - 4, y - 8, 16, 16)
         else
             sspr(88 + (flr((29 - unit.lifetime) / 15) % 2) * 16, 16, 16, 16, x - 4, y - 8, 16, 16)
         end
     end,
     update = function(unit)
        if not wave_running then
            return
        end
        
         unit.ability_cooldown = (unit.ability_cooldown - 1) % unit.type.spawn_time

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
     health = function(wave_number) return 2 * wave_number / 2 + flr(wave_number / 5) * 5 end,
     reward = 0,
     speed = function(unit, wave_number) return 8 + flr(wave_number / 5) * 2 end,
     movement_type = 'walk',
     weakness = nil,
     strength = nil,
     path_iterations = 10,
     draw = function(unit, x, y)
         spr(39 + flr(unit.lifetime / 3) % 2, x, y)
     end
 }
 
 -- BigBoy
 unit_types_list['BigBoy'] = {
     name = 'BigBoy',
     type = 'boss',
     spawn_number = 1,
     damage = 6,
     health = function(wave_number) return 55 * wave_number / 2 + flr(wave_number / 5) * 70 end,
     reward = 6,
     speed = function(unit, wave_number)
         if unit.movement_type == 'fly' then
             if unit.ability_cooldown > 25 then
                 return 0
             else 
                 return 10
             end
         end
         
         return 2 + flr(wave_number / 5) * 2
     end,
     init = function(unit)
         unit.ability_cooldown = 0
         unit.movement_type = unit.type.movement_type
         unit.x_lock = nil
         unit.health_max = unit.health
         spawned_boss = unit
     end,
     movement_type = 'walk',
     weakness = 'laser',
     strength = 'bomb',
     draw = function(unit, x, y)
         local flip = false
         if flr(unit.lifetime / 16) % 2 == 0 and (not unit.movement_type or unit.movement_type == 'walk') then
             flip = true
         end
 
         -- Next wave image
         if not unit.ability_cooldown then
             spr(74, x, y)
             return
         end
 
         local image = 68
         if unit.movement_type == 'fly' then
             if unit.ability_cooldown > 25 then
                 image = 70
             elseif unit.ability_cooldown <= 25 then
                 image = 72
             end
         end
 
         spr(image, unit.px - 4, unit.py - 8, 2, 2, flip)
     end,
     update = function(unit, x, y)
         if unit.ability_cooldown > 0 then
             unit.ability_cooldown -= 1
         end
 
         if unit.movement_type == 'walk' then
             if unit.ability_cooldown == 0 then
                 -- Walking, ready to jump
                 -- Should have a path to follow
                 local real_cell = {x = ceil((unit.px + 4) / CELL_SIZE), y = ceil((unit.py + 4) / CELL_SIZE)}
                 if real_cell.y < GRID_HEIGHT-2 and get_tower_at(real_cell.x, real_cell.y + 2) == nil
                 and get_tower_at(real_cell.x, real_cell.y + 1) ~= nil then
                     -- Jump it
                     unit.ability_cooldown = 50
                     unit.movement_type = 'fly'
                     grid[unit.x][unit.y].unit_id = nil
                     unit.x_lock = unit.px
                 end
             end
 
         else
            unit.px = unit.x_lock
            if unit.ability_cooldown == 0 then
                 -- Flying over tower
                 local land_x = ceil((unit.px) / CELL_SIZE)
                 local land_y = ceil((unit.py + 4) / CELL_SIZE)
 
                 if get_tower_at(land_x, land_y) == nil then
                     unit.movement_type = 'walk'
                     unit.ability_cooldown = 180
                     unit.x = land_x
                     unit.y = land_y
                     unit.path = nil
                 end
             end
         end
     end,
 }
 