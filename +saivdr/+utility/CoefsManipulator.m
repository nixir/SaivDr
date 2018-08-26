classdef CoefsManipulator < matlab.System
    %COEFSMANIPULATOR Coefficient manipulator for OLS/OLA wrapper classes
    %
    % http://msiplab.eng.niigata-u.ac.jp/
    %
    
    properties (Nontunable)
        Manipulation
    end
    
    properties
        State
    end
    
    properties (Logical)
        IsFeedBack = false
        IsStateOutput = false
    end
    
    methods
        
        % Constractor
        function obj = CoefsManipulator(varargin)
            setProperties(obj,nargin,varargin{:})
        end
        
    end
    
    methods(Access = protected)
        
        function s = saveObjectImpl(obj)
            s = saveObjectImpl@matlab.System(obj);
        end
        
        function loadObjectImpl(obj,s,wasLocked)
            loadObjectImpl@matlab.System(obj,s,wasLocked);
        end
        
        
        function coefspst = stepImpl(obj,coefspre)
            isfeedback_ = obj.IsFeedBack;
            manipulation_ = obj.Manipulation;
            
            if isempty(manipulation_)
                coefspst = coefspre;
            else
                if iscell(coefspre)
                    nChs = length(coefspre);
                    coefspst = cell(1,nChs);
                    if isfeedback_
                        if obj.IsStateOutput
                            state = cell(1,nChs);
                            for iCh = 1:nChs
                                [coefspst{iCh},state{iCh}] = ...
                                    manipulation_(coefspre{iCh},...
                                    obj.State{iCh});
                            end
                        else
                            for iCh = 1:nChs
                                coefspst{iCh} = manipulation_(...
                                    coefspre{iCh},obj.State{iCh});
                            end
                            state = coefspst;
                        end
                        obj.State = state;
                    else
                        for iCh = 1:nChs
                            coefspst{iCh} = manipulation_(coefspre{iCh});
                        end
                    end
                else
                    if isfeedback_
                        if obj.IsStateOutput
                            [coefspst,state] = ...
                                manipulation_(coefspre,obj.State);
                        else
                            coefspst = manipulation_(coefspre,obj.State);
                            state = coefspst;                            
                        end
                        obj.State = state;
                    else
                        coefspst = manipulation_(coefspre);        
                    end
                end
            end
        end
    end

end

