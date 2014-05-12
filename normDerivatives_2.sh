

preprocessDate='2_22_14'
project='Colibazzi'
covType=noGSR

# full/path/to/site/subject_list
subject_list="/home/data/Projects/${project}/data/subClean_step2.txt"

### 1. spatial normalize the derivatives
standard_template=/home2/data/Projects/workingMemory/mask/MNI152_T1_2mm_brain.nii.gz
anatDir=/home/data/Projects/${project}/results/CPAC_zy${preprocessDate}_reorganized/${covType}/T1Img

	#for measure in ReHo fALFF DualRegression skewness; do
for measure in ReHo fALFF DualRegression; do
	dataDir=/home/data/Projects/${project}/results/CPAC_zy${preprocessDate}_reorganized/${covType}/${measure}

	for sub in `cat $subject_list`; do

		echo --------------------------
		echo running subject ${sub}
		echo --------------------------

		# Applywarp
		cd ${dataDir}

		if [[ ${measure} = "skewness" ]]; then
		WarpTimeSeriesImageMultiTransform 4 ${measure}_${sub}.nii ${measure}_${sub}_MNI.nii -R ${standard_template} ${anatDir}/anat2MNIWarp_${sub}.nii.gz ${anatDir}/anat2MNIAffine_${sub}.txt ${anatDir}/fun2anatAffine_${sub}.txt
		else
		WarpTimeSeriesImageMultiTransform 4 ${measure}_${sub}.nii.gz ${measure}_${sub}_MNI.nii.gz -R ${standard_template} ${anatDir}/anat2MNIWarp_${sub}.nii.gz ${anatDir}/anat2MNIAffine_${sub}.txt ${anatDir}/fun2anatAffine_${sub}.txt
		fi

	done
done


### 2. smooth the normalized derivatives

#for measure in ReHo fALFF DualRegression DegreeCentrality skewness; do
for measure in ReHo fALFF DualRegression; do
dataDir=/home/data/Projects/${project}/results/CPAC_zy${preprocessDate}_reorganized/${covType}/${measure}

	for sub in `cat $subject_list`; do

		echo --------------------------
		echo running subject ${sub}
		echo --------------------------

		cd ${dataDir}
		if [[ ${measure} = "skewness" ]]; then
		3dmerge -1blur_fwhm 8.0 -doall -prefix ${measure}_${sub}_MNI_fwhm8.nii ${measure}_${sub}_MNI.nii
		elif [[ ${measure} = "DegreeCentrality" ]]; then
		3dmerge -1blur_fwhm 8.0 -doall -prefix ${measure}_${sub}_MNI_fwhm8.nii ${measure}_${sub}.nii.gz
		else
		3dmerge -1blur_fwhm 8.0 -doall -prefix ${measure}_${sub}_MNI_fwhm8.nii ${measure}_${sub}_MNI.nii.gz
		fi

	done
done


### 3. split the dual regression and reorgnize the files 
dataDir=/home/data/Projects/${project}/results/CPAC_zy${preprocessDate}_reorganized/${covType}/DualRegression

for sub in `cat $subject_list`; do

	echo --------------------------
	echo running subject ${sub}
	echo ---------------------
	cd ${dataDir}
	fslsplit DualRegression_${sub}_MNI_fwhm8.nii DualRegression_${sub}_MNI_fwhm8_

	for comp in 0 1 2 3 4 5 6 7 8 9; do
		mkdir -p /home/data/Projects/${project}/results/CPAC_zy${preprocessDate}_reorganized/${covType}/DualRegression${comp}
		3dcalc -a DualRegression_${sub}_MNI_fwhm8_000${comp}.nii.gz -expr 'a' -prefix /home/data/Projects/${project}/results/CPAC_zy${preprocessDate}_reorganized/${covType}/DualRegression${comp}/DualRegression${comp}_${sub}_MNI_fwhm8.nii
	done
done


### 4. copy over the SCA results, raw correlations have not been generated for all seeds, so the Z to standard space and smoothed results were used

for sub in `cat $subject_list`; do

	echo --------------------------
	echo running subject ${sub}
	echo ---------------------
	for seed in `seq 1 1 12`; do
	mkdir -p /home/data/Projects/${project}/results/CPAC_zy${preprocessDate}_reorganized/${covType}/SCA${seed}
	3dcalc -a /home/data/Projects/Colibazzi/results/output/pipeline_zy2_22_14/${sub}/sca_roi_Z_to_standard_smooth/_scan_FunImg_rawFun/_csf_threshold_0.96/_gm_threshold_0.7/_wm_threshold_0.96/_compcor_ncomponents_5_selector_pc10.linear1.wm1.global0.motion1.quadratic1.gm0.compcor0.csf1/_bandpass_freqs_0.01.0.1/_roi_rois_2mm/_fwhm_8/z_score_ROI_number_${seed}_wimt_maths.nii.gz -expr 'a' -prefix /home/data/Projects/${project}/results/CPAC_zy${preprocessDate}_reorganized/${covType}/SCA${seed}/SCA${seed}_${sub}_MNI_fwhm8.nii
	done
done
