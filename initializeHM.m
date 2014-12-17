warning off all;
clearvars;
warning on;
warning off all;
addpath(genpath('.'));
javarmpath('./DistributedCoxWithHE/lib/thep-0.2.jar');
javarmpath('./DistributedCoxWithHE/lib/thep-0.2.jar');
warning on;
a = javaclasspath;
if(isempty(a)|| numel(a) == 1 || isempty(strfind(a{2}, 'thep-0.2.jar')))
    initializeJava('./DistributedCoxWithHE/lib/thep-0.2.jar');
end
warning off all;
javarmpath('./DistributedCoxWithHE/dist/DistributedCoxWithHE.jar');
javarmpath('./DistributedCoxWithHE/dist/DistributedCoxWithHE.jar');

warning on;  %#ok<WNON>
a = javaclasspath;
if(isempty(a)|| numel(a) == 1 || isempty(strfind(a{2}, 'DistributedCoxWithHE.jar')))
    initializeJava('./DistributedCoxWithHE/dist/DistributedCoxWithHE.jar');
end
%%
fi_param.f_bits = 64;