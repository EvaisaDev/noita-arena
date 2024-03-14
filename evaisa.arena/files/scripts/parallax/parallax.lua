-- Reimplementation of the parallax background system by Alex
-- https://github.com/alex-3141/noita-parallax

Inject = dofile_once("mods/evaisa.arena/files/scripts/parallax/inject.lua")

SetContent = ModTextFileSetContent
GetContent = ModTextFileGetContent

DEBUG = false
DEBUUG_SHADER = false

local function debugPrint(msg)
  if DEBUG then
    print("[DEBUG] " .. msg)
  end
end

local function parallaxPrint(msg)
  print("[Parallax] " .. msg)
end

local function printTable(t)
  for k, v in pairs(t) do
    print(k, v)
  end
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

local function pushUniforms(time)
  local error_msg = ""
  local setUniform = GameSetPostFxParameter

  local function setLayerUniforms(bank, char)
    if bank == nil then return end
    for i, layer in ipairs(bank.layers) do

      -- Use a metatable to supply default values for missing keys
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
      if layer_error and Parallax.HIGHLIGHT_ERRORS then error_color = math.floor((GameGetFrameNum() % 60) / 30) end
  
      setUniform( "parallax_"..char.."_"..i.."_1", layer.scale, layer.alpha, layer.offset_x, layer.offset_y )
      setUniform( "parallax_"..char.."_"..i.."_2", layer.depth, layer.sky_blend, layer.speed_x, layer.speed_y )
      setUniform( "parallax_"..char.."_"..i.."_3", layer.sky_index, layer.sky_source, layer.min_y, layer.max_y)
      setUniform( "parallax_"..char.."_"..i.."_4", layer.alpha_blend, layer.alpha_index, layer.alpha_source, error_color) -- 4th param is for error state
  
    end
  end

  local tween = 0
  local mix
  if Parallax.tween_time > 0 then
    tween = Parallax.tween_timer / Parallax.tween_time -- from 1 to 0
  end

  if Parallax.bank.A == nil and Parallax.bank.B == nil then
    mix = 0
    tween = 0
  else
    if Parallax.current_bank == "B" then
      local from = Parallax.bank.A
      local to = Parallax.bank.B
      if from == nil then
        -- from nil to B
        mix = 1 - tween
        tween = 1
      else
        if to == nil then
          -- from A to nil
          mix = tween
          tween = 0
        else
          -- from A to B
          tween = 1 - tween
          mix = 1
        end
      end
    elseif Parallax.current_bank == "A" then
      local from = Parallax.bank.B
      local to = Parallax.bank.A
      if from == nil then
        -- from nil to A
        mix = 1 - tween
        tween = 0
      else
        if to == nil then
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

  -- Only update what we need to
  if tween ~= 1 then
    setLayerUniforms(Parallax.bank.A, "A")
  end
  if tween ~= 0 then
    setLayerUniforms(Parallax.bank.B, "B")
  end

  setUniform( "parallax_world_state", time % 1, mix, tween, 0.0)

  local layer_count_A = Parallax.bank.A == nil and 0 or #Parallax.bank.A.layers
  local layer_count_B = Parallax.bank.B == nil and 0 or #Parallax.bank.B.layers
  setUniform("parallax_layer_count", layer_count_A, layer_count_B, 0.0, 0.0)

  return error_msg
end

local injectShaderCode = function()
  local maxLayers = Parallax.MAX_LAYERS

  local post_final = GetContent("data/shaders/post_final.frag")

  -- Update GLSL version
  post_final = post_final:gsub(Inject.version.pattern, Inject.version.replacement, 1)

  -- Patch
  post_final = post_final:gsub(Inject.patch.pattern, Inject.patch.replacement)

  -- Global Uniforms
  post_final = post_final:gsub(Inject.global_uniforms.pattern, Inject.global_uniforms.replacement .. "\n%1", 1)

  -- Sky Uniforms
  post_final = post_final:gsub(Inject.sky_uniforms.pattern, function(capture)
    local u = ""
    local A = "A"
    local B = "B"
    u = u .. string.format(Inject.sky_uniforms.replacement, A, A, A, A)
    u = u .. string.format(Inject.sky_uniforms.replacement, B, B, B, B)
    u = u .. "\n" .. capture
    return u
  end)

  -- Layer Uniforms
  post_final = post_final:gsub(Inject.layer_uniforms.pattern, function(capture)
    local u = ""
    for i = 1, maxLayers do
      local A = "A_" .. tostring(i) 
      local B = "B_" .. tostring(i)
      u = u .. string.format(Inject.layer_uniforms.replacement, A, A, A, A, A, A, A)
      u = u .. string.format(Inject.layer_uniforms.replacement, B, B, B, B, B, B, B)
    end
    u = u .. "\n" .. capture
    return u
  end)

  -- Functions
  post_final = post_final:gsub(Inject.functions.pattern, Inject.functions.replacement .. "\n%1", 1)

  -- User defined shadercode
  -- TBD

  -- Replace background
  post_final = post_final:gsub(Inject.replace_bg.pattern, Inject.replace_bg.replacement, 1)

  -- Bank A
  post_final = post_final:gsub(Inject.bank_A.pattern, Inject.bank_A.replacement  .. "\n%1", 1)
  post_final = post_final:gsub(Inject.layers.pattern, function()
    local l = ""
    for i = 1, maxLayers do
      local A = "A_" .. tostring(i)
      l = l .. string.format(Inject.layers.replacement, "x", tostring(i), A, A, "A", A, A, A, A, A, A, A, A)
    end
    l = l .. "\n"
    return l
  end)

  -- Bank B
  post_final = post_final:gsub(Inject.bank_B.pattern, Inject.bank_B.replacement  .. "\n%1", 1)
  post_final = post_final:gsub(Inject.layers.pattern, function()
    local l = ""
    for i = 1, maxLayers do
      local B = "B_" .. tostring(i)
      l = l .. string.format(Inject.layers.replacement, "y", tostring(i), B, B, "B", B, B, B, B, B, B, B, B)
    end
    l = l .. "\n"
    return l
  end)

  if DEBUUG_SHADER then print(post_final) end

  -- Apply post_final
  SetContent("data/shaders/post_final.frag", post_final)
end

local pushTextures = function(bank)
  local setTexture = GameSetPostFxTextureParameter
  local char = Parallax.current_bank

  if bank == nil then
    setTexture( "tex_parallax_sky_" .. char, "data/parallax_fallback_sky.png", Parallax.FILTER.BILINEAR, Parallax.WRAP.REPEAT, true )
    return
  end

  for i, layer in ipairs(bank.layers) do
    setTexture( "tex_parallax_" .. char .. "_" .. i, layer.path, Parallax.FILTER.BILINEAR, Parallax.WRAP.CLAMP, true )
    debugPrint("[Parallax] Pushed texture: " .. layer.path .. " as tex_parallax_" .. char .. "_" .. i)
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

local init = function()
  if Parallax.initialized then return end
  injectShaderCode()
  parallaxPrint(string.format("Parallax v%s.%s initialized", Parallax.version.major, Parallax.version.minor))
  Parallax.initialized = true
end

local function registerTextures(textures)
  local makeEditable = ModImageMakeEditable
  for i, path in ipairs(textures) do
    local id, width, height = makeEditable( path, 0, 0 )
    if id == 0 or id == nil then
      error("Failed to load image: " .. path)
    end
    Parallax.tex[path] = {id = id, width = width, height = height}
    debugPrint("[Parallax] Registered texture: " .. path .. " with id: " .. id .. " and size: " .. width .. "x" .. height)
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
  if Parallax.current_bank == "B" then
    Parallax.bank.A = data
    Parallax.current_bank = "A"
  else
    Parallax.bank.B = data
    Parallax.current_bank = "B"
  end

  if data ~= nil then
    debugPrint("[Parallax] Pushing " .. data.id .." to bank " .. Parallax.current_bank)
  end

  pushTextures(data)

  if tween == nil then tween = 0 end

  Parallax.tween_time = tween
  Parallax.tween_timer = tween
end

local update = function()
  local frame = GameGetFrameNum()
  if Parallax.last_frame == frame then return end
  Parallax.last_frame = frame

  local world_state_entity = GameGetWorldStateEntity()
  local world_state = EntityGetFirstComponent( world_state_entity, "WorldStateComponent" )
  local time = ComponentGetValue2( world_state, "time" )
  local day = ComponentGetValue2( world_state, "day_count" )


  local bank = Parallax.bank[Parallax.current_bank]

  if bank ~= nil and bank.update ~= nil and type(bank.update) == "function" then
    bank.update(bank)
  end

  if Parallax.tween_timer > 0 then
    Parallax.tween_timer = Parallax.tween_timer - 1
  end

  local error_msg = pushUniforms(time + day)
  if error_msg ~= "" then
    print(error_msg)
  end
end

local registerLayers = function(num)
  Parallax.MAX_LAYERS = math.max(Parallax.MAX_LAYERS, num)
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
  version = {major = 0, minor = 2},
  last_frame = 0,
  -- banks are used to minimize texture swaps
  bank = {
    A = nil,
    B = nil
  },
  current_bank = "B",
  tween_time = 0,
  tween_timer = 0,
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
  init = init,
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

return Parallax