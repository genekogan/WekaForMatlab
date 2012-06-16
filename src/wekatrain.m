function model = wekatrain2(dataset, classifier, modelname)
% model = wekatrain2(dataset, classifier, modelname)

WEKAPATH = '/Users/Gene/Code/_Externals/weka-3-6-6/';

% set name of model
if nargin<3
    model.path = '.model'; 
    for i=1:8, model.path = [ sprintf('%c', 97+floor(26*rand(1))) model.path ]; end
else
    model.path = modelname;
end

numparams = length(classifier.parameters);
numclasses = length(dataset.classes);

for idxparam = 1:numparams, disp(sprintf('Generating model...'))
    
    model.classes = dataset.classes;
    parameters = classifier.parameters{idxparam};
    if numparams > 1
        disp(sprintf('Parameter set %d of %d', idxparam, numparams)); 
        model.parameters{idxparam} = parameters;
    else
        model.parameters = parameters;
    end               
        
    % create model 
    cmd = [ 'java -Xmx2g -classpath ' WEKAPATH 'weka.jar ' ...
        classifier.classifier ' ' parameters ...
        ' -t ' dataset.path ' -d ' model.path ' -o' ]; % -M        

    tic;
    [ status, result ] = system(cmd);
    disp(cmd);
    disp(result);
    toc;

end

