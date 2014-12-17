function mul_mat = secureMatrixMultiply_fi(A, B)
    % does not work. need to check precision.
   % alway perform A*B
   if(isfi(B)) % B is not encrypted for A*B
       n = size(B, 2);
   else % B is encrypted for A*B
       n = size(B(1), 2);
   end
   m = size(A, 1);
   
   mul_mat = javaArray('thep.paillier.EncryptedInteger', m, n);
   for i = 1:m
       for j = 1:n
           mul_mat(i, j) = innerProduct(A(i, :), B(:, j));
       end
   end
end

function sum_val = innerProduct(v1, v2)
    sum_val = thep.paillier.EncryptedInteger(v1(1)).multiply(java.math.BigInteger(getfield(v2(1), 'dec')));
    len = size(v2, 1);
    for i = 2:len
        sum_val = thep.paillier.EncryptedInteger(sum_val).add(thep.paillier.EncryptedInteger(v1(i)).multiply(java.math.BigInteger(getfield(v2(i), 'dec')))); 
    end
end