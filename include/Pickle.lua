----------------------------------------------
-- Pickle.lua
-- A table serialization utility for lua
-- Steve Dekorte, http://www.dekorte.com, Apr 2000
-- Freeware
----------------------------------------------

function pickle(t)
    return Pickle:clone():pickle_(t)
end

Pickle = {
    clone = function (t) local nt={}; for i, v in pairs(t) do nt[i]=v end return nt end 
}

function Pickle:pickle_(root)
    if type(root) ~= "table" then 
        error("can only pickle tables, not ".. type(root).."s")
    end
    self._tableToRef = {}
    self._refToTable = {}
    local savecount = 0
    self:ref_(root)
    local s = ""

    while #(self._refToTable) > savecount do
        savecount = savecount + 1
        local t = self._refToTable[savecount]
        s = s.."{\n"
        for i, v in pairs(t) do
            if type(v) ~= "function" then
                s = string.format("%s[%s]=%s,\n", s, self:value_(i), self:value_(v))
            end
        end
        s = s.."},\n"
    end

    return string.format("{%s}", s)
end

function Pickle:value_(v)
    local vtype = type(v)
    if vtype == "string" then return string.format("%q", v)
    elseif vtype == "number" then return round(v,2)
    elseif vtype == "boolean" then return tostring(v)
    elseif vtype == "table" then return "{"..self:ref_(v).."}"
    else error("pickle a "..type(v).." is not supported")
    end
end

function Pickle:ref_(t)
    local ref = self._tableToRef[t]
    if not ref then 
        if t == self then error("can't pickle the pickle class") end
        table.insert(self._refToTable, t)
        ref = #(self._refToTable)
        self._tableToRef[t] = ref
    end
    return ref
end