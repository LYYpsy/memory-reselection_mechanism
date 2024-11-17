clear


%% load the data 
clear
dirPath='*_key.txt'
fileList=dir(dirPath)
dataAll=[]       
for subj=1:length(fileList)
    str=fileList(subj).name
   data= readtable(str) ;
   dataAll=[dataAll;data]
end
writetable(dataAll,'CD_key.csv');


