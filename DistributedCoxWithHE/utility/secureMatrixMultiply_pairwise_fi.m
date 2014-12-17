function mul_mat = secureMatrixMultiply_pairwise_fi(A, B)
   assert(isfi(B), 'B is not a fixed point matrix');
   [m, n] = size(B);  
   mul_mat = javaArray('thep.paillier.EncryptedInteger', m, n);
   for i = 1:m
       for j = 1:n
           mul_mat(i, j) = thep.paillier.EncryptedInteger(A(i, j)).multiply(java.math.BigInteger(getfield(B(i, j), 'dec')));
       end
   end
end