function results = wekaxval(dataset1, dataset2, classifier, numfold)
% results = wekaxval(dataset1, dataset2, classifier, numfold)

WEKAPATH = '/Users/Gene/Code/_Externals/weka-3-6-6/';

if (nargin < 4) numfold = 10; end

for idxparam = 1:length(classifier.parameters), tic 
    
    results.classes = dataset1.classes;
    results.parameters{idxparam} = classifier.parameters{idxparam};    
    
    % train on dataset1, apply labels to dataset2
    if ~isempty(dataset2)
        cmd = [ 'java -Xmx2g -classpath ' WEKAPATH 'weka.jar ' ...
            classifier.classifier ' ' results.parameters{idxparam} ...
            ' -t ' dataset1.path ' -T ' dataset2.path ' -x ' num2str(numfold) ' -o -p 0' ];

    % cross validation on instances
    else
        cmd = [ 'java -Xmx2g -classpath ' WEKAPATH 'weka.jar ' ...
            classifier.classifier ' ' results.parameters{idxparam} ...
            ' -t ' dataset1.path ' -x ' num2str(numfold) ' ' ];        
    end

    [ status, result ] = system(cmd);
    
    disp(cmd);
    disp(result);    

    paramResults = parseResults(result, dataset1, dataset2);
    
    % append each field from results to results file
    if length(classifier.parameters) > 1
        fields = fieldnames(paramResults);        
        for i=1:length(fields)
            eval(sprintf('results.%s{%d} = paramResults.%s;', fields{i}, idxparam, fields{i}));
        end        
    else
        results = paramResults;
    end
    
    disp(sprintf('Parameter set %d/%d finished in %0.1f seconds', idxparam, length(classifier.parameters), toc));       
end


% convert cells to matrices for specific metrics
if length(classifier.parameters)>1
    converts = { 'mae', 'rmse', 'rae', 'rrse', 'corrcoef', 'accuracy', 'kappa' };
    fields = fieldnames(results);
    for i=1:length(fields)
        eval(sprintf('if ~isempty(find(strcmp(converts,''%s''))), results.%s = cell2mat(results.%s); end', fields{i}, fields{i}, fields{i}));
    end
end