clear;

addpath(genpath('.'));

%% set up fix point 
fi_param.f_bits= 16;
fi_param.f_fbits = fi_param.f_bits/2;
fi_param.f_base = 2^fi_param.f_fbits;
fi_param.F = fimath('ProductMode', 'SpecifyPrecision', 'SumMode', 'SpecifyPrecision', 'ProductWordLength', fi_param.f_bits, 'ProductFractionLength', fi_param.f_fbits, 'SumWordLength', fi_param.f_bits, 'SumFractionLength', fi_param.f_fbits);
fi_param.f_bits2= fi_param.f_bits/2;
fi_param.f_fbits2 = fi_param.f_fbits/2;
fi_param.f_base2 = 2^fi_param.f_fbits2;
fi_param.F2 = fimath('ProductMode', 'SpecifyPrecision', 'SumMode', 'SpecifyPrecision', 'ProductWordLength', fi_param.f_bits2, 'ProductFractionLength', fi_param.f_fbits2, 'SumWordLength', fi_param.f_bits2, 'SumFractionLength', fi_param.f_fbits2);


%%
tmp1 = fi(0, 1, fi_param.f_bits, fi_param.f_fbits, 'fimath', fi_param.F);
tmp2 = fi(0, 1, fi_param.f_bits2, fi_param.f_fbits2, 'fimath', fi_param.F2);
a1 = fi(-2.5, 1, fi_param.f_bits2, fi_param.f_fbits2, 'fimath', fi_param.F2);
a2 = fi(2.5, 1, fi_param.f_bits2, fi_param.f_fbits2, 'fimath', fi_param.F2);
a1h = fi(-2.5, 1, fi_param.f_bits, fi_param.f_fbits, 'fimath', fi_param.F);
a2h = fi(2.5, 1, fi_param.f_bits, fi_param.f_fbits, 'fimath', fi_param.F);
a3 = a1*a2;
a3h = a1h*a2h;
tmp2.dec = disp(mod(vpi(a1.dec)*vpi(a2.dec), 2^(fi_param.f_bits2))); tmp2.double
% tmp2.dec = disp(vpi(a1.dec)*vpi(a2.dec)/2^(fi_param.f_fbits2)); tmp2.double
