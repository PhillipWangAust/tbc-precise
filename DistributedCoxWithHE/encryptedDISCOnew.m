function encryptedDISCOwithouHessian()
    warning off all; 
    clearvars; % clear java;
%     clear import;
    warning on;
%     clear import;
    warning off all;
    addpath(genpath('.'));
    javarmpath('./thep-0.2.jar');
    warning on;  %#ok<WNON>
    a = javaclasspath;
    if(isempty(a)|| numel(a) == 1 || isempty(strfind(a{2}, 'thep-0.2.jar')))
        initializeJava('./lib/thep-0.2.jar');
    end
    beta1b = [0.04662361 0.16557074 -0.08061256 -0.04669741 0.42733030 0.30508387 0.46840772 -1.55717079 -0.20015416 -0.28199239 -0.98681534 -0.89868068 -0.62474572 -0.07643697 0.05896709 0.03487108 0.00765597 0.00676887 0.64347647 -0.16433476];
    d = load('seer_test.txt');  %% For the seek of simplicity, here we assume all the input data have been sorted by the time. If not, we can use an index mapping table to achieve this goal, but it will not be implemented in this code.
    [~, pos] = sort(d(:, end-1));
    d = d(pos, :);
    Z = d(:, 1:end-2);
    inv_ZZ4 = inv(Z'*Z)*4;
    % split data into two sites
    site_n = 2;
    dc{1} = d(1:863, :);
    dc{2} = d(864:end, :);
    epsilon = 1E-6;
    % get data dimension
    m = size(dc{1}, 2)-2;
    % get number of rows in each site
    full_nc(1) = size(dc{1}, 1);
    full_nc(2) = size(dc{2}, 1);
    full_n = full_nc(1) + full_nc(2);
    
    Zc{1} = dc{1}(:, 1:m);
    Zc{2} = dc{2}(:, 1:m);
    Tc{1} = dc{1}(:, m+1);
    Tc{2} = dc{2}(:, m+1);
    Deltac{1} = dc{1}(:, m+2);
    Deltac{2} = dc{2}(:, m+2);
    
    fi_param.f_bits= 160;
    fi_param.f_fbits = 80;
    fi_param.F = fimath('ProductMode', 'SpecifyPrecision', 'SumMode', 'SpecifyPrecision', 'ProductWordLength', fi_param.f_bits, 'ProductFractionLength', fi_param.f_fbits, 'SumWordLength', fi_param.f_bits, 'SumFractionLength', fi_param.f_fbits);
    fi_param.f_bits2= fi_param.f_bits*2;
    fi_param.f_fbits2 = fi_param.f_fbits*2;
    fi_param.F2 = fimath('ProductMode', 'SpecifyPrecision', 'SumMode', 'SpecifyPrecision', 'ProductWordLength', fi_param.f_bits2, 'ProductFractionLength', fi_param.f_fbits2, 'SumWordLength', fi_param.f_bits2, 'SumFractionLength', fi_param.f_fbits2);
    
    Zc_fi{1} = fi(dc{1}(:, 1:m), 1, fi_param.f_bits, fi_param.f_fbits, 'fimath', fi_param.F); % get fixed point
    Zc_fi{2} = fi(dc{2}(:, 1:m), 1, fi_param.f_bits, fi_param.f_fbits, 'fimath', fi_param.F);
    %%  demonstration of matrix paillier encryption
    bits = 512;
    % create privateKey;
    enc_key = thep.paillier.PrivateKey(bits);
    
%     %% get inversion of zzc
%     zzc{1} = Zc{1}'*Zc{1};
%     zzc{2} = Zc{2}'*Zc{2};
%     zzca = zzc{1} + zzc{2};
%     inv_ZZc = zzca'/sum(sum(zzc{2}))^2;
%     inv_ZZc_tmp = inv_ZZc;
%     len = size(zzca, 1);
%     for i = 1:50
%         inv_ZZc = inv_ZZc*(2*eye(len) - zzca*inv_ZZc);
%     end
%     inv_ZZc4 = 4*inv_ZZc;
    
%     %% get inversion of zzc
    zzc_fi{1} = Zc_fi{1}'*Zc_fi{1};
    zzc_fi{2} = Zc_fi{2}'*Zc_fi{2};
%     zzca_fi = zzc_fi{1} + zzc_fi{2};
%     dd = 1/sum(sum(zzc_fi{2}))^2;
%     inv_ZZc_fi = zzca_fi'*dd;
%     len = zzca_fi.size(1);
%     for i = 1:50
%         inv_ZZc_fi = inv_ZZc_fi*(2*eye(len) - zzca_fi*inv_ZZc_fi);
%     end
%     inv_ZZc4 = 4*inv_ZZc_fi.double;
    %% encryption the intermediate information
    zzc_fi_ec{1} = encryptMatrix_fi(enc_key.getPublicKey, zzc_fi{1});
    zzc_fi_ec{2} = encryptMatrix_fi(enc_key.getPublicKey, zzc_fi{2});
    % secure sum
    zzca_fi_ec = secureMatrixSum(zzc_fi_ec{1}, zzc_fi_ec{2});
    dd_fi = 1/sum(sum(zzc_fi{2}))^2; % done by the second party 
    % secure multiplication
    inv_ZZc_fi_ec = secureMatrixMultiply_fi(secureMatrixTranpose(zzca_fi_ec), dd_fi);
    %% decrypt aggregated information without leaking the intermediate information
    zzca_fi_dc = decryptMatrix_fi(zzca_fi_ec, enc_key, fi_param);
    inv_ZZc_fi_dc = decryptMatrixMultiply_fi(inv_ZZc_fi_ec, enc_key, fi_param);
    for i = 1:50
        inv_ZZc_fi_dc = inv_ZZc_fi_dc*(2*eye(m) - (zzca_fi_dc)*inv_ZZc_fi_dc);
    end
    inv_ZZc4 = 4*inv_ZZc_fi_dc;
    %% test
%     a = fi(6944696, 1, fi_param.f_bits, fi_param.f_fbits, 'fimath', fi_param.F);
%     b = fi(dd_fi, 1, fi_param.f_bits, fi_param.f_fbits, 'fimath', fi_param.F);
%     encryptor1 = thep.paillier.EncryptedInteger(enc_key.getPublicKey);
%     encryptor1.set(java.math.BigInteger(a.dec));
%     encryptor2 = encryptor1.multiply(java.math.BigInteger(b.dec));
%     c = encryptor2.decrypt(enc_key).toString;
%     d = fi(0, 1, fi_param.f_bits2, fi_param.f_fbits2, 'fimath', fi_param.F2);
%     d.dec = char(c);
    %% generate ZZv within each client.
    for s = 1:site_n
        ZZvc{s} = zeros(full_nc(s), m, m);
        for i = 1:full_nc(s)
            tmpZ_i = repmat(Zc{s}(i, :), m, 1);
            ZZvc{s}(i, :, :) =  tmpZ_i' .* tmpZ_i;
        end
    end
    
    %%  client upload unique time ticks to server. We assume there is no privacy within the time ticks information
    T = [Tc{1}; Tc{2}];
    Tuniq = unique(T);
    n = numel(Tuniq);
    %% Server replaces the time ticks, which have only one observation.
    for k = 1:n
        T_idx = find(T == Tuniq(k));
        if(numel(T_idx) == 1)
            if(T_idx == 1)
                T(T_idx) = T(T_idx + 1);
            else
                T(T_idx) = T(T_idx - 1);  
            end
        end
    end
    %% calculate Di, sumZ, index
    for k = 1:n
        T_idx1 = Tc{1} == Tuniq(k);
        T_idx2 = Tc{2} == Tuniq(k);
        index(k, 1) = sum(T_idx1) + sum(T_idx2);
        Delta_idx1 = Deltac{1} == 1;
        Delta_idx2 = Deltac{2} == 1;
        total_idx1 = T_idx1 & Delta_idx1;
        total_idx2 = T_idx2 & Delta_idx2;
        %%
        DI(k, 1) = sum(total_idx1) + sum(total_idx2);
        sumZ(k, :) = sum(Zc{1}(total_idx1, :)) + sum(Zc{2}(total_idx2, :));
    end
    
    index = cumsum([0; index(1:end-1)])+1;
    idx = index <= full_nc(1);
    indexc{1} = index(idx);
    indexc{2} = index(~idx) - full_nc(1);
    DIc{1} = DI(idx);
    DIc{2} = DI(~idx);
    sumZc{1} = sumZ(idx, :);
    sumZc{2} = sumZ(~idx, :);
    nn(1) = size(sumZc{1}, 1);
    nn(2) = size(sumZc{2}, 1);
    
    beta0 = zeros(m, 1) - 1;
    beta1 = zeros(m, 1);
    iter = 0;
    maxIter = 600;
    
    tic;
    
    while(sum(abs(beta0 - beta1)) > epsilon && iter < maxIter)
        iter = iter + 1;
        beta0 = beta1;
        ZBc{1} = exp(Zc{1} * beta0);
        ZBc{2} = exp(Zc{2} * beta0);
        %%
        thetac{2} = rot90(cumsum(ZBc{2}(end:-1:1)), 2);
        thetac{1} = rot90(cumsum(ZBc{1}(end:-1:1)), 2);
        thetac{1} = thetac{1} + thetac{2}(1);
        %%
        thetaZtmpc{1} = Zc{1} .* repmat(ZBc{1}, 1, m);
        thetaZtmpc{2} = Zc{2} .* repmat(ZBc{2}, 1, m);
        
        thetaZtmpc{2}(end:-1:1, :) = cumsum(thetaZtmpc{2}(end:-1:1, :));
        thetaZtmpc{1}(end:-1:1, :) = cumsum(thetaZtmpc{1}(end:-1:1, :));
        thetaZtmpc{1} = thetaZtmpc{1} + repmat(thetaZtmpc{2}(1, :), full_nc(1), 1); 
        
        thetaZtmpc{1} = thetaZtmpc{1} ./ repmat(thetac{1}, 1, m);
        thetaZtmpc{2} = thetaZtmpc{2} ./ repmat(thetac{2}, 1, m);
        
        thetaZc{1} = thetaZtmpc{1}(indexc{1}, :);
        thetaZc{2} = thetaZtmpc{2}(indexc{2}, :);
        %%
        thetaZc{1} = thetaZc{1} .* repmat(DIc{1}, 1, m);
        thetaZc{2} = thetaZc{2} .* repmat(DIc{2}, 1, m);
        
        Gvc{1} = sumZc{1} - thetaZc{1};
        Gvc{2} = sumZc{2} - thetaZc{2};
        
        sumGvc_fi{1} = fi(sum(Gvc{1}), 1, fi_param.f_bits, fi_param.f_fbits, 'fimath', fi_param.F); % get fixed point
        sumGvc_fi{2} = fi(sum(Gvc{2}), 1, fi_param.f_bits, fi_param.f_fbits, 'fimath', fi_param.F);
        sumGvc_fi_ec{1} = encryptMatrix_fi(enc_key.getPublicKey, sumGvc_fi{1});
        sumGvc_fi_ec{2} = encryptMatrix_fi(enc_key.getPublicKey, sumGvc_fi{2});
        G_ec = secureMatrixSum(sumGvc_fi_ec{1}, sumGvc_fi_ec{2});
        G = decryptMatrix_fi(G_ec, enc_key, fi_param);
        beta1 = beta1 + inv_ZZc4.double*G.double';
    end
    toc
    iter
    [beta1, beta1b(:)]
    sum(abs(beta1(:) - beta1b(:)))
end

function enc_mat = encryptMatrix_fi(PublicKey, matrix)
    [m, n] = size(matrix);
    enc_mat = javaArray('thep.paillier.EncryptedInteger', m, n);
    for i = 1:m
        for j = 1:n
            encryptor = thep.paillier.EncryptedInteger(PublicKey);
            a = matrix(i, j);
            encryptor.set(java.math.BigInteger(a.dec));
            enc_mat(i, j) = encryptor;
        end
    end
    
end

function sum_mat = secureMatrixSum(A, B)
   m = A.length;
   n = A(1).length;
   sum_mat = javaArray('thep.paillier.EncryptedInteger', m, n);
   for i = 1:m
        for j = 1:n
            sum_mat(i, j) = thep.paillier.EncryptedInteger(A(i, j)).add(B(i, j));
        end
    end
end

function mul_mat = secureMatrixMultiply_fi(A, B)
   m = A.length;
   n = A(1).length;
   mul_mat = javaArray('thep.paillier.EncryptedInteger', m, n);
   for i = 1:m
        for j = 1:n
            mul_mat(i, j) = thep.paillier.EncryptedInteger(A(i, j)).multiply(java.math.BigInteger(B.dec));
        end
    end
end

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

function dc_mat = decryptMatrix_fi(A, enc_key, fi_param)
   warning off;
   m = A.length;
   n = A(1).length;
   dc_mat = fi(zeros(m,n), 1, fi_param.f_bits, fi_param.f_fbits, 'fimath', fi_param.F);
   a = fi(0, 1, fi_param.f_bits, fi_param.f_fbits, 'fimath', fi_param.F);   
   for i = 1:m
        for j = 1:n
            a.dec = char(A(i, j).decrypt(enc_key).toString);
            dc_mat(i, j) = a;
        end
   end
    warning on;
end

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




