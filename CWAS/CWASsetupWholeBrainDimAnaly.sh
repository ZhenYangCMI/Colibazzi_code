# generate subfilePath and mask the data with the CWAS mask

smooth=8
preprocessDate=2_22_14
numSub=39
subList="/home/data/Projects/Colibazzi/data/patients_${numSub}sub.txt" 
baseDir="/home/data/Projects/Colibazzi/results/CPAC_zy${preprocessDate}_reorganized/compCor"
sublistFile="/home/data/Projects/Colibazzi/data/subFunImgFilePath_${numSub}patients.txt"
outputDir="${baseDir}/FunImg_3mm_fwhm${smooth}"
rm -rf $sublistFile
## 1. create the subject data path file
for sub in `cat $subList`; do
echo "${outputDir}/normFunImg_${sub}_3mm_fwhm${smooth}_masked.nii" >> $sublistFile
done

maskDir="/home/data/Projects/Colibazzi/masks"
subIncludedList=${maskDir}/tmp_${numSub}patients.txt
rm -rf $subIncludedList
## 2. create the group mask
for sub in `cat $subList`; do
echo "${maskDir}/CWAS/stdMask_${sub}.nii.gz" >> $subIncludedList
done
a=$(cat $subIncludedList)

cmd1="3dMean -prefix ${maskDir}/stdMask_${numSub}patients_compCor.nii.gz $a"
echo $cmd1
eval $cmd1

3dcalc -a ${maskDir}/stdMask_${numSub}patients_compCor.nii.gz -expr 'step(a-0.99999)' -prefix ${maskDir}/stdMask_${numSub}patients_compCor_100prct.nii.gz

#3dcalc -a ${maskDir}/stdMask_99sub_compCor.nii.gz -expr 'equals(a,1)' -prefix ${maskDir}/stdMask_99sub_compCor_100prct.nii.gz
#rm -rf ${maskDir}/stdMask_????.nii.gz
#3dcalc -a /home/data/Projects/workingMemory/mask/CPACpreprocessing/CWAS_${covType}/stdMask_68sub.nii -expr 'step(a-0.899)' -prefix /home/data/Projects/workingMemory/mask/CPACpreprocessing/CWAS_${covType}/stdMask_68sub_90percent.nii

