%Demo for Maximum Circuit
clear;
clc;
NumOfBits =160;
LengthOfData = 64;
randSeed = 11; % set random seed from here.
if strcmp(version('-release'), '2010b')
    RandStream.setDefaultStream(RandStream('mt19937ar','seed',randSeed));
else
    RandStream.setGlobalStream(RandStream('mt19937ar','seed',randSeed));
end

GMaxCircuit1 = GMaxCircuit(NumOfBits, LengthOfData);

AllKeysOfInputA = logical(round(rand(2 * NumOfBits, LengthOfData)));
AllKeysOfInputB = logical(round(rand(2 * NumOfBits, LengthOfData)));
AllGarbledOutput = logical(round(rand(2 * NumOfBits, LengthOfData)));

GMaxCircuit1 = GMaxCircuit1.initializeKeys(AllKeysOfInputA, AllKeysOfInputB, AllGarbledOutput);

timeA = zeros(1000,1);
timeB = zeros(1000,1);

for m = 1:100
    m
    InputA = round(rand(1, NumOfBits));
    InputB = round(rand(1, NumOfBits));
    
    deA = bi2de(InputA);
    deB = bi2de(InputB);

    IndexA = (1:2:(2*NumOfBits)) + InputA;
    IndexB = (1:2:(2*NumOfBits)) + InputB;

    KeysOfInputA = AllKeysOfInputA(IndexA,:);
    KeysOfInputB = AllKeysOfInputB(IndexB,:);
    tic;
    GarbledOutput = GMaxCircuit1.getGarbledOutput(KeysOfInputA, KeysOfInputB);
    timeA(m) = toc;
    tic;
    temp = deA + deB;
    timeB(m) = toc;
    ValueFromGarbled = zeros(1,NumOfBits);
%     for m = 1:NumOfBits
%         if sum(abs(GarbledOutput(m,:) - AllGarbledOutput(2*m-1,:))) == 0
%         elseif sum(abs(GarbledOutput(m,:) - AllGarbledOutput(2*m,:))) == 0
%             ValueFromGarbled(m) = 1;
%         else
%             error('wrong!');
%         end
%     end

% val1 = mod(bi2de(InputA) + bi2de(InputB), 2^NumOfBits) - bi2de(ValueFromGarbled);
    val1 = sum(xor(logical(InputA) & logical(InputB), ValueFromGarbled));
%end
end