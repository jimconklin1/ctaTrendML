%Loads all factor transform configs from a given directory
function [ret] = loadFactorTransformCfg(pth)
   pattern = fullfile(pth, '*.json');
   file_list = dir(pattern);
   sz = length(file_list);
   ret = FactorTransformCfg;
   for i = 1:sz
       fn = file_list(i).name;
       tmp = fromJsonFile(fullfile(pth, fn));
       cfg_item = FactorTransformSpec.fromStruct(tmp);
       if cfg_item.name == "*"
           cfg_item.name = regexprep(fn, '[.].*', '');
       end % if
       ret.addItem(cfg_item);
   end % i
end

