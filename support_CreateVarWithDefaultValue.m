function structobj = support_CreateVarWithDefaultValue(structobj, fieldname, defaultvalue)
    if ~isfield(structobj, fieldname)
        structobj.(fieldname) = defaultvalue;
    end
end