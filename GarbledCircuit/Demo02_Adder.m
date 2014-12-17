%test garbled circuit
NumOfBits =32;
LengthOfData = 64;
randSeed = 11; % set random seed from here.
if strcmp(version('-release'), '2010b')
    RandStream.setDefaultStream(RandStream('mt19937ar','seed',randSeed));
else
    RandStream.setGlobalStream(RandStream('mt19937ar','seed',randSeed));
end

GAddCircuit1 = GAddCircuit(NumOfBits, LengthOfData);
AllKeysOfInputA = logical(round(rand(2 * NumOfBits, LengthOfData)));
AllKeysOfInputB = logical(round(rand(2 * NumOfBits, LengthOfData)));
AllGarbledOutputS = logical(round(rand(2 * NumOfBits, LengthOfData)));

GAddCircuit1 = GAddCircuit1.initializeKeysForAAndB(AllKeysOfInputA, AllKeysOfInputB, AllGarbledOutputS);

InputA = round(rand(1, NumOfBits));
InputB = round(rand(1, NumOfBits));

IndexA = (1:2:(2*NumOfBits)) + InputA;
IndexB = (1:2:(2*NumOfBits)) + InputB;

KeysOfInputA = AllKeysOfInputA(IndexA,:);
KeysOfInputB = AllKeysOfInputB(IndexB,:);
GarbledOutputS = GAddCircuit1.getGarbledOutput(KeysOfInputA, KeysOfInputB);
ValueFromGarbled = zeros(1,NumOfBits);
for m = 1:NumOfBits
    if sum(abs(GarbledOutputS(m,:) - AllGarbledOutputS(2*m-1,:))) == 0
    elseif sum(abs(GarbledOutputS(m,:) - AllGarbledOutputS(2*m,:))) == 0
        ValueFromGarbled(m) = 1;
    else
        error('wrong!');
    end
end

val1 = mod(bi2de(InputA) + bi2de(InputB), 2^NumOfBits) - bi2de(ValueFromGarbled);