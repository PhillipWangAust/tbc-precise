classdef Facility
    properties
        PubKey
        F1
        fi_word,
        fi_fraction
        Data0
        Counts
    end
    methods
        function obj = Facility(PubKey, F1, fi_word, fi_fraction, Data0)
            obj.PubKey = PubKey;
            obj.F1 = F1;
            obj.fi_word = fi_word;
            obj.fi_fraction = fi_fraction;
            obj.Data0 = Data0;
        end
        
        function obj = getEachCounts(obj, func)
            obj.Counts = func(obj.Data0);
            obj.Counts = StatFunc(obj.Data0);
        end
        
        function [EncCount, Counts] = encryptForEachcounts(obj)
            EncCount = cell(numel(obj.Counts), 1);
            Counts = obj.Counts;
            
            
            for m = 1:numel(EncCount)
                EncCount{m} = encryptMatrix_fi(obj.PubKey{m}, fi(obj.Counts(m), 1, obj.fi_word, obj.fi_fraction, 'fimath', obj.F1));
            end
        end
    end
end