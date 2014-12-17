%% preparation
warning off all;
clearvars; % clear java;
%     clear import;
L1 = tic;
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
%% set up fix point 
fi_param.f_bits= 160;
fi_param.f_fbits = fi_param.f_bits/2;
fi_param.F = fimath('ProductMode', 'SpecifyPrecision', 'SumMode', 'SpecifyPrecision', 'ProductWordLength', fi_param.f_bits, 'ProductFractionLength', fi_param.f_fbits, 'SumWordLength', fi_param.f_bits, 'SumFractionLength', fi_param.f_fbits);
fi_param.f_bits2= fi_param.f_bits*2;
fi_param.f_fbits2 = fi_param.f_fbits*2;
fi_param.F2 = fimath('ProductMode', 'SpecifyPrecision', 'SumMode', 'SpecifyPrecision', 'ProductWordLength', fi_param.f_bits2, 'ProductFractionLength', fi_param.f_fbits2, 'SumWordLength', fi_param.f_bits2, 'SumFractionLength', fi_param.f_fbits2);
%% set up encryption Key
bits_key = 512;
% create privateKey;
enc_key = thep.paillier.PrivateKey(bits_key);
%%
use_fixed_point = true;
print_infom = true;

%% load data and split data into different sites.
load('beta1.mat');
d = load('seer_test.txt');
s = RandStream('mt19937ar','Seed',0);
RandStream.setGlobalStream(s);
d = d(randperm(size(d, 1)), :);
% get data dimension
m = size(d, 2)-2;
num_records = size(d, 1);
site_n = 3;
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
L2 = tic;
zzc = zeros(m, m);
for site_id = 1:site_n
    zzc = zzc + Zc{site_id}'*Zc{site_id};
end
% inv_ZZc4 = inv(zzc)*4;
% newton method for matrix inversion
X{1} = zzc'/(max(sum(zzc, 2))*max(sum(zzc, 1)));
for i = 2:50    
    X{i} = X{i-1}*(2*eye(m) - zzc*X{i-1});
end
inv_ZZc4 = X{end}*4;
%%  fixed point algorithm
if(use_fixed_point)
    L3 = tic;
    zzc_fi = zeros(m, m);
    for site_id = 1:site_n
        zzc_fi = zzc_fi + Zc_fi{site_id}'*Zc_fi{site_id};
    end
    
    X_fi = zzc_fi' * (1/max(sum(zzc_fi, 2)))*(1/max(sum(zzc_fi, 1)));
    for i = 2:50
        X_fi = X_fi*(2*eye(m) - zzc_fi*X_fi);
    end
    inv_ZZc4_fi = X_fi*4;
    fprintf('   Fixed point inv time: %f s\n',toc(L3));
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
            tmp_fi((end+1):-1:1, :) = [fi(zeros(1, m), 1, fi_param.f_bits, fi_param.f_fbits, 'fimath', fi_param.F); cumsum_fi(tmp_fi(end:-1:1, :))];
            for site_id_inner = 1:site_n
                part2_u2_fi = part2_u2_fi + DI{site_id_inner} .* tmp_fi(startID{site_id}, :);
            end
        end
        G_fi = sumZ_all_fi - sum(part2_u2_fi.* repmat(1./part2_d_fi, 1, m), 1);
        beta1_fi = beta0_fi + inv_ZZc4_fi*G_fi';
        if(print_infom)
            %disp([beta1_fi.double'; beta1']);
            fprintf('   >          MAE fi vs non_fi: %G\n', mean(abs(beta1_fi.double(:) - beta1(:))));
            fprintf('   >    MAE between iter in fi: %G;      MAE fi vs central: %G\n', mean(abs(double(beta0_fi - beta1_fi))), mean(abs(beta1_fi.double - beta1b)));
            fprintf('   >MAE between iter in non_fi: %G;  MAE non_fi vs central: %G\n', mean(abs(beta0 - beta1)), mean(abs(beta1 - beta1b)));
            fprintf('   >Time cost: %f s; fixed point cost: %f s\n\n', toc(h1), toc(h2));
        end
    end
end
% beta1
fprintf('Average error: %G \nTotal run time: %f s\n\n', mean(abs(beta1 - beta1b)), toc(L1));