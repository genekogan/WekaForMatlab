classdef WDataset < handle
    % TO - DO
    % handle naming exceptions (spaces, formatting, name collisions)
    % handle instance exceptions (what if one wrong type?)

    properties (SetAccess = private)
        title;
        path;
        attributes;
        attributeTypes
        features;
        numinstances;
        numattributes;
        classes;
    end
    
    methods    
        % constructor
        function d = WDataset(title,path)
            d.title = title;
            d.path = path;
            d.attributes = [];
            d.attributeTypes = [];
            d.features = [];
            d.numinstances = 0;
            d.numattributes = 0;
            d.classes = [];
        end
        
        %%%%%%%%%%%%%%%%%%%%
        % add attribute    %
        %%%%%%%%%%%%%%%%%%%%
        function addAttribute(d, type, name)            

            % nominal classes
            if iscell(type)
                d.attributeTypes{d.numattributes+1} = type;                

            % numeric classes
            elseif isequal(lower(type),'numeric')
                d.attributeTypes{d.numattributes+1} = 'numeric';                
            
            else
                fprintf('Error: attribute rexognized neither as numeric, nor nominal\n');
                return;                
            end
                        
            % attribute name and count
            % need to handle exceptions better
            d.numattributes = d.numattributes + 1;                
            if nargin<3
                name = sprintf('Attribute_%d', d.numattributes);
            end
            d.attributes{d.numattributes} = convertToArffText(name);
        end

        
        %%%%%%%%%%%%%%%%%%%%
        % add instance     %
        %%%%%%%%%%%%%%%%%%%%
        function addInstances(d,feat)
            for n=1:size(feat,1)
                
                % if wrong number of features
                if size(feat,2)~=d.numattributes
                    fprintf('Error: wrong number of features! (found %d, expecting %d)\n', length(feat), d.numattributes);
                    return;

                % right number of features, validate correct type
                else
                    d.numinstances = d.numinstances + 1;
                    for i=1:d.numattributes

                        % numeric features
                        if isequal(d.attributeTypes{i},'numeric')
                            if ischar(feat{i})
                                d.features{d.numinstances, i} = str2double(feat{n,i});
                            else
                                d.features{d.numinstances, i} = feat{m,i};
                            end

                        % nominal features
                        else
                            if find(strcmp(d.attributeTypes{i}, feat{n,i}))
                                d.features{d.numinstances, i} = feat{n,i};
                            else
                                fprintf('ERRROR! feature not of expected nominal type');
                            end
                        end
                    end
                end
            end
        end
        
        
        function removeFeature(d,idx)
        end
        
        
        % write to arff file at location specified by d.path
        function write(d)
            fid = fopen(d.path,'w');
            fprintf(fid, '@relation %s\n\n', d.title);
            
            % write attributes
            for i=1:d.numattributes
                nomString = getNominalString(d.attributeTypes{i});
                nomString = convertToArffText(nomString);
                fprintf(fid, sprintf('@attribute %s %s\n', d.attributes{i}, nomString));
            end
            
            % write features
            fprintf(fid,'\n@data\n');
            for i=1:d.numinstances
                featStr = '';
                for j=1:d.numattributes
                    if ischar(d.features{i,j})
                        featStr = [ featStr convertToArffText(d.features{i,j}) ',' ];
                    else
                        featStr = [ featStr num2str(d.features{i,j}) ',' ];
                    end
                end
                featStr = sprintf('%s\n',featStr(1:end-1));
                fprintf(fid, featStr);
            end
            fclose(fid);
            
            d.classes = d.attributeTypes{end};
        end

        % display all parameters
        function display(d)
            fprintf('Dataset located: %s\n', d.path);
            
            d.attributes
            d.attributeTypes
            
        end
        function open(d)
            eval(sprintf('open %s', d.path));
        end
        
    end
end


%%%%%%%%%%%%%%%%%%%%
% helper functions %
%%%%%%%%%%%%%%%%%%%%
function nominalString = getNominalString(type)
    if isequal(type,'numeric')
        nominalString = 'numeric';
    else
        nominalString = '';
        for i=1:length(type)
            nominalString = sprintf('%s%s,', nominalString, type{i});
        end
        nominalString = sprintf('{%s}', nominalString(1:end-1));
    end
end

function str2 = convertToArffText(str)
    str2 = regexprep(str,' ','_');
end

