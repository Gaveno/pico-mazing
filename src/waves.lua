-- Constants
WAVE_PREP_TIME = 15 * 30 -- 15 seconds (PICO-8 runs at 30 FPS)

-- Variables
wave_number = 1
wave_timer = WAVE_PREP_TIME + 10
wave_units_to_spawn = 0
wave_spawning_unit_type = nil

-- Update wave timing and spawning units
function update_waves()
    -- Check if wave is still spawning
    if wave_units_to_spawn > 0 then
        spawn_unit(wave_spawning_unit_type)
        wave_units_to_spawn -= 1
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
    next_unit_type = get_next_unit_type()
end

function get_wave_unit_total(wave)
    return 2 + ceil(wave / 2)
end