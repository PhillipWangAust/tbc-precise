%test OPE
clear all;
addpath(genpath('.'));
Degree = 1000;
k = 3;
m = 2;
alpha = 600.0;
coeff1 = ones(Degree + 1,1);%rand(5,1) * 2 - 1;

func1 = @(x)(approxExp_fi(x, coeff1));
tic;
Val = OPE(func1, Degree, alpha, k, m);
display(sprintf('Val = %e, func1(alpha) = %e, exp(alpha) = %e', Val, func1(alpha), exp(alpha)));
toc;
%end