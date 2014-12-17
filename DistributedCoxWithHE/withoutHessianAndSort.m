clear;
load('beta1.mat');
d = load('seer_test.txt');
s = RandStream('mt19937ar','Seed',0);
RandStream.setGlobalStream(s);
d = d(randperm(size(d, 1)), :);
%% 
% Z = d(:, 1:end-2);
% inv_ZZ4 = inv(Z'*Z)*4;
% split data into two sites
site_n = 2;
dc{1} = d(1:863, :);
dc{2} = d(864:end, :);

[~, pos1] = sort(dc{1}(:, end-1));
[~, pos2] = sort(dc{2}(:, end-1));

dc{1} = dc{1}(pos1, :);
dc{2} = dc{2}(pos2, :);

% get data dimension
m = size(dc{1}, 2)-2;
% get number of rows in each site
full_nc(1) = size(dc{1}, 1);
full_nc(2) = size(dc{2}, 1);

Zc{1} = dc{1}(:, 1:m);
Zc{2} = dc{2}(:, 1:m);
Tc{1} = dc{1}(:, m+1);
Tc{2} = dc{2}(:, m+1);
Deltac{1} = logical(dc{1}(:, m+2));
Deltac{2} = logical(dc{2}(:, m+2));

%%
zzc = Zc{1}'*Zc{1} + Zc{2}'*Zc{2};
% inv_ZZc4 = inv(zzc)*4;
% newton method for matrix inversion
len = size(zzc, 2);
X{1} = zzc'/(max(sum(zzc, 2))*max(sum(zzc, 1)));
for i = 2:50    
    X{i} = X{i-1}*(2*eye(len) - zzc*X{i-1});
end
inv_ZZc4 = X{end}*4;

%%  client upload unique time ticks to server. We assume there is no privacy within the time ticks information
Tuniq = unique([Tc{1}; Tc{2}]);
n = numel(Tuniq);

sumZ{1} = sum(Zc{1}(Deltac{1}, :), 1);
sumZ{2} = sum(Zc{2}(Deltac{2}, :), 1);
sumZ_all = sumZ{1} + sumZ{2};

DI(:, 1) = hist(Tc{1}(Deltac{1}), Tuniq)';
DI(:, 2) = hist(Tc{2}(Deltac{2}), Tuniq)';
DI_all = repmat(DI(:, 1) + DI(:, 2), 1, m);

PInd(:, 1) = hist(Tc{1}, Tuniq)';
PInd(:, 2) = hist(Tc{2}, Tuniq)';

startID = cumsum([zeros(1, site_n); PInd(1:(end-1), :)]) + 1;

%%
beta0 = zeros(m, 1) - 1;
beta1 = zeros(m, 1);
iter = 0;
maxIter = 1000;
epsilon = 1E-6;
tic;
part2_u = zeros(n, m);
while(sum(abs(beta0 - beta1)) > epsilon && iter < maxIter)
    iter = iter + 1;
    beta0 = beta1;
    part2_dc = zeros(site_n, 1);
    part2_uc = zeros(site_n, m);
    ZBc{1} = exp(Zc{1} * beta0);
    ZBc{2} = exp(Zc{2} * beta0);
    
    tmp{1} = rot90(cumsum(ZBc{1}(end:-1:1)), 2);
    tmp{2} = rot90(cumsum(ZBc{2}(end:-1:1)), 2);
    tmp{1} = [tmp{1}; 0];
    tmp{2} = [tmp{2}; 0];
    part2_d = (tmp{1}(startID(:, 1)) + tmp{2}(startID(:, 2)));
    
    tmp{1} = Zc{1} .* repmat(ZBc{1}, 1, m);
    tmp{2} = Zc{2} .* repmat(ZBc{2}, 1, m);
    
    tmp{1}(end:-1:1, :) = cumsum(tmp{1}(end:-1:1, :));
    tmp{2}(end:-1:1, :) = cumsum(tmp{2}(end:-1:1, :));
    
    tmp{1} = [tmp{1}; zeros(1, m)];
    tmp{2} = [tmp{2}; zeros(1, m)];
    part2_u2 = tmp{1}(startID(:, 1), :) + tmp{2}(startID(:, 2), :);

    G = sumZ_all - sum(DI_all .* part2_u2./repmat(part2_d, 1, m), 1);
    beta1 = beta0 + inv_ZZc4*G';
end
toc

% beta1
mean(abs(beta1 - beta1b))
