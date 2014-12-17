function res = mae_fun(a, b)
    res = mean(abs(double(a(:)) - double(b(:))));
end