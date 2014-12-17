function de = s_bi2de(bi)
NumOfBits = size(bi, 2);
inds = bi(:,end) > 0;
de = bi2de(bi);
de(inds) = de(inds) - 2^NumOfBits;
end