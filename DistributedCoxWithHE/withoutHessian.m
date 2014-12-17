clear;
load('beta1.mat');
d = load('seer_test.txt');  %% For the seek of simplicity, here we assume all the input data have been sorted by the time. If not, we can use an index mapping table to achieve this goal, but it will not be implemented in this code.
[~, pos] = sort(d(:, end-1));
%%
d = d(pos, :); 
Z = d(:, 1:end-2);
inv_ZZ4 = inv(Z'*Z)*4;
% split data into two sites
site_n = 2;
dc{1} = d(1:863, :);
dc{2} = d(864:end, :);

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
Deltac{1} = logical(dc{1}(:, m+2));
Deltac{2} = logical(dc{2}(:, m+2));

%%
zzc = Zc{1}'*Zc{1} + Zc{2}'*Zc{2};
inv_ZZc4 = inv(zzc)*4;
% newton method for matrix inversion
len = size(zzc, 2);
X{1} = zzc'/(max(sum(zzc, 2))*max(sum(zzc, 1)));
for i = 2:50    
    X{i} = X{i-1}*(2*eye(len) - zzc*X{i-1});
end
zzc_inv4 = X{end}*4;

%%  client upload unique time ticks to server. We assume there is no privacy within the time ticks information
Tuniq = unique([Tc{1}; Tc{2}]);
n = numel(Tuniq);
%% calculate Di, sumZ, index
for k = 1:n
    sumZ(k, :) = sum(Zc{1}(Deltac{1} & (Tc{1} == Tuniq(k)), :)) + sum(Zc{2}(Deltac{2} & (Tc{2} == Tuniq(k)), :));
end
DI = (hist(Tc{1} .* Deltac{1}, [0; Tuniq]) + hist(Tc{2} .* Deltac{2}, [0;Tuniq]))';
DI(1) = [];

index = (hist(Tc{1}, Tuniq) + hist(Tc{2}, Tuniq))';
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

%%
beta0 = zeros(m, 1) - 1;
beta1 = zeros(m, 1);
iter = 0;
maxIter = 600;
epsilon = 1E-6;
tic;

while(sum(abs(beta0 - beta1)) > epsilon && iter < maxIter)
    iter = iter + 1;
    beta0 = beta1;
    ZBc{1} = exp(Zc{1} * beta0);
    ZBc{2} = exp(Zc{2} * beta0);
    %%
    thetac{2} = rot90(cumsum(ZBc{2}(end:-1:1)), 2);
    thetac{1} = rot90(thetac{2}(1)+cumsum(ZBc{1}(end:-1:1)), 2);
    
    thetaZtmpc{1} = Zc{1} .* repmat(ZBc{1}, 1, m);
    thetaZtmpc{2} = Zc{2} .* repmat(ZBc{2}, 1, m);
    
    thetaZtmpc{2}(end:-1:1, :) = cumsum(thetaZtmpc{2}(end:-1:1, :));
    thetaZtmpc{1}(end, :) = thetaZtmpc{2}(1, :) + thetaZtmpc{1}(end, :);
    thetaZtmpc{1}(end:-1:1, :) = cumsum(thetaZtmpc{1}(end:-1:1, :));
    thetaZtmpc{1} = thetaZtmpc{1} ./ repmat(thetac{1}, 1, m);
    thetaZtmpc{2} = thetaZtmpc{2} ./ repmat(thetac{2}, 1, m);
    
    thetaZc{1} = thetaZtmpc{1}(indexc{1}, :);
    thetaZc{2} = thetaZtmpc{2}(indexc{2}, :);
    %%
    TZTZc = thetaZc;
    thetaZc{1} = thetaZc{1} .* repmat(DIc{1}, 1, m);
    thetaZc{2} = thetaZc{2} .* repmat(DIc{2}, 1, m);
    
    Gvc{1} = sumZc{1} - thetaZc{1};
    Gvc{2} = sumZc{2} - thetaZc{2};
    
    G = sum(Gvc{1}) + sum(Gvc{2});
    
    beta1 = beta0 + inv_ZZc4*G';
end
toc

beta1
sum(abs(beta1 - beta1b))
