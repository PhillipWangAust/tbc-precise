function mul_mat = secureMatrixMultiplyEcVector_fi(A, B)
   [m, n] = size(A);
   mul_mat = javaArray('thep.paillier.EncryptedInteger', m, 1);
   for i = 1:m
        mul_mat(i, 1) = thep.paillier.EncryptedInteger(B(1, 1).getPublicKey);
        mul_mat(i, 1).set(java.math.BigInteger(0));
        for j = 1:n
            a = A(i, j);
            mul_mat(i, 1) = mul_mat(i, 1).add(B(1, j).multiply(java.math.BigInteger(a.dec)));
        end
    end
end