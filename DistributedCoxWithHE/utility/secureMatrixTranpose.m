function B = secureMatrixTranpose(A)
   m = A.length;
   n = A(1).length;
   B = javaArray('thep.paillier.EncryptedInteger', n, n);
   for i = 1:n
        for j = 1:m
            B(i, j) = thep.paillier.EncryptedInteger(A(j, i));
        end
    end
end
