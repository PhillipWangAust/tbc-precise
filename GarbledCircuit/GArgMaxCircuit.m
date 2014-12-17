classdef GArgMaxCircuit
    properties
        NumOfBits
        GAdder2C
        GAdderComp
%         GAndsA
%         GAndsB
%         GAdderOutput
        LengthOfKeys
        InputNum1ForGAdder2C
    end
    methods
        function obj = GArgMaxCircuit(NumOfBits, LengthOfKeys)
            obj.NumOfBits = NumOfBits;
            obj.LengthOfKeys = LengthOfKeys;
            obj.GAdder2C = GAddCircuit(NumOfBits, LengthOfKeys);
            obj.GAdderComp = GAddCircuit(NumOfBits, LengthOfKeys);  
%             obj.GAndsA = GGateArrayCircuit(NumOfBits, LengthOfKeys,'AND');
%             obj.GAndsB = GGateArrayCircuit(NumOfBits, LengthOfKeys,'AND');
%             obj.GAdderOutput = GAddCircuit(NumOfBits, LengthOfKeys);      
        end
        
        function obj = initializeKeys(obj, InputA, InputB, Output)
            CInputA = SwapKeys(InputB);
%             keysForGAdder2C = logical(round(rand(obj.GAdder2C.getNumOfKeys(),obj.LengthOfKeys)));
            temp_inputB = logical(round(rand(obj.NumOfBits * 2,obj.LengthOfKeys)));
            temp_output = logical(round(rand(obj.NumOfBits * 2,obj.LengthOfKeys)));
            obj.GAdder2C = obj.GAdder2C.initializeKeysForAAndB(CInputA, temp_inputB, temp_output);
            obj.InputNum1ForGAdder2C = temp_inputB(1:2:end,:);
            obj.InputNum1ForGAdder2C(1,:) = temp_inputB(2,:);
            
            temp_inputA = InputA;
            temp_inputB = temp_output;
            temp_output = logical(round(rand(obj.NumOfBits * 2,obj.LengthOfKeys)));
            temp_output((end - 1):end,:) = Output;
            obj.GAdderComp = obj.GAdderComp.initializeKeysForAAndB(temp_inputA, temp_inputB, temp_output);
            
%             temp_inputA = InputA;
%             temp_inputB = repmat(temp_output((end-1):end,:), obj.NumOfBits, 1);
%             temp_inputB = SwapKeys(temp_inputB);
%             temp_output1 = logical(round(rand(obj.NumOfBits * 2,obj.LengthOfKeys)));
%             obj.GAndsA = obj.GAndsA.initializeKeysIO(temp_inputA, temp_inputB, temp_output1);
%             
%             temp_inputA = InputB;
%             temp_inputB = SwapKeys(temp_inputB);
%             temp_output2 = logical(round(rand(obj.NumOfBits * 2,obj.LengthOfKeys)));
%             obj.GAndsB = obj.GAndsA.initializeKeysIO(temp_inputA, temp_inputB, temp_output2);
%             
%             temp_inputA = temp_output1;
%             temp_inputB = temp_output2;
%             obj.GAdderOutput = obj.GAdderOutput.initializeKeysForAAndB(temp_inputA, temp_inputB, Output);
        end
        
        function GarbledOutput = getGarbledOutput(obj, GInputA, GInputB)
            temp_GarbledOutput1 = obj.GAdder2C.getGarbledOutput(GInputB, obj.InputNum1ForGAdder2C);
            
            temp_inputA = GInputA;
            temp_inputB = temp_GarbledOutput1;
            temp_GarbledOutput1 = obj.GAdderComp.getGarbledOutput(temp_inputA, temp_inputB);
            
            GarbledOutput = temp_GarbledOutput1(end,:);
            
%             temp_inputB = repmat(temp_GarbledOutput1(end,:), obj.NumOfBits,1);
%             
%             temp_inputA = GInputA;
%             temp_GarbledOutput1 = obj.GAndsA.getGarbledOutput(temp_inputA, temp_inputB);
%             
%             temp_inputA = GInputB;
%             temp_GarbledOutput2 = obj.GAndsB.getGarbledOutput(temp_inputA, temp_inputB);
%             
%             GarbledOutput = obj.GAdderOutput.getGarbledOutput(temp_GarbledOutput1, temp_GarbledOutput2);
        end
    end
end