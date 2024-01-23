get_new_seed = function(x, y, synced)
    local rounds = tonumber(GlobalsGetValue("holyMountainCount", "0")) or 0
    local a, b, c, d, e, f = GameGetDateAndTimeLocal()
    local seed = ((GameGetFrameNum() + GameGetRealWorldTimeSinceStarted() + a * 34 + b / 14 + c + d * 3 + e + f * 53) / 2) * (rounds + 1)

    if(synced)then
        seed = ((tonumber(GlobalsGetValue("world_seed", "0")) or 1) * 214) * rounds
    end
	if(x and y)then
		seed = seed + (x * 324) + (y * 436)
	end
    return seed
end
