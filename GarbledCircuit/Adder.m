classdef Adder
    properties
        XORGate1
        XORGate2
        AndGate1
        AndGate2
        ORGate
        MAC
    end
    properties (Constant)
        KeyMapForXORGate1 = 3:8;
        KeyMapForXORGate2 = [7 8 1 2 13 14];
        KeyMapForAndGate1 = [7 8 1 2 9 10];
        KeyMapForAndGate2 = [3:6 11 12];
        KeyMapForORGate = [9:12 15 16];
    end
    methods
        function obj = Adder(MAC)
            obj.XORGate1 = BasedGate('XOR', MAC);
            obj.XORGate2 = BasedGate('XOR', MAC);
            obj.AndGate1 = BasedGate('AND', MAC);
            obj.AndGate2 = BasedGate('AND', MAC);
            obj.ORGate = BasedGate('OR', MAC);
            obj.MAC = MAC;
        end
        function obj = ShuffleAllCircuit(obj,ShuffleOrder)
            obj.XORGate1 = obj.XORGate1.ShuffleTrueTable(ShuffleOrder(1,:));
            obj.XORGate2 = obj.XORGate2.ShuffleTrueTable(ShuffleOrder(2,:));
            obj.AndGate1 = obj.AndGate1.ShuffleTrueTable(ShuffleOrder(3,:));
            obj.AndGate2 = obj.AndGate2.ShuffleTrueTable(ShuffleOrder(4,:));
            obj.ORGate = obj.ORGate.ShuffleTrueTable(ShuffleOrder(5,:));
        end
        function obj = setEncTrueTable(obj, Keys)
            if size(Keys,1) ~= 16
                error('wrong number of keys!');
            end
            obj.XORGate1 = obj.XORGate1.setKeysAndTrueTable(Keys(Adder.KeyMapForXORGate1,:));
            obj.XORGate2 = obj.XORGate2.setKeysAndTrueTable(Keys(Adder.KeyMapForXORGate2,:));
            obj.AndGate1 = obj.AndGate1.setKeysAndTrueTable(Keys(Adder.KeyMapForAndGate1,:));
            obj.AndGate2 = obj.AndGate2.setKeysAndTrueTable(Keys(Adder.KeyMapForAndGate2,:));
            obj.ORGate = obj.ORGate.setKeysAndTrueTable(Keys(Adder.KeyMapForORGate,:));
        end
        function [OutputS, OutputC] = getSAndC(obj, InputC, InputA, InputB)
            A_B_XOR = obj.XORGate1.decryptOutput(InputA, InputB);
            OutputS = obj.XORGate2.decryptOutput(A_B_XOR, InputC);
            And1 = obj.AndGate1.decryptOutput(A_B_XOR, InputC);
            And2 = obj.AndGate2.decryptOutput(InputA, InputB);
            OutputC = obj.ORGate.decryptOutput(And1, And2);
        end
    end
end