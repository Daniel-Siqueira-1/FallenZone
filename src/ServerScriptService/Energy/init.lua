local Energy = {}
Energy.__index = Energy

export type Energy = {
     Destroy: (self: Energy)->()
}

function Energy.new(): Energy
     local NewEnergy: any = {}

     return setmetatable(NewEnergy,Energy) :: Energy
end

function Energy:

function Energy:Destroy(): ()
     table.clear(self)
end

return Energy