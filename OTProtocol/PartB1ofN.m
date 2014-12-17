classdef PartB1ofN < PartB
    properties
        L
        BitsOfB
        KVal
        Ys
    end
    methods
        function obj = PartB1ofN(b, L)
            obj = obj@PartB(b);
            obj.BitsOfB = de2bi(b-1,L);
            obj.L = L;
        end
        
        function obj =setKVal(obj, KVal)
            obj.KVal = KVal;
        end
        
        function obj = receiveYsFromA(obj, Ys)
            obj.Ys = Ys;
        end
        
        function m_b = getMb(obj)
            m_b = obj.Ys(obj.b);
            
            for m = 1:obj.L
                m_b = bitxor(m_b, RandFunc(obj.KVal(m), obj.b, PartA1ofN.NumOfBits));
            end
        end
    end
end