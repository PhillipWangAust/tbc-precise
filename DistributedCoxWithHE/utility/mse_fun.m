function res = mse_fun(a, b)
    res = mean((a(:) - b(:)).^2);
end