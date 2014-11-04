# generate subfilePath and mask the data with the CWAS mask

preprocessDate=2_22_14
project='Colibazzi'
subList="/home/data/Projects/Zhen/${project}/data/subClean_step2_98sub.txt" 
numSub='98'
dataDir="/home/data/Projects/Zhen/${project}/results/CPAC_zy${preprocessDate}_reorganized/noGSR/FunImg"
maskDir="/home/data/Projects/Zhen/${project}/masks/CWAS"
smooth=8

## 1. spatial normalize the functional data
standard_template=/home2/data/Projects/Zhen/workingMemory/mask/MNI152_T1_3mm_brain.nii.gz
anatDir=/home/data/Projects/Zhen/${project}/results/CPAC_zy${preprocessDate}_reorganized/noGSR/T1Img

	
for sub in `cat $subList`; do

	echo --------------------------
	echo running subject ${sub}
	echo --------------------------

	# Applywarp
	cd ${dataDir}

	WarpTimeSeriesImageMultiTransform 4 FunImg_${sub}.nii.gz normFunImg_${sub}_3mm.nii.gz -R ${standard_template} ${anatDir}/anat2MNIWarp_${sub}.nii.gz ${anatDir}/anat2MNIAffine_${sub}.txt ${anatDir}/fun2anatAffine_${sub}.txt
	3dmerge -1blur_fwhm 6.0 -doall -prefix ${dataDir}/normFunImg_${sub}_3mm_fwhm${smooth}.nii.gz ${dataDir}/normFunImg_${sub}_3mm.nii.gz 
	3dcalc -a ${dataDir}/normFunImg_${sub}_3mm_fwhm${smooth}.nii.gz -b /home2/data/Projects/Zhen/workingMemory/mask/MNI152_T1_GREY_3mm_25pc_mask.nii.gz -expr 'a*b' -prefix ${dataDir}/normFunImg_${sub}_3mm_fwhm${smooth}_masked.nii.gz
	3dcalc -a ${dataDir}/normFunImg_${sub}_3mm.nii.gz -b /home2/data/Projects/Zhen/workingMemory/mask/MNI152_T1_GREY_3mm_25pc_mask.nii.gz -expr 'a*b' -prefix ${dataDir}/normFunImg_${sub}_3mm_masked.nii.gz
done
	

## 2. create the group mask
for sub in `cat $subList`; do

cmd1="fslmaths ${dataDir}/normFunImg_${sub}_3mm_masked.nii.gz -Tstd -bin ${maskDir}/stdMask_${sub}_3mm"
echo $cmd1
eval $cmd1
done

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

## 3. create filepath for all subject
sublistFile="/home/data/Projects/Zhen/${project}/data/subCWASFunImgFilePath_${numSub}sub.txt"
rm -rf $sublistFile
for sub in `cat $subList`; do
echo "${dataDir}/normFunImg_${sub}_3mm_fwhm${smooth}_masked.nii.gz" >> $sublistFile 
done
