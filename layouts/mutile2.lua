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
    local width = wa.width * kleft
    local height = wa.height * 0.756
    local lwidth = wa.width * kright
    local lheight = wa.height * 0.22
    local bw = 4
    -- if cls[1] then bw = cls[1].border_width end

    local geom = {}
    geom[1] = {}
    geom[1].x = wa.x + bw/2
    geom[1].y = wa.y + bw/2
    geom[2] = {}
    geom[2].x = wa.x + width + bw*2
    geom[2].y = wa.y + bw/2
    geom[3] = {}
    geom[3].x = wa.x + bw/2
    geom[3].y = wa.y + height + bw*2
    geom[4] = {}
    geom[4].x = wa.x + width + bw*2
    geom[4].y = wa.y + height + bw*2 
    local tn = 1

    for k, c in ipairs(cls) do
        local g = {
            x = geom[tn].x,
            y = geom[tn].y
            --width = width - 2*c.border_width
            -- height = height - 2*c.border_width
        }
        if tn>2 then
          g.height = lheight
        else 
          g.height = height
        end
        if tn % 2 == 0 then
            g.width = lwidth
        else
            g.width = width
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
