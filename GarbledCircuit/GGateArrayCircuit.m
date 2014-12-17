classdef GGateArrayCircuit
    properties
        NumOfBits
        LengthOfKeys
        Gates
        Type
    end
    methods
        function obj = GGateArrayCircuit(NumOfBits, LengthOfKeys, Type)
            obj.Type = Type;
            obj.NumOfBits = NumOfBits;
            obj.LengthOfKeys = LengthOfKeys;
            MAC = logical(round(rand(NumOfBits, LengthOfKeys)));
            
            for m = 1:NumOfBits
                obj.Gates{m} = BasedGate(Type, MAC(m,:));
            end
        end
        
        function NumOfKeys = getNumOfKeys(obj)
            NumOfKeys = 3 * 2 * obj.NumOfBits;
        end
        function obj = initializeKeysIO(obj, KeysOfInputA, KeysOfInputB, KeysOfOutput)
            Keys = logical(round(rand(obj.getNumOfKeys(), obj.LengthOfKeys)));
            Keys = GGateArrayCircuit.setKeysOfInputA(Keys, KeysOfInputA);
            Keys = GGateArrayCircuit.setKeysOfInputB(Keys, KeysOfInputB);
            Keys = GGateArrayCircuit.setKeysOfOutput(Keys, KeysOfOutput);
            
            for m = 1:obj.NumOfBits
                obj.Gates{m} = obj.Gates{m}.setKeysAndTrueTable(Keys((1+ 6*(m-1)):(6*m),:));
            end
        end
        function OutputGarbles = getGarbledOutput(obj, InputA, InputB)
            for m = 1:obj.NumOfBits
                OutputGarbles(m,:)  = obj.Gates{m}.decryptOutput(InputA(m,:), InputB(m,:));
            end
        end
    end
    
    methods(Static)
        function [KeysOfInputA KeysOfInputB KeysOfOutput] = getKeysOfIO(Keys)
            if mod(size(Keys,1),6) ~= 0
                error('The length of Keys are error!');
            end
            
            KeysOfInputA = zeros(size(Keys,1)/3, size(Keys,2));
            KeysOfInputB = KeysOfInputA;
            KeysOfOutput = KeysOfInputA;
            temp = Keys(1:6:end,:);
            KeysOfInputA(1:2:end,:) = temp;
            temp = Keys(2:6:end,:);
            KeysOfInputA(2:2:end,:) = temp;
            
            temp = Keys(3:6:end,:);
            KeysOfInputB(1:2:end,:) = temp;
            temp = Keys(4:6:end,:);
            KeysOfInputB(2:2:end,:) = temp;
            
            temp = Keys(5:6:end,:);
            KeysOfOutput(1:2:end,:) = temp;
            temp = Keys(6:6:end,:);
            KeysOfOutput(2:2:end,:) = temp;
        end
        
        function KeysOfInputA = getKeysOfInputA(Keys)
            if mod(size(Keys,1),6) ~= 0
                error('The length of Keys are error!');
            end
            
            KeysOfInputA = zeros(size(Keys,1)/3, size(Keys,2));

            temp = Keys(1:6:end,:);
            KeysOfInputA(1:2:end,:) = temp;
            temp = Keys(2:6:end,:);
            KeysOfInputA(2:2:end,:) = temp;
            
        end
        
        function KeysOfInputB = getKeysOfInputB(Keys)
            if mod(size(Keys,1),6) ~= 0
                error('The length of Keys are error!');
            end
            
            KeysOfInputB = zeros(size(Keys,1)/3, size(Keys,2));
            
            temp = Keys(3:6:end,:);
            KeysOfInputB(1:2:end,:) = temp;
            temp = Keys(4:6:end,:);
            KeysOfInputB(2:2:end,:) = temp;
            
        end
        
        function KeysOfOutput = getKeysOfOutput(Keys)
            if mod(size(Keys,1),6) ~= 0
                error('The length of Keys are error!');
            end
            
            KeysOfOutput = zeros(size(Keys,1)/3, size(Keys,2));
            
            temp = Keys(5:6:end,:);
            KeysOfOutput(1:2:end,:) = temp;
            temp = Keys(6:6:end,:);
            KeysOfOutput(2:2:end,:) = temp;
        end
        
        function Keys = setKeysOfInputA(Keys, InputA)
            temp = InputA(1:2:end,:);
            Keys(1:6:end,:) = temp;
            temp = InputA(2:2:end,:);
            Keys(2:6:end,:) = temp;
        end
        
        function Keys = setKeysOfInputB(Keys, InputB)
            temp = InputB(1:2:end,:);
            Keys(3:6:end,:) = temp;
            temp = InputB(2:2:end,:);
            Keys(4:6:end,:) = temp;
        end
        
        function Keys = setKeysOfOutput(Keys, Output)
            temp = Output(1:2:end,:);
            Keys(5:6:end,:) = temp;
            temp = Output(2:2:end,:);
            Keys(6:6:end,:) = temp;
        end
    end
end