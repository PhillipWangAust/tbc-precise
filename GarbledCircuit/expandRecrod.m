function RetRecord = expandRecrod(Record1, OrderOfAttb, ValOfAttb, Children)
Type1 =iscell(Record1{OrderOfAttb});
NumOfAttbs = numel(Record1);
RetRecord = Record1;

Index1 = getIndexOfPos(RetRecord, OrderOfAttb, ValOfAttb, Type1);

while ~isempty(Index1)
    for m = 1:NumOfAttbs
        if iscell(Record1{m}) || ischar(Record1{m})
            if iscell(Record1{m})
                for n = 1:numel(Children)
                    temp{n,1} = RetRecord{m}{Index1};
                end
            else
                for n = 1:numel(Children)
                    temp{n,1} = RetRecord{m};
                end
            end
            tempRecord{m} = temp;
        else
            tempRecord{m} = repmat(RetRecord{m}(Index1), size(Children,1),1);
        end
    end
    

    tempRecord{OrderOfAttb} = Children;
    
    RetRecord = insertRecord(RetRecord, tempRecord, Index1);
    
    Index1 = getIndexOfPos(RetRecord, OrderOfAttb, ValOfAttb, Type1);
end
end

function Index = getIndexOfPos(RetRecord, OrderOfAttb, ValOfAttb, Type1)
if ~Type1
    Index = strcmp(RetRecord{OrderOfAttb}, ValOfAttb);
else
    Index = (ValOfAttb(1) == RetRecord{OrderOfAttb}(:,1) & ValOfAttb(2) == RetRecord{OrderOfAttb}(:,2));
end
Index = find(Index, 1, 'first');
end

function RetRecord = insertRecord(RetRecord, tempRecord, Index1)
NumOfAttbs = numel(RetRecord);

for m = 1:NumOfAttbs
    temp = RetRecord{m};
    if iscell(temp) || ischar(temp)
        U_Half = temp{1:(Index1 - 1),1};
        B_Half = temp{(Index1+1):end,1};
        temp = {U_Half{:,1};tempRecord{:,1};B_Half{:,1}};
        
    else
        U_Half = temp(1:(Index1 - 1),:);
        B_Half = temp((Index1+1):end,:);
        temp = [U_Half;tempRecord{m};B_Half];     
    end
    RetRecord{m} = temp;
end

end 