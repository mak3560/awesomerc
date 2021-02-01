---------------------------------------------------------------------------
-- @author Uli Schlachter &lt;psychon@znc.in&gt;
-- @copyright 2009 Uli Schlachter
-- @copyright 2008 Julien Danjou
-- @release v3.5.9
---------------------------------------------------------------------------

-- Grab environment we need
local ipairs = ipairs
local math = math

-- awful.layout.suit.spiral
local mutile = {}

function do_arrange(p, kleft, kright)
    local wa = p.workarea
    local cls = p.clients
    local n = #cls
    local l_width = wa.width * kleft
    local ul_height = wa.height * 0.81
    local ur_height = wa.height * 0.76
    local r_width = wa.width * kright
    local bl_height = wa.height * 0.174
    local br_height = wa.height * 0.23
    local bw = 4
    -- if cls[1] then bw = cls[1].border_width end

    local geom = {}
    geom[1] = {}
    geom[1].x = wa.x -- + bw/2
    geom[1].y = wa.y -- + bw/2
    geom[1].h = ul_height
    geom[2] = {}
    geom[2].x = wa.x + l_width + bw*2
    geom[2].y = wa.y -- + bw/2
    geom[2].h = ur_height
    geom[3] = {}
    geom[3].x = wa.x + bw/2
    geom[3].y = wa.y + ul_height + bw*2
    geom[3].h = bl_height
    geom[4] = {}
    geom[4].x = wa.x + l_width + bw*2
    geom[4].y = wa.y + ur_height + bw
    geom[4].h = br_height
    local tn = 1

    for k, c in ipairs(cls) do
        local g = {
            x = geom[tn].x,
            y = geom[tn].y,
            height = geom[tn].h
            -- width = width - 2*c.border_width
            -- height = height - 2*c.border_width
        }
        -- if tn>2 then
        --   g.height = lheight
        -- else 
        --   g.height = height
        -- end
        if tn % 2 == 0 then
            g.width = r_width
        else
            g.width = l_width
        end
        c:geometry(g)
        tn = tn + 1
        if tn>4 then tn=1 end
    end
end

--- layouts
mutile.first = {}
mutile.first.name = "spiral"
function mutile.first.arrange(p)
    return do_arrange(p, 0.5906, 0.402)
end

mutile.second = {}
mutile.second.name = "spiral"
function mutile.second.arrange(p)
    return do_arrange(p, 0.559, 0.434)
end

mutile.third = {} --  delete this /=
mutile.third.name = "spiral"
function mutile.third.arrange(p)
    return do_arrange(p, 0.5, 0.5)
end

mutile.fourth = {}
mutile.fourth.name = "spiral"
function mutile.fourth.arrange(p)
    return do_arrange(p, 0.554, 0.44)
end

mutile.feefth = {}
mutile.feefth.name = "spiral"
function mutile.feefth.arrange(p)
    return do_arrange(p, 0.45, 0.55)
end

mutile.sixez = {}
mutile.sixez.name = "spiral"
function mutile.sixez.arrange(p)
    return do_arrange(p, 0.7, 0.5)
end

mutile.name = "spiral"
mutile.arrange = mutile.second.arrange 

return mutile

-- vim: filetype=lua:expandtab:shiftwidth=2:tabstop=4:softtabstop=2:textwidth=80
