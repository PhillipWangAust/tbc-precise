function sum_mat = secureMatrixSum(A, B, method, numofThreads)
    if(~exist('method', 'var') || isempty(method))
        method = 'pairwise';
    end
    
    if(~exist('numofThreads', 'var'))
        global numofThreads;
    elseif(isempty(numofThreads))
        clear numofThreads;
        global numofThreads;
    end
    
    switch method
        case 'pairwise'
            sum_mat = secureMatrixPairwiseSum(A, B, numofThreads);
        otherwise
            sum_mat = [];
            warning('method is unknown');
    end

end

function sum_mat = secureMatrixPairwiseSum(A, B, numofThreads)
    %% use matlab wraper
%    tic;
%    m = A.length;
%    n = A(1).length;
%    sum_mat = javaArray('thep.paillier.EncryptedInteger', m, n);
%    for i = 1:m
%         for j = 1:n
%             sum_mat(i, j) = thep.paillier.EncryptedInteger(A(i, j)).add(B(i, j));
%         end
%    end
%    toc
%% using java wraper
%     tic;
%     sum_mat = distributedcoxwithhe.JAVA_HM_Matrix.secureMatrixPairwiseSum(A, B);
%     toc
%% using java parallel wraper
%     tic;
    secureMatrixPairwiseSum_java = distributedcoxwithhe.JAVA_HM_Matrix(A, B, 'secureMatrixPairwiseSum');
    parallelWorker_java = parallelComputing.ParallelWorker();
    parallelWorker_java.performMTprocessing(numofThreads, secureMatrixPairwiseSum_java);
    sum_mat = secureMatrixPairwiseSum_java.getEnc_matrix();
%     toc
end