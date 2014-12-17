function enc_mat = encryptMatrix_fi(PublicKey, matrix, numofThreads)
%% using matlab wraper
%     tic;
%     [m, n] = size(matrix);
%     enc_mat = javaArray('thep.paillier.EncryptedInteger', m, n);
%     for i = 1:m
%         for j = 1:n
%             encryptor = thep.paillier.EncryptedInteger(PublicKey);
%             a = matrix(i, j);
%             encryptor.set(java.math.BigInteger(a.dec));
%             enc_mat(i, j) = encryptor;
%         end
%     end
%     toc
%% using java wraper
%     tic;
%     enc_mat = distributedcoxwithhe.JAVA_HM_Matrix.encryptMatrix(PublicKey, fiMAtrix2Str(matrix));
%     toc
%% using java parallel wraper
%     tic;
    if(~exist('numofThreads', 'var'))
        global numofThreads;
    elseif(isempty(numofThreads))
        clear numofThreads;
        global numofThreads;
    end
    encryptMatrix_java = distributedcoxwithhe.JAVA_HM_Matrix(PublicKey, fiMAtrix2Str(matrix), 'encryptMatrix');
    parallelWorker_java = parallelComputing.ParallelWorker();
    parallelWorker_java.performMTprocessing(numofThreads, encryptMatrix_java);
    enc_mat = encryptMatrix_java.getEnc_matrix();
%     toc
end

