classdef PartA1of2 < PartA
    properties
        cipher
        keyPair
        x
        v
        
        %RSA
        p
        q
        PhiN
        N
        PubKey
        PrvKey
        %end
    end
    
    
    methods
        function obj = PartA1of2(m)
            obj = obj@PartA(m);
            
%             obj.p = vpi('16166223861194825652016705970903');
%             obj.q = vpi('61570799792903542731038087086913');
%             obj.PhiN = vpi('995367332764886682184783526439670225371729846961751693817034624');
%             obj.N = vpi('995367332764886682184783526439747962395383945330134748610092439');
%             obj.PubKey = vpi(65537);
%             obj.PrvKey = vpi('708544437617643369352953615140508344203151514723890932144472577');
%             
%             obj.x = vpi(randi([1,2^50],2,1));

            obj.p = 9070583;
            obj.q = 7290001;
            obj.N = 66124559140583;
            obj.PhiN = 66124542780000;
            obj.PubKey = 65537;
            obj.PrvKey = 61472204913473;
            
            obj.x = randi([1,10^6],2,1);
        end
        
        function x = sendX2PartB(obj)
            x = obj.x;
        end
        
        function PubKey = sendPubKey2PartB(obj)
            PubKey = obj.PubKey;      
        end
        
        function N = sendN2PartB(obj)
            N = obj.N;       
        end
        
        function obj = receiveVFromPartB(obj,v)
            obj.v = v;
        end
        
        function mp = sendMp2PartB(obj)
            mp(1) = powermod(obj.v - obj.x(1), obj.PrvKey, obj.N) + obj.m(1);
            mp(2) = powermod(obj.v - obj.x(2), obj.PrvKey, obj.N) + obj.m(2);
        end
    end
end