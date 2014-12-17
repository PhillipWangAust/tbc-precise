function y = StatFunc(x)

% age
data1 = x(:,4);
data2 = x(:,3);
data3 = x(:,7);

y = sum((data1 > 50) & (data2 == 2)&(data3 ~= 2));

% for m = 1:6
%     y(1,m) = sum((data1 >= (m+1) * 10) & (data1 < (m+2)*10));
% end
% y(1,7) = sum(data1 >= 80);
% 
% y = round(y ./ sum(y) .* 100);
%end
end