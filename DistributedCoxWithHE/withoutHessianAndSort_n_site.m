clear;
load('beta1.mat');
d = load('seer_test.txt');
s = RandStream('mt19937ar','Seed',0);
RandStream.setGlobalStream(s);
d = d(randperm(size(d, 1)), :);
% get data dimension
m = size(d, 2)-2;
num_records = size(d, 1);
site_n = 1;
steps = floor(num_records/site_n);
id_lower = [0:(site_n-1)] * steps + 1;
id_upper = [1:site_n] * steps;
id_upper(site_n) = num_records;
%% 
% Z = d(:, 1:end-2);
% inv_ZZ4 = inv(Z'*Z)*4;
% split data into two sites
dc = cell(site_n, 1);
Zc = cell(site_n, 1);
Tc = cell(site_n, 1);
Deltac = cell(site_n, 1); 
for site_id = 1:site_n
    dc{site_id} = d(id_lower(site_id):id_upper(site_id), :);
    [~, pos] = sort(dc{site_id}(:, end-1));
    dc{site_id} = dc{site_id}(pos, :);
    Zc{site_id} = dc{site_id}(:, 1:m);
    Tc{site_id} = dc{site_id}(:, m+1);
    Deltac{site_id} = logical(dc{site_id}(:, m+2));
end

%%
zzc = zeros(m, m);
for site_id = 1:site_n
    zzc = zzc + Zc{site_id}'*Zc{site_id};
end
% inv_ZZc4 = inv(zzc)*4;
% newton method for matrix inversion
len = size(zzc, 2);
X{1} = zzc'/(max(sum(zzc, 2))*max(sum(zzc, 1)));
for i = 2:50    
    X{i} = X{i-1}*(2*eye(len) - zzc*X{i-1});
end
inv_ZZc4 = X{end}*4;

%%  client upload unique time ticks to server. We assume there is no privacy within the time ticks information
T_all = [];
for site_id = 1:site_n
    T_all = [T_all; Tc{site_id};];
end

Tuniq = unique(T_all);
n = numel(Tuniq);

sumZ_all = zeros(1, m);
for site_id = 1:site_n
    sumZ{site_id} = sum(Zc{site_id}(Deltac{site_id}, :), 1);
    sumZ_all = sumZ_all + sumZ{site_id};
    
    DI{site_id} = repmat(hist(Tc{site_id}(Deltac{site_id}), Tuniq)', 1, m);
    PInd{site_id} = hist(Tc{site_id}, Tuniq)';
    startID{site_id} = cumsum([0; PInd{site_id}(1:(end-1))]) + 1;
end

%%
beta0 = zeros(m, 1) - 1;
beta1 = zeros(m, 1);
iter = 0;
maxIter = 1000;
epsilon = 1E-6;
tic;
max_val = -inf;
min_val = inf;
max_order_approxExp = 100;
while(sum(abs(beta0 - beta1)) > epsilon && iter < maxIter)
    iter = iter + 1;
    beta0 = beta1;
    part2_d = zeros(n, 1);
    part2_u2 = zeros(n, m);
    for site_id = 1:site_n
        max_val = max(max_val, max(Zc{site_id} * beta0));
        min_val = min(min_val, min(Zc{site_id} * beta0));
        ZBc{site_id} = exp(Zc{site_id} * beta0);
%         ZBc{site_id} = approxExp(Zc{site_id} * beta0, max_order_approxExp);
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
end
toc

% beta1
fprintf('min_val: %f; \nmax_val: %f', min_val, max_val);
mean(abs(beta1 - beta1b))
