-- Constants
WAVE_PREP_TIME = 15 * 30 -- 15 seconds (PICO-8 runs at 30 FPS)

-- Variables
wave_number = 1
wave_timer = WAVE_PREP_TIME + 10
wave_units_to_spawn = 0
wave_spawning_unit_type = nil
chicken_spawn_delay = 0

-- Update wave timing and spawning units
function update_waves()
    -- Check if wave is still spawning
    if wave_units_to_spawn > 0 then
        if wave_spawning_unit_type.name == 'Chicken' and chicken_spawn_delay > 0 then
            chicken_spawn_delay -= 1
        else
            chicken_spawn_delay = unit_types_list['Chicken'].spawn_rate
            printh("Attempting to spawn: "..wave_spawning_unit_type.name)
            local spawned_unit = spawn_unit(wave_spawning_unit_type)
            if spawned_unit then
                printh("Successfully spawned "..wave_spawning_unit_type.name)
                wave_units_to_spawn -= 1
            end
        end
    end

    -- Check if game has been won
    if wave_number > 30 and #units == 0 then
        game_state = 'victory'
    end

    -- If no units left in wave, countdown timer
    if #units == 0 and wave_units_to_spawn == 0 and wave_timer > 0 then
        wave_timer -= 1
    end

    if wave_timer <= 0 and wave_number <= 30 then
        start_wave()
        wave_number += 1
        if wave_number <= 30 then
            wave_timer = WAVE_PREP_TIME -- 20 seconds after all units destroyed
        end
    end
end

-- Start a new wave of units
function start_wave()
    wave_units_to_spawn = get_wave_unit_total(wave_number)
    wave_spawning_unit_type = next_unit_type
    -- Bosses have their own fixed number of spawns
    if wave_spawning_unit_type.type == 'boss' then
        wave_units_to_spawn = wave_spawning_unit_type.spawn_number
    end
    next_unit_type = get_next_unit_type()
end

function get_wave_unit_total(wave)
    return 2 + ceil(wave / 3)
end

-- Determine the next unit type based on probabilities
function get_next_unit_type()
    -- Define basic unit probabilities
    local unit_probs = {
        {type = unit_types_list['Walker'], prob = 0.3},
        {type = unit_types_list['Knight'], prob = 0.3},
        {type = unit_types_list['Lizard'], prob = 0.3},
        {type = unit_types_list['Bat'], prob = 0.1}
    }

    -- Override with boss probabilities for wave 10 and 30
    if wave_number == 9 or wave_number == 29 then
        unit_probs = {
            {type = unit_types_list['Carrier'], prob = 0.5},
            {type = unit_types_list['BigBoy'], prob = 0.5},
        }
    -- elseif wave_number == 1 or wave_number == 7 or wave_number == 13 or wave_number == 19 or
    -- wave_number == 23 or wave_number == 27 then
    elseif wave_number == 19 or wave_number == 27 then
        unit_probs = {
            {type = unit_types_list['Chicken'], prob = 1.0},
        }
    end

    -- Set chicken deploy
    printh("unit type: "..unit_probs[1].type.name)
    if unit_probs[1].type.name == 'Chicken' then
        chicken_deploy_y = 6 + ceil(rnd(GRID_HEIGHT - 10))
        -- printh("chicken_deploy_y: "..chicken_deploy_y)
    end

    -- Randomly select unit type based on probabilities
    local r = rnd(1)
    local cumulative = 0
    for i = 1, #unit_probs do
        cumulative += unit_probs[i].prob
        if r <= cumulative then
            return unit_probs[i].type
        end
    end

    return unit_probs[1].type -- Default to first type
end