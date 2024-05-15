local Debuffers = {};
local Buffers = {}

return {
    ToInformation = function(Callback: (...any)->()): ()
        return function(...:any): ...any
            local Package: {any} = {};

            for _, Item: any in table.pack(...) do
                local Type: string = type(Item)
                if Debuffers[Type] then
                    local Information: any = Debuffers[Type](Item)
                    table.insert(Package,Information)
                else
                    table.insert(Package, Item)
                end
            end

            Callback(table.unpack(Package))
        end
    end;

    ToBuffer = function(Callback: (...any)->()): ()
        return function(...:any): ...any
            local Package: {any} = {};

            for _, Item: any in table.pack(...) do
                local Type: string = type(Item)
                if Buffers[Type] then
                    local Information: any = Buffers[Type](Item)
                    table.insert(Package,Information)
                else
                    table.insert(Package, Item)
                end
            end

            Callback(table.unpack(Package))
        end
    end;
}