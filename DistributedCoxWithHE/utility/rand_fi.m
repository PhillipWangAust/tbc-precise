function res = rand_fi(m, n, fi_param)
    res = fi(rand(m, n), 1, fi_param.f_bits, fi_param.f_fbits, 'fimath', fi_param.F);
end