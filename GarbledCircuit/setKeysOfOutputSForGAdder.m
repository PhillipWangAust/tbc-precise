function [Keys] = setKeysOfOutputSForGAdder(OutputS, Keys)
NumOfKeys = size(Keys,1);
NumOfBits = (NumOfKeys/2 - 4)/7 + 1;
if 2*NumOfBits ~= size(OutputS,1)
    errors('Input Keys doesnot match orignal keys!');
end

Keys(5:6,:) = OutputS(1:2,:);

for m = 1:(NumOfBits - 1)
    Keys((5+14*m):(6+14*m),:) = OutputS((2*m+1):(2*m + 2),:);
end
end