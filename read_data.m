clear;
data = readtable('exportqueryresults_test1.csv');

names = data.Properties.VariableNames;
for i = 1:numel(names)
    [a, ~, tmp] = unique(data(:, names{i}));
    lookupTable{i} = table2cell(a);
    data1(:, names{i}) = array2table(tmp, 'variablenames', {names{i}});
end


data1 = table2array(data1);
data1(:, 4) = (datenum(data.x2975_08_1800_00_00_0) - datenum(data.x2879_08_1100_00_00_0))/365;
data1(:, [5]) = [];

for i = 1: numel(lookupTable)
    if(ismember('null', lookupTable{i}))
        i
    end
end


ii = 3; % for sex;
idx = data1(:, ii) == 1;
data1(idx, :) = [];
data1(:, ii) = data1(:, ii) -1;
lookupTable{ii}(1) =[];

ii = 11; % for sex;
idx = data1(:, ii) == 1;
data1(idx, :) = [];
data1(:, ii) = data1(:, ii) -1;
lookupTable{ii}(1) =[];
save data1.mat