function [Keys] = setKeysOfInputAForGAdder(InputA, Keys)
NumOfKeys = size(Keys,1);
NumOfBits = (NumOfKeys/2 - 4)/7 + 1;
if 2*NumOfBits ~= size(InputA,1)
    errors('Input Keys doesnot match orignal keys!');
end

Keys(1:2,:) = InputA(1:2,:);

for m = 1:(NumOfBits - 1)
    Keys((8 + (m - 1)*14 + 1):(8 + (m - 1)*14 + 2),:) = InputA((2*m+1):(2*m + 2),:);
end
end