function Result1 = RandFunc(Key, val, NumOfBits)
rng(Key);
temp = randi([0,2^NumOfBits - 1],val,1);
Result1 = temp(val);
end