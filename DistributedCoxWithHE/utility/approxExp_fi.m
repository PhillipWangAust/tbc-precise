function y = approxExp_fi(x, max_order, bounds)
if(exist('bounds', 'var') && ~isempty(bounds) && (min(x.double) < bounds(1) || max(x.double) > bounds(2)))
    x(x < bounds(1)) = bounds(1);
    x(x > bounds(2)) = bounds(2);
    warning('ApproxExp values (%f, %f) exceed bound (%f, %f)', min(x.double), max(x.double), bounds(1), bounds(2));
end
y = 1;
tmp = 1;
for i = 1:max_order
    tmp = tmp/i.*x;
    y = y + tmp;
end

end