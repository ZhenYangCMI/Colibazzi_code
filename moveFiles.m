

clear
clc

% move the easythreshed image to one folder and plot surfaceMap
measureList={'ReHo','fALFF', 'VMHC', 'DegreeCentrality', 'DualRegression0', 'DualRegression1', 'DualRegression2', 'DualRegression3', 'DualRegression4', 'DualRegression5', 'DualRegression6', 'DualRegression7', 'DualRegression8', 'DualRegression9', 'SCA1', 'SCA2', 'SCA3', 'SCA4'...
'SCA5', 'SCA6', 'SCA7', 'SCA8', 'SCA9', 'SCA10', 'SCA11', 'SCA12' };
%measureList={, 'DegreeCentrality',}
numMeasure=length(measureList)

funDestination=['/home/data/Projects/Colibazzi/figs/'];
for i=1:numMeasure
     measure=char(measureList{i})
sourceFun=['/home/data/Projects/Colibazzi/results/CPAC_zy2_22_14_reorganized/groupAnalysis/', measure, '/easythresh/thresh_', measure, '_T1_Z_cmb.nii'];
copyfile(sourceFun, funDestination)
end

% move the mean functional image files to one folder then run 3dTcat -prefix normFunImg_99sub.nii.gz normFunImg_*.nii.gz to combine them for visual inspection
subList=load('/home/data/Projects/Colibazzi/data/subClean_step2.txt');
mkdir(['/home/data/Projects/Colibazzi/data/columbia/normFunImg'])
funDestination=['/home/data/Projects/Colibazzi/data/columbia/normFunImg'];
for i=1:length(subList)
    sub=num2str(subList(i))
sourceFun=['/home/data/Projects/Colibazzi/results/output/pipeline_zy2_22_14/', sub, '/mean_functional_in_mni/_scan_FunImg_rawFun/rawFun_calc_tshift_resample_volreg_calc_tstat_wimt.nii.gz'];
copyfile(sourceFun, [funDestination, '/normFunImg_', sub, '.nii.gz'])
end

% move data for added healthy controls
subList=load('/home/data/Projects/Colibazzi/data/subjectlist_addedLater.txt');

for i=1:length(subList)
    sub=num2str(subList(i))
mkdir(['/home/data/Projects/Colibazzi/data/columbia/', sub, '/FunImg'])
mkdir(['/home/data/Projects/Colibazzi/data/columbia/', sub, '/T1Img'])
T1destination=['/home/data/Projects/Colibazzi/data/columbia/', sub, '/T1Img/'];
funDestination=['/home/data/Projects/Colibazzi/data/columbia/', sub, '/FunImg/'];

sourceFun=['/home/data/Projects/Colibazzi/FunImg/', sub];
cd(sourceFun)
fun=dir(['*.nii.gz'])
funImg=fun.name
copyfile(funImg, [funDestination, '/rawFun.nii.gz'])
sourceT1=['/home/data/Originals/Colibazzi/T1Img/', sub];
cd(sourceT1)
T1=dir(['*.nii.gz'])
T1Img=T1.name

copyfile(T1Img, [T1destination, '/T1Img.nii.gz'])

end
