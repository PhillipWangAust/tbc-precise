function [Keys] = setKeysOfInputBForGAdder(InputB, Keys)
NumOfKeys = size(Keys,1);
NumOfBits = (NumOfKeys/2 - 4)/7 + 1;
if 2*NumOfBits ~= size(InputB,1)
    errors('Input Keys doesnot match orignal keys!');
end

Keys(3:4,:) = InputB(1:2,:);

for m = 1:(NumOfBits - 1)
    Keys((8 + (m - 1)*14 + 3):(8 + (m - 1)*14 + 4),:) = InputB((2*m+1):(2*m + 2),:);
end
end