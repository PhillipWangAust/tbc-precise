function y = approxExp_fi(x, coeff)
max_order = numel(coeff) - 1;
y = coeff(1);
tmp = 1;
for m = 1:max_order
    tmp = tmp/m.*x;
    y = y + tmp .* coeff(m+1);
end

end