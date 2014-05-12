#subject=$1

## full/path/to/site
analysisdirectory=/home/data/Projects/Colibazzi/data/columbia

## full/path/to/site/subject_list
subject_list=/home/data/Projects/Colibazzi/data/subClean_step2_67To99.txt

## name of resting-state scan (no extension)
rest=rest

## name of rest directory
func_dir_name=FunImg

## name of anat directory
anat_dir_name=T1Img

standard_template=/home2/data/Projects/workingMemory/mask/MNI152_T1_2mm_brain.nii.gz
standard_template_3mm=/home2/data/Projects/workingMemory/mask/MNI152_T1_3mm_brain.nii.gz
##############################################################
## compute the transformation matrix and norm the ICA componets
##############################################################
#subject=9006154
for subject in `cat $subject_list`; do

#for realization in `seq 2 30`
#do
## directory setup
dir=${analysisdirectory}
func_dir=${dir}/${subject}/${func_dir_name}
func_reg_dir=${func_dir}/reg
anat_dir=${dir}/${subject}/${anat_dir_name}
anat_reg_dir=${anat_dir}/reg
ICA_dir=${func_dir}/ICA

echo --------------------------
echo running subject ${subject}
echo --------------------------

# Registration anat to standard
cd ${anat_reg_dir}
antsIntroduction.sh -d 3 -i highres.nii.gz  -o ants_ -r /home/data/Projects/workingMemory/data/gRAICAR_analysis/MNI152_T1_1mm_brain.nii.gz -t GR

% convert transformation matrix of funct to anat from .mat to ants format
cd ${func_dir}
fslroi ${rest}_mc.nii.gz example_func.nii.gz 7 1
	fslmaths example_func.nii.gz -mas ${rest}_mask.nii.gz tmpbrain.nii.gz

# register func to T1 using BBR: poor contrast on 14 subjects, BBR can not be used on them
#flirt -in tmpbrain.nii.gz -ref ${anat_reg_dir}/highres.nii.gz -out ${func_reg_dir}/example_func2highresBBR.nii.gz -omat ${func_reg_dir}/example_func2highresBBR.mat  -cost bbr -wmseg ${anat_reg_dir}/segment_seg_2.nii.gz -dof 6 -init ${func_reg_dir}/example_func2highres.mat -schedule /usr/share/fsl/5.0/etc/flirtsch/bbr.sch 

# Convert fsl affine to ants affine
c3d_affine_tool -ref ${anat_reg_dir}/highres.nii.gz -src tmpbrain.nii.gz ${func_reg_dir}/example_func2highres.mat -fsl2ras -oitk ${func_reg_dir}/example_func2highers_affine.txt

# Applywarp
cd ${ICA_dir}/melodic_autoDim
WarpTimeSeriesImageMultiTransform 4 melodic_IC.nii.gz melodic_IC_mni152_2mm_ANTs.nii.gz -R ${standard_template} ${anat_reg_dir}/ants_Warp.nii.gz ${anat_reg_dir}/ants_Affine.txt ${func_reg_dir}/example_func2highers_affine.txt

cd ${ICA_dir}
3dTstat -mean -prefix ${analysisdirectory}/${subject}/FunImg/ICA/rest_gms_mean.nii.gz ${analysisdirectory}/${subject}/FunImg/ICA/rest_gms.nii.gz

WarpTimeSeriesImageMultiTransform 4 rest_gms_mean.nii.gz rest_gms_mean_mni152_ANTs.nii.gz -R ${standard_template} ${anat_reg_dir}/ants_Warp.nii.gz ${anat_reg_dir}/ants_Affine.txt ${func_reg_dir}/example_func2highers_affine.txt

done


