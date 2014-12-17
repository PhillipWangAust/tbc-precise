function b = fiMAtrix2Str(a)
    b = a.dec;
    b = cellfun(@(x)regexp(x,'[\s]+','split'), mat2cell(b, ones(1, size(b, 1)), size(b, 2)), 'UniformOutput', false);
    b = cat(1, b{:});    
end