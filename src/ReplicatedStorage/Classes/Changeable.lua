local Changeable = {}
Changeable.__index = Changeable

export type Changeable = {
     Destroy: (self: Changeable)->(),
     Start: (self: Changeable, Amount: number)->(),
     ValueBase: NumberValue,
}

function Changeable.new(ValueBase: ValueBase): Changeable
     local NewChangeable: any = {
        ValueBase = ValueBase
     }

     return setmetatable(NewChangeable,Changeable) :: Changeable
end

function Changeable:Start(Amount: number): boolean
    local Remaining = self.ValueBase.Value - Amount
    if Remaining >= 0 then
        self.ValueBase.Value = Remaining
        return true
    end

    return false
end

function Changeable:Stop(): ()
    
end

function Changeable:Destroy(): ()
     table.clear(self)
end

return Changeable