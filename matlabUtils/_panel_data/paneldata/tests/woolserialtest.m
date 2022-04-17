function [ test ] = woolserialtest( est, varargin )
%WOOLSERIALTEST Wooldridge's serial correlation test.
%   Computes the Wooldridge's serial correlation test.
%
%   testo = WOOLSERIALTEST( est ) Computes the Wooldridge serial correlation
%   test for the specified estimation output. Returns a test output structure,
%   testout.
%   testo = WOOLSERIALTEST( est ) additional properties using one or more 
%   Name,Value pair arguments.
%
%   Additional properties:
%   - 'dfcorrection': If set to 0 supress the degrees of freedom correction
%   of the clustered regression. Default: 1.
%
%   Example
%     
%      test = woolserialtest(est);
%
%   See also TESTOUT
%
%   Copyright 2013-2015 Inmaculada C. �lvarez, Javier Barbero, Jos� L. Zof�o
%   http://www.paneldatatoolbox.com
%
%   Version: 2.0
%   LAST UPDATE: 17, June, 2015
%

    if est.isMultiEq
        error('Wooldridge''s serial correlation test not available for multi-equation models')
    end
    
    if ~strcmpi(est.options.method,'fe')
        error('Wooldridge''s serial correlation test must be performed after a Fixed Effects estimation');
    end
    
    if est.isInstrumental
        error('PWooldridge''s serial correlation test not valid for instrumetnal estimation')
    end
    
    % Parse Additional options
    p = inputParser;
    if verLessThan('matlab', '8.2')
        addPar = @(v1,v2,v3,v4) addParamValue(v1,v2,v3,v4);
    else
        addPar = @(v1,v2,v3,v4) addParameter(v1,v2,v3,v4);
    end
    addPar(p,'dfcorrection',1,@(x) isnumeric(x));
    p.parse(varargin{:})
    options = p.Results;
    
    % Create otuput structure
    test = testout();
    
    % Get used variables    
    n = est.n;
    T = est.T;
    id = est.id;
    time = est.time;
    
    % Get fe residuals
    res = est.res;
    resLag = res;
    resLag2 = res;
    idLag = id;
    for i=n:-1:1
        tmin = min(time(id == i));
        pos = find(id == i & time == tmin);
        resLag(pos) = [];
        idLag(pos) = [];
        
        
        tmax = max(time(id == i));
        pos = find(id == i & time == tmax);
        resLag2(pos) = [];
        
    end

    % Regress
    wreg = paneldataols(resLag, resLag2,'vartype','cluster','clusterid',idLag,'dfcorrection',options.dfcorrection);
    
    % Compute test
    rho = -1/(T-1);
    R = [1 0];
    r = rho;
    wtest = waldsigtest(wreg,R,r);
    F = wtest.value;
    df = wtest.df;
    p = wtest.p;

    % Store results
    test.test = 'WOOLSERIAL';
    test.value = F;
    test.p = p;
    test.df = df;
    test.isAsymptotic = 0;
    test.isRobust = 0;
    
    % WOOLSERIAL specific
    test.rho = rho;
    
    
end