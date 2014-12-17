function bi = s_de2bi(de, NumOfBits)
inds = de < 0;
de(inds) = 2^NumOfBits - abs(de(inds));
bi = de2bi(de, NumOfBits);
end