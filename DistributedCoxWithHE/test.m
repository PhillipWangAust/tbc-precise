clear

%% set up fix point 
fi_param.f_bits= 100;
fi_param.f_fbits = fi_param.f_bits/2;
fi_param.F = fimath('ProductMode', 'SpecifyPrecision', 'SumMode', 'SpecifyPrecision', 'ProductWordLength', fi_param.f_bits, 'ProductFractionLength', fi_param.f_fbits, 'SumWordLength', fi_param.f_bits, 'SumFractionLength', fi_param.f_fbits);


a = 5.72;

a_hat = fi(a, 1, fi_param.f_bits, fi_param.f_fbits, 'fimath', fi_param.F);


e_a_hat = approxExp_fi(a_hat, 50, [-20, 20]);


e_a = exp(a);

