local utilities = "\n(//[%s-]+\n// utilities)"

local inject = {
  version = {
    pattern = "#version %d+",
    replacement = "#version 330"
  },
  patch = {
    pattern = "gl_TexCoord%[0%]",
    replacement = "tex_coord_"
  },
  global_uniforms = {
    pattern = utilities,
    replacement = [[

      uniform vec4 parallax_world_state;
      uniform vec4 parallax_layer_count_A;
      uniform vec4 parallax_layer_count_B;
      uniform sampler2D tex_parallax_sky_A;
      uniform sampler2D tex_parallax_sky_B;
    ]]
  },
  sky_uniforms = {
    pattern = utilities,
    replacement = [[

      uniform vec4 parallax_sky_gradient_%s;
      uniform vec4 parallax_sky_gradient_index_%s;
      uniform vec4 parallax_sky_gradient_color_%s_1;
      uniform vec4 parallax_sky_gradient_color_%s_2;
    ]]
  },
  layer_uniforms = {
    pattern = utilities,
    replacement = [[

      uniform sampler2D tex_parallax_%s;
      uniform vec4 parallax_sky_color_%s;
      uniform vec4 parallax_alpha_color_%s;
      uniform vec4 parallax_%s_1;
      uniform vec4 parallax_%s_2;
      uniform vec4 parallax_%s_3;
      uniform vec4 parallax_%s_4;
    ]]
  },
  functions = {
    pattern = utilities,
    replacement = [[

      // Pixel art smoothing
      vec2 smooth_pixel(vec2 uv, vec2 tex_size_pixels) {
        uv *= tex_size_pixels;
        uv = floor(uv) + smoothstep(0.0, 1.0, fract(uv) / fwidth(uv)) - 0.5;
        uv /= tex_size_pixels;
        return uv;
      }

      vec3 get_sky_color(sampler2D tex, float index){
        float texel_height = textureSize(tex, 0).y;
        float sample_height = 1.5 + (index - 1.0) * 3.0;
        vec2 uv = vec2(parallax_world_state.x, sample_height / texel_height);
        return texture2D(tex, uv).rgb;
      }

      vec4 get_layer_color(vec2 uv, sampler2D tex, sampler2D tex_sky, vec4 values_1, vec4 values_2, vec4 values_3, vec4 values_4, vec4 dynamic_sky_color, vec4 dynamic_alpha_color){
        float viewport_aspect =  world_viewport_size.y/world_viewport_size.x;
        vec2 texture_size_texels = textureSize(tex, 0).xy;
        float texture_aspect = texture_size_texels.y / texture_size_texels.x;
        vec2 pixel_size = vec2(427.0, 242.0);
      
        vec2 cam = camera_pos.xy;
        cam.x *= viewport_aspect;
      
        float scale = texture_size_texels.y / world_viewport_size.y * values_1.x;
      
        vec2 offset = values_1.zw;
        float depth = values_2.x;
        vec2 speed = values_2.zw;
      
        depth = 1.0 - depth; // Depth as a measure of distance from the camera makes more sense
      
        depth /= pixel_size.y;
        
        vec2 scroll = time * speed;
        vec2 pos = cam.xy * depth;
      
        // PARALLAX_INJECT_UV_PRE
      
        pos += offset;
        pos.y = clamp(pos.y, values_3.z, values_3.w);
        uv /= scale;
        uv += (pos + scroll) / scale; // Apply scale, offset, camera parallax and scrolling
      
        // Correct for texture aspect
        uv.x *= texture_aspect;
        uv.x /= viewport_aspect;
        
        uv.y = clamp(uv.y, 0.0, 1.0);
        uv.x = fract(uv.x); // Repeat textures horizontally
      
        // PARALLAX_INJECT_UV_POST
      
        uv = smooth_pixel(uv, texture_size_texels ); // Pixel art filter
        uv = clamp(uv, (1/texture_size_texels)*0.5, 1.0 - (1/texture_size_texels)*0.5); // Remove seams on repeating textures
      
        vec4 color = texture2D(tex, uv);
      
        color.a *= values_1.y; 	// Apply alpha
        vec3 sky_color = get_sky_color(tex_sky, values_3.x); 	// Get sky texture color
        sky_color = mix(sky_color, dynamic_sky_color.rgb, values_3.y); 	// Mix with dynamic color
        vec3 alpha_color = get_sky_color(tex_sky, values_4.y); 	// Get alpha color
        alpha_color = mix(alpha_color, dynamic_alpha_color.rgb, values_4.z); 	// Mix with dynamic alpha color
        float luminosity = sqrt(min(1.0, dot(alpha_color, vec3(0.299, 0.587, 0.114) * 1.0))); 	// Calculate luminosity for the alpha blend
        vec3 colorBlend = mix(color.rgb, sky_color, values_2.y); 	// Calculate color blend
        float alphaBlend = color.a * luminosity; 	// Calculate alpha blend
        alphaBlend = mix(color.a, alphaBlend, values_4.x); 	// Apply alpha blend amount
        color.rgb = colorBlend;
        color.a = alphaBlend;
      
        // PARALLAX_INJECT_POST
      
        // Show layer errors
        vec4 error = (int(mod(gl_FragCoord.x / 16.0, 2.0)) + int(mod(gl_FragCoord.y / 16.0, 2.0))) %% 2 == 0 ? vec4(1.0, 0.0, 1.0, 1.0) : vec4(0.0, 0.0, 0.0, 1.0);
        color = mix(color, error, values_4.w * (1.0 - step(color.a, 0.0)));
      
        return color;
      }

      vec3 get_sky_gradient(sampler2D tex_sky, vec4 sky_gradient_index, vec4 sky_gradient, vec4 sky_gradient_color_1, vec4 sky_gradient_color_2){
        vec3 sky_color_1 = get_sky_color(tex_sky, sky_gradient_index.x);
        vec3 sky_color_2 = get_sky_color(tex_sky, sky_gradient_index.y);
        vec3 color_texture = mix(sky_color_1, sky_color_2, smoothstep(sky_gradient.z, sky_gradient.w, tex_coord_.y));
        vec3 color_dynamic = mix(sky_gradient_color_1.rgb, sky_gradient_color_2.rgb, smoothstep(sky_gradient.z, sky_gradient.w, tex_coord_.y));
        return mix(color_texture, color_dynamic, sky_gradient.x);
      }
    ]]
  },
  bank_A = {
    pattern = utilities,
    replacement = [[
      vec3 get_background_color_A(vec2 uv){
        uv.y = 1.0 - uv.y;
        vec3 color = get_sky_gradient(tex_parallax_sky_A, parallax_sky_gradient_index_A, parallax_sky_gradient_A, parallax_sky_gradient_color_A_1, parallax_sky_gradient_color_A_2);

        while(true){
        // PARALLAX_INJECT_LAYERS
        break;
        }
      
        return color;
      }
    ]]
  },
  bank_B = {
    pattern = utilities,
    replacement = [[
      vec3 get_background_color_B(vec2 uv){
        uv.y = 1.0 - uv.y;
        vec3 color = get_sky_gradient(tex_parallax_sky_B, parallax_sky_gradient_index_B, parallax_sky_gradient_B, parallax_sky_gradient_color_B_1, parallax_sky_gradient_color_B_2);

        while(true){
        // PARALLAX_INJECT_LAYERS
        break;
        }
      
        return color;
      }
    ]]
  },
  replace_bg = {
    pattern = "\n\tvec3 color%s*=%s*texture2D%(%s*tex_bg,%s*tex_coord%s*%)%.rgb;",
    replacement = [[

      vec3 bg_orig = texture2D(tex_bg, tex_coord).rgb;
      vec3 new_bg_A = get_background_color_A(tex_coord);
      vec3 new_bg_B = get_background_color_B(tex_coord);
      vec3 new_bg = mix(new_bg_A, new_bg_B, parallax_world_state.z);
      vec3 color = mix(bg_orig, new_bg, parallax_world_state.y);
    ]]
  },
  layers = {
    pattern = "\n%s*// PARALLAX_INJECT_LAYERS",
    replacement = [[

      if(parallax_layer_count_%s.x < %s.0) break;
      vec4 layer_%s = get_layer_color(uv, tex_parallax_%s, tex_parallax_sky_%s, parallax_%s_1, parallax_%s_2, parallax_%s_3, parallax_%s_4, parallax_sky_color_%s, parallax_alpha_color_%s);
      color = mix(color, layer_%s.rgb, layer_%s.a);
    ]]
  },
  uv_pre = {
    pattern = "\n(%s*// PARALLAX_INJECT_LAYERS)"
  },
  uv_post = {
    pattern = [[(\n%s+\/\/ PARALLAX_INJECT_UV_POST)]]
  },
  post = {
    pattern = [[(\n%s+\/\/ PARALLAX_INJECT_POST)]]
  },
  effect1 = {
    replacement = [[
      float theta = time + 2.0 * 3.14159265 * uv.x;
      float perspective = cos(theta);
      float adjustedV = uv.y * (1.0 + perspective) / 2.0;
      uv = vec2(uv.x, adjustedV);
    ]]
  },
  effect2 = {
    replacement = [[
      uv = uv * 2.0 - 1.0;
      vec2 screenUV = gl_FragCoord.xy / window_size;
      uv.y += pow(   abs(screenUV.x - 0.5), 1.6   ) * (screenUV.y - 0.5) * 3.0;
      uv = (uv + 1.0) / 2.0;
    ]]
  }
}

return inject