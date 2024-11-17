clear
clc

load('BMS.mat')
[MAX,m]=(max(BMS.DCM.rfx.model.xp)) %%Model exceedance probability
load('model_space.mat')

for n=1:1:49  %%model        %%R12  B input modulate
 model15.B(n,1)=subj(n).sess.model(m).Ep.B(1,2,1)  %%2-1  smg-ATL
 model15.B(n,2)=subj(n).sess.model(m).Ep.B(3,2,1)  %%2-3  smg-dlpfc
 model15.B(n,3)=subj(n).sess.model(m).Ep.B(2,1,1) %%1-3 ATL-smg 
 model15.B(n,4)=subj(n).sess.model(m).Ep.B(2,3,1) %%1-3 dlpfc-smg 

end  

name={'smgatl','smgdlpfc','atlsmg','dlpfcsmg'}
for e = 1:4 %:4
    x = model15.B(:,e);  
    m=mean(x)
  [h,p,~,stat] = ttest(x,0);
  pvalue(e,:)={name(e),m,h,p,stat}
end

save('pvalue.mat','model15','pvalue','MAX','m')


