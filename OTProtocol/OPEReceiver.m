classdef OPEReceiver
    properties
        Alpha
        Dp
        K
        M
        N
        SPoly
        X0
        Selected0
    end
    
    methods
        function obj= OPEReceiver(Alpha0, Dp0, K0, M0)
            obj.Alpha = Alpha0;
            obj.Dp = Dp0;
            obj.K = K0;
            obj.M = M0;
            obj.N = K0 * Dp0 + 1;
             
            tempCoeff = rand(K0 + 1, 1) * 2 - 1;
            tempCoeff(1) = Alpha0;
            obj.SPoly = @(x)(approxExp_fi(x, tempCoeff));
        end
        
        function [RandPointsX, RandPointsY, Index0] =generatePoints(obj)
            N0 = obj.M * obj.N;
            RandPointsX = rand(N0, 1) * 2 - 1;
            RandPointsY = rand(N0, 1) * 2 - 1;
            while sum(RandPointsX == 0) || sum(RandPointsY == 0)
                RandPointsX = rand(N0, 1) * 2 - 1;
                RandPointsY = rand(N0, 1) * 2 - 1;
            end
            
            obj.X0 = RandPointsX;
            Index0 = randi([0, (obj.M-1)], 1, obj.N);
            obj.Selected0 = Index0;
            IndX0 = (obj.Selected0 + (0:(obj.N - 1)) * obj.M + 1)';
            
            RandPointsY(IndX0) = obj.SPoly(RandPointsX(IndX0));
        end
        
        function Val = FitPolyAtAlpha(obj, XVal, YVal)
            poly0 = polyfit(XVal, YVal, obj.N - 1);
            Val = polyval(poly0, 0);
        end
    end
end