clear;
load('beta1.mat');
d = load('seer_test.txt');  %% here we assume all the input data have been sorted by the time.
[~, pos1] = sort(d(:, end-1));
d = d(pos1, :); 

% split data into two sites
d_1 = d(1:863, :);
d_2 = d(864:end, :);
% get data dimension
m = size(d_1, 2)-2;
full_n = size(d, 1);
Z = d(:, 1:m);
T = d(:, m+1);
Delta = d(:, m+2);

inv_ZZ4 = inv(Z'*Z)*4;
%% generate ZZv within each client.
ZZv = zeros(full_n, m, m);
for i = 1:full_n
    tmpZ_i = repmat(Z(i, :), m, 1);
    ZZv(i, :, :) =  tmpZ_i' .* tmpZ_i;
end

%%  client upload time ticks to server.
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
    T_idx = T == Tuniq(k);
    Delta_idx = Delta == 1;
    total_idx = T_idx & Delta_idx;
    DI(k, 1) = sum(total_idx);
    sumZ(k, :) = sum(Z(total_idx, :));
    index(k, 1) = sum(T_idx);
end

index = cumsum([0; index(1:end-1)])+1;


beta0 = zeros(m, 1) - 1;
beta1 = zeros(m, 1);
iter = 0;
maxIter = 600;
epsilon = 1E-6;
tic;
while(sum(abs(beta0 - beta1)) > epsilon && iter < maxIter)
    iter = iter + 1;
    beta0 = beta1;
    ZB = exp(Z * beta0);
    %%
    theta = rot90(cumsum(ZB(end:-1:1)), 2);
    thetaZtmp = Z .* repmat(ZB, 1, m);
    thetaZtmp(end:-1:1, :) = cumsum(thetaZtmp(end:-1:1, :));
    thetaZtmp = thetaZtmp ./ repmat(theta, 1, m);
    thetaZ = thetaZtmp(index, :);
    %%
    TZTZ = thetaZ;
    thetaZ = thetaZ .* repmat(DI, 1, m);
    Gv = sumZ - thetaZ;
    G = sum(Gv);
    
    beta1 = beta0 + inv_ZZ4*G';
    
%%  the followings are optional for calculating hessian matrix only.
%     for i = 1:full_n
%         ZZtmp(i, :, :) = ZZv(i, :, :) * ZB(i);
%     end
%     
%     ZZtmp(end:-1:1, :, :) = cumsum(ZZtmp(end:-1:1, :, :));
%     for i = 1:full_n
%         ZZtmp(i, :, :) = ZZtmp(i, :, :) / theta(i);
%     end
%     
%     thetaZZ = ZZtmp(index, :, :);
%     
%     for k = 1:n
%         tmpTZTZ_k = repmat(TZTZ(k, :), m, 1);
%         TZTZv(k, :, :) = tmpTZTZ_k' .* tmpTZTZ_k;
%     end
%     neghessian = eye(m, m)*epsilon;
%     
%     for i = 1:n
%         neghessian = neghessian + squeeze((thetaZZ(i, :, :) - TZTZv(i, :, :))) * DI(i); 
%     end
end
toc

beta1
sum(abs(beta1 - beta1b))









    


