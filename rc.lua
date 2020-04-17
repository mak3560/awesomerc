-- Standard awesome library
gears = require("gears")
awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
require("awful.remote")
local wibox = require("wibox")
local beautiful = require("beautiful")
naughty = require("naughty")
local lain    = require("lain")
local alttab = require("alttab")
local quake = require("quake")
-- lortracker = require("lortracker.tracker")
local mutile = require("layouts.mutile2")
local magnifier = require("layouts.magnifier2")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ title = "Oops, there were errors during startup!",
    font="Liberation Sans", border_width=2, border_color="#CB3837",
    bg="#F4F4F2", fg="#666666", timeout=0, text=awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ title = "Oops, an error happened!", timeout=0,
        font="Liberation Sans", border_width=2, border_color="#CB3837",
        bg="#F4F4F2", fg="#666666", text=err })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- localization
os.setlocale(os.getenv("LANG"))
-- awful.mouse.snap.edge_enabled = false
-- awful.mouse.snap.client_enabled = false
local MHOME = os.getenv("HOME")

-- Themes define colours, icons, font and wallpapers.
local theme = "zenburn"
beautiful.init(MHOME .. "/.config/awesome/themes/" .. theme .. "/theme.lua")
theme = beautiful.get()
-- This is used later as the default terminal and editor to run.
terminal = "xterm"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"
appkey = "Menu"
altkey = "Mod1"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    lain.layout.uselessfair,
    magnifier,
    mutile.first,
    mutile.second,
    mutile.third,
    mutile.fourth,
    mutile.feefth,
    mutile.sixez
}
-- }}}

--- {{{ Wallpaper
local function set_wallpaper(s)
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end
-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)
--- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {
    names  = { "web", "vweb", "work", "media", "term" },
    layout = { layouts[1], layouts[1], layouts[7], layouts[1], layouts[9] }
}
-- }}}

-- {{{ Freedesktop Menu
--require("freedesktop/freedesktop")
menu_items = {}
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end } 
}

local icon_sys_path = "/usr/share/icons/Numix/22/actions/"
local icon_gapp_path = "/usr/share/icons/gnome/22x22/apps/"
local icon_app_path = "/usr/share/icons/hicolor/22x22/apps/"

powermenu = {
   {"Сон", "systemctl suspend", icon_sys_path.."system-suspend.svg"},
   -- {"Анабиоз", "systemctl hibernate", icon_sys_path.."system-suspend-hibernate.svg"},
   {"Перезагрузка", "systemctl reboot", icon_sys_path.."system-reboot.svg" },
   {"Выключить", "systemctl poweroff", icon_sys_path.."system-shutdown.svg" }
}

table.insert(menu_items, {"awesome", myawesomemenu, beautiful.awesome_icon})
table.insert(menu_items, {"PCmanFM", "pcmanfm", icon_gapp_path.."file-manager.png"})
table.insert(menu_items, {"Notepad", "mousepad", icon_gapp_path.."text-editor.png"})
table.insert(menu_items, {"Deadbeef", "deadbeef", icon_app_path.."deadbeef.png"})
table.insert(menu_items, {"SMplayer", "smplayer", icon_app_path.."smplayer.png"})
table.insert(menu_items, {"Terminal", "xfce4-terminal", icon_gapp_path.."terminal.png"})
table.insert(menu_items, {"Выключение", powermenu, icon_sys_path.."system-shutdown.svg"})
-- table.insert(menu_items, {"Сон", "systemctl suspend", icon_sys_path.."system-suspend.svg"})
-- table.insert(menu_items, {"Анабиоз", "systemctl hibernate", icon_sys_path.."system-suspend-hibernate.svg" })
-- table.insert(menu_items, {"Перезагрузка", "systemctl reboot", icon_sys_path.."system-reboot.svg" })
-- table.insert(menu_items, {"Выключить", "systemctl poweroff", icon_sys_path.."system-shutdown.svg" })

mymainmenu = awful.menu.new({ items = menu_items }) 
-- }}}

-- {{{ Wibox
local markup = lain.util.markup
-- CPU
--cpuicon = wibox.widget.imagebox()
--cpuicon:set_image(beautiful.widget_cpu)
--cpuwidget = lain.widgets.cpu({
--    settings = function()
--        widget:set_markup(markup("#e33a6e", cpu_now.usage .. "% "))
--    end
--})
-- Coretemp
local tempicon = wibox.widget.imagebox(beautiful.widget_temp)
local hwdevice = ""
local tfile = io.open("/sys/class/hwmon/hwmon0/name", "r")
if tfile then
  local tname = tfile:read("*a"):gsub('\n*$','')
  if tname == "k10temp" then
    hwdevice = "/sys/class/hwmon/hwmon0/temp1_input"
  end
  tfile:close()
else
  tfile = io.open("/sys/class/hwmon/hwmon1/name", "r")
  if tfile then
    local tname = tfile:read("*a"):gsub('\n*$','')
    if tname == "k10temp" then
      hwdevice = "/sys/class/hwmon/hwmon1/temp1_input"
    end
    tfile:close()
  end
end

--local tw = require("widgets.temp2")
local tempwidget = nil
if string.len(hwdevice) > 0 then
  tempwidget = lain.widgets.temp({ tempfile = hwdevice,
    settings = function()
        widget:set_markup(markup(theme.fg_red,
            string.format('%.1f', coretemp_now) .. "°C "))
    end
})
else
  tempwidget = wibox.widget.textbox()
  tempwidget:set_markup(markup(theme.fg_red, "0.0°C "))
end
-- all temperatures
local tempinfo = require("showinfo.tempinfo")
tempinfo:attach(tempwidget, { script="alltemp2",
  bg_header='#768AA7', fg_header='#FAFAFA',
  fg_cells='#4D515A', bg_line1='#FAFAFA', bg_line2='#F1F1F1',
      add_width=20, DEBUG=false })

-- MEM
local memicon = wibox.widget.imagebox(beautiful.widget_mem)
local memwidget = lain.widgets.mem({
    settings = function()
        widget:set_markup(markup(theme.fg_green, mem_now.used .. "M "))
    end
})
local meminfo = require("showinfo.meminfo")
meminfo:attach(memwidget, { script="meminfo",
  bg_header='#768AA7', fg_header='#FAFAFA',
  fg_cells='#4D515A', bg_line1='#FAFAFA', bg_line2='#F1F1F1',
     headers={"Memory", "Size"}, DEBUG=false })

---- Net 
--netdownicon = wibox.widget.imagebox(beautiful.widget_netdown)
----netdownicon.align = "middle"
--netdowninfo = wibox.widget.textbox()
--netupicon = wibox.widget.imagebox(beautiful.widget_netup)
----netupicon.align = "middle"
--netupinfo = lain.widgets.net({ iface = "enp4s0",
--    settings = function()
--        widget:set_markup(markup("#e54c62", net_now.sent .. " "))
--        netdowninfo:set_markup(markup("#87af5f", net_now.received .. " "))
--    end
--})

-- Create a Taskwarrior widget
-- require('taskwarrior')
-- mytaskwarrior = taskwarrior.create_widget(1)

-- Textclock
local clockicon = wibox.widget.imagebox(beautiful.widget_clock)
local mytextclock = wibox.widget.textclock(markup(theme.fg_yellow, "%A ")..markup(theme.fg_yellow, "%H:%M "))
--mytextclock = awful.widget.textclock(markup("#7788af", "%A %d %B ") .. markup("#de5e1e", " %H:%M "))
-- lain.widgets.contrib.task:attach(mytextclock)
-- Calendar
lain.widgets.calendar:attach(mytextclock, { font_size=10, font="Monospace",
    icons=MHOME.."/.config/awesome/icons/cal/white/", 
    fg='#FAFAFA', bg='#4D515A' })

-- Create a systray
local mysystray = wibox.widget.systray()
local spacer = wibox.widget.textbox(" ")

-- / fs
local fs = require("widgets.fs2")
local fsicon = wibox.widget.imagebox(beautiful.widget_fs)
local fswidget = fs({font_size = 10, font="Monospace", bg=theme.fg_white, 
    fg=theme.fg_black, settings  = function()
        widget:set_markup(markup(theme.fg_blu, fs_now.used .. "% "))
    end
})
local fsinfo = require("showinfo.fsinfo")
fsinfo:attach(fswidget, { script="fsinfo", ncolumns=3,
  bg_header='#768AA7', fg_header='#FAFAFA',
  fg_cells='#4D515A', bg_line1='#FAFAFA', bg_line2='#F1F1F1',
  headers = { "Mount point", "Free", "Size"},
  headers_align = { "left", "right", "right" }, DEBUG=false })


-- Create a wibox for each screen and add it
local taglist_buttons = awful.util.table.join(
    awful.button({ }, 1, function(t) t:view_only() end),
    awful.button({ modkey }, 1, function(t)
      if client.focus then client.focus:move_to_tag(t) end end),
    awful.button({ }, 3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, function(t)
      if client.focus then client.focus:toggle_tag(t) end end),
    awful.button({ }, 5, function(t) awful.tag.viewnext(t.screen) end),
    awful.button({ }, 4, function(t) awful.tag.viewprev(t.screen) end))

local tasklist_buttons = awful.util.table.join(
    awful.button({ }, 1, function (c)
      if c == client.focus then
          c.minimized = true
      else
          -- Without this, the following
          -- :isvisible() makes no sense
          c.minimized = false
          --if not c:isvisible() then
          --    awful.tag.viewonly(c:tags()[1])
          if not c:isvisible() and c.first_tag then
            c.first_tag:view_only()
          end
          -- This will also un-minimize the client, if needed
          client.focus = c
          c:raise()
      end
    end),
    awful.button({ }, 3, function ()
        if instance then
            instance:hide()
            instance = nil
        else
            instance = awful.menu.clients({
            theme = { width = 250 }
            })
        end
    end),
    awful.button({ }, 4, function ()
        awful.client.focus.byidx(1)
        if client.focus then client.focus:raise() end
    end),
    awful.button({ }, 5, function ()
        awful.client.focus.byidx(-1)
        if client.focus then client.focus:raise() end
    end))

awful.screen.connect_for_each_screen(function(s)
  -- Wallpaper
  set_wallpaper(s)
  -- Each screen has its own tag table.
  awful.tag(tags.names, s, tags.layout)
  -- quakeconsole
  s.quakeconsole = quake({ terminal=terminal, height=0.65, width=0.55, screen=s })

  -- Create a promptbox for each screen
  s.mypromptbox = awful.widget.prompt()
  -- We need one layoutbox per screen.
  s.mylayoutbox = awful.widget.layoutbox(s)
  s.mylayoutbox:buttons(awful.util.table.join(
    awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
    awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
    awful.button({ }, 5, function () awful.layout.inc(layouts, 1) end),
    awful.button({ }, 4, function () awful.layout.inc(layouts, -1) end)))
  -- Create a taglist widget
  s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist_buttons)

  -- Create a tasklist widget
  s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags,
      tasklist_buttons, { height=18 } ) -- { bg_focus = theme.bg_focus, shape = gears.shape.rectangle, 
      -- shape_border_width = 1, shape_border_color="#768DAB", align = "center" })
  --s.mytasklist.beautiful.tasklist_shape = gears.shape.rectangle(1, 
  --      s.mytasklist.width, s.mytasklist.height)

  -- Create the wibox  #88A3C6 border_width=1, border_color="#44474F", bgimage=theme.wibar_bgimage
  s.mywibox = awful.wibox({ position = "top", screen = s, height=18,
                              border_width=1, border_color="#44474F" })

  -- Widgets that are aligned to the left
  local left_layout = wibox.layout.fixed.horizontal()
  left_layout:add(s.mytaglist)
  left_layout:add(s.mypromptbox)

  -- Widgets that are aligned to the right
  local right_layout = wibox.layout.fixed.horizontal()
  right_layout:add(wibox.widget.systray())
  right_layout:add(spacer)
  --right_layout:add(netdownicon)
  --right_layout:add(netdowninfo)
  --right_layout:add(netupicon)
  --right_layout:add(netupinfo)
  --right_layout:add(cpuicon)
  --right_layout:add(cpuwidget)   
  --right_layout:add(mytaskwarrior)
  right_layout:add(clockicon)
  right_layout:add(mytextclock)
  right_layout:add(memicon)
  right_layout:add(memwidget) 
  right_layout:add(fsicon)
  right_layout:add(fswidget)
  --   right_layout:add(netwidget)
  right_layout:add(tempicon)
  right_layout:add(tempwidget)
  right_layout:add(s.mylayoutbox)

  -- Now bring it all together (with the tasklist in the middle)
  local layout = wibox.layout.align.horizontal()
  layout:set_left(left_layout)
  layout:set_middle(s.mytasklist)
  layout:set_right(right_layout)

  s.mywibox:set_widget(layout)
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end)
    -- awful.button({ }, 5, awful.tag.viewnext),
    -- awful.button({ }, 4, awful.tag.viewprev)
))
-- }}}

-- {{{ My functins
function usefuleval(s)
  local f, err = loadstring(s);
  --if not f then
	--f, err = loadstring(s);
  --end
  if f then
	  setfenv(f, _G);
	  local ret = { pcall(f) };
	  if ret[1] then
	    -- Ok
	    table.remove(ret, 1)
	    local highest_index = #ret;
	    for k, v in pairs(ret) do
		    if type(k) == "number" and k > highest_index then
		      highest_index = k;
		    end
		    ret[k] = select(2, pcall(tostring, ret[k])) or "<no value>";
	    end
	    -- Fill in the gaps
	    for i = 1, highest_index do
		    if not ret[i] then
		      ret[i] = "nil"
		    end
	    end
	    local rettext = ""
	    if highest_index > 0 then
		    rettext = awful.util.escape("Result"..(highest_index > 1 and "s" or "")..": "..tostring(table.concat(ret, ", ")));
	    else
		    rettext = "Result: Nothing";
	    end
	    naughty.notify({ title="Lua:", text=rettext })
	  else
	    err = ret[2];
	  end
  end
  if err then
	  naughty.notify({title="Lua:",text=awful.util.escape("Error: "..tostring(err))})
  end
end

do
    local conky = nil

    function get_conky(default)
        if conky and conky.valid then
            return conky
        end

        conky = awful.client.iterate(function(c) return c.class == "Conky" end)()
        return conky or default
    end

    function raise_conky()
        get_conky({}).ontop = true
    end

    function lower_conky()
        get_conky({}).ontop = false
    end

    local t = timer({ timeout = 0.1 })
    t:connect_signal("timeout", function()
        t:stop()
        lower_conky()
    end)
    function lower_conky_delayed()
        t:again()
    end

    function toggle_conky()
        local conky = get_conky({})
        conky.ontop = not conky.ontop
    end
end

-- lortimer = timer({timeout=60})
-- lortimer:connect_signal("timeout", lortracker.update)
-- lortimer:start()
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,     }, "Left",   awful.tag.viewprev ),
    awful.key({ modkey,     }, "Right",  awful.tag.viewnext ),
    awful.key({ modkey,     }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,     }, "j",
      function ()
        awful.client.focus.byidx( 1)
        if client.focus then client.focus:raise() end
      end),
    awful.key({ modkey,     }, "k",
      function ()
        awful.client.focus.byidx(-1)
        if client.focus then client.focus:raise() end
      end),
    -- awful.key({ modkey,     }, "w", function () mymainmenu:show() end),

    -- Layout manipulation
    awful.key({modkey, "Shift"  },"j", function () awful.client.swap.byidx(  1)    end),
    awful.key({modkey, "Shift"  },"k", function () awful.client.swap.byidx( -1)    end),
    awful.key({modkey, "Control"},"j", function () awful.screen.focus_relative( 1) end),
    awful.key({modkey, "Control"},"k", function () awful.screen.focus_relative(-1) end),
    awful.key({modkey,          },"u", awful.client.urgent.jumpto),
    --awful.key({ modkey,           }, "Tab",
    --    function ()
    --        awful.client.focus.history.previous()
    --        if client.focus then
    --            client.focus:raise()
    --        end
    --    end),
    awful.key({ "Mod1", }, "Tab", function ()
        alttab.switch(1, "Alt_L", "Tab", "ISO_Left_Tab") end),
    awful.key({ "Mod1", "Shift"}, "Tab", function ()
        alttab.switch(-1, "Alt_L", "Tab", "ISO_Left_Tab") end),
    -- Standard program
    awful.key({ modkey, }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Control" }, "q", awesome.quit),
    --awful.key({ modkey, }, "l",  function () awful.tag.incmwfact( 0.05)    end),
    --awful.key({ modkey, }, "h",  function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift" }, "h", function () awful.tag.incnmaster( 1)  end),
    awful.key({ modkey, "Shift" }, "l", function () awful.tag.incnmaster(-1)  end),
    awful.key({ modkey, "Control" }, "h", function () awful.tag.incncol( 1)   end),
    awful.key({ modkey, "Control" }, "l", function () awful.tag.incncol(-1)   end),
    awful.key({ modkey,     }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"},"space",function () awful.layout.inc(layouts,-1) end),
    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    --awful.key({ modkey }, "r", function () awful.screen.focused().mypromptbox:run() end),
    awful.key({ modkey }, "x",
      function ()
          awful.prompt.run({ prompt = "Lua: ",
          textbox = awful.screen.focused().mypromptbox.widget,
          exe_callback = usefuleval,
          history_path = awful.util.get_cache_dir() .. "/history_eval" })
      end),
    -- Copy to clipboard
    awful.key({ modkey }, "c", function () os.execute("xsel -po | xsel -ib") end),
    --awful.key({ modkey }, "v", function () os.execute("xsel -ob") end),
    awful.key({ modkey }, "m", function () show_mbar() end),

    -- My keys
    -- awful.key({ appkey }, "g", function() awful.util.spawn("gvim") end),
    awful.key({ "Mod1" }, "F1", function()
        for s in screen do
            s.mywibox.visible = not s.mywibox.visible
        end end),
    awful.key({ "Mod1" }, "F2", function() awful.spawn("rofi -show run") end),
    --awful.key({ "Mod1" }, "F2", function() awful.util.spawn("xfce4-appfinder") end),
    awful.key({ modkey }, "n", function() awful.spawn("leafpad") end),
    awful.key({ modkey }, "r", function() awful.spawn(MHOME .. "/run-ff-nightly.sh") end),
    awful.key({ modkey }, "f", function() awful.spawn(MHOME .. "/run-firefox.sh") end),
    awful.key({ modkey }, "o", function() awful.spawn(MHOME .. "/run-opera.sh") end),
    awful.key({ modkey }, "g", function() awful.spawn(MHOME .. "/run-chrome.sh") end),
    awful.key({ }, "XF86WWW", function() awful.spawn(MHOME .. "/run-opera.sh") end),
    awful.key({ modkey }, "s", function() awful.spawn("smplayer") end),
    awful.key({ modkey }, "p", function() awful.spawn("pcmanfm") end),
    -- awful.key({ modkey }, "l", function() awful.spawn("luakit") end),
    awful.key({ modkey }, "d", function() awful.spawn("deadbeef") end),
    -- awful.key({ modkey }, "s", function() awful.spawn("MHOME/run-slimjet.sh") end),
    awful.key({ modkey }, "t", function() awful.spawn("transmission-gtk") end),
    -- awful.key({ modkey }, "v", function() awful.spawn("MHOME/run-vivaldi.sh") end),
    awful.key({ modkey }, "h", function() awful.spawn("sakura -e htop") end),
    awful.key({ modkey }, "b", function() awful.spawn("leafpad " .. MHOME .. "/text-buffer") end),
    awful.key({ modkey }, "q", function() awful.spawn("oblogout") end),
    --awful.key({ modkey }, "a", function () scratch.pad.toggle() end),
    awful.key({ modkey }, "Print", function() awful.spawn("gscreenshot") end),
    awful.key({ "Control"}, "F1", function () awful.screen.focused().quakeconsole:toggle() end),
    --awful.key({}, "F2", function() raise_conky() end, function() lower_conky_delayed() end)
    awful.key({"Control"}, "F2", function () if(screen[1].twibox) then
        local mp=mouse.coords()
        screen[1].twibox:geometry({x=mp.x, y=mp.y})
        screen[1].twibox.visible=true end end),
    awful.key({"Control"}, "F3", function() if(screen[1].twibox) then
        screen[1].twibox.visible=false end end)
)

clientkeys = awful.util.table.join(
  --awful.key({ modkey, }, "f", function (c) c.fullscreen = not c.fullscreen  end),
  awful.key({ modkey, "Shift"  }, "c",      function (c) c:kill() end),
  awful.key({ modkey, "Control"}, "space",  awful.client.floating.toggle ),
  awful.key({ modkey, "Control"}, "Return", function (c) c:swap(awful.client.getmaster()) end),
  awful.key({ "Mod1" }, "F4", function(c) c.maximized = not c.maximized end)
  -- awful.key({ modkey,          }, "o", function (c) c:move_to_screen() end),
  --awful.key({ modkey,          }, "t", function (c) c.ontop = not c.ontop end),
  --awful.key({ modkey,          }, "n", function (c)
  --    -- The client currently has the input focus, so it cannot be
  --    -- minimized, since minimized clients can't have the focus.
  --    c.minimized = true
  --end)
  --awful.key({ modkey     }, "m",
  --  function (c)
  --    c.maximized_horizontal = not c.maximized_horizontal
  --    c.maximized_vertical   = not c.maximized_vertical
  --  end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
  globalkeys = awful.util.table.join(globalkeys,
    -- View tag only.
    awful.key({ modkey }, "#" .. i + 9,
      function ()
        local screen = awful.screen.focused()
        local tag = screen.tags[i]
        if tag then tag:view_only() end
      end),
    -- Toggle tag display.
    awful.key({ modkey, "Control" }, "#" .. i + 9,
      function ()
        local screen = awful.screen.focused()
        local tag = screen.tags[i]
        if tag then awful.tag.viewtoggle(tag) end
      end),
    -- Move client to tag.
    awful.key({ modkey, "Shift" }, "#" .. i + 9,
      function ()
        if client.focus then
          local tag = client.focus.screen.tags[i]
          if tag then client.focus:move_to_tag(tag) end
        end
      end),
    -- Toggle tag on focused client.
    awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
      function ()
        if client.focus then
          local tag = client.focus.screen.tags[i]
          if tag then client.focus:toggle_tag(tag) end
        end
      end))
end

clientbuttons = awful.util.table.join(
  awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
  awful.button({ modkey }, 1, awful.mouse.client.move),
  awful.button({ modkey }, 3, awful.mouse.client.resize))

mousebuttons = awful.util.table.join(
  awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
  awful.button({ modkey }, 1, awful.mouse.client.move),
  awful.button({ }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
  -- All clients will match this rule.
  { rule = {}, 
      properties = {
        border_width = beautiful.border_width,
        border_color = beautiful.border_normal,
	      switchtotag = true, raise = true,
        focus = awful.client.focus.filter, 
        keys = clientkeys, buttons = clientbuttons, 
        screen = awful.screen.preferred,
        placement = awful.placement.no_offscreen }},
  { rule_any = { class = {"Gimp"}}, properties = { floating=true }},
  { rule_any = { class = {"Firefox", "slimjet-user", "Opera",
                          "Chromium-browser", "vivaldi-stable"}}, 
	    properties = { screen=1, tag = "web" }},
  { rule = { class = "Opera" }, properties = { floating = true, 
        callback = function(c) if not c.hints then c.hints = {} end
                     c.hints.nohint_size = true
                     c.hints.nohint_position = true end }},
  { rule_any = { class = {"URxvt", "XTerm"}}, properties = { floating=false }},
  { rule =     { class = "Stjerm" },
      properties = { floating = true, ontop = false,
        callback = function(c) if not c.hints then c.hints = {} end
                      c.hints.user_size = true
                      c.hints.user_position = true end }},
  { rule_any = { class = {"Pcmanfm", "smplayer", "Deadbeef"}},
	    properties = { tag = "media" }},
  { rule_any = { class = {"MPlayer", "gpicview"}},
      properties = { floating = true, buttons = mousebuttons,
        callback = function(c) if not c.hints then c.hints = {} end
                      c.hints.user_size = true end }},
  { rule =     { class = "Basic-gtk" },
      properties = { floating = true,
        callback = function(c) if not c.hints then c.hints = {} end
                      c.hints.user_size = true end }}, 
  { rule =     { class = "mpv" },
      properties = { floating = true,
        callback = function(c)  local geo = c:geometry()
                      geo.x = screen[1].geometry.width/2 - geo.width/2
                      geo.y = 50
                      c:geometry(geo)
                      if not c.hints then c.hints = {} end
                      c.hints.user_position = true end }},
  { rule = { class = "Oblogout" },
      properties = { floating = true, ontop = true,
        callback = function(c) if not c.hints then c.hints = {} end
                      c.hints.nohint_position=true end }},
  { rule = { class = "Firefox", instance = "Devtools" },
      properties = { floating = true, ontop = true,
        callback = function(c) if not c.hints then c.hints = {} end
                      c.hints.nohint_size = true
                      c.hints.nohint_position = true end }},
  { rule = { type = "dialog" },
      properties = { ontop=false,
        callback = function(c)  local geo = c:geometry()
                      geo.x = screen[1].geometry.width/2 - geo.width/2
                      geo.y = 30
                      c:geometry(geo) end }},
  { rule = { modal = true },
      properties = { ontop=false,
        callback = function(c)  local geo = c:geometry()
                      geo.x = screen[1].geometry.width/2 - geo.width/2
                      geo.y = 150
                      c:geometry(geo) end }},
  { rule = { class = "Conky" },
      properties = { floating = true, sticky = true, ontop = false,
                      switchtotag = false, focusable = false }}
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
local appstate = require("appstate")
client.connect_signal("manage", appstate.manage)
client.connect_signal("unmanage", appstate.unmanage)
client.connect_signal("property::fullscreen", function(c)
  if c.fullscreen then
    gears.timer.delayed_call(function() 
      if c.valid then c:geometry(c.screen.geometry) end
    end)
  end 
end)
client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

awful.spawn.with_shell('xkbcomp $DISPLAY - | egrep -v "group . = AltGr;" | xkbcomp - $DISPLAY')
--awful.util.spawn_with_shell('xmodmap ~/.Xmodmap')


