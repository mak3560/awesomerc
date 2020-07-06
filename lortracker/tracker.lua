local gumbo = require "gumbo"
--local lgi = require 'lgi'
--local Notify = lgi.require('Notify')
local naughty = require("naughty")
local awful = require("awful")
-- re-map global functions
local io = { popen=io.popen, open=io.open, write=io.write }
local string = { len=string.len, gsub=string.gsub, sub=string.sub }
local table = { insert=table.insert }
local utf8 = { offset=utf8.offset, len=utf8.len }
local pairs = pairs
local ipairs = ipairs
local tostring = tostring
--local capi = { timer = timer }

local tracker = {}
local listfile = awful.util.getdir("config").."/tracker.list"

function getElemByClass(node, element)
  for n in node:walk() do
    if n.type == "element" and n.className == element then
        return n
    end
  end
end

function getElemById(node, element)
  for n in node:walk() do
    if n.type == "element" and n.id == element then
        return n
    end
  end
end

function getElemByTag(node, element)
  local lNameLow = element:lower()
  for n in node:walk() do
    if n.type == "element" and n.localName == lNameLow  and not n.className then
        return n
    end
  end
end

local npreset = { ontop=false, timeout=600, position="top_right", font="Liberation Sans",
  border_width=2, border_color="#666666", bg="#F4F4F2", fg="#666666" }
local nid = { id=0 }

function notify(msg)
  --io.write(msg)
  if nid.id>0 then
    nid = naughty.notify{text=msg, preset=npreset, replaces_id=nid.id}
  else
    nid = naughty.notify{text=msg, preset=npreset}
  end
end

local stracker = ""

function tracker.update()
  local ncount = 0
  local tr_list = {}
  stracker = ""

  local data = assert(io.popen("curl -s 'https://www.linux.org.ru/tracker/?filter=all'"))
  --local data = io.open('LOR-tracker.html')
  local document = gumbo.parse(data:read("*a"))
  --local node = document:getElementsByClassName("forum")
  local node = getElemByClass(document, "message-table")
  node = node.childNodes[4]

  for k,v in pairs(node.childNodes) do
    if tostring(v) == "<tr>" then
      local anode = getElemByTag(node.childNodes[k], "a")

      for i,d in pairs(anode.childNodes) do
        --print("  i: "..tostring(i)..", d: "..tostring(d))
        if anode.childNodes[i].data then
          text = anode.childNodes[i].data
        end
      end

      if string.len(text)>0 then
        local title = string.gsub(text, "^%s+", "")
        --print(title)
        --sfile:write(title)
        if utf8.len(title)>60 then
          local sp = utf8.offset(title, 60)
          if sp>1 then title = string.sub(title, 1, sp-1)..".." end
        end
        stracker = stracker .. title .. "\n"
        table.insert(tr_list, title)
        ncount = ncount + 1
        if ncount>=8 then break end
      end
    end
  end

  stracker = string.sub(stracker, 1, string.len(stracker)-1)

  local sfile = io.open(listfile, "r")
  if sfile then
    local line = sfile:read()
    sfile:close()

    if line ~= tr_list[1] then
      notify(stracker)
      sfile = io.open(listfile, "w")
      sfile:write(stracker)
      sfile:close()
    end
    --print(tr_list[1])
    --print(line)
  else
    notify(stracker)
    sfile = io.open(listfile, "w")
    sfile:write(stracker)
    sfile:close()
  end
end

function tracker.show()
	if(string.len(stracker)>0) then 
		notify(stracker) 
	else
		notify('<empty>')
	end
end

return tracker

