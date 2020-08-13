classdef nsoltFinalRotationLayer < nnet.layer.Layer
    %NSOLTFINALROTATIONLAYER
    %
    %   コンポーネント別に入力(nComponents):
    %      nRows x nCols x nChs x nSamples
    %
    %   コンポーネント別に出力(nComponents):
    %      nRows x nCols x nDecs x nSamples
    %
    %
    % Requirements: MATLAB R2020a
    %
    % Copyright (c) 2020, Shogo MURAMATSU
    %
    % All rights reserved.
    %
    % Contact address: Shogo MURAMATSU,
    %                Faculty of Engineering, Niigata University,
    %                8050 2-no-cho Ikarashi, Nishi-ku,
    %                Niigata, 950-2181, JAPAN
    %
    % http://msiplab.eng.niigata-u.ac.jp/
        
    properties
        % (Optional) Layer properties.
        NumberOfChannels
        DecimationFactor
        Mus
        
        % Layer properties go here.
    end
    
    properties (Learnable)
        Angles
    end
    
    
    methods
        function layer = nsoltFinalRotationLayer(varargin)
            % (Optional) Create a myLayer.
            % This function must have the same name as the class.
            p = inputParser;
            addParameter(p,'NumberOfChannels',[])
            addParameter(p,'DecimationFactor',[])
            addParameter(p,'Mus',[]);
            addParameter(p,'Angles',[]);
            addParameter(p,'Name','')
            parse(p,varargin{:})
            
            % Layer constructor function goes here.
            layer.NumberOfChannels = p.Results.NumberOfChannels;
            layer.DecimationFactor = p.Results.DecimationFactor;
            layer.Mus = p.Results.Mus;
            layer.Angles = p.Results.Angles;
            layer.Name = p.Results.Name;
            layer.Description = "NSOLT final rotation ( " ...
                + "(ps,pa) = (" ...
                + layer.NumberOfChannels(1) + "," ...
                + layer.NumberOfChannels(2) + "), "  ...
                + "(mv,mh) = (" ...
                + layer.DecimationFactor(1) + "," ...
                + layer.DecimationFactor(2) + ")" ...
                + " )";
            layer.Type = '';
            
                        
            if isempty(layer.Angles)
                nChsTotal = sum(layer.NumberOfChannels);
                nAngles = (nChsTotal-2)*nChsTotal/4;
                layer.Angles = zeros(nAngles,1);
            end
            
        end
        
        function Z = predict(layer, X)
            % Forward input data through the layer at prediction time and
            % output the result.
            %
            % Inputs:
            %         layer       - Layer to forward propagate through
            %         X1, ..., Xn - Input data (n: # of components)
            % Outputs:
            %         Z           - Outputs of layer forward function
            %  
            import saivdr.dcnn.*
            
            % Layer forward function for prediction goes here.
            nrows = size(X,1);
            ncols = size(X,2);
            ps = layer.NumberOfChannels(1);
            pa = layer.NumberOfChannels(2);
            nSamples = size(X,4);
            stride = layer.DecimationFactor;
            nDecs = prod(stride);
            %
            if isempty(layer.Mus)
                muW = 1;
                muU = 1;
            else
                muW = layer.Mus(1:ps);
                muU = layer.Mus(ps+1:end);
            end
            if isempty(layer.Angles)
                W0T = eye(ps);
                U0T = eye(pa);
            else
                anglesW = layer.Angles(1:length(layer.Angles)/2);
                anglesU = layer.Angles(length(layer.Angles)/2+1:end);
                W0T = transpose(fcn_orthonormalmatrixgenerate(anglesW,muW));
                U0T = transpose(fcn_orthonormalmatrixgenerate(anglesU,muU));
            end
            Y = permute(X,[3 1 2 4]);
            Ys = reshape(Y(1:ps,:,:,:),ps,nrows*ncols*nSamples);
            Ya = reshape(Y(ps+1:ps+pa,:,:,:),pa,nrows*ncols*nSamples);
            Zsa = [ W0T(1:nDecs/2,:)*Ys; U0T(1:nDecs/2,:)*Ya ];
            Z = permute(reshape(Zsa,nDecs,nrows,ncols,nSamples),[2 3 1 4]);
        end
        
    end

end
