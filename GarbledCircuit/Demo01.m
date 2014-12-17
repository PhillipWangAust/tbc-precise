%test garbled circuit
NumOfBits =32;
NumOfBitsForMAC = 64;
randSeed = 11; % set random seed from here.
if strcmp(version('-release'), '2010b')
    RandStream.setDefaultStream(RandStream('mt19937ar','seed',randSeed));
else
    RandStream.setGlobalStream(RandStream('mt19937ar','seed',randSeed));
end

MAC = logical(round(rand(NumOfBits, NumOfBitsForMAC)));
GAddCircuit1 = GAddCircuit(MAC);
NumOfKeys = GAddCircuit1.getNumOfKeys();
Keys = logical(round(rand(NumOfKeys, NumOfBitsForMAC)));
[AllKeysOfInputA AllKeysOfInputB AllKeysOfOutputS] = getKeysOfInputAAndBOutputSFromGAdder(Keys);
GAddCircuit1 = GAddCircuit1.initializeKeys(Keys);

InputA = round(rand(1, NumOfBits));
InputB = round(rand(1, NumOfBits));

IndexA = (1:2:(2*NumOfBits)) + InputA;
IndexB = (1:2:(2*NumOfBits)) + InputB;

KeysOfInputA = AllKeysOfInputA(IndexA,:);
KeysOfInputB = AllKeysOfInputB(IndexB,:);
GarbledOutputS = GAddCircuit1.getGarbledOutput(KeysOfInputA, KeysOfInputB, Keys);
ValueFromGarbled = zeros(1,NumOfBits);
for m = 1:NumOfBits
    if sum(abs(GarbledOutputS(m,:) - AllKeysOfOutputS(2*m-1,:))) == 0
    elseif sum(abs(GarbledOutputS(m,:) - AllKeysOfOutputS(2*m,:))) == 0
        ValueFromGarbled(m) = 1;
    else
        error('wrong!');
    end
end

