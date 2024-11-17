clear
clc
root_dir = '/media/dell/AAfMRI/Results/DCM_SPM_4run';

name=['DCM_lFFA41']        

output_dir = fullfile(root_dir,'DCM_GroupmaskR1234',name);   
mkdir(output_dir);

input_dir = fullfile(root_dir,'DCM_allsubjsR1234',name);
cd (input_dir);
n=0;                  
for subj=[17 18 20:26 28:38 40:68];    
    n=n+1;
    dcmlist = spm_select('FPList',fullfile(input_dir,num2str(subj)), '^DCM*'); 
    matlabbatch{1}.spm.dcm.bms.inference.sess_dcm{n}.dcmmat = cellstr(dcmlist);
end

matlabbatch{1}.spm.dcm.bms.inference.dir = {output_dir};
matlabbatch{1}.spm.dcm.bms.inference.model_sp = {''};
matlabbatch{1}.spm.dcm.bms.inference.load_f = {''};
matlabbatch{1}.spm.dcm.bms.inference.method = 'RFX';                      
matlabbatch{1}.spm.dcm.bms.inference.family_level.family_file = {''}; 
matlabbatch{1}.spm.dcm.bms.inference.bma.bma_yes.bma_famwin = 'famwin';       
matlabbatch{1}.spm.dcm.bms.inference.bma.bma_no = 0;
matlabbatch{1}.spm.dcm.bms.inference.verify_id = 1; 

spm_jobman('run',matlabbatch);
cd(root_dir)
copyfile('r12ttest.m',output_dir) 
cd(output_dir)