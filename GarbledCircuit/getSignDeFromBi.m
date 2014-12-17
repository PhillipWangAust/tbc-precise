function Val = getSignDeFromBi(bi1)
NumOfBits = size(bi1, 2);
index = ((bi1(:,end) - 1) == 0);
Val = zeros(size(bi1,1),1);
if sum(index) > 0
    Val(not(index)) = bi2de(bi1(not(index),:));
    Val(index) = mod(bi2de(not(bi1(index,:))) + 1, 2^NumOfBits);
else
    Val = bi2de(bi1);
end
end