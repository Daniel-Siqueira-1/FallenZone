local HttpService = game:GetService("HttpService")
local Changeable = {}
Changeable.__index = Changeable

export type Changeable = {
     Destroy: (self: Changeable)->(),

     Enabled: boolean;

     Start: (self: Changeable, Amount: number, Rate: number)->();
     Stop: (self: Changeable)->();

     Object: NumberValue,
}

local function GetSize(Dictionary: {[any]: any}): number
     local Size: number = 0;

     for _,_ in Dictionary do
          Size += 1
     end

     return Size
end

function Changeable.new(Object: NumberValue): Changeable
     local NewChangeable: any = {
          Enabled = false;
          Object = Object;

          Base = Object.Value;

          __tasks = {}
     }

     return setmetatable(NewChangeable,Changeable) :: Changeable
end

function Changeable:Start(Amount: number, Rate: number): ()
     Rate = 60 / (Rate * 60)

     local TaskID: string = HttpService:GenerateGUID()

     if self.__regenthread then
          task.cancel(self.__regenthread)
          self.__regenthread = nil
     end

     local TaskThread: thread = task.spawn(function(): ()
          while self.ValueBase.Value >= 0 do
               local Remaining: number = self.ValueBase.Value - Amount
               self.ValueBase.Value = Remaining

               task.wait(Rate)
          end

          self:Stop(TaskID)
     end)

     self.__tasks[TaskID] = TaskThread
     self.Enabled = true
end

function Changeable:Stop(TaskID: string): ()
     local TaskThread: thread = self.__tasks[TaskID]
     if TaskThread then
          task.cancel(TaskThread)
          self.__tasks[TaskID] = nil

          if GetSize(self.__tasks) == 0 then
               self.Enabled = false

               self.__regenthread = task.delay(3, self.Regenerate,self)
          end
     end
end

function Changeable:Regenerate(Amount: number, Rate: number): ()
     while self.Object.Value < self.Base do
          if self.Enabled then
               break
          end
          
          local CurrentAmount: number = self.Object.Value
          local RegeneratedAmount: number = math.clamp(CurrentAmount + Amount, 0, self.Base)

          self.Object.Value = RegeneratedAmount
     end
end

function Changeable:Destroy(): ()
     table.clear(self)
end

return Changeable