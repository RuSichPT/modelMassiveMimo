function struct = deleteFields(struct, varargin)
    % deletedFields - ���� ������� ��������� 
    deletedFields = varargin;
    fields = fieldnames(struct);

    for i = 1:numel(fields)
        flagDelete = false;
        
        for j = 1:numel(deletedFields)
            if (deletedFields{j} == fields{i})
                flagDelete = true;
                break;
            end
        end
        
        if (flagDelete == true)
            struct = rmfield(struct,fields{i});
        end

    end
end