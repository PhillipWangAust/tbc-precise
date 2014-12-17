import javax.crypto.Cipher;

plaintext = 'beijing';

cipher = Cipher.getInstance('RSA');
keygen = java.security.KeyPairGenerator.getInstance('RSA');
keyPair = keygen.genKeyPair();
cipher.init(Cipher.ENCRYPT_MODE, keyPair.getPrivate());

plaintextUnicodeVals = uint16(plaintext);
plaintextBytes = typecast(plaintextUnicodeVals, 'int8');
ciphertext = cipher.doFinal(plaintextBytes)'  %'

% And back out
cipher.init(Cipher.DECRYPT_MODE, keyPair.getPublic());
decryptedBytes = cipher.doFinal(ciphertext);
decryptedText = char(typecast(decryptedBytes, 'uint16'))'




% cipher = Cipher.getInstance('RSA');
% keygen = java.security.KeyPairGenerator.getInstance('RSA');
% keyPair = keygen.genKeyPair();
% cipher.init(Cipher.ENCRYPT_MODE, keyPair.getPrivate());
% 
% plaintextBytes = typecast(plaintext, 'int8');
% ciphertext = cipher.doFinal(plaintextBytes)'  %'
% 
% % And back out
% cipher.init(Cipher.DECRYPT_MODE, keyPair.getPublic());
% decryptedBytes = cipher.doFinal(ciphertext);
% decryptedText = typecast(decryptedBytes, 'uint32')'