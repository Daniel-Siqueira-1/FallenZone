local LinearProjectile = {}
LinearProjectile.__index = LinearProjectile

export type LinearProjectile = {
     Destroy: (self: LinearProjectile)->()
}

function LinearProjectile.new(Caster: Player): LinearProjectile
     local self: any = {
        Parameters = RaycastParams.new()
     }

     return setmetatable(self,LinearProjectile) :: LinearProjectile
end

function LinearProjectile:Cast(Origin: Vector3, Direction: Vector3): ()
     local Raycast: RaycastResult? = workspace:Raycast(Origin, Direction, self.Parameters)

     
end

function LinearProjectile:Destroy(): ()
     table.clear(self)
end

return LinearProjectile