
# create DC mask
preprocessDate=2_22_14
subList="/home/data/Projects/Colibazzi/data/patients_50sub.txt" 

# create DC mask
cmd4="3dMean -prefix /home/data/Projects/Colibazzi/masks/meanStandFunMask_98sub.nii.gz /home/data/Projects/Colibazzi/results/CPAC_zy${preprocessDate}_reorganized/noGSR/FunImg/standFunMask_*.nii.gz"
echo $cmd4
eval $cmd4

3dcalc -a /home/data/Projects/Colibazzi/masks/meanStandFunMask_98sub.nii.gz -expr 'step(a-0.899)' -prefix /home/data/Projects/Colibazzi/masks/meanStandFunMask_98sub_90prct.nii.gz


subList=/home/data/Projects/Zhen/Colibazzi/data/subClean_step2_98sub.txt
sublistFile="/home/data/Projects/Zhen/Colibazzi/data/VMHC_data_path.txt"
rm -rf $sublistFile
for i in `cat $subList`; do
echo "/home/data/Projects/Zhen/Colibazzi/results/CPAC_zy2_22_14_reorganized/noGSR/VMHC/SnormVMHC_${i}.nii" >> $sublistFile
done
a=$(cat $sublistFile)
#cmd1="3dTcat $a -prefix /home/data/Projects/Zhen/Colibazzi/results/CPAC_zy2_22_14_reorganized/noGSR/VMHC/VMHC_98sub.nii"
cmd1="3dTstat -mean -prefix /home/data/Projects/Zhen/Colibazzi/results/CPAC_zy2_22_14_reorganized/noGSR/VMHC/VMHC_mean_98sub.nii /home/data/Projects/Zhen/Colibazzi/results/CPAC_zy2_22_14_reorganized/noGSR/VMHC/VMHC_98sub.nii"
cmd1="3dTstat -stdev -prefix /home/data/Projects/Zhen/Colibazzi/results/CPAC_zy2_22_14_reorganized/noGSR/VMHC/VMHC_std_98sub.nii /home/data/Projects/Zhen/Colibazzi/results/CPAC_zy2_22_14_reorganized/noGSR/VMHC/VMHC_98sub.nii"
echo $cmd1
eval $cmd1

#echo $cmd2
#eval $cmd2
#rm -rf $sublistFile

fslmaths /home/data/Projects/Zhen/Colibazzi/results/CPAC_zy2_22_14_reorganized/noGSR/VMHC/VMHC_98sub.nii -bin /home/data/Projects/Zhen/Colibazzi/masks/VMHC_98sub_bin.nii
fslmaths /home/data/Projects/Zhen/Colibazzi/masks/VMHC_98sub_bin.nii -Tmean /home/data/Projects/Zhen/Colibazzi/masks/VMHC_98sub_mask.nii

3dcalc -a /home/data/Projects/Zhen/Colibazzi/masks/VMHC_98sub_mask.nii.gz -expr 'step(a-0.899)' -prefix /home/data/Projects/Zhen/Colibazzi/masks/VMHC_98sub_mask_90prct.nii

3dresample -master /usr/share/data/fsl-mni152-templates/MNI152_T1_3mm_brain.nii.gz -prefix /home/data/Projects/Zhen/Colibazzi/masks/SCAMaskFinal/Thalamus-maxprob-thr50-3mm.nii.gz -inset /home/data/Projects/Zhen/Colibazzi/masks/SCAMaskFinal/Thalamus-maxprob-thr50-2mm.nii.gz

3dcalc \
-a /home/data/Projects/Zhen/Colibazzi/results/CPAC_zy2_22_14_reorganized/groupAnalysis98sub/Group_text_ROI1/easythresh/thresh_Group_text_ROI1_T1_Z_cmb.nii \
-b /home/data/Projects/Zhen/Colibazzi/results/CPAC_zy2_22_14_reorganized/groupAnalysis98sub/Group_text_ROI2/easythresh/thresh_Group_text_ROI2_T1_Z_cmb.nii \
-c /home/data/Projects/Zhen/Colibazzi/results/CPAC_zy2_22_14_reorganized/groupAnalysis98sub/Group_text_ROI3/easythresh/thresh_Group_text_ROI3_T1_Z_cmb.nii \
-d /home/data/Projects/Zhen/Colibazzi/results/CPAC_zy2_22_14_reorganized/groupAnalysis98sub/Group_text_ROI4/easythresh/thresh_Group_text_ROI4_T1_Z_cmb.nii \
-e /home/data/Projects/Zhen/Colibazzi/results/CPAC_zy2_22_14_reorganized/groupAnalysis98sub/Group_text_ROI5/easythresh/thresh_Group_text_ROI5_T1_Z_cmb.nii \
-f /home/data/Projects/Zhen/Colibazzi/results/CPAC_zy2_22_14_reorganized/groupAnalysis98sub/Group_text_ROI6/easythresh/thresh_Group_text_ROI6_T1_Z_cmb.nii \
-g /home/data/Projects/Zhen/Colibazzi/results/CPAC_zy2_22_14_reorganized/groupAnalysis98sub/DegreeCentrality/easythresh/thresh_DegreeCentrality_T1_Z_cmb_3mm.nii \
-expr 'astep(a,0) * astep(b,0) * astep(c,0) * astep(d,0) * astep(e,0) * astep(f,0) * astep(g,0)' \
-prefix /home/data/Projects/Zhen/Colibazzi/masks/MDMR_DC_commonThalamus.nii

3dcalc -a /home/data/Projects/Zhen/Colibazzi/masks/MDMR_DC_commonThalamus.nii -b /home/data/Projects/Zhen/Colibazzi/masks/SCAMaskFinal/Thalamus-maxprob-thr50-3mm.nii.gz -expr 'a*b' -prefix /home/data/Projects/Zhen/Colibazzi/masks/MDMR_DC_commonThalamus_overlapWithThalamusROIs.nii

3dcalc -a /home/data/Projects/Zhen/Colibazzi/masks/SCAMaskFinal/Thalamus-maxprob-thr50-3mm.nii.gz -b /home/data/Projects/Zhen/Colibazzi/masks/MDMR_DC_commonThalamus_overlapWithThalamusROIs.nii -expr 'equals(a,1)*3+equals(a,2)*6+equals(a,6)*9 + astep(b,0)' -prefix /home/data/Projects/Zhen/Colibazzi/masks/MDMR_DC_commonThalamus_overlapWithThalamusROI126.nii

3dcalc -a /home/data/Projects/Zhen/Colibazzi/masks/MDMR_DC_commonThalamus_overlapWithThalamusROIs.nii -expr 'astep(a,0)' -prefix /home/data/Projects/Zhen/Colibazzi/masks/SCAMaskFinal/MDMRiFC_DC_THAL_overlapmask.nii


# mask half of the VMHC results
3dcalc -a VMHC_T1_Z.nii -b /usr/share/data/fsl-mni152-templates/MNI152_T1_2mm_left_hemisphere_mask.nii.gz -expr 'a*b' -prefix VMHC_T1_Z_L.nii

3dcalc -a /home/data/Projects/Zhen/Colibazzi/masks/VMHC_98sub_mask_90prct.nii -b /usr/share/data/fsl-mni152-templates/MNI152_T1_2mm_left_hemisphere_mask.nii.gz -expr 'a*b' -prefix /home/data/Projects/Zhen/Colibazzi/masks/VMHC_98sub_mask_90prct_L.nii 

3dcalc -a cluster_mask_Group_text_Yeo_net5rmd.nii -b MNI152_T1_3mm_left_hemisphere_mask.nii.gz -expr 'a*b' -prefix tmp.nii

