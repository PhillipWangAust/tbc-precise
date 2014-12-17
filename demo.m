clear all;
initializeHM;
global numofThreads;
numofThreads = 8;
load data1.mat data1;
%%
RandSeed = 10; %random seed
NumOfFacilities = 4;
NumOfBits = 32; %The number of bits of each data
GLengthOfKeys = 64; %The length of Garbled circuit Keys

isOT = 1; % 1: use OT protocol; 0 no;
isCompwithAverage = 1;% if compare the each owner data with their avearage

% Func1 = @(x)(round(mean(x(:,4))));
Func1 = @(x)StatFunc(x);
NumOfAttributes = 1;

%homomorphic encryption system parameters
bits_key = 128;%the length of encryption key
fi_word= 32; %the length of bits for homomorphic encryption word
fi_fraction = 0; %the lenght of bits for homomorphic encryption fraction
SignOfFixNumber = 1;
%%
RandStream.setGlobalStream(RandStream('mt19937ar', 'seed', RandSeed));
F1 = fimath('ProductMode', 'SpecifyPrecision', 'SumMode', 'SpecifyPrecision', 'ProductWordLength', fi_word, 'ProductFractionLength', fi_fraction, 'SumWordLength', fi_word, 'SumFractionLength', fi_fraction);
%%
LengthOfData = size(data1, 1);
idx = randperm(LengthOfData);
data1 = data1(idx, :);

LengthOfDataForEachHospital = floor(LengthOfData / NumOfFacilities);

crypto_provider = CryptoProvider(NumOfAttributes, NumOfFacilities, NumOfBits, GLengthOfKeys, F1, fi_word, fi_fraction, bits_key, isCompwithAverage);
crypto_provider = crypto_provider.initializeKeys();

PubKey = crypto_provider.getPubKey();
cloud_server = Cloud(NumOfFacilities, NumOfAttributes, NumOfBits, GLengthOfKeys, F1, fi_word, fi_fraction, bits_key, PubKey, isOT, isCompwithAverage);

for m = 1:NumOfFacilities - 1
    facilities(m) = Facility(PubKey, F1, fi_word, fi_fraction, data1(LengthOfDataForEachHospital*(m -1)+1:LengthOfDataForEachHospital*m,:));
    facilities(m) = facilities(m).getEachCounts(Func1);
end

facilities(NumOfFacilities) = Facility(PubKey, F1, fi_word, fi_fraction, data1(LengthOfDataForEachHospital*(NumOfFacilities -1)+1:LengthOfDataForEachHospital*NumOfFacilities,:));
facilities(NumOfFacilities) = facilities(NumOfFacilities).getEachCounts(Func1);
%%
%Implementation

%Homormophic encryption
for m = 1:NumOfFacilities - 1
    facilities(m) = facilities(m).getEachCounts(Func1);
end
facilities(NumOfFacilities) = facilities(NumOfFacilities).getEachCounts(Func1);
[Enc_counts_from_facilities, counts_of_from_owners] = getEncCountsOfConceptFromOwners(facilities, NumOfAttributes);
cloud_server = cloud_server.initializeMu();
EncCountsWithMu = cloud_server.sumEnccountsWithMu(Enc_counts_from_facilities);
crypto_provider = crypto_provider.decryptCountsWithMu(EncCountsWithMu);
%end of homormophic encryption

%Yao' Circuit
crypto_provider = crypto_provider.getGCircuit();

Rank = cloud_server.getRankByGarbledCricuit(crypto_provider);

%end
%%2615.884353 seconds.
