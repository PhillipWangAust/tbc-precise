classdef UtilityCircuit
    properties
        NumOfChildren;
        NumOfClasses;
        KeysOfCrytpo;
        NumOfBits
        LengthOfKeys
        PreAdder
        Minus
        Maxs
        Adders
        InputNum1ForGAdder2C
        
        PreAdderOutKeyMap
        MinusOutKeyMap
        MaxsOutKeyMap
        AddersOutKeyMap
        
        Keys
    end
    methods
        function obj = UtilityCircuit(NumOfChildren, NumOfClasses, NumOfBits, LengthOfKeys)
            obj.NumOfChildren = NumOfChildren;
            obj.NumOfClasses = NumOfClasses;
            obj.NumOfBits = NumOfBits;
            obj.LengthOfKeys = LengthOfKeys;
            
            for m = 1:NumOfChildren
                for n = 1:NumOfClasses
                    obj.PreAdder{m,n} = GAddCircuit(NumOfBits, LengthOfKeys);
                end
            end
            
            for m = 1:NumOfChildren
                for n = 1:NumOfClasses
                    obj.Minus{m,n} = GAddCircuit(NumOfBits, LengthOfKeys);
                end
            end
            
            for m = 1:NumOfChildren
                for n = 1:(NumOfClasses - 1)
                    obj.Maxs{m, n} = GMaxCircuit(NumOfBits, LengthOfKeys);
                end
            end
            
            for m = 1:(NumOfChildren - 1)
                obj.Adders{m} = GAddCircuit(NumOfBits, LengthOfKeys);
            end
        end
        
        function obj = initializeKeys(obj, Keys)
            if sum(not(isfield(Keys,{'Input','Output'})))
                error('no this field!');
            end
            
            obj.Keys = Keys;
            for m = 1:obj.NumOfChildren
                for n = 1:obj.NumOfClasses
                    temp_inputB = logical(round(rand(obj.NumOfBits * 2,obj.LengthOfKeys)));
                    temp_output{m,n} = logical(round(rand(obj.NumOfBits * 2,obj.LengthOfKeys)));
                    obj.PreAdder{m,n} = obj.PreAdder{m,n}.initializeKeysForAAndB(SwapKeys(Keys.Input(m,n).KeysOfInputA), temp_inputB, temp_output{m,n});
            
                    obj.InputNum1ForGAdder2C{m,n} = temp_inputB(1:2:end,:);
                    obj.InputNum1ForGAdder2C{m,n}(1,:) = temp_inputB(2,:);
                end
            end
            
            obj.PreAdderOutKeyMap = temp_output;
            
            for m = 1:obj.NumOfChildren
                for n = 1:obj.NumOfClasses
                    temp_output1{m,n} = logical(round(rand(obj.NumOfBits * 2,obj.LengthOfKeys)));
                    obj.Minus{m,n} = obj.Minus{m,n}.initializeKeysForAAndB(temp_output{m,n}, Keys.Input(m,n).KeysOfInputB, temp_output1{m,n});
                end
            end
            
            obj.MinusOutKeyMap = temp_output1;
            
            clear tempOutput;
            for m = 1:obj.NumOfChildren
                tempInputA = temp_output1{m,1};
                for n = 1:(obj.NumOfClasses-1)
                    tempOutput = logical(round(rand(2*obj.NumOfBits, obj.LengthOfKeys)));
                    obj.Maxs{m,n} = obj.Maxs{m}.initializeKeys(tempInputA, temp_output1{m, n+1}, tempOutput);
                    tempInputA = tempOutput;
                end
                tempOutMax{m} = tempOutput; 
            end
            
            obj.MaxsOutKeyMap = tempOutMax;
            
            tempInputA = tempOutMax{1};
            for m = 1:(obj.NumOfChildren - 1)
                if m ~= obj.NumOfChildren - 1
                    tempKeysOfOutput = logical(round(rand(2*obj.NumOfBits, obj.LengthOfKeys)));
                else
                    tempKeysOfOutput = Keys.Output;
                end
                obj.Adders{m} = obj.Adders{m}.initializeKeysForAAndB(tempInputA, tempOutMax{m+1}, tempKeysOfOutput);
                tempInputA = tempKeysOfOutput;
            end
        end
        
        function obj = initializeInputCrypo(obj, KeysOfCrytpo)
            obj.KeysOfCrytpo = KeysOfCrytpo;
        end
        
        function OutputUFunc = getGarbledOutput(obj, KeysOfAggregator)
            for m = 1:obj.NumOfChildren
                for n = 1:obj.NumOfClasses
                    OutputKeysOfPreAdder{m,n} = obj.PreAdder{m,n}.getGarbledOutput(KeysOfAggregator{m,n}, obj.InputNum1ForGAdder2C{m,n});
                end
            end
            
            for m = 1:obj.NumOfChildren
                for n = 1:obj.NumOfClasses
                    OutputKeysOfMinus{m,n} = obj.Minus{m,n}.getGarbledOutput(OutputKeysOfPreAdder{m,n}, obj.KeysOfCrytpo{m,n});
                end
            end
            
            for m = 1:obj.NumOfChildren
                OutputKeysOfMax{m} = OutputKeysOfMinus{m,1};
                for n = 1:(obj.NumOfClasses - 1)
                    OutputKeysOfMax{m} = obj.Maxs{m,n}.getGarbledOutput(OutputKeysOfMax{m}, OutputKeysOfMinus{m,n+1});
                end
            end
            
            OutputUFunc = OutputKeysOfMax{1};
            for m = 1:(obj.NumOfChildren - 1)
                OutputUFunc = obj.Adders{m}.getGarbledOutput(OutputUFunc, OutputKeysOfMax{m+1});
            end
        end
    end
    
    methods(Static)
        function ValueFromGarbled = getOrgOfOutput(OutputKeys, KeyMap)
            NumOfBits1 = size(OutputKeys, 1);
            ValueFromGarbled = zeros(1,NumOfBits1);
            
            for m = 1:NumOfBits1
                if sum(abs(OutputKeys(m,:) - KeyMap(2*m-1,:))) == 0
                elseif sum(abs(OutputKeys(m,:) - KeyMap(2*m,:))) == 0
                    ValueFromGarbled(m) = 1;
                else
                    error('wrong!');
                end
            end
        end
        
        function OutputKeys = getKeysFromNumber(Num, KeyMap)
            NumOfBits1 = size(KeyMap,1)/2;
            Bits1 = s_de2bi(Num, NumOfBits1);
            Index1 = (1:2:(2*NumOfBits1)) + Bits1;
            OutputKeys = KeyMap(Index1,:);
        end
    end
end