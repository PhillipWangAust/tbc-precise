%% preparation
warning off all;
clearvars; % clear java;
%     clear import;
L1 = tic;
warning on;
%     clear import;
warning off all;
addpath(genpath('.'));
javarmpath('./lib/thep-0.2.jar');
javarmpath('./lib/thep-0.2.jar');
warning on;  %#ok<WNON>
a = javaclasspath;
if(isempty(a)|| numel(a) == 1 || isempty(strfind(a{2}, 'thep-0.2.jar')))
    initializeJava('./lib/thep-0.2.jar');
end
warning off all;
javarmpath('./dist/DistributedCoxWithHE.jar');
javarmpath('./dist/DistributedCoxWithHE.jar');
warning on;  %#ok<WNON>
a = javaclasspath;
if(isempty(a)|| numel(a) == 1 || isempty(strfind(a{2}, 'DistributedCoxWithHE.jar')))
    initializeJava('./dist/DistributedCoxWithHE.jar');
end

%% set up fix point 
fi_param.f_bits= 160;
fi_param.f_fbits = fi_param.f_bits/2;
fi_param.f_base = 2^fi_param.f_fbits;
fi_param.F = fimath('ProductMode', 'SpecifyPrecision', 'SumMode', 'SpecifyPrecision', 'ProductWordLength', fi_param.f_bits, 'ProductFractionLength', fi_param.f_fbits, 'SumWordLength', fi_param.f_bits, 'SumFractionLength', fi_param.f_fbits);
fi_param.f_bits2= fi_param.f_bits*2;
fi_param.f_fbits2 = fi_param.f_fbits*2;
fi_param.f_base2 = 2^fi_param.f_fbits*2;
fi_param.F2 = fimath('ProductMode', 'SpecifyPrecision', 'SumMode', 'SpecifyPrecision', 'ProductWordLength', fi_param.f_bits2, 'ProductFractionLength', fi_param.f_fbits2, 'SumWordLength', fi_param.f_bits2, 'SumFractionLength', fi_param.f_fbits2);
%% set up encryption Key
bits_key = 1024;
% create privateKey;
enc_key = thep.paillier.PrivateKey(bits_key);
%%
use_fixed_point =  true;
use_Homomorphic_enc = true;
verify_Homomorphic_enc = true;
print_infom = true;

%% load data and split data into different sites.
load('beta1.mat');
d = load('seer_test.txt');
s = RandStream('mt19937ar','Seed',0);
RandStream.setDefaultStream(s);
d = d(randperm(size(d, 1)), :);
% get data dimension
m = size(d, 2)-2;
num_records = size(d, 1);
site_n = 2;
steps = floor(num_records/site_n);
id_lower = [0:(site_n-1)] * steps + 1;
id_upper = [1:site_n] * steps;
id_upper(site_n) = num_records; 
% Z = d(:, 1:end-2);
% inv_ZZ4 = inv(Z'*Z)*4;
% split data into two sites
for site_id = 1:site_n
    dc{site_id} = d(id_lower(site_id):id_upper(site_id), :);
    [~, pos] = sort(dc{site_id}(:, end-1));
    dc{site_id} = dc{site_id}(pos, :);
    Tc{site_id} = dc{site_id}(:, m+1);
    Deltac{site_id} = logical(dc{site_id}(:, m+2));    
    Zc{site_id} = dc{site_id}(:, 1:m);
    if(use_fixed_point)
        Zc_fi{site_id} = fi(Zc{site_id}, 1, fi_param.f_bits, fi_param.f_fbits, 'fimath', fi_param.F); % get fixed point
    end
end
%% 
max_iter_newton = 50;
L2 = tic;
zzc = zeros(m, m);
inv_zzc_initial = zeros(m, m);
for site_id = 1:site_n
    tmp = Zc{site_id}'*Zc{site_id};
    zzc = zzc + tmp;
    inv_zzc_initial = inv_zzc_initial + tmp/sum(sum(tmp))^2;
end
% inv_ZZc4 = inv(zzc)*4;
inv_ZZc4 = newton_inv(zzc, max_iter_newton, inv_zzc_initial)*4;

%%  fixed point algorithm
if(use_fixed_point)
    L3 = tic;
    zzc_fi = zeros_fi(m, m, fi_param);
    inv_ZZc_fi_initial = zeros_fi(m, m, fi_param);
    for site_id = 1:site_n
        tmp = Zc_fi{site_id}'*Zc_fi{site_id};
        inv_ZZc_fi_initial = inv_ZZc_fi_initial + tmp* (1/sum(sum(tmp)))^2;
        zzc_fi = zzc_fi + tmp;
    end
    inv_ZZc4_fi = newton_inv_fi(zzc_fi, max_iter_newton, inv_ZZc_fi_initial)*4;
    fprintf('   Fixed point inv time: %f s\n',toc(L3));
end

%%  user homomorphic encryption
global numofThreads;

numofThreads = 8;

if(use_Homomorphic_enc)
    L4 = tic;
    zzc_fi_enc = encryptMatrix_fi(enc_key.getPublicKey, zeros_fi(m, m, fi_param));
    % server aggregation through secure sum.
    inv_ZZc_fi_initial_enc = encryptMatrix_fi(enc_key.getPublicKey, zeros_fi(m, m, fi_param));
    for site_id = 1:site_n
        tmp = Zc_fi{site_id}'*Zc_fi{site_id};
        inv_ZZc_fi_initial_enc = secureMatrixSum(inv_ZZc_fi_initial_enc, encryptMatrix_fi(enc_key.getPublicKey, tmp* (1/sum(sum(tmp)))^2));
        zzc_fi_enc = secureMatrixSum(zzc_fi_enc, encryptMatrix_fi(enc_key.getPublicKey, tmp));
    end
%     tmp_rand_fi = rand_fi(m, m, fi_param)*100;
%     zzc_fi_time_rand_enc = secureMatrixMultiply_pairwise_fi(zzc_fi_enc, tmp_rand_fi);
    
    if(verify_Homomorphic_enc)
        zzc_fi_dec = decryptMatrix_fi(zzc_fi_enc, enc_key, fi_param);
        inv_ZZc_fi_initial_dec = decryptMatrix_fi(inv_ZZc_fi_initial_enc, enc_key, fi_param);
%         zzc_fi_time_rand_dec = decryptMatrixMultiply_fi(zzc_fi_time_rand_enc, enc_key, fi_param);
        fprintf('   Error1: %G\n', mae_fun(zzc_fi_dec, zzc_fi));
        fprintf('   Error2: %G\n', mae_fun(inv_ZZc_fi_initial_dec, inv_ZZc_fi_initial));
%         fprintf('   Error3: %G\n', mae_fun(zzc_fi_time_rand_dec ./ tmp_rand_fi, zzc_fi_dec));
    end
    X_fi = inv_ZZc_fi_initial;
    for i = 2:50
        X_fi = X_fi*(2*eye(m) - zzc_fi*X_fi);
    end
    inv_ZZc4_fi_dec = X_fi*4;
    fprintf('   homomorphic encryption inv time: %f s\n',toc(L4));
end

%%  client upload unique time ticks to server. We assume there is no privacy within the time ticks information
T_all = [];
for site_id = 1:site_n
    T_all = [T_all; Tc{site_id};];
end

Tuniq = unique(T_all);
n = numel(Tuniq);

sumZ_all = zeros(1, m);
sumZ_all_fi = zeros(1, m); %fi(zeros(1, m), 1, fi_param.f_bits, fi_param.f_fbits, 'fimath', fi_param.F);
for site_id = 1:site_n
    sumZ{site_id} = sum(Zc{site_id}(Deltac{site_id}, :), 1);
    sumZ_all = sumZ_all + sumZ{site_id};
    
    if(use_fixed_point)
        sumZ_fi{site_id} = sum(Zc_fi{site_id}(Deltac{site_id}, :), 1);
        sumZ_all_fi = sumZ_all_fi + sumZ_fi{site_id};
        DI_fi{site_id} = repmat(fi(hist(Tc{site_id}(Deltac{site_id}), Tuniq)', 1, fi_param.f_bits, fi_param.f_fbits, 'fimath', fi_param.F), 1, m);
    end
    
    DI{site_id} = repmat(hist(Tc{site_id}(Deltac{site_id}), Tuniq)', 1, m);
    PInd{site_id} = hist(Tc{site_id}, Tuniq)';
    startID{site_id} = cumsum([0; PInd{site_id}(1:(end-1))]) + 1;
end
fprintf('    Initialization time: %f s\n',toc(L1));
%%
beta1 = zeros(m, 1);
beta0 = beta1 - 1;

beta1_fi = zeros(m, 1); %fi(zeros(m, 1), 1, fi_param.f_bits, fi_param.f_fbits, 'fimath', fi_param.F);
beta0_fi = beta1_fi - 1;

iter = 0;
maxIter = 1000;
epsilon = 1E-6;
max_order_approxExp = 50;
while(sum(abs(beta0 - beta1)) > epsilon && iter < maxIter)
    h1 = tic;
    iter = iter + 1;
    if(use_fixed_point)
        fprintf('iter: %d \n', iter);
    end
    beta0 = beta1;
    part2_d = zeros(n, 1);
    part2_u2 = zeros(n, m);
    
    for site_id = 1:site_n
        ZBc{site_id} = exp(Zc{site_id} * beta0);
        tmp = [rot90(cumsum(ZBc{site_id}(end:-1:1)), 2); 0];
        part2_d = part2_d + tmp(startID{site_id});
        tmp = Zc{site_id} .* repmat(ZBc{site_id}, 1, m);
        tmp((end+1):-1:1, :) = [zeros(1, m); cumsum(tmp(end:-1:1, :))];
        for site_id_inner = 1:site_n
            part2_u2 = part2_u2 + DI{site_id_inner} .* tmp(startID{site_id}, :);
        end
    end
    G = sumZ_all - sum(part2_u2./repmat(part2_d, 1, m), 1);
    beta1 = beta0 + inv_ZZc4*G';
    %%
    if(use_fixed_point)
        h2 = tic;
        beta0_fi = beta1_fi;
        part2_d_fi = zeros(n, 1); %fi(zeros(n, 1), 1, fi_param.f_bits, fi_param.f_fbits, 'fimath', fi_param.F);
        part2_u2_fi = zeros(n, m); %fi(zeros(n, m), 1, fi_param.f_bits, fi_param.f_fbits, 'fimath', fi_param.F);
        for site_id = 1:site_n
            ZBc_fi{site_id} = approxExp_fi(Zc_fi{site_id} * beta0_fi, max_order_approxExp, [-20, 20]);
            tmp_fi = [rot90(cumsum_fi(ZBc_fi{site_id}(end:-1:1)), 2); 0];
            part2_d_fi = part2_d_fi + tmp_fi(startID{site_id});
            tmp_fi = Zc_fi{site_id} .* repmat(ZBc_fi{site_id}, 1, m);
            tmp_fi((end+1):-1:1, :) = [zeros_fi(1, m, fi_param); cumsum_fi(tmp_fi(end:-1:1, :))];
            for site_id_inner = 1:site_n
                part2_u2_fi = part2_u2_fi + DI{site_id_inner} .* tmp_fi(startID{site_id}, :);
            end
        end
        G_fi = sumZ_all_fi - sum(part2_u2_fi.* repmat(1./part2_d_fi, 1, m), 1);
        beta1_fi = beta0_fi + inv_ZZc4_fi*G_fi';
        if(print_infom)
            %disp([beta1_fi.double'; beta1']);
            fprintf('   >          MAE fi vs non_fi: %G\n', mae_fun(beta1_fi.double(:), beta1(:)));
            fprintf('   >    MAE between iter in fi: %G;      MAE fi vs central: %G\n', mae_fun(beta0_fi, beta1_fi), mae_fun(beta1_fi.double, beta1b));
            fprintf('   >MAE between iter in non_fi: %G;  MAE non_fi vs central: %G\n', mae_fun(beta0, beta1), mae_fun(beta1, beta1b));
            fprintf('   >Time cost: %f s; fixed point cost: %f s\n\n', toc(h1), toc(h2));
        end
    end
end
% beta1
fprintf('Average error: %G \nTotal run time: %f s\n\n', mae_fun(beta1, beta1b), toc(L1));