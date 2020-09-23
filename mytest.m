function testRes = mytest(testCaseStr,isProfiling)
%MYTEST Script of unit testing for SaivDr Package
%
% This test script works with unit testing framework
% See the following site:
%
% http://www.mathworks.co.jp/jp/help/matlab/matlab-unit-test-framework.html
%
% Requirements: MATLAB R2015b
%
% Copyright (c) 2014-2018, Shogo MURAMATSU
%
% All rights reserved.
%
% Contact address: Shogo MURAMATSU,
%    Faculty of Engineering, Niigata University,
%    8050 2-no-cho Ikarashi, Nishi-ku,
%    Niigata, 950-2181, JAPAN
%
% http://msiplab.eng.niigata-u.ac.jp/
%
tic
%%
import matlab.unittest.TestSuite
import matlab.unittest.TestRunner
if nargin > 0
    isTestCase = true;
else
    clear classes %#ok
isTestCase = false;
end

if nargin < 2
isProfiling = false;
end

%% Package list
packageList = { ...
    'saivdr.testcase.dcnn',...
    'saivdr.testcase.dictionary.olpprfb',...
    'saivdr.testcase.dictionary.udhaar',...
    'saivdr.testcase.dictionary.nsoltx',...
    'saivdr.testcase.dictionary.nsoltx.design',...
    'saivdr.testcase.dictionary.olaols',...
    'saivdr.testcase.dictionary.nsgenlotx',...
    'saivdr.testcase.dictionary.nsgenlotx.design',...
    'saivdr.testcase.dictionary.generalfb',...
    'saivdr.testcase.dictionary.mixture',...
    'saivdr.testcase.dictionary.utility',...
    'saivdr.testcase.utility',...
    'saivdr.testcase.degradation',...
    'saivdr.testcase.degradation.noiseprocess'...
    };

packageList_serial = {...
    'saivdr.testcase.sparserep',...
    'saivdr.testcase.degradation.linearprocess',...
    'saivdr.testcase.restoration.ista',...
    'saivdr.testcase.restoration.pds',...
    'saivdr.testcase.restoration.denoiser',...
    'saivdr.testcase.restoration.metricproj',...
    'saivdr.testcase.embedded'...
    };%parpool function cannot be executed by parpool worker.

%% Set path
setpath

%% Run test cases
if isProfiling
    profile on
end
if isTestCase
    testCase = eval(testCaseStr);
    testRes = run(testCase);
else
    packageList = [packageList, packageList_serial];
    testRes = cell(length(packageList),2);
    for idx = 1:length(packageList)
        if verLessThan('matlab','8.2.0.701') && ...
                strcmp(packageList{idx},'saivdr.testcase.embedded')
            disp('Package +embedded is available for R2013b or later.')
        else
            packageSuite = TestSuite.fromPackage(packageList{idx});
            runner = TestRunner.withTextOutput;
            
            testRes{idx,1} = packageList{idx};
            if idx > length(packageList) - length(packageList_serial)
                testRes{idx,2} = run(packageSuite);
            else
                testRes{idx,2} = runInParallel(runner,packageSuite);
            end
        end
    end
end
if isProfiling
    profile off
    profile viewer
end

%% License check
license('inuse')