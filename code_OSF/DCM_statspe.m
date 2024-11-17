clc;
clear;
%--------------------------------------------------------------------------
% Initialise SPM
%--------------------------------------------------------------------------
spm('Defaults','fMRI');
spm_jobman('initcfg');
%spm_get_defaults('cmdline',1);


rootdir = '/media/dell/AAfMRI/Results/DCM_SPM_4run/subject';
cd(rootdir)
%%para

for subj = [17]; 
  %%  
    clear SPM     %%del workspace
    clear matlabbatch
    bar = waitbar(0,num2str(subj))  
    subjdir= [rootdir,'/',num2str(subj)]
    cd(subjdir)   
%------------------------------------------------------------------------------------------------------  %------------------------------------------------------------------------------------------------------  %          
    
    infile= [subjdir,'/','infile']
    TR = 2;
    TE = 0.03;    
  
     cd (infile)
      a=niftiinfo('fourRun.nii')
      b=a.ImageSize(4)  %%取出TR数
      frames = 1:b;   %%总TR数
      f = spm_select('ExtFPList',infile,'fourRun.nii',frames); 
    
%TR for everyRun             
    a=niftiinfo('r1.nii')
    frame1=a.ImageSize(4) ; 
    a=niftiinfo('r2.nii')
    frame2=a.ImageSize(4) ;
    a=niftiinfo('r3.nii')
    frame3=a.ImageSize(4) ;
    a=niftiinfo('r4.nii')
    frame4=a.ImageSize(4);
    
  motion_file = load('motCensor.txt');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % GLM0326_meanR3412 SPECIFICATION, ESTIMATION & INFERENCE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    onsetdir = fullfile(infile,'onset');        
    cd(onsetdir)
    load('PRE.1D')
    load('R34.1D')
        
    % MODEL SPECIFICATION
    %--------------------------------------------------------------------------
     GLM = fullfile(subjdir,'GLMmeanR1234');
     mkdir(GLM) 
    %--------------------------------------------------------------------------
    matlabbatch{1}.spm.stats.fmri_spec.dir = {GLM};
    matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT    = TR;
    matlabbatch{1}.spm.stats.fmri_spec.sess.scans            = cellstr(f);
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).name     = 'PRE';
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).onset    = [PRE];
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).duration = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).name     = 'POST';
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).onset    = [POST];
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).duration = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = {motion_file};
 spm_jobman('run',matlabbatch);
 clear matlabbatch
    
   %%contantate all sessions  By-session adjustment before estimation
   %%--------------------------------------------------------------------------
    cd (GLM)
    scans = [frame1 frame2 frame3 frame4]
    spm_fmri_concatenate('SPM.mat',scans);
    %--------------------------------------------------------------------------
 
   matlabbatch{1}.spm.stats.fmri_est.spmmat = cellstr(fullfile(GLM,'SPM.mat')); 
   spm_jobman('run',matlabbatch);

%-----------------------------------------------------------------------------------------------------  %------------------------------------------------------------------------------------------------------  %  
%------------------------------------------------------------------------------------------------------ %------------------------------------------------------------------------------------------------------   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % VOLUMES OF INTEREST
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
%--------------------------------------------------------------------------
% EXTRACTING TIME SERIES: use AFNI 3dMaskave

    close(bar)
end

% produce SPM.mat        DCM