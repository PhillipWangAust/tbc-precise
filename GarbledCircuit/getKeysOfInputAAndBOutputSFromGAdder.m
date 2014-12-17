function [KeysOfInputA KeysOfInputB KeysOfOutputS] = getKeysOfInputAAndBOutputSFromGAdder(Keys)
NumOfKeys = size(Keys,1);
NumOfBits = (NumOfKeys/2 - 4)/7 + 1;
KeysOfInputA(1:2,:) = Keys(1:2,:);
KeysOfInputB(1:2,:) = Keys(3:4,:);
KeysOfOutputS(1:2,:)= Keys(5:6,:);

for m = 1:(NumOfBits - 1)
    KeysOfInputA((2*m+1):(2*m + 2),:) = Keys((8 + (m - 1)*14 + 1):(8 + (m - 1)*14 + 2),:);
    KeysOfInputB((2*m+1):(2*m + 2),:) = Keys((8 + (m - 1)*14 + 3):(8 + (m - 1)*14 + 4),:);
    KeysOfOutputS((2*m+1):(2*m+2),:) = Keys((5+14*m):(6+14*m),:);
end
end