clear;
% warning off all; 
% clearvars; % clear java; 
% clear import; 
% warning on;
% clear import; 
% warning off all;
%  addpath(genpath('.'));
% javarmpath('./thep-0.2.jar');
% warning on;  %#ok<WNON>
% initializeJava('./lib/thep-0.2.jar');
load('beta1.mat');
d = load('seer_test.txt');  %% For the seek of simplicity, here we assume all the input data have been sorted by the time. If not, we can use an index mapping table to achieve this goal, but it will not be implemented in this code.
[~, pos] = sort(d(:, end-1));
d = d(pos, :); 
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
Deltac{1} = dc{1}(:, m+2);
Deltac{2} = dc{2}(:, m+2);

zzc = Zc{1}'*Zc{1} + Zc{2}'*Zc{2};
inv_ZZc4 = inv(zzc)*4;
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
epsilon = 1E-6;
calculateHessian = 0;
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
    
    if(calculateHessian)
        %%  the following are optional if we need to calculate the hessian matrix.
        for i = 1:full_nc(1)
            ZZtmpc{1}(i, :, :) = ZZvc{1}(i, :, :) * ZBc{1}(i);
        end
        for i = 1:full_nc(2)
            ZZtmpc{2}(i, :, :) = ZZvc{2}(i, :, :) * ZBc{2}(i);
        end
        %%
        ZZtmpc{2}(end:-1:1, :, :) = cumsum(ZZtmpc{2}(end:-1:1, :, :));
        ZZtmpc{1}(end, :, :) = ZZtmpc{2}(1, :, :) + ZZtmpc{1}(end, :, :);
        ZZtmpc{1}(end:-1:1, :, :) = cumsum(ZZtmpc{1}(end:-1:1, :, :));
        %%
        for i = 1:full_nc(1)
            ZZtmpc{1}(i, :, :) = ZZtmpc{1}(i, :, :) / thetac{1}(i);
        end
        for i = 1:full_nc(2)
            ZZtmpc{2}(i, :, :) = ZZtmpc{2}(i, :, :) / thetac{2}(i);
        end
        %%
        thetaZZc{1} = ZZtmpc{1}(indexc{1}, :, :);
        thetaZZc{2} = ZZtmpc{2}(indexc{2}, :, :);
        %%
        for k = 1:nn(1)
            tmpTZTZ_k = repmat(TZTZc{1}(k, :), m, 1);
            TZTZvc{1}(k, :, :) = tmpTZTZ_k' .* tmpTZTZ_k;
        end
        for k = 1:nn(2)
            tmpTZTZ_k = repmat(TZTZc{2}(k, :), m, 1);
            TZTZvc{2}(k, :, :) = tmpTZTZ_k' .* tmpTZTZ_k;
        end
        
        %%
        neghessian = eye(m, m)*epsilon;
        
        for i = 1:nn(1)
            neghessian = neghessian + squeeze((thetaZZc{1}(i, :, :) - TZTZvc{1}(i, :, :))) * DIc{1}(i);
        end
        for i = 1:nn(2)
            neghessian = neghessian + squeeze((thetaZZc{2}(i, :, :) - TZTZvc{2}(i, :, :))) * DIc{2}(i);
        end
    end
end
toc

beta1
sum(abs(beta1 - beta1b))
