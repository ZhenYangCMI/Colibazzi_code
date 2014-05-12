
## full/path/to/site
analysisdirectory=/home/data/Projects/Colibazzi/data/columbia

## full/path/to/site/subject_list
subList="/home/data/Projects/Colibazzi/data/subjectlist_addedLater.txt"

## name of resting-state scan (no extension)
rest=rawFun_gms

## name of rest directory
func_dir_name=FunImg

## Set high pass and low pass cutoffs for temporal filtering
hp=0.01 ; lp=0.1

## run temporal filtering and ICA for each subject

for subject in `cat $subList`; do
#subject=1616468
#for realization in `seq 2 30`
#do
## directory setup
dir=${analysisdirectory}
func_dir=${dir}/${subject}/${func_dir_name}
ICA_dir=${func_dir}/ICA

echo --------------------------
echo running subject ${subject}
echo --------------------------

mkdir -p ${ICA_dir} ; cd ${ICA_dir}
cp ${func_dir}/${rest}.nii.gz ./

## 0. Make mask
rm -rf ${func_dir}/${rest}_mask.nii.gz
if [ ! -e ${func_dir}/${rest}_mask.nii.gz ]
then
3dAutomask -overwrite -prefix ${func_dir}/${rest}_mask.nii.gz  ${func_dir}/${rest}.nii.gz
fi

## 1. Temporal filtering

rm -rf ${rest}_filt.nii.gz
rm -rf ${ICA_dir}/${rest}_filt.nii.gz
if [ ! -e ${rest}_filt.nii.gz ]
then
echo "High-pass filtering: ${subject}"
#3dTcat -rlt -float -overwrite -prefix ${func_dir}/rlt.nii.gz  ${func_dir}/${rest}_gms.nii.gz
3dFourier -lowpass ${lp} -highpass ${hp} -prefix ${ICA_dir}/${rest}_filt.nii.gz ${func_dir}/${rest}.nii.gz
fi

## 2. ICA

cmd="melodic -i ${rest}_filt.nii.gz --outdir=tmp.ica --mask=${func_dir}/${rest}_mask.nii.gz --nobet --no_mm --Oorig"
echo $cmd
eval $cmd

rm -rf melodic_autoDim
mkdir -p melodic_autoDim
mv tmp.ica/melodic_IC.nii.gz melodic_autoDim/melodic_IC.nii.gz
mv tmp.ica/melodic_FTmix tmp.ica/melodic_mix melodic_autoDim/
rm -rf tmp.ica
done

