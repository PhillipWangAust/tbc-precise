classdef UciBreast
    properties
        NumOfBits
        LengthOfKeys
        PreAdder
        Minus
        arg_max
        
        PreAdderOutKeyMap
        MinusOutKeyMap
    end
    
    methods
        function obj = UciBreast(NumOfBits, LengthOfKeys)
            obj.NumOfBits = NumOfBits;
            obj.LengthOfKeys = LengthOfKeys;
            obj.PreAdder{1} = GAddCircuit(NumOfBits, LengthOfKeys);
            obj.PreAdder{1} = GAddCircuit(NumOfBits, LengthOfKeys);
            
            obj.Minus{1} = GAddCircuit(NumOfBits, LengthOfKeys);
            obj.Minus{2} = GAddCircuit(NumOfBits, LengthOfKeys);
            
            obj.arg_max = GArgMaxCircuit(NumOfBits, LengthOfKeys);
        end
        
        function obj = initializeKeys(obj, Keys)
            if sum(not(isfield(Keys,{'Input','Output'})))
                error('no this field!');
            end
            
            obj.Keys = Keys;
            
            for m = 1:2
                temp_inputB = logical(round(rand(obj.NumOfBits * 2,obj.LengthOfKeys)));
                temp_output{m} = logical(round(rand(obj.NumOfBits * 2,obj.LengthOfKeys)));
                obj.PreAdder{m} = obj.PreAdder{m}.initializeKeysForAAndB(SwapKeys(Keys.Input(m).KeysOfInputA), temp_inputB, temp_output{m});
                
                obj.InputNum1ForGAdder2C{m} = temp_inputB(1:2:end,:);
                obj.InputNum1ForGAdder2C{m}(1,:) = temp_inputB(2,:);
            end
            
            obj.PreAdderOutKeyMap = temp_output;
            
            for m =1:2
                temp_output1{m} = logical(round(rand(obj.NumOfBits * 2,obj.LengthOfKeys)));
                obj.Minus{m} = obj.Minus{m}.initializeKeysForAAndB(temp_output{m}, Keys.Input(m).KeysOfInputB, temp_output1{m});
            end
            
            obj.MinusOutKeyMap = temp_output1;
            
            obj.arg_max = obj.arg_max.initializeKeys(temp_output1{1}, temp_output1{2}, Output);
        end
        
        function obj = initializeInputCrypo(obj, KeysOfCrytpo)
            obj.KeysOfCrytpo = KeysOfCrytpo;
        end
        
        function GarbledOutput = getGarbledOutput(obj, KeysOfAggregator)
            for m = 1:2
                OutputKeysOfPreAdder{m} = obj.PreAdder{m}.getGarbledOutput(KeysOfAggregator{m}, obj.InputNum1ForGAdder2C{m});
            end
            
            for m = 1:2
                OutputKeysOfMinus{m} = obj.Minus{m}.getGarbledOutput(OutputKeysOfPreAdder{m}, obj.KeysOfCrytpo{m});
            end
            
            GarbledOutput = obj.arg_max.getGarbledOutput(OutputKeysOfMinus{1}, OutputKeysOfMinus{2});
        end
        
    end
end