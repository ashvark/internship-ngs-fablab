#!/bin/bash

###reference_genome
###dbkey
###input_bam
###tag_name
###sequence_platform
###mean_insert_size
###output
###threads
###max_range_index
###size_of_window
###seq_error_rate
###max_mismatch_rate
###report_inversions -r
###report_tandem_duplications -t
###report_long_inversions -l
###report_breakpoints -k
###report_close_mapped_reads -s
###additional_mismatch
###min_perfect_match_around_bp
###min_nt_size
###min_inversion_size
###min_num_matched_bases

reference_genome=${1}
dbkey=${2}
input_bam=${3}
tag_name=${4}
sequence_platform=${5}
mean_insert_size=${6}
threads=${7}
max_range_index=${8}
size_of_window=${9}
seq_error_rate=${10}
sensitivity=${11}
max_mismatch_rate=${12}
report_inversions=${13}
report_tandem_duplications=${14}
report_long_inversions=${15}
report_breakpoints=${16}
report_close_mapped_reads=${17}
reportOnlyClosedMapped=${18}
reportInterchrEvents=${19}
includefile=${20}
excludefile=${21}
additional_mismatch=${22}
min_perfect_match_around_bp=${23}
min_nt_size=${24}
min_inversion_size=${25}
min_num_matched_bases=${26}
balanceCutoff=${27}
anchorQuality=${28}
minSupportForEvent=${29}

final_output=${30}
#final_output_log=${31}

chromosome=${31}

output=${32}

if [ "${33}" == "Yes" ];
then
    gatkvar=" -G "
else
    gatkvar=""
fi

vcfheader=${34}

#runBAM2Sam()
#echo "Converting BAM to SAM format..."
#samtools view -h ${input_bam} > ${output}_sam
#echo "done..." 

#Sam2Pindel() doesn't work (homozygous and heterozygous issues)
#echo "Converting SAM to pindel input format..." 
#sam2pindel ${output}_sam ${output}_inpindel ${mean_insert_size} ${tag_name} 0 ${sequence_platform}
#echo "done..."

# bam index
echo "creating bam index file..."
cp ${input_bam} ${output}_bam
samtools index ${output}_bam

# bam configuration input file
echo "Creating bam configuration input file..."
echo -e "${output}_bam ${mean_insert_size} ${tag_name}" > ${output}_inpindel

#runPindel_v0_2_5()
if [ ${includefile} != "None" ] ;
then
    includefilevar="-j ${includefile}"
else
    includefilevar=""
fi

if [ ${excludefile} != "None" ] ;
then
    excludefilevar="-J ${excludefile}"
else
    excludefilevar=""
fi


#Indexing Reference file if Required
if [ ! -f ${reference_genome}.fai ];
then
    echo "Reference File is not indexed. Indexing Reference using Samtool"
    samtools faidx ${reference_genome}
fi

echo "Running pindel..."
pindel -f ${reference_genome} -i ${output}_inpindel -o ${output}_outpindel -c ${chromosome} -T ${threads} -x ${max_range_index} -w ${size_of_window} -e ${seq_error_rate} -E ${sensitivity} -u ${max_mismatch_rate} -r ${report_inversions} -t ${report_tandem_duplications} -l ${report_long_inversions} -k ${report_breakpoints} -s ${report_close_mapped_reads} -S ${reportOnlyClosedMapped} -I ${reportInterchrEvents} ${includefilevar} ${excludefilevar} -a ${additional_mismatch} -m ${min_perfect_match_around_bp} -n ${min_nt_size} -v ${min_inversion_size} -d ${min_num_matched_bases} -B ${balanceCutoff} -A ${anchorQuality} -M ${minSupportForEvent}
#echo "pindel -f ${reference_genome} -i ${output}_inpindel -o ${output}_outpindel -c ${chromosome} -T ${threads} -x ${max_range_index} -w ${size_of_window} -e ${seq_error_rate} -E ${sensitivity} -u ${max_mismatch_rate} -r ${report_inversions} -t ${report_tandem_duplications} -l ${report_long_inversions} -k ${report_breakpoints} -s ${report_close_mapped_reads} -S ${reportOnlyClosedMapped} -I ${reportInterchrEvents} ${includefilevar} ${excludefilevar} -a ${additional_mismatch} -m ${min_perfect_match_around_bp} -n ${min_nt_size} -v ${min_inversion_size} -d ${min_num_matched_bases} -B ${balanceCutoff} -A ${anchorQuality} -M ${minSupportForEvent}" 2>&1
echo "done..." 
#echo ${output}_inpindel 2>&1 >> ${final_output_log}

###filter_option
###     min_supported_reads
###     min_pos_supported
###     min_neg_supported

#filterPindels()
# not used by maja

#pindel2VCF()
# multiple files
echo "Converting pindel output to vcf format..."
#echo "$(ls ${output}_outpindel*)"
sleep 10

for f in `ls ${output}_outpindel*`;
do
    if [ `wc -l ${f} | cut -f1 -d " "` -gt 0 ] ;
    then
       grep "ChrID" ${f} > ${f}.tmp
       #echo "pindel2vcf -r ${reference_genome} -p ${f} -R ${dbkey} -d ${dbkey} -v ${f}.vcf" 2>&1
       pindel2vcf -r ${reference_genome} -p ${f}.tmp -R ${dbkey} -d ${dbkey} ${gatkvar} -v ${f}.vcf
    fi
done
echo "done..."

#mergedPindelOutput()
echo "Merging outputs..." 2>&1
#echo "find $(dirname ${output}) -name '$(basename ${output})*.vcf'" 2>&1
#echo "$(find $(dirname ${output}) -name '$(basename ${output})*.vcf')" 2>&1
#if [ ! -n "$(find $(dirname ${output}) -name '$(basename ${output})*.vcf')" ] ;
if [ -z "`find \`dirname ${output}\` -name "\`basename ${output}\`*.vcf"`" ] ;
then
    echo "All outputs from pindel were empty..." >&2
    echo "Terminating..." >&2
    exit 1
fi

if [ `ls ${output}_outpindel*.vcf | wc -l` -gt 1 ];
then
    grep -v "^#"  ${output}_outpindel*.vcf | cut -f2- -d ":" > ${output}_merged_tmp.vcf
else
    grep -v "^#"  ${output}_outpindel*.vcf > ${output}_merged_tmp.vcf
fi
echo "done..." 

#sortBed()
echo "Sorting the output..."
sortBed -i ${output}_merged_tmp.vcf > ${output}_merged.vcf
echo "done..."
# add header
# if bam header is needed
#echo "Adding header from the sam file..." 2>&1 >> ${final_output_log}
#samtools view -H ${input_bam} > ${output}_samheader
#cat ${output}_samheader ${output}_merged.vcf > ${final_output}
# if pindel header is needed

#merging vcfs
#tmpvcfvar=""
#for f in $(ls ${output}_outpindel*.vcf);
#do
#    vcf-sort ${f} > ${f}.sorted
#    bgzip ${f}.sorted
#    tabix -p vcf ${f}.sorted.gz
#    tmpvcfvar=${tmpvcfvar}" "${f}".sorted.gz"
#
#done

#if [ $(echo ${tmpvcfvar} | wc -w) -gt 1 ];
#then
#    vcf-merge ${tmpvcfvar} > ${final_output}
#else
#    gunzip -c ${tmpvcfvar} > ${final_output}
#fi
    

#rm ${output}*
# if pindel header is needed
# slightly different headers in those multiple pindel outputs !!????

if [ "${vcfheader}" == "Yes" ];
then
    tmpvcfvar=""
    for f in $(ls ${output}_outpindel*.vcf);
    do
        vcf-sort ${f} > ${f}.sorted
        bgzip ${f}.sorted
        tabix -p vcf ${f}.sorted.gz
        tmpvcfvar=${tmpvcfvar}" "${f}".sorted.gz"
    done

    if [ $(echo ${tmpvcfvar} | wc -w) -gt 1 ];
    then
        vcf-merge ${tmpvcfvar} > ${final_output}
    else
        gunzip -c ${tmpvcfvar} > ${final_output}
    fi

else

    if [ `ls ${output}_outpindel*.vcf | wc -l` -gt 1 ];
    then
        grep -v "^#"  ${output}_outpindel*.vcf | cut -f2- -d ":" > ${output}_merged_tmp.vcf
    else
        grep -v "^#"  ${output}_outpindel*.vcf > ${output}_merged_tmp.vcf
    fi
    echo "done..."

    echo "Sorting the output..."
    sortBed -i ${output}_merged_tmp.vcf > ${output}_merged.vcf
    echo "done..."

    echo "Adding header from pindel..."
    echo -e "#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFORMAT\t${tag_name}" > ${final_output}
    cat ${output}_merged.vcf >> ${final_output}


   echo "done.."
fi

echo "finito..."

