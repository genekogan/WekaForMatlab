function results = wekaclassify(classifier, model, dataset)
% results = wekaclassify(classifier, model, dataset)

WEKAPATH = '/Users/Gene/Code/_Externals/weka-3-6-6/';

% apply model to classifier
cmd = [ 'java -Xmx2g -classpath ' WEKAPATH 'weka.jar ' ...
    classifier.classifier ' -l ' model.path ' -T ' dataset.path ...
    ' -o -p 0 -distribution' ];        
% -p 0 -distribution
[ status, result ] = system(cmd);
disp(cmd)
%disp(result)

% parse results
t = strfind(result,'=== Predictions on test data ===');
if ~isempty(t)
    res = regexp(result(t:end), '[\f\n\r]', 'split');
    numinstances = length(res)-5;
    pred = zeros(numinstances,1);
    actual = zeros(numinstances,1);
    prob = [];
    for i=1:numinstances
        line = regexp(res{3+i},'[ ]*','split');
        line = line(find(~strcmp(line,'')));
        actual0 = regexp(line{2},':','split');
        actual(i) = str2num(actual0{2});        
        pred0 = regexp(line{3},':','split');
        pred(i) = str2num(pred0{2});
        prob0 = regexp(regexprep(line{end},'*',''),',','split');
        for j=1:length(prob0)
            prob(i,j) = str2double(prob0{j});
        end
    end
    results.actual = actual;
    results.predicted = pred;
    results.prob = prob;
end