classdef TBCGCircuit
    properties
        NumOfBits
        LengthOfKeys
        GAdder1
        GAdder2
        GComp
        Keys
    end
    
    methods
        function obj = TBCGCircuit(NumOfBits, LengthOfKeys)
            obj.NumOfBits = NumOfBits;
            obj.LengthOfKeys = LengthOfKeys;
            
            obj.GAdder1 = GAddCircuit(NumOfBits, LengthOfKeys);
            obj.GAdder2 = GAddCircuit(NumOfBits, LengthOfKeys);
            
            obj.GComp = GArgMaxCircuit(NumOfBits, LengthOfKeys);
        end
        
        function obj = initializeKeys(obj, Keys)
            if sum(not(isfield(Keys, {'InputA1', 'InputA2','InputB1','InputB2','Output'})))
                error('No this field!');
            end
            
            obj.Keys = Keys;
            
            tempOutputForGAdder1 = logical(round(rand(obj.NumOfBits * 2, obj.LengthOfKeys)));
            tempOutputForGAdder2 = logical(round(rand(obj.NumOfBits * 2, obj.LengthOfKeys)));
            
            obj.GAdder1 = obj.GAdder1.initializeKeysForAAndB(Keys.InputA1, Keys.InputB1, tempOutputForGAdder1);
            obj.GAdder2 = obj.GAdder2.initializeKeysForAAndB(Keys.InputA2, Keys.InputB2, tempOutputForGAdder2);
            
            obj.GComp = obj.GComp.initializeKeys(tempOutputForGAdder1, tempOutputForGAdder2, Keys.Output);
            
        end
        
        function OutputGarbledVals = getGarbledOutput(obj, GarbledInputA, GarbledInputB)          
            OutputFromGAdder1 = obj.GAdder1.getGarbledOutput(GarbledInputA{1}, GarbledInputB{1});
            OutputFromGAdder2 = obj.GAdder2.getGarbledOutput(GarbledInputA{2}, GarbledInputB{2});
            OutputGarbledVals = obj.GComp.getGarbledOutput(OutputFromGAdder1, OutputFromGAdder2);
        end
        
        function OutputVal = getOutput(obj, GarbledInputA, GarbledInputB)          
            OutputFromGAdder1 = obj.GAdder1.getGarbledOutput(GarbledInputA{1}, GarbledInputB{1});
            OutputFromGAdder2 = obj.GAdder2.getGarbledOutput(GarbledInputA{2}, GarbledInputB{2});
            OutputGarbledVals = obj.GComp.getGarbledOutput(OutputFromGAdder1, OutputFromGAdder2);
            
            if sum(abs(OutputGarbledVals - obj.Keys.Output(1,:)))
                OutputVal = 0;
            elseif sum(abs(OutputGarbledVals - obj.Keys.Output(2,:)))
                OutputVal = 1;
            else
                error('The output of decryption is wrong!');
            end
        end
    end
    
    methods(Static)
        function KeyMaps = getKeyMaps(NumOfBits, LengthOfKeys)
            KeyMapOfInputA1 = logical(round(rand(NumOfBits * 2, LengthOfKeys)));
            KeyMapOfInputA2 = logical(round(rand(NumOfBits * 2, LengthOfKeys)));
            
            KeyMapOfInputB1 = logical(round(rand(NumOfBits * 2, LengthOfKeys)));
            KeyMapOfInputB2 = logical(round(rand(NumOfBits * 2, LengthOfKeys)));
            
            KeyMapOutput = logical(round(rand(2, LengthOfKeys)));
            
            KeyMaps = struct('InputA1', KeyMapOfInputA1, 'InputA2', KeyMapOfInputA2, 'InputB1', KeyMapOfInputB1, 'InputB2', KeyMapOfInputB2,'Output', KeyMapOutput);
        end   
    end
end