function inv_A_fi = newton_inv_fi(A_fi, max_iter, inv_A_fi_initial)
    % newton method for matrix inversion
    [m, n] = size(A_fi);
    assert(m == n, 'num of cols and rows must be equal');
    if(exist('inv_A_fi_initial', 'var') && ~isempty(inv_A_fi_initial))
        inv_A_fi = inv_A_fi_initial;
    else
%         inv_A_fi = A_fi' * (1/max(sum(A_fi, 2)))*(1/max(sum(A_fi, 1)));
        inv_A_fi = A_fi' * (1/sum(sum(A_fi)))^2;
    end
    for i = 2:max_iter
        inv_A_fi = inv_A_fi*(2*eye(m) - A_fi*inv_A_fi);
%         inv_A_fi = 2*inv_A_fi - inv_A_fi*zzc_fi*inv_A_fi;
    end
end