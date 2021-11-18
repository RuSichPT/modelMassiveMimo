function struct = clearStructExcept(struct, varargin)
    % exceptFields - пол€ которые не удал€ютс€ 
    exceptFields = varargin;
    fields = fieldnames(struct);

    for i = 1:numel(fields)
        flagDelete = true;
        
        for j = 1:numel(exceptFields)
            if (exceptFields{j} == fields{i})
                flagDelete = false;
                break;
            end
        end
        
        if (flagDelete == true)
            struct = rmfield(struct,fields{i});
        end

    end
end