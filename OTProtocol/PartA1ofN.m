classdef PartA1ofN < PartA
    properties
        L
        K
        Y
    end
    
    properties (Constant)
        MaxRandomNum = 1000000;
        NumOfBits = 32;
    end
    
    methods
        function obj = PartA1ofN(m)     
            obj = obj@PartA(m);
            N = numel(m);
            obj.L = log2(N);
            if mod(obj.L,1) ~= 0
                error('The number of m should be power of 2 in PartA1ofN!');
            end
            obj.K = randi(PartA1ofN.MaxRandomNum, 2, obj.L);
            
            obj.Y = obj.m;
            for n = 1:N
                tempBits = de2bi(n-1, obj.L);
                for m = 1:obj.L
                    obj.Y(n) = bitxor(obj.Y(n), RandFunc(obj.K(tempBits(m)+1,m), n, PartA1ofN.NumOfBits));
                end
            end
            
        end
        
        function L = getL(obj)
            L = obj.L;
        end
        
        function Ys = sendYs2PartB(obj)
            Ys = obj.Y;
        end
    end
    
end