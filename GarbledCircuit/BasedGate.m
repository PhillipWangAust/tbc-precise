classdef BasedGate
    properties
        type;
        Enc_TrueTable
        MAC
        Enc_MAC
    end
    methods
        function obj = BasedGate(type, MAC)
            if strcmp(type, 'AND') || strcmp(type, 'OR') || strcmp(type, 'XOR')
                obj.type = type;
                obj.MAC = MAC;
            else
                error('No this type circuit!');
            end
            if size(obj.MAC,2) == 64
                obj.MAC = MAC;
            else
                error('The length for each MAC must be 64!');
            end
        end
        function obj = ShuffleTrueTable(obj, ShuffleOrder)
            if size(obj.Enc_TrueTable,1) ~= 4 || numel(ShuffleOrder) ~= 4
                error('Wrong enc true talbe!');
            end
            obj.Enc_TrueTable = obj.Enc_TrueTable(ShuffleOrder,:);
            obj.Enc_MAC = obj.Enc_MAC(ShuffleOrder,:);
        end
        function obj = setKeysAndTrueTable(obj, Keys)
            if size(Keys, 1) ~= 6
                error('The Keys is not correct!');
            end
            obj.Enc_MAC(1, :) = DES(DES(obj.MAC, 'ENC', Keys(1,:)), 'ENC', Keys(3,:));
            obj.Enc_MAC(2, :) = DES(DES(obj.MAC, 'ENC', Keys(1,:)), 'ENC', Keys(4,:));
            obj.Enc_MAC(3, :) = DES(DES(obj.MAC, 'ENC', Keys(2,:)), 'ENC', Keys(3,:));
            obj.Enc_MAC(4, :) = DES(DES(obj.MAC, 'ENC', Keys(2,:)), 'ENC', Keys(4,:));
            switch obj.type
                case 'AND'
                    obj.Enc_TrueTable(1,:) = DES(DES(Keys(5,:), 'ENC', Keys(1,:)), 'ENC', Keys(3,:));
                    obj.Enc_TrueTable(2,:) = DES(DES(Keys(5,:), 'ENC', Keys(1,:)), 'ENC', Keys(4,:));
                    obj.Enc_TrueTable(3,:) = DES(DES(Keys(5,:), 'ENC', Keys(2,:)), 'ENC', Keys(3,:));
                    obj.Enc_TrueTable(4,:) = DES(DES(Keys(6,:), 'ENC', Keys(2,:)), 'ENC', Keys(4,:));
                case 'OR'
                    obj.Enc_TrueTable(1,:) = DES(DES(Keys(5,:), 'ENC', Keys(1,:)), 'ENC', Keys(3,:));
                    obj.Enc_TrueTable(2,:) = DES(DES(Keys(6,:), 'ENC', Keys(1,:)), 'ENC', Keys(4,:));
                    obj.Enc_TrueTable(3,:) = DES(DES(Keys(6,:), 'ENC', Keys(2,:)), 'ENC', Keys(3,:));
                    obj.Enc_TrueTable(4,:) = DES(DES(Keys(6,:), 'ENC', Keys(2,:)), 'ENC', Keys(4,:));
                case 'XOR'
                    obj.Enc_TrueTable(1,:) = DES(DES(Keys(5,:), 'ENC', Keys(1,:)), 'ENC', Keys(3,:));
                    obj.Enc_TrueTable(2,:) = DES(DES(Keys(6,:), 'ENC', Keys(1,:)), 'ENC', Keys(4,:));
                    obj.Enc_TrueTable(3,:) = DES(DES(Keys(6,:), 'ENC', Keys(2,:)), 'ENC', Keys(3,:));
                    obj.Enc_TrueTable(4,:) = DES(DES(Keys(5,:), 'ENC', Keys(2,:)), 'ENC', Keys(4,:));
                otherwise
                    error('No this type circut!');
            end
            RndP = randperm(4);
            obj.Enc_TrueTable = obj.Enc_TrueTable(RndP,:);
            obj.Enc_MAC = obj.Enc_MAC(RndP,:);
            
        end
        function Output1 = decryptOutput(obj, inputA, inputB)
            for m = 1:4
                Temp_MAC = DES(DES(obj.Enc_MAC(m,:), 'DEC', inputB), 'DEC', inputA);
                if sum(abs(Temp_MAC - obj.MAC)) == 0
                    Output1 = DES(DES(obj.Enc_TrueTable(m,:), 'DEC', inputB), 'DEC', inputA);
                    return;
                end
            end
            error('The keys provided are wrong!');
        end
    end
end