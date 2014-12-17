classdef CryptoProvider
    properties
        NumOfAttributes
        NumOfFacilities
        NumOfBits
        GLengthOfKeys
        fi_word
        fi_fraction
        F1
        bits_key
        Alpha2
        decrypt1
        
        HomoKey
        
        GbCircuit
        KeyMap
        
        CountWithMu
        
        InputIndexOfCryptoProvider
        isCompwithAverage
    end
    methods
        function obj = CryptoProvider(NumOfAttributes, NumOfFacilities, NumOfBits, GLengthOfKeys, F1, fi_word, fi_fraction, bits_key, isCompwithAverage)
            obj.NumOfAttributes= NumOfAttributes;
            obj.NumOfFacilities = NumOfFacilities;
            obj.NumOfBits = NumOfBits;
            obj.GLengthOfKeys = GLengthOfKeys;
            obj.F1 = F1;
            obj.fi_word = fi_word;
            obj.fi_fraction = fi_fraction;
            obj.bits_key = bits_key;
            
            obj.decrypt1.f_bits = fi_word;
            obj.decrypt1.f_fbits = fi_fraction;
            obj.decrypt1.F = F1;
            obj.isCompwithAverage = isCompwithAverage;
            
        end
        
        function obj = initializeKeys(obj)
            for m = 1:obj.NumOfAttributes
                obj.HomoKey{m} = thep.paillier.PrivateKey(obj.bits_key);
            end
        end
        
        function PubKey = getPubKey(obj)
            for m = 1:obj.NumOfAttributes
                PubKey{m} = obj.HomoKey{m}.getPublicKey;
            end   
        end
        
        function obj = getGCircuit(obj)
            obj.GbCircuit = TBCGCircuit(obj.NumOfBits, obj.GLengthOfKeys);
            obj.KeyMap = TBCGCircuit.getKeyMaps(obj.NumOfBits, obj.GLengthOfKeys);
            obj.GbCircuit = obj.GbCircuit.initializeKeys(obj.KeyMap);
        end
        
        function obj = getKeyMapOfGarbledCircuit(obj)
            obj.KeyMap = TBCGCircuit.getKeyMaps(obj.NumOfBits, obj.GLengthOfKeys);
        end
        
        function obj = decryptCountsWithMu(obj, EncCountsWithMu)
            [NumOfFacilities1, NumOfAttributes1] = size(EncCountsWithMu);
            obj.CountWithMu = zeros(NumOfFacilities1, NumOfAttributes1);
            for n = 1:NumOfFacilities1
                for m = 1:NumOfAttributes1
                    obj.CountWithMu(n,m) = decryptMatrix_fi(EncCountsWithMu{n,m}, obj.HomoKey{m}, obj.decrypt1);
                end
            end
            obj = obj.getKeysOfCryptoProvider();
        end
        
        
        function obj = getKeysOfCryptoProvider(obj)
            if obj.isCompwithAverage
                NumOfFacilities1 = obj.NumOfFacilities + 1;
            else
                NumOfFacilities1 = obj.NumOfFacilities;
            end
            obj.InputIndexOfCryptoProvider = cell(obj.NumOfAttributes,1);
            for m = 1:obj.NumOfAttributes
                obj.InputIndexOfCryptoProvider{m} = repmat(1:2:(2*obj.NumOfBits),NumOfFacilities1,1) + s_de2bi(obj.CountWithMu(:,m), obj.NumOfBits);
            end
        end
        
        function obj = SwapIndexOfKeysPos(obj, m, n1, n2)
            obj.InputIndexOfCryptoProvider{m}([n1, n2], :) = obj.InputIndexOfCryptoProvider{m}([n2, n1], :);
        end
        
        function Key = getKeysOfCrytoProvider(obj, n, m, Type)
            switch Type
                case 'A1'
                    Key = obj.KeyMap.InputA1(obj.InputIndexOfCryptoProvider{m}(n,:),:);
                case 'A2'
                    Key = obj.KeyMap.InputA2(obj.InputIndexOfCryptoProvider{m}(n,:),:);
                otherwise
                    error('The input provided is wrong!');
            end
        end
        
        function Keys = getKeysOfCloud(obj, orderOfBit, Type)
            switch Type
                case 'B1'
                    Keys = obj.KeyMap.InputB1(((orderOfBit - 1)*2+1):(orderOfBit*2),:);
                case 'B2'
                    Keys = obj.KeyMap.InputB2(((orderOfBit - 1)*2+1):(orderOfBit*2),:);
                otherwise
                    error('The input provided is wrong!');
            end
        end
    end
end