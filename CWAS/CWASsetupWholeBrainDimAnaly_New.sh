# generate subfilePath and mask the data with the CWAS mask

preprocessDate=2_22_14
project='Colibazzi'
numSub='40'
subList="/home/data/Projects/Zhen/${project}/data/patients_${numSub}sub.txt" 
dataDir="/home/data/Projects/Zhen/${project}/results/CPAC_zy${preprocessDate}_reorganized/noGSR/FunImg"
maskDir="/home/data/Projects/Zhen/${project}/masks/CWAS"
smooth=8

## 1. create the group mask and threshold at 100%
subIncludedList="subIncludedList.txt"
for sub in `cat $subList`; do
echo "${maskDir}/stdMask_${sub}_3mm.nii.gz" >> $subIncludedList
done

a=$(cat $subIncludedList)

cmd1="3dMean -prefix ${maskDir}/stdMask_${numSub}sub_3mm_noGSR.nii.gz $a"
echo $cmd1
eval $cmd1

3dcalc -a ${maskDir}/stdMask_${numSub}sub_3mm_noGSR.nii.gz -expr 'step(a-0.99999)' -prefix ${maskDir}/stdMask_${numSub}sub_3mm_noGSR_100prct.nii.gz

rm -rf $subIncludedList

## 2. create filepath for all subject
sublistFile="/home/data/Projects/Zhen/${project}/data/CWASFunImgFilePath_${numSub}sub.txt"
rm -rf $sublistFile
for sub in `cat $subList`; do
echo "${dataDir}/normFunImg_${sub}_3mm_fwhm${smooth}_masked.nii.gz" >> $sublistFile 
done
