classdef OvsdLpPuFb2dTypeIVm1System < saivdr.dictionary.nsoltx.AbstOvsdLpPuFb2dTypeISystem %#codegen
    %OVSDLPPUFBMDTYPEIVM1SYSTEM 2-D Type-I Oversampled LPPUFB with one VM
    %
    % SVN identifier:
    % $Id: OvsdLpPuFb2dTypeIVm1System.m 683 2015-05-29 08:22:13Z sho $
    %
    % Requirements: MATLAB R2013b
    %
    % Copyright (c) 2014-2015, Shogo MURAMATSU
    %
    % All rights reserved.
    %
    % Contact address: Shogo MURAMATSU,
    %                Faculty of Engineering, Niigata University,
    %                8050 2-no-cho Ikarashi, Nishi-ku,
    %                Niigata, 950-2181, JAPAN
    %
    % LinedIn: http://www.linkedin.com/pub/shogo-muramatsu/4b/b08/627    
    %      
    
    properties (Access = private)
        initOmgs_
        propOmgs_
    end
    
    methods
        function obj = OvsdLpPuFb2dTypeIVm1System(varargin)
            import saivdr.dictionary.utility.OrthonormalMatrixGenerationSystem
            obj = obj@saivdr.dictionary.nsoltx.AbstOvsdLpPuFb2dTypeISystem(...
                varargin{:});
            obj.initOmgs_ = OrthonormalMatrixGenerationSystem();
            obj.propOmgs_ = OrthonormalMatrixGenerationSystem();
        end
    end
    
    methods (Access = protected)

        function s = saveObjectImpl(obj)
            s = saveObjectImpl@saivdr.dictionary.nsoltx.AbstOvsdLpPuFb2dTypeISystem(obj);
            s.initOmgs_ = matlab.System.saveObject(obj.initOmgs_);
            s.propOmgs_ = matlab.System.saveObject(obj.propOmgs_);
        end
        
        function loadObjectImpl(obj,s,wasLocked)
            loadObjectImpl@saivdr.dictionary.nsoltx.AbstOvsdLpPuFb2dTypeISystem(obj,s,wasLocked);
            obj.initOmgs_ = matlab.System.loadObject(s.initOmgs_);
            obj.propOmgs_ = matlab.System.loadObject(s.propOmgs_);
        end        
        
        function updateParameterMatrixSet_(obj)
            import saivdr.dictionary.nsoltx.ChannelGroup
            nch = sum(obj.NumberOfChannels);
            
            [symAngles, initAngles, propAngles] = splitAngles_(obj);
            
            % symmetric matrix
            mtx = diag(exp(1i*symAngles));
            step(obj.ParameterMatrixSet,mtx,uint32(1));
            
            % initial matrix
            mtx = step(obj.initOmgs_,initAngles,obj.Mus(:,1));
            step(obj.ParameterMatrixSet,mtx,uint32(2));
            
            angles = reshape(propAngles,[],obj.nStages-1);
            mus    = obj.Mus(:,2:end);
            
            nParamMtxAngs = nch*(nch-2)/8;
%             % No-DC-Leackage condition
%             angles(1:nChs(ChannelGroup.LOWER)-1,1) = ...
%                 zeros(nChs(ChannelGroup.LOWER)-1,1);
%             mus(1,1) = 1;
            pmMtxSet = obj.ParameterMatrixSet;
            omgs     = obj.propOmgs_;
            for iParamMtx = uint32(1):obj.nStages-1
                %TODO: No-DC-Leakage conditionを実装する
                % W
                mtx = step(omgs,angles(1:nParamMtxAngs,iParamMtx),mus(1:nch/2,iParamMtx));
                step(pmMtxSet,mtx,3*iParamMtx);
                
                % U
                mtx = step(omgs,angles(nParamMtxAngs+1:2*nParamMtxAngs,iParamMtx),mus(nch/2+1:end,iParamMtx));
                step(pmMtxSet,mtx,3*iParamMtx+1);
                
                % angsB
                step(pmMtxSet,angles(2*nParamMtxAngs+1:end,iParamMtx),3*iParamMtx+2);
            end
            %TODO: No-DC-Leakage Conditionを実装
%             obj.Angles = angles;
%             obj.Mus = mus;
        end
        
    end
    
    methods (Access = protected, Static = true)
        function value = getDefaultPolyPhaseOrder_()
            value = [ 0 0 ];
        end
    end
    
end
