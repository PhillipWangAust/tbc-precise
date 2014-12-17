warning off all; 
clearvars; % clear java; 
clear import; 
warning on;
clear import; 
warning off all;
 addpath(genpath('.'));
javarmpath('./thep-0.2.jar');
warning on;  %#ok<WNON>
initializeJava('./thep-0.2.jar');

%%  demonstration of matrix paillier encryption
bits = 30;
% create privateKey;
enc_key = thep.paillier.PrivateKey(bits);
% create encryptor
encryptor = thep.paillier.EncryptedInteger(enc_key.getPublicKey);
% encrypt a plain value
plainVal = '6';  % please keep # of bit of this value less than the # of bit of you key.
encryptor.set(java.math.BigInteger(plainVal));
% decryption
decryptedVal = encryptor.decrypt(enc_key);
% decrypted val.
decryptedVal.toString

%%  generate another encrypted data to test homomorphic addition 
% create encryptor
encryptor1 = thep.paillier.EncryptedInteger(enc_key.getPublicKey);
% encrypt a plain value
plainVal = '7';  % please keep # of bit of this value less than the # of bit of you key.
encryptor1.set(java.math.BigInteger(plainVal));
% decryption
decryptedVal1 = encryptor1.decrypt(enc_key);
% decrypted val.
decryptedVal1.toString

% homomorphic addition
encryptor3 = encryptor.add(encryptor1);
% decryption
decryptedVal3 = encryptor3.decrypt(enc_key);
% decrypted val.
decryptedVal3.toString

% homomorphic multiplication by a constant at each local set.

encryptor4 = encryptor.multiply(java.math.BigInteger('3'));
% decryption
decryptedVal4 = encryptor4.decrypt(enc_key);
% decrypted val.
decryptedVal4.toString


%% newton method for matrix inversion with multiplication and subtraction
% only.
s = RandStream('mt19937ar','Seed',0);
RandStream.setGlobalStream(s);

len = 10;
A = rand(len);
X{1} = A'/(max(sum(A, 2))*max(sum(A, 1)));
for i = 2:50    
    X{i} = X{i-1}*(2*eye(len) - A*X{i-1});
end
A_inv = X{end};
inv(A);