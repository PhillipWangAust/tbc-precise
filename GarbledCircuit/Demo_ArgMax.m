%Demo for Maximum Circuit
clear;
NumOfBits =160;
LengthOfData = 64;
randSeed = 11; % set random seed from here.
if strcmp(version('-release'), '2010b')
    RandStream.setDefaultStream(RandStream('mt19937ar','seed',randSeed));
else
    RandStream.setGlobalStream(RandStream('mt19937ar','seed',randSeed));
end

GArgMaxCircuit1 = GArgMaxCircuit(NumOfBits, LengthOfData);

AllKeysOfInputA = logical(round(rand(2 * NumOfBits, LengthOfData)));
AllKeysOfInputB = logical(round(rand(2 * NumOfBits, LengthOfData)));
AllGarbledOutput = logical(round(rand(2, LengthOfData)));

GArgMaxCircuit1 = GArgMaxCircuit1.initializeKeys(AllKeysOfInputA, AllKeysOfInputB, AllGarbledOutput);

InputA = round(rand(1, NumOfBits));
InputB = round(rand(1, NumOfBits));

InputA = de2bi(119,NumOfBits);
InputB = de2bi(120, NumOfBits);

IndexA = (1:2:(2*NumOfBits)) + InputA;
IndexB = (1:2:(2*NumOfBits)) + InputB;

KeysOfInputA = AllKeysOfInputA(IndexA,:);
KeysOfInputB = AllKeysOfInputB(IndexB,:);
GarbledOutput = GArgMaxCircuit1.getGarbledOutput(KeysOfInputA, KeysOfInputB);
ValueFromGarbled = zeros(1,1);
for m = 1
    if sum(abs(GarbledOutput(m,:) - AllGarbledOutput(2*m-1,:))) == 0
    elseif sum(abs(GarbledOutput(m,:) - AllGarbledOutput(2*m,:))) == 0
        ValueFromGarbled(m) = 1;
    else
        error('wrong!');
    end
end

% val1 = mod(bi2de(InputA) + bi2de(InputB), 2^NumOfBits) - bi2de(ValueFromGarbled);
val1 = sum(xor(logical(InputA) & logical(InputB), ValueFromGarbled));
%end