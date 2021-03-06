classdef GradientPursuitTestCase < matlab.unittest.TestCase
    %GradientPursuitTESTCASE Test case for sis2dSystem
    %
    % Requirements: MATLAB R2015b
    %
    % Copyright (c) 2014-2020, Shogo MURAMATSU
    %
    % All rights reserved.
    %
    % Contact address: Shogo MURAMATSU,
    %                Faculty of Engineering, Niigata University,
    %                8050 2-no-cho Ikarashi, Nishi-ku,
    %                Niigata, 950-2181, JAPAN
    %
    % http://msiplab.eng.niigata-u.ac.jp/    
    %
    properties
        gp
    end
        
    methods (TestMethodTeardown)
        function deleteObject(testCase)
            delete(testCase.gp);
        end
    end
    
    methods (Test)
        
        function testGpNsoltCh5plus2Ord44Level1(testCase)
            
            nDecs = [ 2 2 ];
            nChs  = [ 5 2 ];
            nOrds = [ 4 4 ];
            height = 32;
            width  = 32;
            srcImg = rand(height,width);
            
            % Expected values
            nCoefsExpctd = 32;
            sizeOfCoefExpctd = [ 1 numel(srcImg)*sum(nChs)/prod(nDecs) ];
            
            % Preparation
            import saivdr.dictionary.nsoltx.*
            lppufb = NsoltFactory.createOvsdLpPuFb2dSystem(...
                'DecimationFactor',nDecs,...
                'NumberOfChannels', nChs ,...
                'PolyPhaseOrder',nOrds,...
                'OutputMode','ParameterMatrixSet' );
            angs = get(lppufb,'Angles');
            angs = randn(size(angs));
            set(lppufb,'Angles',angs);
            
            % Instantiation of target class
            import saivdr.sparserep.*
            synthesizer = NsoltFactory.createSynthesis2dSystem(...
                lppufb,...
                'BoundaryOperation','Termination');            
            analyzer     = NsoltFactory.createAnalysis2dSystem(...
                lppufb,...
                'BoundaryOperation','Termination');                        
            testCase.gp = GradientPursuit(...
                'Dictionary', { synthesizer, analyzer });
            
            % Actual values
            testCase.gp.NumberOfSparseCoefficients = nCoefsExpctd;
            [resActual, coefsActual, scalesActual] = ...
                testCase.gp.step(srcImg);
            nCoefsActual = nnz(coefsActual);
            
            % Evaluation
            import matlab.unittest.constraints.IsTrue;
            testCase.verifySize(resActual, size(srcImg));
            testCase.verifySize(coefsActual, sizeOfCoefExpctd);
            testCase.verifyThat(norm(resActual(:)) < norm(srcImg(:)), ...
                IsTrue, ...
                sprintf('||r||^2 = %g must be less than ||x||^2 = %g.',...
                norm(resActual(:)),norm(srcImg(:)))); 
            testCase.verifyThat(nCoefsActual<=nCoefsExpctd,IsTrue);
            
            resExpctd = step(synthesizer,coefsActual,scalesActual);
            testCase.verifyEqual(resActual,resExpctd,...
                'AbsTol',1e-9);
            
            %{
            mse = @(x,y) ((x(:)-y(:)).^2)/numel(x);
            psnr = @(x,y) -10*log10(mse(x,y));
            sprintf('psnr = %6.2f [dB]\n',psnr(resImg,srcImg))
            %}
        end

        function testGpNsoltCh5plus2Ord44Level2(testCase)
            
            nDecs = [ 2 2 ];
            nChs  = [ 5 2 ];
            nOrds = [ 4 4 ];
            nLevels = 2;
            height = 32;
            width  = 32;
            srcImg = rand(height,width);
            
            % Expected values
            nCoefsExpctd = 32;
            
            % Preparation
            import saivdr.dictionary.nsoltx.*
            lppufb = NsoltFactory.createOvsdLpPuFb2dSystem(...
                'DecimationFactor',nDecs,...
                'NumberOfChannels', nChs ,...
                'PolyPhaseOrder',nOrds,...
                'OutputMode','ParameterMatrixSet' );
            angs = get(lppufb,'Angles');
            angs = randn(size(angs));
            set(lppufb,'Angles',angs);
            
            % Instantiation of target class
            synthesizer = NsoltFactory.createSynthesis2dSystem(...
                lppufb,...
                'BoundaryOperation','Termination');                        
            analyzer    = NsoltFactory.createAnalysis2dSystem(...
                lppufb,...
                'BoundaryOperation','Termination',...
                'NumberOfLevels',nLevels);
            import saivdr.sparserep.*
            testCase.gp = GradientPursuit(...
                'Dictionary', { synthesizer, analyzer });
            
            % Expected values
            nCoefs = numel(srcImg)*((sum(nChs)-1)/prod(nDecs) ...
                + sum(nChs)/prod(nDecs)^2);
            sizeOfCoefsExpctd = [ 1 nCoefs ];
            
            % Actual values
            testCase.gp.NumberOfSparseCoefficients = nCoefsExpctd;
            [resActual, coefsActual, scalesActual] = ...
                testCase.gp.step(srcImg);
            nCoefsActual =  nnz(coefsActual);
            
            % Evaluation
            import matlab.unittest.constraints.IsTrue;
            testCase.verifySize(resActual, size(srcImg));
            testCase.verifySize(coefsActual, sizeOfCoefsExpctd);
            testCase.verifyThat(norm(resActual(:)) < norm(srcImg(:)), ...
                IsTrue, ...
                sprintf('||r||^2 = %g must be less than ||x||^2 = %g.',...
                norm(resActual(:)),norm(srcImg(:)))); 
            testCase.verifyThat(nCoefsActual<=nCoefsExpctd,IsTrue);
            
            resExpctd = step(synthesizer,coefsActual,scalesActual);
            testCase.verifyEqual(resActual,resExpctd,...
                'AbsTol',1e-9);
            
            %{
            mse = @(x,y) ((x(:)-y(:)).^2)/numel(x);
            psnr = @(x,y) -10*log10(mse(x,y));
            sprintf('psnr = %6.2f [dB]\n',psnr(resImg,srcImg))
            %}        
        end

        function testGpNsoltCh5plus2Ord44Level3(testCase)
            
            nDecs = [ 2 2 ];
            nChs  = [ 5 2 ];
            nOrds = [ 4 4 ];
            nLevels = 3;
            height = 32;
            width  = 32;
            srcImg = rand(height,width);
            
            % Expected values
            nCoefsExpctd = 32;
            
            % Preparation
            import saivdr.dictionary.nsoltx.*
            lppufb = NsoltFactory.createOvsdLpPuFb2dSystem(...
                'DecimationFactor',nDecs,...
                'NumberOfChannels', nChs ,...
                'PolyPhaseOrder',nOrds,...
                'OutputMode','ParameterMatrixSet' );
            angs = get(lppufb,'Angles');
            angs = randn(size(angs));
            set(lppufb,'Angles',angs);
            
            % Instantiation of target class
            synthesizer = NsoltFactory.createSynthesis2dSystem(...
                lppufb,...
                'BoundaryOperation','Termination');                        
            analyzer    = NsoltFactory.createAnalysis2dSystem(...
                lppufb,...
                'BoundaryOperation','Termination',...
                'NumberOfLevels',nLevels);                                    
            import saivdr.sparserep.*
            testCase.gp = GradientPursuit(...
                'Dictionary', { synthesizer, analyzer });
            
            % Expected values
            nCoefs = numel(srcImg)*((sum(nChs)-1)/prod(nDecs) ...
                + (sum(nChs)-1)/prod(nDecs)^2 ...
                + sum(nChs)/prod(nDecs)^3);
            sizeOfCoefsExpctd = [ 1 nCoefs ];
            
            % Actual values
            testCase.gp.NumberOfSparseCoefficients = nCoefsExpctd;
            [resActual, coefsActual, scalesActual] = ...
                testCase.gp.step(srcImg);
            nCoefsActual = nnz(coefsActual);
            
            % Evaluation
            import matlab.unittest.constraints.IsTrue;
            testCase.verifySize(resActual, size(srcImg));
            testCase.verifySize(coefsActual, sizeOfCoefsExpctd);
            testCase.verifyThat(norm(resActual(:)) < norm(srcImg(:)), ...
                IsTrue, ...
                sprintf('||r||^2 = %g must be less than ||x||^2 = %g.',...
                norm(resActual(:)),norm(srcImg(:)))); 
            testCase.verifyThat(nCoefsActual<=nCoefsExpctd,IsTrue);
            
            resExpctd = step(synthesizer,coefsActual,scalesActual);
            testCase.verifyEqual(resActual,resExpctd,...
                'AbsTol',1e-9);
            %{
            mse = @(x,y) ((x(:)-y(:)).^2)/numel(x);
            psnr = @(x,y) -10*log10(mse(x,y));
            sprintf('psnr = %6.2f [dB]\n',psnr(resImg,srcImg))
                %}
        end

        function testGpNsoltCh2plus2Ord22Level1(testCase)
            
            nDecs = [ 2 2 ];
            nChs  = [ 2 2 ];
            nOrds = [ 4 4 ];
            height = 32;
            width  = 32;
            srcImg = rand(height,width);
            
            % Expected values
            nCoefsExpctd = 32;
            sizeOfCoefsExpctd = [ 1 numel(srcImg)*sum(nChs)/prod(nDecs) ];
            
            % Preparation
            import saivdr.dictionary.nsoltx.*
            lppufb = NsoltFactory.createOvsdLpPuFb2dSystem(...
                'DecimationFactor',nDecs,...
                'NumberOfChannels', nChs ,...
                'PolyPhaseOrder',nOrds,...
                'OutputMode','ParameterMatrixSet' );
            angs = get(lppufb,'Angles');
            angs = randn(size(angs));
            set(lppufb,'Angles',angs);
            
            % Instantiation of target class
            synthesizer = NsoltFactory.createSynthesis2dSystem(...
                lppufb,...
                'BoundaryOperation','Termination');
            analyzer    = NsoltFactory.createAnalysis2dSystem(...
                lppufb,...
                'BoundaryOperation','Termination');
            import saivdr.sparserep.*
            testCase.gp = GradientPursuit(...
                'Dictionary', { synthesizer, analyzer });
            
            % Actual values
            testCase.gp.NumberOfSparseCoefficients = nCoefsExpctd;
            [resActual, coefsActual, scalesActual] = ...
                testCase.gp.step(srcImg);
            nCoefsActual = nnz(coefsActual);
            
            % Evaluation
            import matlab.unittest.constraints.IsTrue;
            testCase.verifySize(resActual, size(srcImg));
            testCase.verifySize(coefsActual, sizeOfCoefsExpctd);
            testCase.verifyThat(norm(resActual(:)) < norm(srcImg(:)), ...
                IsTrue, ...
                sprintf('||r||^2 = %g must be less than ||x||^2 = %g.',...
                norm(resActual(:)),norm(srcImg(:)))); 
            testCase.verifyThat(nCoefsActual<=nCoefsExpctd,IsTrue);
            
            resExpctd = step(synthesizer,coefsActual,scalesActual);
            testCase.verifyEqual(resActual,resExpctd,...
                'AbsTol',1e-9);
            
            %{
            mse = @(x,y) ((x(:)-y(:)).^2)/numel(x);
            psnr = @(x,y) -10*log10(mse(x,y));
            sprintf('psnr = %6.2f [dB]\n',psnr(resImg,srcImg))
            %}
        end

        function testGpNsoltCh2plus2Ord22Level2(testCase)
            
            nDecs = [ 2 2 ];
            nChs  = [ 2 2 ];
            nOrds = [ 2 2 ];
            nLevels = 2;
            height = 32;
            width  = 32;
            srcImg = rand(height,width);
            
            % Expected values
            nCoefsExpctd = 32;
            
            % Preparation
            import saivdr.dictionary.nsoltx.*
            lppufb = NsoltFactory.createOvsdLpPuFb2dSystem(...
                'DecimationFactor',nDecs,...
                'NumberOfChannels', nChs ,...
                'PolyPhaseOrder',nOrds,...
                'OutputMode','ParameterMatrixSet' );
            angs = get(lppufb,'Angles');
            angs = randn(size(angs));
            set(lppufb,'Angles',angs);
            
            % Instantiation of target class
            synthesizer = NsoltFactory.createSynthesis2dSystem(...
                lppufb,...
                'BoundaryOperation','Termination');            
            analyzer    = NsoltFactory.createAnalysis2dSystem(...
                lppufb,...
                'BoundaryOperation','Termination',...
                'NumberOfLevels',nLevels);            
            import saivdr.sparserep.*
            testCase.gp = GradientPursuit(...
                'Dictionary', { synthesizer, analyzer });
            
            % Expected values
            nCoefs = numel(srcImg)*(...
                (sum(nChs)-1)/prod(nDecs) + sum(nChs)/(prod(nDecs)^2));
            sizeOfCoefsExpctd = [ 1 nCoefs ];
            
            % Actual values
            testCase.gp.NumberOfSparseCoefficients = nCoefsExpctd;
            [resActual, coefsActual, scalesActual] = ...
                testCase.gp.step(srcImg);
            nCoefsActual = nnz(coefsActual);
            
            % Evaluation
            import matlab.unittest.constraints.IsTrue;
            testCase.verifySize(resActual, size(srcImg));
            testCase.verifySize(coefsActual, sizeOfCoefsExpctd);
            testCase.verifyThat(norm(resActual(:)) < norm(srcImg(:)), ...
                IsTrue, ...
                sprintf('||r||^2 = %g must be less than ||x||^2 = %g.',...
                norm(resActual(:)),norm(srcImg(:)))); 
            testCase.verifyThat(nCoefsActual<=nCoefsExpctd,IsTrue);
            
            resExpctd = step(synthesizer,coefsActual,scalesActual);
            testCase.verifyEqual(resActual,resExpctd,...
                'AbsTol',1e-9);
            
            %{
            mse = @(x,y) ((x(:)-y(:)).^2)/numel(x);
            psnr = @(x,y) -10*log10(mse(x,y));
            sprintf('psnr = %6.2f [dB]\n',psnr(resImg,srcImg))
            %}        
        end
 
        function testGpNsoltCh2plus2Ord22Level3(testCase)
            
            nDecs = [ 2 2 ];
            nChs  = [ 2 2 ];
            nOrds = [ 2 2 ];
            nLevels = 3;
            height = 32;
            width  = 32;
            srcImg = rand(height,width);
            
            % Expected values
            nCoefsExpctd = 32;
            
            % Preparation
            import saivdr.dictionary.nsoltx.*
            lppufb = NsoltFactory.createOvsdLpPuFb2dSystem(...
                'DecimationFactor',nDecs,...
                'NumberOfChannels', nChs ,...
                'PolyPhaseOrder',nOrds,...
                'OutputMode','ParameterMatrixSet' );
            angs = get(lppufb,'Angles');
            angs = randn(size(angs));
            set(lppufb,'Angles',angs);
            
            % Instantiation of target class
            synthesizer = NsoltFactory.createSynthesis2dSystem(...
                lppufb,...
                'BoundaryOperation','Termination');            
            analyzer    = NsoltFactory.createAnalysis2dSystem(...
                lppufb,...
                'BoundaryOperation','Termination',...
                'NumberOfLevels',nLevels);                        
            import saivdr.sparserep.*
            testCase.gp = GradientPursuit(...
                'Dictionary', { synthesizer, analyzer });
            
            % Expected values
            nCoefs = numel(srcImg)*sum(nChs)/prod(nDecs);
            sizeOfCoefsExpctd = [ 1 nCoefs ];
                
            % Actual values
            testCase.gp.NumberOfSparseCoefficients = nCoefsExpctd;
            [resActual, coefsActual, scalesActual] = ...
                testCase.gp.step(srcImg);
            nCoefsActual = nnz(coefsActual);
            
            % Evaluation
            import matlab.unittest.constraints.IsTrue;
            testCase.verifySize(resActual, size(srcImg));
            testCase.verifySize(coefsActual, sizeOfCoefsExpctd);
            testCase.verifyThat(norm(resActual(:)) < norm(srcImg(:)), ...
                IsTrue, ...
                sprintf('||r||^2 = %g must be less than ||x||^2 = %g.',...
                norm(resActual(:)),norm(srcImg(:)))); 
            testCase.verifyThat(nCoefsActual<=nCoefsExpctd,IsTrue);
            
            resExpctd = step(synthesizer,coefsActual,scalesActual);
            testCase.verifyEqual(resActual,resExpctd,...
                'AbsTol',1e-9);
            
            %{
            mse = @(x,y) ((x(:)-y(:)).^2)/numel(x);
            psnr = @(x,y) -10*log10(mse(x,y));
            sprintf('psnr = %6.2f [dB]\n',psnr(resImg,srcImg))
                %}
        end        
 
        function testGpNsoltCh5plus2Ord44Level3Aprx(testCase)
            
            nDecs = [ 2 2 ];
            nChs  = [ 5 2 ];
            nOrds = [ 4 4 ];
            height = 32;
            width  = 64;
            nLevels = 3;
            srcImg = rand(height,width);
            
            % Preparation
            vm = 1;
            import saivdr.dictionary.nsoltx.*
            lppufb = NsoltFactory.createOvsdLpPuFb2dSystem(...
                'DecimationFactor',nDecs,...
                'NumberOfChannels', nChs ,...
                'PolyPhaseOrder',nOrds,...
                'NumberOfVanishingMoments',vm,...
                'OutputMode','ParameterMatrixSet');
            synthesizer = NsoltFactory.createSynthesis2dSystem(...
                lppufb,...
                'BoundaryOperation','Termination');            
            analyzer    = NsoltFactory.createAnalysis2dSystem(...
                lppufb,...
                'BoundaryOperation','Termination',...
                'NumberOfLevels',nLevels);     
            
            % Instantiation of target class
            import saivdr.sparserep.*
            testCase.gp = GradientPursuit(...
                'Dictionary', { synthesizer, analyzer });
            
            % Evaluation
            import matlab.unittest.constraints.IsLessThan
            testCase.gp.NumberOfSparseCoefficients = 1;
            res0 = testCase.gp.step(srcImg);
            for nCoefs = 2:32
                testCase.gp.NumberOfSparseCoefficients = nCoefs;
                res1 = testCase.gp.step(srcImg);
                testCase.verifyThat(norm(res1(:)-srcImg(:),2),...
                    IsLessThan(norm(res0(:)-srcImg(:),2)),...
                    sprintf('||r1|| = %g must be less than ||r0|| = %g.',...
                    norm(res1(:),2),norm(res0(:),2)));
                res0 = res1;
            end
        end        
             
        function testGpNsHaarLevel1(testCase)
            
            nLevels = 1;
            height = 32;
            width  = 32;
            srcImg = rand(height,width);
            
            % Expected values
            nCoefsExpctd = 32;
            
            % Instantiation of target class
            import saivdr.dictionary.udhaar.*
            import saivdr.sparserep.*
            synthesizer = UdHaarSynthesis2dSystem();
            analyzer    = UdHaarAnalysis2dSystem();
            analyzer.NumberOfLevels = nLevels;
            testCase.gp = GradientPursuit(...
                'Dictionary', { synthesizer, analyzer });
            
            % Actual values
            testCase.gp.NumberOfSparseCoefficients = nCoefsExpctd;
            [resActual, coefsActual] = ...
                testCase.gp.step(srcImg);
            nCoefsActual = nnz(coefsActual);
            
            % Evaluation
            import matlab.unittest.constraints.IsTrue;
            testCase.verifySize(resActual, size(srcImg));
            testCase.verifySize(coefsActual, [ 1 (3*nLevels+1)*height*width]);
            testCase.verifyThat(norm(resActual(:)) < norm(srcImg(:)), ...
                IsTrue, ...
                sprintf('||r||^2 = %g must be less than ||x||^2 = %g.',...
                norm(resActual(:)),norm(srcImg(:)))); 
            testCase.verifyThat(nCoefsActual<=nCoefsExpctd,IsTrue);
            
            resExpctd = step(synthesizer,coefsActual,repmat(size(srcImg),[4 1]));
            testCase.verifyEqual(resActual,resExpctd,...
                'AbsTol',1e-10);
            
            %{
            mse = @(x,y) ((x(:)-y(:)).^2)/numel(x);
            psnr = @(x,y) -10*log10(mse(x,y));
            sprintf('psnr = %6.2f [dB]\n',psnr(resImg,srcImg))
            %}
        end
              
        function testGpNsHaarLevel2(testCase)
            
            nLevels = 2;
            height = 32;
            width  = 32;
            srcImg = rand(height,width);
            
            % Expected values
            nCoefsExpctd = 32;
            
            % Instantiation of target class
            import saivdr.dictionary.udhaar.*
            import saivdr.sparserep.*
            synthesizer = UdHaarSynthesis2dSystem();
            analyzer    = UdHaarAnalysis2dSystem();
            analyzer.NumberOfLevels = nLevels;
            testCase.gp = GradientPursuit(...
                'Dictionary', { synthesizer, analyzer });
            
            % Actual values
            testCase.gp.NumberOfSparseCoefficients = nCoefsExpctd;
            [resActual, coefsActual] = ...
                testCase.gp.step(srcImg);
            nCoefsActual = nnz(coefsActual);
            
            % Evaluation
            import matlab.unittest.constraints.IsTrue;
            testCase.verifySize(resActual, size(srcImg));
            testCase.verifySize(coefsActual, [ 1 (3*nLevels+1)*height*width]);
            testCase.verifyThat(norm(resActual(:)) < norm(srcImg(:)), ...
                IsTrue, ...
                sprintf('||r||^2 = %g must be less than ||x||^2 = %g.',...
                norm(resActual(:)),norm(srcImg(:)))); 
            testCase.verifyThat(nCoefsActual<=nCoefsExpctd,IsTrue);
            
            resExpctd = step(synthesizer,coefsActual,repmat(size(srcImg),[7 1]));
            testCase.verifyEqual(resActual,resExpctd,...
                'AbsTol',1e-10);
            
            %{
            mse = @(x,y) ((x(:)-y(:)).^2)/numel(x);
            psnr = @(x,y) -10*log10(mse(x,y));
            sprintf('psnr = %6.2f [dB]\n',psnr(resImg,srcImg))
            %}
        end

        % Test step monitoring
        function testStepMonitoring(testCase)
            
            % Preperation
            height = 32;
            width  = 32;
            srcImg = rand(height,width);
            nCoefs = 32;
            import saivdr.dictionary.nsoltx.*
            synthesizer = NsoltFactory.createSynthesis2dSystem();
            analyzer    = NsoltFactory.createAnalysis2dSystem();
            analyzer.NumberOfLevels = 3;
            
            % Instantiation of step monitor
            import saivdr.utility.*
            stepMonitor = StepMonitoringSystem(...
                'SourceImage',srcImg,...
                'IsVerbose',false,...
                'IsMSE',true);
            
            % Instantiation of target class
            import saivdr.sparserep.*
            testCase.gp = GradientPursuit(...
                'Dictionary', { synthesizer, analyzer },...
                'StepMonitor',stepMonitor);
            
            % Definition of MSE
            mse = @(x,y) sum((double(x(:))-double(y(:))).^2)/numel(x);
            
            % MSE after processing
            testCase.gp.NumberOfSparseCoefficients = nCoefs;
            resImg = testCase.gp.step(srcImg);
            mseExpctd = mse(uint8(255*resImg),uint8(255*srcImg));
            
            % Actual value
            mses = get(stepMonitor,'MSEs');
            nitr = get(stepMonitor,'nItr');
            mseActual = mses(nitr);
            
            % Evaluation
            diff = max(abs(mseExpctd(:)-mseActual(:))./abs(mseExpctd(:)));
            testCase.assertEqual(mseActual,mseExpctd,'AbsTol',1e-10,...
                sprintf('diff = %f\n',diff))
            
        end
        
               
        % Test
        function testClone(testCase)
            
            % Preperation
            height = 32;
            width  = 32;
            nCoefs = 32;
            srcImg = rand(height,width);
            import saivdr.dictionary.nsoltx.*
            synthesizer = NsoltFactory.createSynthesis2dSystem();
            analyzer    = NsoltFactory.createAnalysis2dSystem();
            analyzer.NumberOfLevels = 3;
            
            % MSE before processing
            mse = @(x,y) sum((x(:)-y(:)).^2)/numel(x);
            
            % Instantiation of target class
            import saivdr.sparserep.*
            testCase.gp = IterativeHardThresholding(...
                'Dictionary', { synthesizer, analyzer });
            
            % MSE by original object
            testCase.gp.NumberOfSparseCoefficients = nCoefs;
            resImg = testCase.gp.step(srcImg);
            mseOrg = mse(int16(255*resImg),int16(255*srcImg));            
            
            % Instantiation of target class
            cloneGp = clone(testCase.gp);
            
            % MSE by clone object
            cloneGp.NumberOfSparseCoefficients = nCoefs;
            resImg = cloneGp.step(srcImg);
            mseCln = mse(int16(255*resImg),int16(255*srcImg));                        
            
            % Evaluation
            testCase.verifyEqual(mseCln,mseOrg);
            
        end
        
        % Test
        function testCloneWithChildObj(testCase)
            
            % Preperation
            import saivdr.dictionary.nsoltx.*
            synthesizer = NsoltFactory.createSynthesis2dSystem();
            analyzer    = NsoltFactory.createAnalysis2dSystem();
            analyzer.NumberOfLevels = 3;
            
            % Instantiation of target class
            import saivdr.sparserep.*
            testCase.gp = IterativeHardThresholding(...
                'Dictionary', { synthesizer, analyzer });
            
            % Instantiation of target class
            cloneGp = clone(testCase.gp);
            
            % Evaluation
            testCase.verifyEqual(cloneGp,testCase.gp);
            testCase.verifyFalse(cloneGp == testCase.gp);
            %
            prpOrg = testCase.gp.Dictionary{1};
            prpCln = cloneGp.Dictionary{1};
            testCase.verifyEqual(prpCln,prpOrg);
            testCase.verifyFalse(prpCln == prpOrg);
            %
            prpOrg = testCase.gp.Dictionary{2};
            prpCln = cloneGp.Dictionary{2};
            testCase.verifyEqual(prpCln,prpOrg);
            testCase.verifyFalse(prpCln == prpOrg);
            
        end                
        
        function testIhtNsoltDec222Ch66Ord222Level1(testCase)
            
            nDecs = [ 2 2 2 ];
            nChs  = [ 6 6 ];
            nOrds = [ 2 2 2 ];
            height = 32;
            width  = 32;
            depth  = 32;
            srcImg = rand(height,width,depth);
            
            % Expected values
            nCoefsExpctd = 32;
            sizeOfCoefsExpctd = [ 1 numel(srcImg)*sum(nChs)/prod(nDecs) ];
            
            % Preparation
            import saivdr.dictionary.nsoltx.*
            lppufb = NsoltFactory.createOvsdLpPuFb3dSystem(...
                'DecimationFactor', nDecs,...
                'NumberOfChannels', nChs ,...
                'PolyPhaseOrder', nOrds,...
                'OutputMode','ParameterMatrixSet');
            angs = get(lppufb,'Angles');
            angs = randn(size(angs));
            set(lppufb,'Angles',angs);
            
            % Instantiation of target class
            import saivdr.sparserep.*            
            synthesizer = NsoltFactory.createSynthesis3dSystem(...
                lppufb,'BoundaryOperation','Termination');
            analyzer    = NsoltFactory.createAnalysis3dSystem(...
                lppufb,'BoundaryOperation','Termination');            
            testCase.gp = IterativeHardThresholding(...
                'Dictionary',{ synthesizer, analyzer});
            
            % Actual values
            testCase.gp.NumberOfSparseCoefficients = nCoefsExpctd;
            [resActual, coefsActual, scalesActual] = ...
                testCase.gp.step(srcImg);
            nCoefsActual = nnz(coefsActual);
            
            % Evaluation
            import matlab.unittest.constraints.IsTrue;
            testCase.verifySize(resActual, size(srcImg));
            testCase.verifySize(coefsActual, sizeOfCoefsExpctd);
            testCase.verifyThat(norm(resActual(:),2) < norm(srcImg(:),2), ...
                IsTrue, ...
                sprintf('||r|| = %g must be less than ||x|| = %g.',...
                norm(resActual(:),2),norm(srcImg(:),2))); 
            testCase.verifyThat(nCoefsActual<=nCoefsExpctd,IsTrue);
            
            resExpctd = step(synthesizer,coefsActual,scalesActual);
            testCase.verifyEqual(resActual,resExpctd,...
                'AbsTol',1e-10);
            
            %{
            mse = @(x,y) ((x(:)-y(:)).^2)/numel(x);
            psnr = @(x,y) -10*log10(mse(x,y));
            sprintf('psnr = %6.2f [dB]\n',psnr(resImg,srcImg))
            %}
        end

        function testIhtNsoltDec222Ch66Ord222Level2(testCase)
            
            nDecs = [ 2 2 2 ];
            nChs  = [ 6 6 ];
            nOrds = [ 2 2 2 ];
            nLevels = 2;
            height = 32;
            width  = 32;
            depth  = 32;
            srcImg = rand(height,width,depth);
            
            % Expected values
            nCoefsExpctd = 32;
            
            % Preparation
            import saivdr.dictionary.nsoltx.*
            lppufb = NsoltFactory.createOvsdLpPuFb3dSystem(...
                'DecimationFactor', nDecs,...
                'NumberOfChannels', nChs ,...
                'PolyPhaseOrder', nOrds,...
                'OutputMode','ParameterMatrixSet');
            angs = get(lppufb,'Angles');
            angs = randn(size(angs));
            set(lppufb,'Angles',angs);
            
            % Instantiation of target class
            import saivdr.sparserep.*            
            synthesizer = NsoltFactory.createSynthesis3dSystem(...
                lppufb,'BoundaryOperation','Termination');            
            analyzer    = NsoltFactory.createAnalysis3dSystem(...
                lppufb,'BoundaryOperation','Termination',...
                'NumberOfLevels',2);            
            testCase.gp = IterativeHardThresholding(...
                'Dictionary',{ synthesizer, analyzer});
            
            % Expected values
            P = sum(nChs);
            M = prod(nDecs);
            nCoefs = numel(srcImg)*((P-1)/(M-1)-(P-M)/((M-1)*M^nLevels));
            sizeOfCoefsExpctd = [ 1 nCoefs ];
            
            % Actual values
            testCase.gp.NumberOfSparseCoefficients = nCoefsExpctd;
            [resActual, coefsActual, scalesActual] = ...
                testCase.gp.step(srcImg);
            nCoefsActual = nnz(coefsActual);
            
            % Evaluation
            import matlab.unittest.constraints.IsTrue;
            testCase.verifySize(resActual, size(srcImg));
            testCase.verifySize(coefsActual, sizeOfCoefsExpctd);
            testCase.verifyThat(norm(resActual(:)) < norm(srcImg(:)), ...
                IsTrue, ...
                sprintf('||r||^2 = %g must be less than ||x||^2 = %g.',...
                norm(resActual(:)),norm(srcImg(:)))); 
            testCase.verifyThat(nCoefsActual<=nCoefsExpctd,IsTrue);
            
            resExpctd = step(synthesizer,coefsActual,scalesActual);
            testCase.verifyEqual(resActual,resExpctd,...
                'AbsTol',1e-10);
            
            %{
            mse = @(x,y) ((x(:)-y(:)).^2)/numel(x);
            psnr = @(x,y) -10*log10(mse(x,y));
            sprintf('psnr = %6.2f [dB]\n',psnr(resImg,srcImg))
            %}        
        end
       
        function testIhtNsoltDec222Ch66Ord222Level3(testCase)
            
            nDecs = [ 2 2 2 ];
            nChs  = [ 6 6 ];
            nOrds = [ 2 2 2 ];
            nLevels = 3;
            height = 32;
            width  = 32;
            depth  = 32;
            srcImg = rand(height,width,depth);
            
            % Expected values
            nCoefsExpctd = 32;
            
            % Preparation
            import saivdr.dictionary.nsoltx.*
            lppufb = NsoltFactory.createOvsdLpPuFb3dSystem(...              
                'DecimationFactor', nDecs,...
                'NumberOfChannels', nChs ,...
                'PolyPhaseOrder', nOrds,...
                'OutputMode','ParameterMatrixSet');
            angs = get(lppufb,'Angles');
            angs = randn(size(angs));
            set(lppufb,'Angles',angs);
            
            % Instantiation of target class
            import saivdr.sparserep.*            
            synthesizer = NsoltFactory.createSynthesis3dSystem(...
                lppufb,'BoundaryOperation','Termination');            
            analyzer    = NsoltFactory.createAnalysis3dSystem(...
                lppufb,'BoundaryOperation','Termination',...
                'NumberOfLevels',nLevels);                        
            testCase.gp = IterativeHardThresholding(...
                'Dictionary',{ synthesizer, analyzer});
            
            % Expected values
            P = sum(nChs);
            M = prod(nDecs);
            nCoefs = numel(srcImg)*(...
                (P-1)/(M-1)-(P-M)/((M-1)*M^nLevels));
            sizeOfCoefsExpctd = [ 1 nCoefs ];
            
            % Actual values
            testCase.gp.NumberOfSparseCoefficients = nCoefsExpctd;
            [resActual, coefsActual, scalesActual] = ...
                testCase.gp.step(srcImg);
            nCoefsActual = nnz(coefsActual);
            
            % Evaluation
            import matlab.unittest.constraints.IsTrue;
            testCase.verifySize(resActual, size(srcImg));
            testCase.verifySize(coefsActual, sizeOfCoefsExpctd);
            testCase.verifyThat(norm(resActual(:)) < norm(srcImg(:)), ...
                IsTrue, ...
                sprintf('||r||^2 = %g must be less than ||x||^2 = %g.',...
                norm(resActual(:)),norm(srcImg(:)))); 
            testCase.verifyThat(nCoefsActual<=nCoefsExpctd,IsTrue);
            
            resExpctd = step(synthesizer,coefsActual,scalesActual);
            testCase.verifyEqual(resActual,resExpctd,...
                'AbsTol',1e-10);
            
            %{
            mse = @(x,y) ((x(:)-y(:)).^2)/numel(x);
            psnr = @(x,y) -10*log10(mse(x,y));
            sprintf('psnr = %6.2f [dB]\n',psnr(resImg,srcImg))
                %}
        end        
        
        function testIhtNsoltDec222Ch64Ord222Level3(testCase)
            
            nDecs = [ 2 2 2 ];
            nChs  = [ 6 4 ];
            nOrds = [ 2 2 2 ];
            nLevels = 3;
            height = 16;
            width  = 32;
            depth  = 64;
            srcImg = rand(height,width,depth);
            
            % Expected values
            nCoefsExpctd = 32;
            
            % Preparation
            import saivdr.dictionary.nsoltx.*
            lppufb = NsoltFactory.createOvsdLpPuFb3dSystem(...              
                'DecimationFactor', nDecs,...
                'NumberOfChannels', nChs ,...
                'PolyPhaseOrder', nOrds,...
                'OutputMode','ParameterMatrixSet');
            angs = get(lppufb,'Angles');
            angs = randn(size(angs));
            set(lppufb,'Angles',angs);
            
            % Instantiation of target class
            import saivdr.sparserep.*            
            synthesizer = NsoltFactory.createSynthesis3dSystem(...
                lppufb,'BoundaryOperation','Termination');            
            analyzer    = NsoltFactory.createAnalysis3dSystem(...
                lppufb,'BoundaryOperation','Termination',...
                'NumberOfLevels',nLevels);                        
            testCase.gp = IterativeHardThresholding(...
                'Dictionary',{ synthesizer, analyzer});
            
            % Expected values
            P = sum(nChs);
            M = prod(nDecs);
            nCoefs = numel(srcImg)*(...
                (P-1)/(M-1)-(P-M)/((M-1)*M^nLevels));
            sizeOfCoefsExpctd = [ 1 nCoefs ];
            
            % Actual values
            testCase.gp.NumberOfSparseCoefficients = nCoefsExpctd;
            [resActual, coefsActual, scalesActual] = ...
                testCase.gp.step(srcImg);
            nCoefsActual = nnz(coefsActual);
            
            % Evaluation
            import matlab.unittest.constraints.IsTrue;
            testCase.verifySize(resActual, size(srcImg));
            testCase.verifySize(coefsActual, sizeOfCoefsExpctd);
            testCase.verifyThat(norm(resActual(:)) < norm(srcImg(:)), ...
                IsTrue, ...
                sprintf('||r||^2 = %g must be less than ||x||^2 = %g.',...
                norm(resActual(:)),norm(srcImg(:)))); 
            testCase.verifyThat(nCoefsActual<=nCoefsExpctd,IsTrue);
            
            resExpctd = step(synthesizer,coefsActual,scalesActual);
            testCase.verifyEqual(resActual,resExpctd,...
                'AbsTol',1e-10);
            
            %{
            mse = @(x,y) ((x(:)-y(:)).^2)/numel(x);
            psnr = @(x,y) -10*log10(mse(x,y));
            sprintf('psnr = %6.2f [dB]\n',psnr(resImg,srcImg))
                %}
        end                
        
        function testIhtNsoltDec112Ch22Ord222Level3(testCase)
            
            nDecs = [ 1 1 2 ];
            nChs  = [ 2 2 ];
            nOrds = [ 2 2 2 ];
            nLevels = 3;
            height = 16;
            width  = 32;
            depth  = 64;
            srcImg = rand(height,width,depth);
            
            % Expected values
            nCoefsExpctd = 32;
            
            % Preparation
            import saivdr.dictionary.nsoltx.*
            lppufb = NsoltFactory.createOvsdLpPuFb3dSystem(...              
                'DecimationFactor', nDecs,...
                'NumberOfChannels', nChs ,...
                'PolyPhaseOrder', nOrds,...
                'OutputMode','ParameterMatrixSet');
            angs = get(lppufb,'Angles');
            angs = randn(size(angs));
            set(lppufb,'Angles',angs);
            
            % Instantiation of target class
            import saivdr.sparserep.*            
            synthesizer = NsoltFactory.createSynthesis3dSystem(...
                lppufb,'BoundaryOperation','Termination');            
            analyzer    = NsoltFactory.createAnalysis3dSystem(...
                lppufb,'BoundaryOperation','Termination',...
                'NumberOfLevels',nLevels);                        
            testCase.gp = IterativeHardThresholding(...
                'Dictionary',{ synthesizer, analyzer});
            
            % Expected values
            P = sum(nChs);
            M = prod(nDecs);
            nCoefs = numel(srcImg)*(...
                (P-1)/(M-1)-(P-M)/((M-1)*M^nLevels));
            sizeOfCoefsExpctd = [ 1 nCoefs ];
            
            % Actual values
            testCase.gp.NumberOfSparseCoefficients = nCoefsExpctd;
            [resActual, coefsActual, scalesActual] = ...
                testCase.gp.step(srcImg);
            nCoefsActual = nnz(coefsActual);
            
            % Evaluation
            import matlab.unittest.constraints.IsTrue;
            testCase.verifySize(resActual, size(srcImg));
            testCase.verifySize(coefsActual, sizeOfCoefsExpctd);
            testCase.verifyThat(norm(resActual(:),2) < norm(srcImg(:),2), ...
                IsTrue, ...
                sprintf('||r|| = %g must be less than ||x|| = %g.',...
                norm(resActual(:),2),norm(srcImg(:),2))); 
            testCase.verifyThat(nCoefsActual<=nCoefsExpctd,IsTrue);
            
            resExpctd = step(synthesizer,coefsActual,scalesActual);
            testCase.verifyEqual(resActual,resExpctd,...
                'AbsTol',1e-10);
            
            %{
            mse = @(x,y) ((x(:)-y(:)).^2)/numel(x);
            psnr = @(x,y) -10*log10(mse(x,y));
            sprintf('psnr = %6.2f [dB]\n',psnr(resImg,srcImg))
                %}
        end 
    end
    
end
