
local helpers      = require("lain.helpers")
local beautiful    = require("beautiful")
local wibox        = require("wibox")
local gstr         = {}
local io           = { popen  = io.popen, open = io.open }
local pairs        = pairs
local math         = { fmod = math.fmod }
local table        = { unpack = table.unpack }
local string       = { match  = string.match, gmatch = string.gmatch,
                       format = string.format, sub = string.sub }
local tonumber     = tonumber
local setmetatable = setmetatable

-- widgets.fs2
local fs = {}

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

-- Unit definitions
local unit = { ["mb"] = 1024, ["gb"] = 1024^2 }

local function worker(args)
    local args      = args or {}
    local timeout   = args.timeout or 600
    local partition = args.partition or "/"
    local settings  = args.settings or function() end
    fs.fg           = args.fg or beautiful.fg_normal or "#FFFFFF"
    fs.bg           = args.bg or beautiful.bg_normal or "#020202"
    fs.font      = args.font or beautiful.font:sub(beautiful.font:find(""), beautiful.font:find(" "))
    fs.font_size = tonumber(args.font_size) or 12

    fs.widget = wibox.widget.textbox('')

    function update()
        fs_info = {}
        fs_now  = {}
        local f = io.popen("LC_ALL=C df -kP " .. partition)

        for line in f:lines() do -- Match: (size) (used)(avail)(use%) (mount)
            local s     = string.match(line, "^.-[%s]([%d]+)")
            local u,a,p = string.match(line, "([%d]+)[%D]+([%d]+)[%D]+([%d]+)%%")
            local m     = string.match(line, "%%[%s]([%p%w]+)")

            if u and m then -- Handle 1st line and broken regexp
                fs_info[m .. " size_mb"]  = string.format("%.1f", tonumber(s) / unit["mb"])
                fs_info[m .. " size_gb"]  = string.format("%.1f", tonumber(s) / unit["gb"])
                fs_info[m .. " used_p"]   = tonumber(p)
                fs_info[m .. " avail_p"]  = 100 - tonumber(p)
            end
        end

        f:close()

        fs_now.used      = tonumber(fs_info[partition .. " used_p"])  or 0
        fs_now.available = tonumber(fs_info[partition .. " avail_p"]) or 0
        fs_now.size_mb   = tonumber(fs_info[partition .. " size_mb"]) or 0
        fs_now.size_gb   = tonumber(fs_info[partition .. " size_gb"]) or 0

        widget = fs.widget
        settings()
    end

    helpers.newtimer(partition, timeout, update)
    return setmetatable(fs, { __index = fs.widget })
end

return setmetatable(fs, { __call = function(_, ...) return worker(...) end })

