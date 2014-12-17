
function dc_mat = decryptMatrix_fi(A, enc_key, fi_param, numofThreads)
   m = A.length;
   n = A(1).length;
   dc_mat = fi(zeros(m,n), 1, fi_param.f_bits, fi_param.f_fbits, 'fimath', fi_param.F);
   wordLength = numel(dec(dc_mat(1,1)));
   if(~exist('numofThreads', 'var'))
       global numofThreads;
   elseif(isempty(numofThreads))
       clear numofThreads;
       global numofThreads;
   end
%% use matlab wraper
%    tic
%    for i = 1:m
%        tmp_str = '';
%        for j = 1:n
%            tmp_str = sprintf(sprintf('%%s   %%0%ds', wordLength), tmp_str, char(A(i, j).decrypt(enc_key).toString));
%        end
%        dc_mat.dec(i, :) = strtrim(tmp_str);
%    end
%    toc
%% using java wraper
%     tic;
%     dc_mat.dec = char(distributedcoxwithhe.JAVA_HM_Matrix.decryptMatrix(enc_key, A, wordLength));
%     toc
%% using java parallel wraper
%     tic;
    decryptMatrix_java = distributedcoxwithhe.JAVA_HM_Matrix(enc_key, A, wordLength, 'decryptMatrix');
    parallelWorker_java = parallelComputing.ParallelWorker();
    parallelWorker_java.performMTprocessing(numofThreads, decryptMatrix_java);
    dc_mat.dec = char(decryptMatrix_java.getDec_matrix());
%     toc
end