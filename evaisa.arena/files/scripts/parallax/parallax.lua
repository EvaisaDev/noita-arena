DEBUG_LOG_LEVEL = 0 -- 0 = none, 1 = events, 2 = everything
DEBUUG_SHADER = false

-- Hack to get mod ID and path
local orig_do_mod_appends = do_mod_appends
do_mod_appends = function(filename, ...)
    _G["PARALLAX_MODID"] = filename:match("mods/([^/]+)/files/")
    _G["PARALLAX_PATH"] = filename:match("(.+/)[^/]+")
    do_mod_appends = orig_do_mod_appends
    do_mod_appends(filename, ...)
end

local function debugPrint(msg, level)
  local level = level or 1
  if level <= DEBUG_LOG_LEVEL then
    print("[DEBUG] [Parallax:" .. _G["PARALLAX_MODID"].. "] " .. msg)
  end
end

local function parallaxPrint(msg)
  print("[Parallax] " .. msg)
end

local function getLayerById(bank, id)
  for i, layer in ipairs(bank.layers) do
    if layer.id == id then
      return layer
    end
  end
  return nil
end

local function lerp(a, b, t)
  return a + (b - a) * t
end

-- LERP
local function lerpColor(a, b, t)
  local r = lerp(a[1], b[1], t)
  local g = lerp(a[2], b[2], t)
  local b = lerp(a[3], b[3], t)
  return {r/255, g/255, b/255}
end

-- Smoothstep
local function smoothstep(a, b, t)
  t = t * t * (3.0 - 2.0 * t)
  return lerpColor(a, b, t)
end

local function getDynamicColor(colors, time)
  local cyclelength = 0
  for i, color in ipairs(colors) do
    cyclelength = cyclelength + color.d
  end

  local t = time % cyclelength
  local i = 1
  while t > colors[i].d do
    t = t - colors[i].d
    i = i + 1
  end

  if colors[i].i == Parallax.INTERP.SMOOTHSTEP then
    return smoothstep(colors[i].c, colors[i % #colors + 1].c, t / colors[i].d)
  elseif colors[i].i == Parallax.INTERP.NONE then
    return colors[i].c
  else
    return lerpColor(colors[i].c, colors[i % #colors + 1].c, t / colors[i].d)
  end
end

local function getSkyGradientColors(bank, time)
  local sky = bank.sky
  local colors1 = sky.gradient_dynamic_colors[1]
  local colors2 = sky.gradient_dynamic_colors[2]

  local color1 = getDynamicColor(colors1, time)
  local color2 = getDynamicColor(colors2, time)

  return color1, color2
end

local function getSkyColor(bank, index, time)
  -- Allow for negative indexes to count from the end
  if index < 0 then
    index = #Parallax.sky.dynamic_colors + index + 1
  end
  if index > #bank.sky.dynamic_colors then
    index = #bank.sky.dynamic_colors
  end
  if index < 1 then return {0, 0, 0} end
  local colors = bank.sky.dynamic_colors[index]
  return getDynamicColor(colors, time)
end

local function setStateUniforms(time, current_bank)
  local getSetting = Parallax.GetSetting
  local frame = Parallax.GetFrame()
  local setUniform = Parallax.SetUniform
  local tween_target = getSetting("parallax_global.tween_target") or frame
  local tween_length = getSetting("parallax_global.tween_length") or 0

  local tween = 0
  local mix

  if tween_target > frame then
    tween  = (tween_target - frame) / tween_length
  end

  local bank_A_is_nil = getSetting("parallax_global.bank_A_is_nil")
  local bank_B_is_nil = getSetting("parallax_global.bank_B_is_nil")

  if bank_A_is_nil and bank_B_is_nil then
    mix = 0
    tween = 0
  else
    if current_bank == "B" then
      if bank_A_is_nil then
        -- from nil to B
        mix = 1 - tween
        tween = 1
      else
        if bank_B_is_nil then
          -- from A to nil
          mix = tween
          tween = 0
        else
          -- from A to B
          tween = 1 - tween
          mix = 1
        end
      end
    elseif current_bank == "A" then
      if bank_B_is_nil then
        -- from nil to A
        mix = 1 - tween
        tween = 0
      else
        if bank_A_is_nil then
          -- from B to nil
          mix = tween
          tween = 1
        else
          -- from B to A
          mix = 1
        end
      end
    end
  end

  debugPrint("Tween: " .. tween .. " Mix: " .. mix .. " Current bank: " .. current_bank, 2)

  setUniform( "parallax_world_state", time % 1, mix, tween, 0.0)
end

local function pushUniforms(time, current_bank)
  local error_msg = ""
  local setUniform = Parallax.SetUniform

  local frame = Parallax.GetFrame()

  debugPrint("pushUniforms called on frame " .. tostring(frame) .. " for bank " .. current_bank .. " from mod " .. _G["PARALLAX_MODID"], 2)

  local function setLayerUniforms(bank, char)
    if bank == nil then return end
    for i, layer in ipairs(bank.layers) do

      -- supply default values for missing keys
      local mt = {
        __index = function(t, key)
          return Parallax.layer_defaults[key]
        end
      }
      setmetatable(layer, mt)
  
      local layer_error = false
  
      -- Unintended indexes should be made highly visible
      local sky_index = layer.sky_index
      local alpha_index = layer.alpha_index
      local sky_tex = Parallax.tex[bank.sky.path]
      if sky_tex == nil or sky_tex == "" then
        sky_tex = Parallax.tex["data/parallax_fallback_sky.png"]
      end
      local sky_tex_height = sky_tex.height
  
      if layer.sky_source == Parallax.SKY_SOURCE.DYNAMIC and math.abs(sky_index) > #bank.sky.dynamic_colors then
        error_msg = error_msg .. "Error in layer " ..  tostring(i) .. ": Dynamic sky index " .. tostring(sky_index) .. " is out of bounds. Max index is " .. tostring(#bank.sky.dynamic_colors) .. "\n"
        layer_error = true
      end
  
      if layer.sky_source == Parallax.SKY_SOURCE.TEXTURE and math.abs(sky_index) > sky_tex_height / 3 then
        error_msg = error_msg .. "Error in layer " ..  tostring(i) .. ": Texture sky index " .. tostring(sky_index) .. " is out of bounds. Max index is " .. tostring(sky_tex_height/ 3) .. " (image height " .. tostring(sky_tex_height) .. "px / 3)\n"
        layer_error = true
      end
  
      if layer.alpha_source == Parallax.SKY_SOURCE.DYNAMIC and math.abs(alpha_index) > #bank.sky.dynamic_colors then
        error_msg = error_msg .. "Error in layer " ..  tostring(i) .. ": Dynamic alpha index " .. tostring(alpha_index) .. " is out of bounds. Max index is " .. tostring(#bank.sky.dynamic_colors) .. "\n"
        layer_error = true
      end
  
      if layer.alpha_source == Parallax.SKY_SOURCE.TEXTURE and math.abs(alpha_index) > sky_tex_height / 3 then
        error_msg = error_msg .. "Error in layer " ..  tostring(i) .. ": Texture alpha index " .. tostring(alpha_index) .. " is out of bounds. Max index is " .. tostring(sky_tex_height / 3) .. " (image height " .. tostring(sky_tex_height) .. "px / 3)\n"
        layer_error = true
      end
  
      local color = getSkyColor(bank, sky_index, time)
      setUniform( "parallax_sky_color_"..char.."_"..i, color[1], color[2], color[3], 1.0)
  
      local alpha_color = getSkyColor(bank, alpha_index, time)
      setUniform( "parallax_alpha_color_"..char.."_"..i, alpha_color[1], alpha_color[2], alpha_color[3], 1.0)
  
      local gradient_1, gradient_2 = getSkyGradientColors(bank, time)
      
      setUniform( "parallax_sky_gradient_color_"..char.."_1", gradient_1[1], gradient_1[2], gradient_1[3], 0.0)
      setUniform( "parallax_sky_gradient_color_"..char.."_2", gradient_2[1], gradient_2[2], gradient_2[3], 0.0)
  
      setUniform( "parallax_sky_gradient_index_"..char, bank.sky.gradient_texture[1], bank.sky.gradient_texture[2], 0.0, 0.0)
      setUniform( "parallax_sky_gradient_"..char, bank.sky.gradient_dynamic_enabled, 0.0, bank.sky.gradient_pos[1], bank.sky.gradient_pos[2])
  
      local error_color = 0
      if layer_error and Parallax.HIGHLIGHT_ERRORS then error_color = math.floor((Parallax.GetFrame() % 60) / 30) end
  
      setUniform( "parallax_"..char.."_"..i.."_1", layer.scale, layer.alpha, layer.offset_x, layer.offset_y )
      setUniform( "parallax_"..char.."_"..i.."_2", layer.depth, layer.sky_blend, layer.speed_x, layer.speed_y )
      setUniform( "parallax_"..char.."_"..i.."_3", layer.sky_index, layer.sky_source, layer.min_y, layer.max_y)
      setUniform( "parallax_"..char.."_"..i.."_4", layer.alpha_blend, layer.alpha_index, layer.alpha_source, error_color) -- 4th param is for error state
  
    end
  end

  setLayerUniforms(Parallax.bank[current_bank], current_bank)

  return error_msg
end

local injectShaderCode = function()
  local injectpath = _G["PARALLAX_PATH"] .. "inject.lua"
  if not Parallax.FileExists(injectpath) then
    error("Failed to find inject.lua at " .. injectpath)
  end
  local inject = Parallax.DoFileOnce( injectpath )
  local maxLayers = Parallax.MAX_LAYERS

  local post_final = Parallax.GetContent("data/shaders/post_final.frag")

  -- Update GLSL version
  post_final = post_final:gsub(inject.version.pattern, inject.version.replacement, 1)

  -- Patch
  post_final = post_final:gsub(inject.patch.pattern, inject.patch.replacement)

  -- Global Uniforms
  post_final = post_final:gsub(inject.global_uniforms.pattern, inject.global_uniforms.replacement .. "\n%1", 1)

  -- Sky Uniforms
  post_final = post_final:gsub(inject.sky_uniforms.pattern, function(capture)
    local u = ""
    local A = "A"
    local B = "B"
    u = u .. string.format(inject.sky_uniforms.replacement, A, A, A, A)
    u = u .. string.format(inject.sky_uniforms.replacement, B, B, B, B)
    u = u .. "\n" .. capture
    return u
  end)

  -- Layer Uniforms
  post_final = post_final:gsub(inject.layer_uniforms.pattern, function(capture)
    local u = ""
    for i = 1, maxLayers do
      local A = "A_" .. tostring(i) 
      local B = "B_" .. tostring(i)
      u = u .. string.format(inject.layer_uniforms.replacement, A, A, A, A, A, A, A)
      u = u .. string.format(inject.layer_uniforms.replacement, B, B, B, B, B, B, B)
    end
    u = u .. "\n" .. capture
    return u
  end)

  -- Functions
  post_final = post_final:gsub(inject.functions.pattern, inject.functions.replacement .. "\n%1", 1)

  -- Replace background
  post_final = post_final:gsub(inject.replace_bg.pattern, inject.replace_bg.replacement, 1)

  -- Bank A
  post_final = post_final:gsub(inject.bank_A.pattern, inject.bank_A.replacement  .. "\n%1", 1)
  post_final = post_final:gsub(inject.layers.pattern, function()
    local l = ""
    for i = 1, maxLayers do
      local A = "A_" .. tostring(i)
      l = l .. string.format(inject.layers.replacement, "A", tostring(i), A, A, "A", A, A, A, A, A, A, A, A)
    end
    l = l .. "\n"
    return l
  end)

  -- Bank B
  post_final = post_final:gsub(inject.bank_B.pattern, inject.bank_B.replacement  .. "\n%1", 1)
  post_final = post_final:gsub(inject.layers.pattern, function()
    local l = ""
    for i = 1, maxLayers do
      local B = "B_" .. tostring(i)
      l = l .. string.format(inject.layers.replacement, "B", tostring(i), B, B, "B", B, B, B, B, B, B, B, B)
    end
    l = l .. "\n"
    return l
  end)

  if DEBUUG_SHADER then print(post_final) end

  -- Apply post_final
  Parallax.SetContent("data/shaders/post_final.frag", post_final)
end

local pushTextures = function(bank, char)
  local setTexture = Parallax.SetTexture

  if bank == nil then
    setTexture( "tex_parallax_sky_" .. char, "data/parallax_fallback_sky.png", Parallax.FILTER.BILINEAR, Parallax.WRAP.REPEAT, true )
    return
  end

  for i, layer in ipairs(bank.layers) do
    setTexture( "tex_parallax_" .. char .. "_" .. i, layer.path, Parallax.FILTER.BILINEAR, Parallax.WRAP.CLAMP, true )
    debugPrint("Pushed texture: " .. layer.path .. " as tex_parallax_" .. char .. "_" .. i, 1)
  end

  local missing_sky = false

  if bank.sky.path == nil or bank.sky.path == "" then
    setTexture( "tex_parallax_sky_" .. char, "data/parallax_fallback_sky.png", Parallax.FILTER.BILINEAR, Parallax.WRAP.REPEAT, true )
    missing_sky = true
  else
    setTexture( "tex_parallax_sky_" .. char, bank.sky.path, Parallax.FILTER.BILINEAR, Parallax.WRAP.REPEAT, true )
  end
  
  if missing_sky then
    error("No sky texture provided. Using fallback texture. Please set sky.path to a valid texture path.")
  end
end

local postInit = function()
  local removeSetting = Parallax.RemoveSetting
  local getSetting = Parallax.GetSetting
  if Parallax.initialized then return end

  parallaxPrint(string.format("Parallax v%s.%s initialized", Parallax.version.major, Parallax.version.minor))

  Parallax.initialized = true
  Parallax.MAX_LAYERS = getSetting("parallax_global.max_layers") or 0

  if getSetting("parallax_global.leader") == _G["PARALLAX_MODID"] then
    local setSetting = Parallax.SetSetting

    parallaxPrint("Leading mod is " .. _G["PARALLAX_MODID"] .. ". Injecting shader code.")

    injectShaderCode()
    
    removeSetting( "parallax_global.max_layers" )
    removeSetting( "parallax_global.leader" )
    removeSetting( "parallax_global.current_bank" )
    removeSetting( "parallax_global.bank_A_owner" )
    removeSetting( "parallax_global.bank_B_owner" )
    removeSetting( "parallax_global.tween_target" )
    removeSetting( "parallax_global.tween_length" )

    setSetting("parallax_global.bank_A_is_nil", true)
    setSetting("parallax_global.bank_B_is_nil", true)
  end
end

local function registerTextures(textures)
  local makeEditable = Parallax.MakeEditable
  for i, path in ipairs(textures) do
    local id, width, height = makeEditable( path, 0, 0 )
    if id == 0 or id == nil then
      error("Failed to load image: " .. path)
    end
    Parallax.tex[path] = {id = id, width = width, height = height}
    debugPrint("Registered texture: " .. path .. " with id: " .. id .. " and size: " .. width .. "x" .. height, 1)
  end
  -- Create a fallback sky texture
  if Parallax.tex["data/parallax_fallback_sky.png"] == nil then
    local id, width, height = makeEditable( "data/parallax_fallback_sky.png", 1, 1 )
    if id == 0 or id == nil then
      error("Failed to generate fallback sky image: data/parallax_fallback_sky.png")
    end
    Parallax.tex["data/parallax_fallback_sky.png"] = {id = id, width = math.huge, height = math.huge}
  end
end

local push = function(data, tween)
  local getSetting = Parallax.GetSetting
  local setSetting = Parallax.SetSetting
  local setUniform = Parallax.SetUniform
  local getFrame = Parallax.GetFrame
  local dataIsNil = data == nil
  
  local current_bank = getSetting("parallax_global.current_bank") or "B"
  -- TODO: Consolidate logic

  current_bank = current_bank == "A" and "B" or "A"

  Parallax.bank[current_bank] = data
  Parallax.bank_owner[current_bank] = true
  setSetting("parallax_global.bank_"..current_bank.."_owner", _G["PARALLAX_MODID"])
  setSetting("parallax_global.current_bank", current_bank)
  setSetting ( "parallax_global.bank_"..current_bank.."_is_nil", dataIsNil )

  if not dataIsNil then
    debugPrint("Pushing " .. data.id .." to bank " .. current_bank, 1)
    setUniform("parallax_layer_count_" .. current_bank, data.layers and #data.layers or 0.0, 0.0, 0.0, 0.0)
  end

  pushTextures(data, current_bank)

  if tween == nil then tween = 0 end
  setSetting("parallax_global.tween_length", tween)
  setSetting("parallax_global.tween_target", getFrame() + tween)
end

local update = function()
  local getSetting = Parallax.GetSetting
  local getFrame = Parallax.GetFrame
  local frame = getFrame()
  if Parallax.last_frame == frame then return end
  Parallax.last_frame = frame

  local world_state_entity = Parallax.GetWorldStateEntity()
  local world_state = Parallax.EntityGetFirstComponent( world_state_entity, "WorldStateComponent" )
  local time = Parallax.ComponentGetValue2( world_state, "time" )
  local day = Parallax.ComponentGetValue2( world_state, "day_count" )

  local error_msg = ""

  local current_owner = {
    A = nil,
    B = nil
  }
  local other_bank = {
    A = "B",
    B = "A"
  }
  local tween_target = nil
  local current_bank = nil
  
  local function processBank(char)
    current_owner[char] = getSetting("parallax_global.bank_" .. char .. "_owner")
    if current_owner[char] == _G["PARALLAX_MODID"] then
      -- Still owner
      local bank = Parallax.bank[char]
      if bank ~= nil then
        -- Only do updates if the bank is visible
        current_bank = current_bank and current_bank or getSetting("parallax_global.current_bank")
        tween_target = tween_target and tween_target or getSetting("parallax_global.tween_target")
        if not (current_bank == other_bank[char] and frame > tween_target) then
          if bank.update ~= nil and type(bank.update) == "function" then
            bank.update(bank)
          end
          error_msg = error_msg .. pushUniforms(time + day, char)
        end
      end
    else
      -- Lost ownership
      debugPrint(_G["PARALLAX_MODID"] .. " lost ownership of bank " .. char, 2)
    end
  end

  if Parallax.bank_owner.B then processBank("B") end
  if Parallax.bank_owner.A then processBank("A") end

  -- State uniforms should only be updated by the owner of the active bank
  if Parallax.bank_owner.A or Parallax.bank_owner.B then
    current_bank = current_bank and current_bank or getSetting("parallax_global.current_bank")
    if current_bank ~= nil then
      local current_bank_owner = nil
      if current_bank == "A" then current_bank_owner = current_owner.A elseif
         current_bank == "B" then current_bank_owner = current_owner.B end
      if current_bank_owner == _G["PARALLAX_MODID"] then
        setStateUniforms(time + day, current_bank)
      end
    end
  end
  
  if error_msg ~= "" then
    print(error_msg)
  end
end

local registerLayers = function(num)
  local getSetting = Parallax.GetSetting
  local setSetting = Parallax.SetSetting
  local current_max = getSetting("parallax_global.max_layers") or 0
  if num > current_max then
    setSetting("parallax_global.max_layers", num)
    setSetting("parallax_global.leader", _G["PARALLAX_MODID"])
  end
end

local getBankTemplate = function()
  return {
    id = nil,
    layers = {},
    sky = {
      w = 0,
      h = 0,
      path = nil,
      dynamic_colors = {},
      gradient_dynamic_enabled = 0,
      gradient_pos = {0.6, 0.4},
      gradient_texture = {1, 2},
      gradient_dynamic_colors = {
      {{c = {0,0,0}, d=1}},
      {{c = {0,0,0}, d=1}},
      },
    },
    state = {},
    getLayerById = getLayerById,
  }
end

Parallax = {
  enabled = 1.0,
  initialized = false,
  version = {major = 1, minor = 0},
  last_frame = 0,
  bank = {
    A = nil,
    B = nil
  },
  bank_owner = {
    A = false,
    B = false
  },
  tex = {},
  FILTER = {
    UNDEFINED = 0,
    BILINEAR = 1,
    NEAREST = 2
  },
  WRAP = {
    CLAMP = 0,
    CLAMP_TO_EDGE = 1,
    CLAMP_TO_BORDER = 2,
    REPEAT = 3,
    MIRRORED_REPEAT = 4,
  },
  MAX_LAYERS = 0,
  SKY_SOURCE = {
    TEXTURE = 0,
    DYNAMIC = 1,
  },
  INTERP = {
    LINEAR = 0,
    SMOOTHSTEP = 1,
    NONE = 2
  },
  -- These are the sky colors that the game uses by default, and serve as a good base to build off of or just use directly
  -- These indexes match up to sky_colors_deafult.png. It was derived from sky_colors.png in data/weather_gfx/
  SKY_DEFAULT = {
    BACKGROUND_1 = 1,
    BACKGROUND_2 = 2,
    CLOUDS_1 = 3,
    CLOUDS_2 = 4,
    MOUNTAIN_1_HIGHLIGHT = 5,
    MOUNTAIN_1_BACK = 6,
    MOUNTAIN_2 = 7,
    STORM_CLOUDS_1 = 8,
    STORM_CLOUDS_2 = 9,
    STORM_CLOUDS_3 = 10,
    STARS_ALPHA = 11,
  },
  HIGHLIGHT_ERRORS = true,
  update = update,
  pushTextures = pushTextures,
  registerTextures = registerTextures,
  registerLayers = registerLayers, 
  push = push,
  postInit = postInit,
  getBankTemplate = getBankTemplate,
}

-- tex_w            | automaticaly set to texture width
-- tex_h            | automatically set to texture height
-- scale            | Layer scale
-- alpha            | Layer transparrency
-- offset_x         | Layer horizontal offset
-- offset_y         | Layer vertical offset
-- depth            | Parallax depth. 0 = infinite distance, 1 = same as foreground
-- sky_blend        | How much the sky color should blend with the layer. 0 = no blending, 1 = full blending
-- speed_x          | Automatic horizontal movement
-- speed_y          | Automatic vertical movement
-- min_y            | Keep layers above this y position (normalized screen position)
-- max_y            | Keep layers below this y position (normalized screen position)
-- sky_index        | Index of the sky color to use
-- sky_source       | Where to get the sky color from. 0 = texture, 1 = dynamic. Can be a mix, eg. 0.5. Dynamic colors can be set via Parallax.sky.dynamic_colors
-- alpha_index      | Index of the alpha color to use. Pulls from the same list as sky_index
-- alpha_source     | Where to get the alpha color from. 0 = texture, 1 = dynamic. Can be a mix, eg. 0.5
-- alpha_blend      | How much the alpha color should blend with the layer. 0 = no blending, 1 = full blending. Dynamic colors can be set via Parallax.sky.dynamic_colors
Parallax.layer_defaults = {
  tex_w = 0, tex_h = 0,
  scale = 1.0, alpha = 1, offset_x = 0, offset_y = 0, depth = 0, sky_blend = 0.0, speed_x = 0, speed_y = 0, min_y = -9999999, max_y = 9999999,
  sky_index = Parallax.SKY_DEFAULT.MOUNTAIN_2, sky_source = Parallax.SKY_SOURCE.TEXTURE, alpha_index = Parallax.SKY_DEFAULT.STARS_ALPHA, alpha_source = Parallax.SKY_SOURCE.TEXTURE,
  alpha_blend = 0.0
}
-- Stash globals
Parallax.SetContent = ModTextFileSetContent
Parallax.GetContent = ModTextFileGetContent
Parallax.SetUniform = GameSetPostFxParameter
Parallax.SetTexture = GameSetPostFxTextureParameter
Parallax.GetFrame = GameGetFrameNum
Parallax.GetSetting = ModSettingGet
Parallax.SetSetting = ModSettingSet
Parallax.RemoveSetting = ModSettingRemove
Parallax.MakeEditable = ModImageMakeEditable
Parallax.GetWorldStateEntity = GameGetWorldStateEntity
Parallax.EntityGetFirstComponent = EntityGetFirstComponent
Parallax.ComponentGetValue2 = ComponentGetValue2
Parallax.FileExists = ModDoesFileExist
Parallax.DoFileOnce = dofile_once

return Parallax