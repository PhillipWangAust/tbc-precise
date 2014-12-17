function Val = OPE(poly, Dp, alpha, k, M)
N = k * Dp + 1;
Sender1 = OPESender(poly, Dp, k, M);
Receivder1 = OPEReceiver(alpha, Dp, k, M);
XVal = zeros(N, 1);
YVal = zeros(N, 1);

[RandPointsX, RandPointsY, Index0] = Receivder1.generatePoints();

parfor n = 1:N
    tempX = RandPointsX((n-1)*M + 1 : n*M);
    tempY = RandPointsY((n-1)*M + 1 : n*M);
    tempVal = Sender1.evalQpoly(tempX, tempY);
    RandomM = randi([1, 2345], M, 1);
    tempVal1 = tempVal .* RandomM;
    
    if M == 2
        SelectVal = OT1of2Process(RandomM, Index0(n));
    else
        SelectVal = OT1ofNProcess(RandomM, Index0(n));
    end
    XVal(n) = tempX(Index0(n)+1);
    YVal(n) = tempVal1(Index0(n)+1)/SelectVal;
end

Val = Receivder1.FitPolyAtAlpha(XVal, YVal);

end