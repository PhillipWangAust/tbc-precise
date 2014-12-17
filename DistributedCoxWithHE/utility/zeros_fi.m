function res = zeros_fi(m, n, fi_param)
    res = fi(zeros(m, n), 1, fi_param.f_bits, fi_param.f_fbits, 'fimath', fi_param.F);
end