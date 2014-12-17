function inv_A = newton_inv(A, max_iter, inv_A_initial)
    % newton method for matrix inversion
    [m, n] = size(A);
    assert(m == n, 'num of cols and rows must be equal');
    if(exist('inv_A_initial', 'var') && ~isempty(inv_A_initial))
        inv_A = inv_A_initial;
    else
        %     inv_A = A'/(max(sum(A, 2))*max(sum(A, 1)));
        inv_A = A'/(sum(sum(A))^2);
    end
    for i = 2:max_iter
        %     X{i} = X{i-1}*(2*eye(m) - zzc*X{i-1});
        inv_A = inv_A*(2*eye(m) - A*inv_A);
    end
end