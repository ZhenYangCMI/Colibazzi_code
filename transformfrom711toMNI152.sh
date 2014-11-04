

standard_template_2mm=/home/data/Projects/Zhen/commonCode/MNI152_T1_2mm_brain.nii.gz
standard_template_2mm_withSkull=/home/data/Projects/Zhen/commonCode/MNI152_T1_2mm.nii.gz
inputImg=/home/data/Projects/Zhen/Colibazzi/masks/archive/AnticevicMask/711.nii.gz
inputBrain=/home/data/Projects/Zhen/Colibazzi/masks/archive/AnticevicMask/711_brain.nii.gz

# Registration anat to standard

#antsIntroduction.sh -d 3 -i highres_rpi.nii.gz  -o ants_ -r ${standard_template_1mm} -t GR  # old version of ANTs
antsRegistration --collapse-linear-transforms-to-fixed-image-header 0 --collapse-output-transforms 0 --dimensionality 3 --interpolation Linear --output [ transform, transform_Warped.nii.gz ] --transform Rigid[ 0.1 ] --metric MI[ ${standard_template_2mm_withSkull}, ${inputImg}, 1, 32, Regular, 0.25 ] --convergence [ 1000x500x250x100, 1e-08, 10 ] --smoothing-sigmas 3.0x2.0x1.0x0.0 --shrink-factors 8x4x2x1 --use-histogram-matching 1 --transform Affine[ 0.1 ] --metric MI[ ${standard_template_2mm_withSkull}, ${inputImg}, 1, 32, Regular, 0.25 ] --convergence [ 1000x500x250x100, 1e-08, 10 ] --smoothing-sigmas 3.0x2.0x1.0x0.0 --shrink-factors 8x4x2x1 --use-histogram-matching 1 --transform SyN[ 0.1, 3.0, 0.0 ] --metric CC[ ${standard_template_2mm_withSkull}, ${inputImg}, 1, 4 ] --convergence [ 100x100x70x20, 1e-09, 15 ] --smoothing-sigmas 3.0x2.0x1.0x0.0 --shrink-factors 6x4x2x1 --use-histogram-matching 1 --winsorize-image-intensities [ 0.01, 0.99 ] 


inputImg1=/home/data/Projects/Zhen/Colibazzi/masks/archive/AnticevicMask/Thalamus.seed.connectivity.map.Anticevic.CerebralCortex.Over-connectivity.hdr
inputImg2=/home/data/Projects/Zhen/Colibazzi/masks/archive/AnticevicMask/Thalamus.seed.connectivity.map.Anticevic.CerebralCortex.Under-connectivity.hdr
cd ${ICA_dir}/melodic_autoDim
#WarpTimeSeriesImageMultiTransform 4 melodic_IC.nii.gz melodic_IC_mni152_3mm_ANTs.nii.gz -R ${standard_template_3mm} ${anat_reg_dir}/ants_Warp.nii.gz ${anat_reg_dir}/ants_Affine.txt ${func_reg_dir}/example_func2highersBBR_affine.txt      # old version of ANTs
antsApplyTransforms --default-value 0 --dimensionality 3 --input ${inputImg1} --input-image-type 3 --interpolation Linear --output Over-connectivity.nii.gz --reference-image ${standard_template_2mm} --transform transform2Warp.nii.gz --transform transform1Affine.mat --transform transform0Rigid.mat 
antsApplyTransforms --default-value 0 --dimensionality 3 --input ${inputImg2} --input-image-type 3 --interpolation Linear --output Under-connectivity.nii.gz --reference-image ${standard_template_2mm} --transform transform2Warp.nii.gz --transform transform1Affine.mat --transform transform0Rigid.mat 

