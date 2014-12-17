classdef HalfAdder
    properties
        XORGate
        AndGate 
        MAC     
    end
    properties (Constant)
        KeyMapForXORGate = 1:6;
        KeyMapForAndGate = [1:4 7 8];
    end
    methods
        function obj = HalfAdder(MAC)
            obj.MAC = MAC;
            obj.XORGate = BasedGate('XOR', MAC);
            obj.AndGate = BasedGate('AND', MAC);
        end
        function obj = ShuffleAllCircuit(obj,ShuffleOrder)
            obj.XORGate = obj.XORGate.ShuffleTrueTable(ShuffleOrder(1,:));
            obj.AndGate = obj.AndGate.ShuffleTrueTable(ShuffleOrder(2,:));   
        end
        function obj = setEncTrueTable(obj, Keys)
            if size(Keys,1) ~= 8
                error('wrong number of keys!');
            end
            obj.XORGate = obj.XORGate.setKeysAndTrueTable(Keys(HalfAdder.KeyMapForXORGate,:));
            obj.AndGate = obj.AndGate.setKeysAndTrueTable(Keys(HalfAdder.KeyMapForAndGate,:));
        end
        function [OutputS OutputC] = getSAndC(obj, InputA, InputB)
            OutputS = obj.XORGate.decryptOutput(InputA, InputB);
            OutputC = obj.AndGate.decryptOutput(InputA, InputB);
        end
    end
end