%test computational time

randNum = randi([1,6], 1000,1);
randNum1 = randi([1,10^6], 1000,1);
fi_word1 = obj.fi_word;
fi_fraction1 = obj.fi_fraction;
temp = cell(1000,1);
F2 = obj.F1;

decrypt1.f_bits = fi_word1;
decrypt1.f_fbits = fi_fraction1;
decrypt1.F = F2;

fi_randNum1 = fi(randNum1, 1, fi_word1, fi_fraction1, 'fimath', F2);
fi_randNum = fi(randNum, 1, fi_word1, fi_fraction1, 'fimath', F2);


tic;
for m1 = 1:1000
    temp{m1} = encryptMatrix_fi(obj.HomoKey{randNum(m1)}.getPublicKey, fi_randNum1(m1));
end
y1 = toc;


tic;
for m1 = 1:1000
    temp{m1} = secureMatrixSum(temp{m1}, temp{m1});
end
y2 = toc;

tic;
for m1 = 1:1000
    temp{m1} = secureMatrixMultiply_pairwise_fi(temp{m1}, fi_randNum(m1));
end
y3 = toc;

tic;
for m1 = 1:1000
    temp{m1} = decryptMatrix_fi(temp{m1}, obj.HomoKey{randNum(m1)}, decrypt1);
end
y4 = toc;
%end


% Rand2 = randi([1,10^6], 2, 1000);
% b1 = round(rand(1000,1));
% tic;
% for m1 = 1:1000
%     m1
%     OTVal = OT1of2Process(Rand2(:,m1), b1(m1));
% end
% y5 = toc;
% y5 / 1000

% tic
% for m1 = 1:100
%     cryp_provider.GbCircuit.getOutput(GarbledInputA, GarbledInputB);
% end
% y6 = toc;
% y6 / 1000
