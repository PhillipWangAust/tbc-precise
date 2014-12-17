classdef TBCCrypto
    properties 
        m
        Cipher_RSA
        keygen
        keyPair
    end
    
    methods
        function obj = TBCCrypto()
        end
        function obj = initializeRSA(obj)
            obj.Cipher_RSA = Cipher.getInstance('RSA');
            obj.keygen = java.security.KeyPairGenerator.getInstance('RSA');
            obj.keyPair = obj.keygen.genKeyPair();
        end
        function PubKey = getPubKey(obj)
            PubKey = obj.keyPair.getPublic();
        end
    end
end