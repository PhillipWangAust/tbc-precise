classdef PartB1of2 < PartB
    properties
        N
        PubKey
        x
        k
        Mp
    end
    
    
    methods
        function obj = PartB1of2(b)
            obj = obj@PartB(b);
            obj.k = randi([1,10^6],1);
        end
        
        function obj = receiveXFromPartA(obj, x)
            obj.x = x;
        end
        
        function obj = receivePubKeyFromPartA(obj, PubKey)
            obj.PubKey = PubKey;      
        end
        
        function obj = receiveNFromPartA(obj,N)
            obj.N = N;
        end
        
        function v = sendv2PartA(obj)
            xb= obj.x(obj.b+1);
            v = powermod(obj.k, obj.PubKey, obj.N);
            v= mod(v+xb, obj.N);
        end
        
        function obj = receiveMpFromPartA(obj, Mp)
            obj.Mp = Mp;
        end
        
        function Mb = getMb(obj)
            Mb = obj.Mp(obj.b+1) - obj.k;
        end
    end
end