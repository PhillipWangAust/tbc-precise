%Demo for Utility Circuit
clear;
clc;
NumOfChildren = 5;
NumOfClasses = 2;
NumOfBits =32;
LengthOfData = 64;
randSeed = 11; % set random seed from here.
if strcmp(version('-release'), '2010b')
    RandStream.setDefaultStream(RandStream('mt19937ar','seed',randSeed));
else
    RandStream.setGlobalStream(RandStream('mt19937ar','seed',randSeed));
end

UtlCirt = UtilityCircuit(NumOfChildren, NumOfClasses, NumOfBits, LengthOfData);

Keys = getIOKeysOfUtilityCircuit(NumOfChildren, NumOfClasses, NumOfBits, LengthOfData);

UtlCirt = UtlCirt.initializeKeys(Keys);

InputAOrg = [2 4;28 10;39 203;39 394;398 394];
InputBOrg = [10 9;102 21;54 3445;324 4955;4564 9458];


for m = 1:NumOfChildren
    for n = 1:NumOfClasses
%         InputA{m, n} = round(rand(1, NumOfBits));
%         InputB{m, n} = round(rand(1, NumOfBits));
        
        InputA{m, n} = getBiForGivenNumOfBits(InputAOrg(m,n),NumOfBits);
        InputB{m, n} = getBiForGivenNumOfBits(InputBOrg(m,n),NumOfBits);
        
        IndexA{m, n} = (1:2:(2*NumOfBits)) + InputA{m, n};
        IndexB{m, n} = (1:2:(2*NumOfBits)) + InputB{m, n};
        
        KeysOfInputA{m,n} = Keys.Input(m,n).KeysOfInputA(IndexA{m,n},:);
        KeysOfInputB{m,n} = Keys.Input(m,n).KeysOfInputB(IndexB{m,n},:);
    end
end

UtlCirt.KeysOfCrytpo = KeysOfInputB;
AllGarbledOutput = Keys.Output;

GarbledOutput = UtlCirt.getGarbledOutput(KeysOfInputA);
ValueFromGarbled = zeros(1,NumOfBits);
for m = 1:NumOfBits
    if sum(abs(GarbledOutput(m,:) - AllGarbledOutput(2*m-1,:))) == 0
    elseif sum(abs(GarbledOutput(m,:) - AllGarbledOutput(2*m,:))) == 0
        ValueFromGarbled(m) = 1;
    else
        error('wrong!');
    end
end
