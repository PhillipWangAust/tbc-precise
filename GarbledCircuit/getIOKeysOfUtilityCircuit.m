function Keys = getIOKeysOfUtilityCircuit(NumOfChildren, NumOfClasses, NumOfBits, LengthOfData)

for m = 1:NumOfChildren
    for n = 1:NumOfClasses
        temp1 = logical(round(rand(2 * NumOfBits, LengthOfData)));
        temp2 = logical(round(rand(2 * NumOfBits, LengthOfData)));
        Input(m,n) = struct('KeysOfInputA', temp1, 'KeysOfInputB', temp2);
    end
end
Output = logical(round(rand(2 * NumOfBits, LengthOfData)));
Keys = struct('Input',Input,'Output',Output);
end