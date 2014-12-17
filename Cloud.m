classdef Cloud
    properties
        NumOfFacilities
        NumOfAttributes
        NumOfBits
        GLengthOfKeys
        F1
        fi_word
        fi_fraction
        bits_key
        Mu
        GbMu
        Alpha1
        PubKey
        isOT
        isCompwithAverage
    end
    methods
        function obj = Cloud(NumOfFacilities, NumOfAttributes, NumOfBits, GLengthOfKeys, F1, fi_word, fi_fraction, bits_key, PubKey, isOT, isCompwithAverage)
            obj.NumOfFacilities = NumOfFacilities;
            obj.NumOfAttributes = NumOfAttributes;
            obj.NumOfBits = NumOfBits;
            obj.GLengthOfKeys = GLengthOfKeys;
            obj.fi_word = fi_word;
            obj.fi_fraction = fi_fraction;
            obj.F1 = F1;
            obj.bits_key = bits_key;
            obj.PubKey = PubKey;
            obj.isOT = isOT;
            obj.isCompwithAverage = isCompwithAverage;
        end
        
        function obj = initializeMu(obj)
            if obj.isCompwithAverage
                obj.Mu = randi([0, 100], obj.NumOfFacilities + 1, obj.NumOfAttributes);
            else
                obj.Mu = randi([0, 100], obj.NumOfFacilities, obj.NumOfAttributes);
            end
        end
        
        function [EncCountsWithMu] = sumEnccountsWithMu(obj, Enc_counts_from_facilities)
            if obj.isCompwithAverage
                EncCountsWithMu = cell(obj.NumOfFacilities + 1, obj.NumOfAttributes);
            else
                EncCountsWithMu = cell(obj.NumOfFacilities, obj.NumOfAttributes);
            end
            for n = 1:obj.NumOfFacilities
                for m = 1:obj.NumOfAttributes
                    EncCountsWithMu{n,m} = secureMatrixSum(encryptMatrix_fi(obj.PubKey{m}, fi(obj.Mu(n,m), 1, obj.fi_word, obj.fi_fraction, 'fimath', obj.F1)), Enc_counts_from_facilities{n}{m});
                    if obj.isCompwithAverage
                        for  k = 1:obj.NumOfFacilities - 1
                            EncCountsWithMu{n,m} = secureMatrixSum(EncCountsWithMu{n,m}, Enc_counts_from_facilities{n}{m});
                        end
                    end
                end
            end
            
            if obj.isCompwithAverage
                for m = 1:obj.NumOfAttributes
                    EncCountsWithMu{obj.NumOfFacilities+1,m} = encryptMatrix_fi(obj.PubKey{m}, fi(obj.Mu(obj.NumOfFacilities+1,m), 1, obj.fi_word, obj.fi_fraction, 'fimath', obj.F1));
                    for n = 1:obj.NumOfFacilities
                        EncCountsWithMu{obj.NumOfFacilities+1,m} = secureMatrixSum(EncCountsWithMu{obj.NumOfFacilities+1,m}, Enc_counts_from_facilities{n}{m});
                    end      
                end
            end
        end
        
        function Rank = getRankByGarbledCricuit(obj, cryp_provider)
            if obj.isCompwithAverage
                NumOfFacilities1 = obj.NumOfFacilities + 1;
            else
                NumOfFacilities1 = obj.NumOfFacilities;
            end
            
            Rank = repmat(1:NumOfFacilities1, obj.NumOfAttributes, 1)';
            for k = 1:obj.NumOfAttributes
                k
                for m = 1:NumOfFacilities1 - 1
                    for n = 1:NumOfFacilities1 - m
                        GarbledInputA{1} = cryp_provider.getKeysOfCrytoProvider(n, k, 'A1');
                        GarbledInputA{2} = cryp_provider.getKeysOfCrytoProvider(n+1, k, 'A2');
                        GarbledInputB{1} = obj.getKeyOfInputB(n, k, 'B1', cryp_provider);
                        GarbledInputB{2} = obj.getKeyOfInputB(n+1, k, 'B2', cryp_provider);
                        
                        if cryp_provider.GbCircuit.getOutput(GarbledInputA, GarbledInputB)
                            cryp_provider = cryp_provider.SwapIndexOfKeysPos(k, n, n+1);
                            obj = obj.SwapValue(k, n, n + 1);
                            Rank([n, n+1], k) = Rank([n+1, n], k);
                        end
                    end
                end
            end
        end
        
        function obj = SwapValue(obj, k, n1, n2)
            obj.Mu([n1,n2],k) = obj.Mu([n2,n1],k);
        end
        
        function KeyOfCloud = getKeyOfInputB(obj, n, m, Type, cryp_provider)
            val = -obj.Mu(n,m);
            bi_val = s_de2bi(val, obj.NumOfBits);
            KeyOfCloud = zeros(obj.NumOfBits, obj.GLengthOfKeys);
            
            for m = 1:obj.NumOfBits
                Map1 = cryp_provider.getKeysOfCloud(m, Type);
                KeyOfCloud(m,:) = Cloud.OTProtocol(Map1, bi_val(m), obj.GLengthOfKeys, obj.isOT);
            end
        end
    end
    
    methods(Static)
        
        function Key = OTProtocol(Map1, b, GLengthOfKeys, flag)
            if flag == 0
                Key = Map1(b+1,:);
            else
                Rand1 = randi([1,10^6], 2, 1);
                Rand1_bi = s_de2bi(Rand1, GLengthOfKeys);
    
                OTPublish = bitxor(Map1, Rand1_bi);
                OTVal = OT1of2Process(Rand1, b);
                Key = bitxor(OTPublish(b+1,:), s_de2bi(OTVal, GLengthOfKeys));
                
                if sum(abs(Key - Map1(b+1,:))) ~= 0
                    error('OT key is wrong!');
                end
            end
        end
    end
end