function [enc_counts_of_concept_from_owners, counts_of_concept_from_owners] = getEncCountsOfConceptFromOwners(facilities, NumOfAttributes)
NumOfDataOwner = numel(facilities);
enc_counts_of_concept_from_owners = cell(NumOfDataOwner, 1);
counts_of_concept_from_owners = zeros(1, NumOfAttributes);

for m = 1:NumOfDataOwner
    [enc_counts_of_concept_from_owners{m}, counts_of_concept_from_owners(m, :)] = facilities(m).encryptForEachcounts();
end

end
