
# create DC mask
preprocessDate=2_22_14
subList="/home/data/Projects/Colibazzi/data/patients_50sub.txt" 

# create DC mask
cmd4="3dMean -prefix /home/data/Projects/Colibazzi/masks/meanStandFunMask_98sub.nii.gz /home/data/Projects/Colibazzi/results/CPAC_zy${preprocessDate}_reorganized/noGSR/FunImg/standFunMask_*.nii.gz"
echo $cmd4
eval $cmd4

3dcalc -a /home/data/Projects/Colibazzi/masks/meanStandFunMask_98sub.nii.gz -expr 'step(a-0.899)' -prefix /home/data/Projects/Colibazzi/masks/meanStandFunMask_98sub_90prct.nii.gz












