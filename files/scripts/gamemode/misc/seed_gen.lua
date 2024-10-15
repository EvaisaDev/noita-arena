get_new_seed = function(x, y, synced)
    local rounds = tonumber(GlobalsGetValue("holyMountainCount", "0")) or 0
    local seed = GameGetFrameNum() * ((rounds + 1) * 16)

    if(synced)then
        seed = (rounds + 1) * 16
    end

    local seed_x = seed
    local seed_y = seed

    if(x ~= nil)then
        seed_x = seed_x + (x * 12)
    end

    if(y ~= nil)then
        seed_y = seed_y + (y * 12)
    end


    return seed_x, seed_y
end
