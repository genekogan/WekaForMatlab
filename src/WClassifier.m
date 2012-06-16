classdef WClassifier < handle
    
    % to-do
    %  complete options and classifiers
    %  what to do when option doesn't take value (typeParam = 1,2,3)
    
    properties (SetAccess = private)
        classifier;
        parameters;
    end
    
    methods    
        % constructor
        function c = WClassifier(class)
            c.classifier = lookupKeyword(class);
            c.parameters = {[]};
        end

        % add a parameter set
        function addParameter(c,name,val)
            if (nargin<3) val=[]; end
            if checkIfParamInt(c,name) paramInt = 1; else paramInt = 0; end
            c.parameters = appendParameters(c.parameters,name,val,paramInt);        
        end
        
        % add a more complicated parameter string
        function addParameterSet(varargin)
            c = varargin{1};
            param = lookupKeyword(varargin{2});
            subparams = {[]};
            for i=1:(length(varargin)-2)/2
                if checkIfParamInt(c,varargin{2*i+1}) paramInt = 1; else paramInt = 0; end
                subparams = appendParameters(subparams, varargin{2*i+1}, varargin{2*i+2}, paramInt);
            end            
            c.parameters = appendParameterStrings(c.parameters, param, subparams);
        end
        
        % display all parameters
        function display(c)
            disp(sprintf('Classifier: %s', c.classifier));
            for i=1:length(c.parameters)
                disp(sprintf(' =>%s', c.parameters{i}));
            end
        end
        
    end
end


% Keyword lookup table
function keystring = lookupKeyword(key)
    switch key
        % Classifiers
        case 'SMO'
            keystring = 'weka.classifiers.functions.SMO';
        case 'SMOreg'
            keystring = 'weka.classifiers.functions.SMOreg';
        case 'LinearRegression'
            keystring = 'weka.classifiers.functions.LinearRegression';
        case 'NaiveBayes'
            keystring = 'weka.classifiers.bayes.NaiveBayesSimple';
        case 'AdaBoost'
            keystring = 'weka.classifiers.meta.AdaBoostM1';
        case 'MultiBoostAB'
            keystring = 'weka.classifiers.meta.MultiBoostAB';
        case 'LogitBoost'
            keystring = 'weka.classifiers.meta.LogitBoost';
        case 'J48'
            keystring = 'weka.classifiers.trees.J48';
        case 'MultiLayerPerceptron'
            keystring = 'weka.classifiers.functions.MultilayerPerceptron';
        case 'M5P'
            keystring = 'weka.classifiers.trees.M5P';
        case 'RandomForest'
            keystring = 'weka.classifiers.trees.RandomForest';
            
        % Kernels
        case 'PolyKernel'
            keystring = '-K "weka.classifiers.functions.supportVector.PolyKernel';
        case 'RBFKernel'
            keystring = '-K "weka.classifiers.functions.supportVector.RBFKernel';
            
        % Misc
        case 'RegSMOImproved'
            keystring = '-I "weka.classifiers.functions.supportVector.RegSMOImproved';            
        otherwise
            disp(sprintf('Warning: %s not found in class lookup', key));
            keystring = key;
    end
end

% Helper functions: append parameter combination to existing parameters
function newparams = appendParameters(currparams, name, val, paramInt)
    newparams = [];
    idx = 1;
    if isempty(val)
        for j=1:max(1,length(currparams))
            newparams{idx} = sprintf('%s -%s', currparams{j}, name);
            idx = idx+1;
        end
    else
        for i=1:length(val)
            for j=1:max(1,length(currparams))
                if paramInt               
                    newparams{idx} = sprintf('%s -%s %d', currparams{j}, name, val(i));
                else
                    newparams{idx} = sprintf('%s -%s %0.8f', currparams{j}, name, val(i));
                end
                idx = idx+1;
            end
        end
    end
end

function newparams = appendParameterStrings(currparams, param, paramStrings)
    newparams = [];
    idx = 1;
    for i=1:length(paramStrings)
        for j=1:max(1,length(currparams))
            newparams{idx} = sprintf('%s %s%s"', currparams{j}, param, paramStrings{i});
            idx = idx+1;
        end
    end
end

function paramInt = checkIfParamInt(c,name)
    paramInt = 0;
    switch c.classifier
        case 'weka.classifiers.functions.LinearRegression'
            if isequal(name,'S') paramInt = 1; end;
        case 'weka.classifiers.functions.MultilayerPerceptron'
            if isequal(name,'N') paramInt = 1; end;
        case 'weka.classifiers.trees.M5P'
            if ismember(name,{'N' 'U' 'R' 'M'}) paramInt = 1; end;
    end
end