# generate subfilePath and mask the data with the CWAS mask

smooth=8
preprocessDate=2_22_14
subList="/home/data/Projects/Colibazzi/data/subClean_step2.txt" 
baseDir="/home/data/Projects/Colibazzi/results/CPAC_zy${preprocessDate}_reorganized/noGSR"

## 1. resample and smooth the functional data 
mkdir ${baseDir}/FunImg_3mm_fwhm${smooth}
outputDir="${baseDir}/FunImg_3mm_fwhm${smooth}"
echo $outputDir
sublistFile="/home/data/Projects/Colibazzi/data/subFunImgFilePath_99sub.txt"
rm -rf $sublistFile
for sub in `cat $subList`; do

3dresample -dxyz 3.0 3.0 3.0 -prefix ${outputDir}/normFunImg_${sub}_3mm.nii -inset ${baseDir}/FunImg/normFunImg_${sub}.nii.gz
3dmerge -1blur_fwhm 8.0 -doall -prefix ${outputDir}/normFunImg_${sub}_3mm_fwhm${smooth}.nii ${outputDir}/normFunImg_${sub}_3mm.nii 
3dcalc -a ${outputDir}/normFunImg_${sub}_3mm_fwhm${smooth}.nii -b /home2/data/Projects/workingMemory/mask/MNI152_T1_GREY_3mm_25pc_mask.nii.gz -expr 'a*b' -prefix ${outputDir}/normFunImg_${sub}_3mm_fwhm${smooth}_masked.nii
rm -rf ${outputDir}/normFunImg_${sub}_3mm.nii ${outputDir}/normFunImg_${sub}_3mm_fwhm${smooth}.nii
done

## 2. create the subject data path file
for sub in `cat $subList`; do
echo "${outputDir}/normFunImg_${sub}_3mm_fwhm${smooth}_masked.nii" >> $sublistFile
done

maskDir="/home/data/Projects/Colibazzi/masks/CWAS"
## 3. create the group mask
for sub in `cat $subList`; do

cmd="fslmaths ${outputDir}/normFunImg_${sub}_3mm_fwhm${smooth}_masked.nii -Tstd -bin ${maskDir}/stdMask_${sub}"
echo $cmd
eval $cmd

done

maskDir="/home/data/Projects/Colibazzi/masks"
cmd1="3dMean -prefix ${maskDir}/stdMask_98sub_compCor.nii.gz ${maskDir}/CWAS/stdMask_*.nii.gz"
echo $cmd1
eval $cmd1

3dcalc -a ${maskDir}/stdMask_98sub_compCor.nii.gz -expr 'step(a-0.99999)' -prefix ${maskDir}/stdMask_98sub_compCor_100prct.nii.gz

#3dcalc -a ${maskDir}/stdMask_99sub_compCor.nii.gz -expr 'equals(a,1)' -prefix ${maskDir}/stdMask_99sub_compCor_100prct.nii.gz
#rm -rf ${maskDir}/stdMask_????.nii.gz
#3dcalc -a /home/data/Projects/workingMemory/mask/CPACpreprocessing/CWAS_${covType}/stdMask_68sub.nii -expr 'step(a-0.899)' -prefix /home/data/Projects/workingMemory/mask/CPACpreprocessing/CWAS_${covType}/stdMask_68sub_90percent.nii

