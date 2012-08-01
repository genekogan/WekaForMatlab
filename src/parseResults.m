function results = parseResults(result, dataset1, dataset2)
% results = parseResults(result, dataset1, dataset2)

% check if actual in prob dist is first or second number, i.e. first:second (labels vs ints) 

%============================
% predictions
%============================
if strfind(result,'=== Predictions on test data ===')
    result = regexp(result, '[\f\n\r]', 'split');
    idxfirst = find(strcmp(result,'=== Predictions on test data ==='));
    
    % get probability distribution...
    if strfind(result{idxfirst+2},'distribution')
        actual = zeros(dataset2.numinstances,1);
        prob = zeros(dataset2.numinstances,length(dataset2.classes));        
        for i=1:dataset2.numinstances
            resline = regexp(result{5+i},'\s+','split');   
            actual0 = regexp(resline{end-3},':','split');
            actual(i) = str2num(actual0{1});
            probdist = regexp(regexprep(resline{end-1},'*',''),',','split');
            for j=1:length(probdist)
                prob(i,j) = str2num(probdist{j});
            end
        end
        results.actual = actual;
        results.prob = prob;
        
    % ... or get actual predictions
    else
        pred = zeros(dataset2.numinstances,1);
        actual = zeros(dataset2.numinstances,1);
        for i=1:dataset2.numinstances
            pred0 = regexp(result{idxfirst+2+i},'\s+','split');
            pred0 = pred0(find(~strcmp(pred0,'')));
            actual(i) = str2num(pred0{2});
            pred(i) = str2num(pred0{3});
        end
        results.actual = actual;
        results.predicted = pred;    
    end
    
    
    
%============================
% classification results
%============================
elseif strfind(result,'=== Stratified cross-validation ===')
    result = regexp(result, '[\f\n\r]', 'split');
    result = result(find(strcmp(result,'=== Stratified cross-validation ===')):end);
        
    idx = find(strncmp(result,'Correctly Classified Instances',30));
    if ~isempty(idx)
        res = regexp(result{idx}, '\s+', 'split');
        res = 0.01 * str2num(res{5});
        results.accuracy = res;
    end
    
    idx = find(strncmp(result,'Kappa statistic',15));
    if ~isempty(idx)
        res = regexp(result{idx}, '\s+', 'split');
        res = str2num(res{3});
        results.kappa = res;
    end

    idx = find(strncmp(result,'Mean absolute error',19));
    if ~isempty(idx)
        res = regexp(result{idx}, '\s+', 'split');
        res = str2num(res{4});
        results.mae = res;
    end

    idx = find(strncmp(result,'Root mean squared error',23));
    if ~isempty(idx)
        res = regexp(result{idx}, '\s+', 'split');
        res = str2num(res{5});
        results.rmse = res;
    end

    idx = find(strncmp(result,'Relative absolute error',23));
    if ~isempty(idx)
        res = regexp(result{idx}, '\s+', 'split');
        res = 0.01 * str2num(res{4});
        results.rae = res;
    end

    idx = find(strncmp(result,'Root relative squared error',27));
    if ~isempty(idx)
        res = regexp(result{idx}, '\s+', 'split');
        res = 0.01 * str2num(res{5});
        results.rrse = res;
    end

    % confusion matrix
    idx = find(strncmp(result,'=== Confusion Matrix ===',23));
    if ~isempty(idx)
        confusion = zeros(length(dataset1.classes));
        for i=1:length(dataset1.classes);
           s = regexp(result{idx+2+i}, '\s+', 'split');
           for j=1:length(dataset1.classes);
               confusion(i,j) = str2num(s{1+j});
           end
        end
%        confusion
%        diag(confusion)
%        sum(confusion)
%        sum(confusion,2)
%        results.confusion = confusion; 
%        results.precision = diag(confusion)' ./ sum(confusion);
%        results.recall = diag(confusion)' ./ sum(confusion,2)';
    end
    
    
%============================
% regression results
%============================    
elseif strfind(result,'=== Cross-validation ===')
    result = regexp(result, '[\f\n\r]', 'split');
    result = result(find(strcmp(result,'=== Cross-validation ===')):end);
        
    idx = find(strncmp(result,'Correlation coefficient',23));
    if ~isempty(idx)
        res = regexp(result{idx}, '\s+', 'split');
        res = str2num(res{3});
        results.corrcoef = res;
    end

    idx = find(strncmp(result,'Mean absolute error',19));
    if ~isempty(idx)
        res = regexp(result{idx}, '\s+', 'split');
        res = str2num(res{4});
        results.mae = res;
    end

    idx = find(strncmp(result,'Root mean squared error',23));
    if ~isempty(idx)
        res = regexp(result{idx}, '\s+', 'split');
        res = str2num(res{5});
        results.rmse = res;
    end

    idx = find(strncmp(result,'Relative absolute error',23));
    if ~isempty(idx)
        res = regexp(result{idx}, '\s+', 'split');
        res = 0.01 * str2num(res{4});
        results.rae = res;
    end

    idx = find(strncmp(result,'Root relative squared error',27));
    if ~isempty(idx)
        res = regexp(result{idx}, '\s+', 'split');
        res = 0.01 * str2num(res{5});
        results.rrse = res;
    end
    
end