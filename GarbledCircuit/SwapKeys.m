function Keys = SwapKeys(Keys)
temp1 = Keys(1:2:end,:);
temp2 = Keys(2:2:end,:);
Keys(1:2:end) = temp2;
Keys(2:2:end) = temp1;
end