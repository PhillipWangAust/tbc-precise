function y = approxExp(x, max_order)
y = 1;
for i = 1:max_order
    y = y + (x.^i)/factorial(i);
end

end