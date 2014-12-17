function bi1 = getBiForGivenNumOfBits(num1, NumOfBits)
bi1 = de2bi(abs(num1), NumOfBits);

if num1 < 0
    bi1 = not(bi1);
    bi1 = de2bi(mod(bi2de(bi1) + 1, 2^NumOfBits),NumOfBits);
end
end