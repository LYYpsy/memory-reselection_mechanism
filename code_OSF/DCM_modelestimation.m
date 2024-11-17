clc;
clear;
tic;
% Initialise SPM--------------------------------------------------------------------------
spm('Defaults','fMRI');
spm_jobman('initcfg');
rootdir = '/media/dell/AAfMRI/Results/DCM_SPM_4run';
cd(rootdir)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DYNAMIC CAUSAL MODELLING  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


for subj = [17 18 20:26 28:38 40:68];  
    clear DCM*
    bar = waitbar(0,num2str(subj))
    subjdir= [rootdir,'/subject/',num2str(subj)]
    cd(subjdir)
    %--------------------------------------------------------------------------
    dcmdir = fullfile(rootdir,'DCM_allsubjsR1234','DCM_rATL',num2str(subj));
    mkdir(dcmdir)
    %--------------------------------------------------------------------------
    
    TR = 2;
    TE = 0.03;
    glmdir = fullfile(subjdir,'GLMmeanR1234');
    load(fullfile(glmdir,'SPM.mat'));
    %--------------------------------------------------------------------------
    % Load regions of interest
    %--------------------------------------------------------------------------
    roidir=fullfile(subjdir,'infile/timecourse');
    cd(roidir)
    DCM.xY(1).u=load('rATL.1d'); 
    DCM.xY(1).name='rATL';
    DCM.xY(2).u=load('smg.1d');
    DCM.xY(2).name='SMG';
    DCM.xY(3).u=load('dlpfc.1d');
    DCM.xY(3).name='DLPFC';
    
    DCM.n = length(DCM.xY);      % number of regions    
    DCM.v = length(DCM.xY(1).u); % number of time points
    %--------------------------------------------------------------------------
    % Time series
    %--------------------------------------------------------------------------
    DCM.Y.dt  = TR;
    %DCM.Y.X0  = DCM.xY(1).X0;   % confounds 
    
    for i = 1:DCM.n
        DCM.Y.y(:,i)  = DCM.xY(i).u;        
        DCM.Y.name{i} = DCM.xY(i).name;      
    end
    
    DCM.Y.Q    = spm_Ce(ones(1,DCM.n)*DCM.v);
    %--------------------------------------------------------------------------
    % Experimental inputs
    %--------------------------------------------------------------
    DCM.U.dt   =  SPM.Sess.U(1).dt;
    DCM.U.name = [SPM.Sess.U.name];
    DCM.U.u    = [SPM.Sess.U(1).u(33:end,1) ...
        SPM.Sess.U(2).u(33:end,1)] ;
    %--------------------------------------------------------------------------
    % DCM parameters and options
    %--------------------------------------------------------------------------
    DCM.delays = repmat(TR/2,DCM.n,1);
    DCM.TE     = TE;
    
    DCM.options.nonlinear  = 0;
    DCM.options.two_state  = 0;
    DCM.options.stochastic = 0;
    %%  DCM.options.centre     = 1; %
    DCM.options.nograph    = 1;
    %--------------------------------------------------------------------------
    % specify and estimate model
    %-------------------------------------------------------------------------
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%% B %%%%%%%%%%%%%%%%%%%%%%%%%%%
    B=zeros(3,3,15);
    B(2,1,1) = 1;
    B(2,3,2) = 1;
    
    B(2,1,3) = 1;
    B(2,3,3) = 1;
    %B2
    B(1,2,4) = 1;
    B(3,2,5) = 1;
    
    B(1,2,6) = 1;
    B(3,2,6) = 1;
    
    %B3
    B(2,1,7) = 1;
    B(1,2,7) = 1;
    
    B(2,1,8) = 1;
    B(3,2,8) = 1;
    
    B(2,3,9) = 1;
    B(1,2,9) = 1;
    
    B(2,3,10) = 1;
    B(3,2,10) = 1;
    
    B(2,1,11) = 1;
    B(2,3,11) = 1;
    B(1,2,11) = 1;
    
    B(2,1,12) = 1;
    B(2,3,12) = 1;
    B(3,2,12) = 1;
    
    B(1,2,13) = 1;
    B(3,2,13) = 1;
    B(2,1,13) = 1;
    
    B(1,2,14) = 1;
    B(3,2,14) = 1;
    B(2,3,14) = 1;
    
    B(2,1,15) = 1;
    B(2,3,15) = 1;
    B(1,2,15) = 1;
    B(3,2,15) = 1;
    
    %%----------------------------------------------------------------------------------------------
    DCM.a = ones(3,3);
    DCM.c = [1 1; 0 0; 0 0]; %%input pre post roi1ATL
    DCM.d = zeros(3,3,0);  %% roi roi 0  
    %%----------------------------------------------------------------------------------------------
    for k=1:1:15
        DCM.b(:,:,1) = B(:,:,k);
        DCM.b(:,:,2) = zeros(3,3);
        if k<10
            str = sprintf(strcat('DCM_model_0',num2str(k)));
        else
            str = sprintf(strcat('DCM_model_',num2str(k)));
        end
        disp ------------------------------------------------------------------------------------------
        disp (subj)
        disp (str)
        disp ------------------------------------------------------------------------------------------
        DCM.name = str;
        save(fullfile(dcmdir,str),'DCM');
        eval(['DCM_',num2str(k),' = spm_dcm_estimate(fullfile(dcmdir,str));'])
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %--------------------------------------------------------------------------
    %%
    close(bar)
end

hours=toc/3600