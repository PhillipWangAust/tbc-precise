function dc_mat = decryptMatrixMultiply_fi(A, enc_key, fi_param)
   m = A.length;
   n = A(1).length;
   dc_mat = fi(zeros(m,n), 1, fi_param.f_bits, fi_param.f_fbits, 'fimath', fi_param.F);
   a = fi(0, 1, fi_param.f_bits2, fi_param.f_fbits2, 'fimath', fi_param.F2);   
   for i = 1:m
        for j = 1:n
            a.dec = char(A(i, j).decrypt(enc_key).toString);
            dc_mat(i, j) = a;
        end
    end
end