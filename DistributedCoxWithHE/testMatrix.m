clear;
syms c real
A = sym('A', [1, 3]);
assume(A, 'real');
%Z = sum(A);
syms Z real
Y = Z;
for i = 1:8   
    Y = Y*(2 - Z*Y);
    fprintf('===========================\niter: %d\n', i);
    pretty(expand(Y));
end

