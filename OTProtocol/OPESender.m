classdef OPESender
    properties
        PPoly
        QPoly
        Dp
        Dr
        K
        M
    end
    
    methods
        function obj = OPESender(Poly0, Dp0, K0, M0)
            obj.PPoly = Poly0;
            obj.Dp = Dp0;
            obj.K = K0;
            obj.M = M0;
            obj.Dr = K0 * Dp0 + 1;
            
            tempCoeff = rand(obj.Dr, 1) * 2 - 1;
            tempCoeff(1) = 0;
            
            obj.QPoly = @(x,y)(approxExp_fi(x, tempCoeff) + Poly0(y)); 
        end
        
        function Val1 = evalQpoly(obj, X, Y)
            Val1 = obj.QPoly(X, Y);
        end
    end
end