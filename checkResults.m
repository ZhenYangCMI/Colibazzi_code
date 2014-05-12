clear
clc

subList=load('/home/data/Projects/Colibazzi/data/subClean_step2.txt');
t=0;
q=0;
for i=1:length(subList)
    sub=subList(i);
    file=['/home/data/Projects/Colibazzi/data/columbia/', num2str(sub), '/FunImg/ICA/melodic_autoDim/melodic_IC.nii.gz'];
    
    
    if exist(file, 'file')
        t=t+1;
    else
        disp(sub)
        q=q+1;
    end
end
