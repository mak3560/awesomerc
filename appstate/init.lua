awful = require("awful")

local appstate = {}
local appsaves = {}

function appdata (ad) 
  if ad and ad.class and string.len(ad.class)>0 then
    appsaves[ad.class] = ad
  end
end

-- local filename = awful.util.getdir("config") .. "/appsaves"
local appfile = io.open(awful.util.getdir("config") .. "/appsaves", "r")
if appfile then
  local adat = appfile:read("*all")
  if string.len(adat)>0 then
   local func, err = load(adat)
    if func then    -- func()
      local ret,err = pcall(func)
      if not ret then
        naughty.notify({ position="top_right", title="Load appsaves error:", 
                text="Error calling func: " .. tostring(err) })
      end
    end
  end
  appfile:close()
end

function appstate.manage (c, startup)
  -- Enable sloppy focus
  c:connect_signal("mouse::enter", function(c)
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
      and awful.client.focus.filter(c) then
        client.focus = c
    end 
  end)

  if not startup then
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- awful.client.setslave(c)
    -- Put windows in a smart way, only if they does not set an initial position.
    --if not c.size_hints.user_position and not c.size_hints.program_position then
    --  awful.placement.no_overlap(c)
    --    awful.placement.no_offscreen(c)
    --end
	
    local geo = c:geometry()
    local class_instance = ""

    if c.instance and string.len(c.instance)>0 then
      class_instance = c.class .. "_" .. c.instance
    else
      class_instance = c.class
    end

    local hint_user_position = false
    local hint_user_size = false
    local hints = awful.client.property.get(c, "hints")

    if c.size_hints.user_position or c.size_hints.program_position then
      hint_user_position = true
    end
    if c.size_hints.user_size or c.size_hints.program_size then
      hint_user_size = true
    end
    
    if hints then
      if hints.user_position then hint_user_position = true end
      if hints.nohint_position then hint_user_position = false end
      if hints.user_size then hint_user_size = true end
      if hints.nohint_size then hint_user_size = false end
      -- naughty.notify({text = c.class.." nohints: "..tostring(c.hints.nohint_position) })
    end
    
	  if not hint_user_position and c.type == "normal" and not c.modal then
      --naughty.notify({text = "I am "..c.class})
	    if appsaves[class_instance] then
		    geo.x = appsaves[class_instance].x
		    geo.y = appsaves[class_instance].y
      elseif appsaves[c.class] then
        geo.x = appsaves[c.class].x
		    geo.y = appsaves[c.class].y
      else
		    geo.x = screen[1].geometry.width/2 - geo.width/2
		    geo.y = 20;
	    end 
	  end
	
	  if not hint_user_size and c.type == "normal" and not c.modal then
	    if appsaves[class_instance] then
		    geo.width = appsaves[class_instance].width
		    geo.height = appsaves[class_instance].height
      elseif appsaves[c.class] then
		    geo.width = appsaves[c.class].width
		    geo.height = appsaves[c.class].height
	    end
	  end
	  c:geometry(geo)
  end
end

function appstate.unmanage (c)
  if c.class and string.len(c.class)>0 and c.type == "normal" and not c.modal then
    local geo = c:geometry();
    if c.instance and string.len(c.instance)>0 then
      local class_instance = c.class .. "_" .. c.instance
      appsaves[class_instance] = { class=class_instance, x = geo.x, y = geo.y,
          width = geo.width, height = geo.height }
    else
      appsaves[c.class] = { class=c.class, x = geo.x, y = geo.y, 
          width = geo.width, height = geo.height }
    end

    local appfile = io.open(awful.util.getdir("config") .. "/appsaves","w")
    if appfile then
      local adat = ""
	    for k,v in pairs(appsaves) do
	      adat = adat .. string.format(
	        "appdata { class='%s', x=%d, y=%d, width=%d, height=%d }\n",
	        v.class, v.x, v.y, v.width, v.height)
      end
	    appfile:write(adat)
      appfile:close()
    end
  end
end

return appstate
