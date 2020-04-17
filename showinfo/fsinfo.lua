
local awful     = require("awful")
local beautiful = require("beautiful")
local wibox     = require("wibox")
-- local gstr      = require("gears.string")
local gstr      = {}
local io        = { popen  = io.popen, open = io.open }
local os        = { getenv = os.getenv }
local pairs     = pairs
local math      = { fmod = math.fmod }
local table     = { unpack = table.unpack }
local string    = { match  = string.match, gmatch = string.gmatch,
                       format = string.format, sub = string.sub }
local tonumber  = tonumber
local setmetatable = setmetatable

local itable = { twibox={}, tempfile="", flog = false }
local DEBUG = false

function itable:hide()
  if itable.twibox ~= nil then
    itable.twibox.visible = false
    itable.twibox = nil
    -- itable.grid.reset()
    itable.grid = nil
    for i=1,itable.ncolumns do
      if itable.header then itable.header[i] = nil end
      if itable.mrghead then itable.mrghead[i] = nil end
      if itable.bghead then itable.bghead[i] = nil end
    end
    
    if itable.sdata then
      for i=1,#itable.sdata do
        itable.sdata[i] = nil
        if itable.mrgdata then itable.mrgdata[i] = nil end
        if itable.bgdata then itable.bgdata[i] = nil end
      end
    end
  end
end

function gstr.split(str, delimiter)
    local pattern = "(.-)" .. delimiter .. "()"
    local result = {}
    local n = 0
    local lastPos = 0
    for part, pos in string.gmatch(str, pattern) do
        n = n + 1
        result[n] = part
        lastPos = pos
    end
    result[n + 1] = string.sub(str, lastPos)
    return result
end

function itable.tmplog(msg)
  if not itable.flog then
    if #itable.tempfile < 1 then
      tf = io.popen('mktemp -p /tmp itable-XXXXXXXX.log')
      itable.tempfile = tf:read('*a'):gsub('\n*$',''); tf:close()
    end  
    itable.flog = io.open(itable.tempfile, 'a')
  end
  
  if itable.flog and msg and #msg>0 then
    itable.flog:write(msg.."\n")
  --  itable.flog:close()
  end
end

function itable:show(t_out)
  -- if itable.grid then itable:hide() end
  
  if DEBUG then
     itable.tmplog("script: "..itable.script_dir..itable.script)
  end

  local f = io.popen(itable.script_dir .. itable.script)
  local stext = ""
  if f then stext = f:read("*a"); f:close()
  else return end
  
  local lines = gstr.split(stext, "\n")
  local lcnt = #lines-1
  if DEBUG then itable.tmplog("lcnt: "..tostring(lcnt)) end

  local htxt = itable.headers
  local align = itable.headers_align
  local ncols = itable.ncolumns
  local wmrg = itable.margin_w
  local hmrg = itable.margin_h
      
  if lcnt and lcnt>0 then
    itable.header  = {}
    itable.mrghead = {}
    itable.bghead  = {}
    itable.grid = wibox.widget{homogeneous=itable.homogeneous,
                  spacing=itable.spacing, layout=wibox.layout.grid}

    for c=1,ncols do
      itable.header[c] = wibox.widget{ text=htxt[c], align=align[c],
                      font=itable.font, widget=wibox.widget.textbox }
      itable.mrghead[c] = wibox.container.margin(itable.header[c],
                                              wmrg, wmrg, hmrg, hmrg)
      itable.bghead[c]  = wibox.widget{ itable.mrghead[c],
                              bg=itable.bg_header, fg=itable.fg_header,
                                  widget=wibox.container.background }
      itable.grid:add_widget_at(itable.bghead[c], 1, c)
    end
    
    itable.sdata = {}
    itable.mrgdata = {}
    itable.bgdata = {}
    local cbg = true
    local maxslen = { len=1, id={} }

    for l=1,lcnt do   
      itable.sdata[l] = {}
      itable.mrgdata[l] = {}
      itable.bgdata[l] = {}
      local data = gstr.split(lines[l], "%|")
      --if data==nil or #data<ncols then return end
      for c=1,ncols do
        itable.sdata[l][c] = wibox.widget{ align=align[c],
                          font=itable.font, widget=wibox.widget.textbox}
        itable.mrgdata[l][c] = wibox.container.margin(itable.sdata[l][c],
                                                  wmrg, wmrg, hmrg, hmrg)
        itable.bgdata[l][c] = wibox.widget{itable.mrgdata[l][c],
                  fg=itable.fg_cells, widget=wibox.container.background}
        
        if DEBUG then itable.tmplog("data["..l.."]["..c.."]: "..data[c]) end
        if cbg then itable.bgdata[l][c].bg = itable.bg_line1
        else itable.bgdata[l][c].bg = itable.bg_line2 end

        if data[c] then
          itable.sdata[l][c].text = data[c]
          if #data[c]>maxslen.len then maxslen.len=#data[c]
            maxslen.id.l = l; maxslen.id.c = c
          end
        end
        itable.grid:add_widget_at(itable.bgdata[l][c], l+1, c)
      end
      cbg = not cbg
    end
    
    local tw,_ = itable.sdata[maxslen.id.l][maxslen.id.c]:get_preferred_size(1)
    local th,_ = itable.sdata[maxslen.id.l][maxslen.id.c]:get_height_for_width(tw, 1)
    if DEBUG then
      itable.tmplog(string.format("tw: %d, th: %d, line: %d, col: %d",
                      tw, th, maxslen.id.l, maxslen.id.c))
    end

    local theight = (lcnt+1)*(hmrg*2 + th)
    local twidth = ncols*(wmrg*2 + tw)+itable.add_width
    if DEBUG then itable.tmplog("twidth:"..twidth..", theight:"..theight) end

    itable.twibox = wibox({type="notification", stretch=false, ontop=true,
        visible=false, fg=itable.fg_header, bg=itable.bg_header,
        border_color=itable.border_clr, border_width=itable.border_w})
    itable.twibox:geometry({ width = twidth, height = theight,
        x=itable.twibox.screen.workarea.width-twidth-8,
        y=itable.twibox.screen.workarea.y+4 })
    itable.twibox:set_widget(itable.grid)
    itable.grid.expand = itable.expand
    itable.twibox.visible = true
  end

  if DEBUG then itable.flog:close(); itable.flog=nil end
end

function itable:attach(widget, args)
  local args          = args
  itable.font         = args.font or beautiful.font
  itable.font_size    = tonumber(args.font_size) or 12
  itable.fg_header    = args.fg_header or "#CED1D3"
  itable.bg_header    = args.bg_header or "#4F5A5F"
  itable.border_clr   = args.border_clr or itable.bg_header
  itable.border_w     = args.border_w or 2
  itable.fg_cells     = args.fg_cells or "#637D88"
  itable.bg_line1     = args.bg_line1 or "#f7f7f4"
  itable.bg_line2     = args.bg_line2 or "#f4eed8"
  itable.margin_w     = args.margin_w or 4  -- left & right margin
  itable.margin_h     = args.margin_h or 2  -- top & bottom margin
  itable.add_width    = args.add_width or 0 -- additional width. If calculated width not enafe.
--  itable.position     = args.position or "top_right"
  itable.ncolumns     = args.ncolumns or 2    -- number of columns
  itable.headers      = args.headers or { "Source", "Temp" }
  itable.headers_align  = args.headers_align or { "left", "right" }
  itable.homogeneous  = args.homogeneous or true  -- see grid.layout docs
  itable.expand       = args.expand or true       -- see grid.layout docs
  itable.spacing      = args.spacing or 0         -- see grid.layout docs
  itable.script_dir   = args.script_dir or os.getenv("HOME").."/.config/awesome/showinfo/"
  itable.script       = args.script or "itable"
  DEBUG               = args.DEBUG or false

  widget:connect_signal("mouse::enter", function () itable:show(0) end)
  widget:connect_signal("mouse::leave", function () itable:hide() end)
end

-- return setmetatable(itable, { __call = function(_, ...) return create(...) end })
return itable

