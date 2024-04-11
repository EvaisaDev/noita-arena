dofile("data/scripts/lib/mod_settings.lua")



local mod_id = "evaisa.arena" -- This should match the name of your mod's folder.
mod_settings_version = 1      -- This is a magic global that can be used to migrate settings to new mod versions. call mod_settings_get_version() before mod_settings_update() to get the old value.
mod_settings =
{
    {
        category_id = "default_settings",
        ui_name = "",
        ui_description = "",
        settings = {
            {
                id = "custom_parallax",
                ui_name = "Custom Parallax",
                ui_description = "Enable the custom parallax system for arenas, turn this off if you experience white screen issues.",
                value_default = true,
                scope = MOD_SETTING_SCOPE_NEW_GAME,
            },
            --[[{
                id = "predictive_netcode",
                ui_name = "Predictive Netcode",
                ui_description = "Predict player movement using latency.",
                value_default = false,
                scope = MOD_SETTING_SCOPE_RUNTIME,
            },]]
            {
                id = "ready_count_left",
                ui_name = "Ready Count Alt Position",
                ui_description = "Move the ready count to the left side of the screen",
                value_default = false,
                scope = MOD_SETTING_SCOPE_RUNTIME,
            },
            --[[{
                id = "spectator_unstable",
                ui_name = "Enable Spectator System",
                ui_description = "Enable unfinished spectator system. (Extremely unstable)",
                value_default = false,
                scope = MOD_SETTING_SCOPE_RUNTIME,
            },]]
			{
				id = "simulated_latency",
				ui_name = "Simulated Latency",
                ui_description = "Simulate latency for testing purposes. (frames)",
				value_default = 0,
				value_min = 0,
				value_max = 300,
				value_display_multiplier = 1,
				value_display_formatting = " $0 frames",
				scope = MOD_SETTING_SCOPE_RUNTIME,
			},
        },
    },
}


function ModSettingsUpdate(init_scope)
    local old_version = mod_settings_get_version(mod_id)
    mod_settings_update(mod_id, mod_settings, init_scope)
end

function ModSettingsGuiCount()
    return mod_settings_gui_count(mod_id, mod_settings)
end

function ModSettingsGui(gui, in_main_menu)
    mod_settings_gui(mod_id, mod_settings, gui, in_main_menu)
end