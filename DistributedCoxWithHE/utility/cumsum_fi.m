function a = cumsum_fi(a)
    for i = 2:size(a, 1)
        a(i, :) = a(i, :) + a(i-1, :);
    end
end