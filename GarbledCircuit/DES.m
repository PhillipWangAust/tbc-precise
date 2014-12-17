function [output1] = DES(input64,mode,key)
output1 = xor(input64,key);
end