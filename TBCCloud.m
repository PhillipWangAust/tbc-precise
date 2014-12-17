classdef TBCCloud
    properties
        b
        PubKey
    end
    methods
        function obj = setPubKey(PubKey)
            obj.PubKey = PubKey;
        end
    end
end