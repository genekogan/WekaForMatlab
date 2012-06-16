function results = wekaclassify2(classifier, model, dataset)
% results = wekaclassify2(classifier, model, dataset)

WEKAPATH = '/Users/Gene/Code/_Externals/weka-3-6-6/';

% apply model to classifier
cmd = [ 'java -Xmx2g -classpath ' WEKAPATH 'weka.jar ' ...
    classifier.classifier ' -l ' model.path ' -T ../genregrams/' dataset.path ...
    ' -o -p 0 -distribution' ];        

tic;
[ status, result ] = system(cmd);
disp(cmd);
disp(result);
toc;

results = result;

% parse results


%{ 
%distribution

% parse results
result = regexp(result, '[\f\n\r]', 'split');
if strfind(result{5},'distribution')   % or predictions on test data (use []* for multi space)
    prob = zeros(dataset.numinstances,length(dataset.classes));
    for i=1:dataset.numinstances
        pred = regexp(result{5+i},' ','split');
        probdist = regexp(regexprep(pred{end-1},'*',''),',','split');
        for j=1:length(probdist)
            prob(i,j) = str2num(probdist{j});
        end
    end
    results.prob = prob;
end
%}


% regression

t = strfind(result,'=== Predictions on test data ===')
if ~isempty(t)
    result = regexp(result(t:end), '[\f\n\r]', 'split');
    pred = zeros(dataset.numinstances,1);
    actual = zeros(dataset.numinstances,1);
    for i=1:dataset.numinstances
        pred0 = regexp(result{3+i},'[ ]*','split');
        pred0 = pred0(find(~strcmp(pred0,'')));
        actual(i) = str2num(pred0{2});
        pred(i) = str2num(pred0{3});
    end
    results.actual = actual;
    results.predicted = pred;
end
