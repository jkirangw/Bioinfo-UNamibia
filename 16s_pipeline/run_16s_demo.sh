#The following command can be used to obtain the workflow. This will pull the repository in to the assets folder of Nextflow and provide a list of all parameters available for the workflow as well as an example command:

nextflow run epi2me-labs/wf-16s --help


#To update a workflow to the latest version on the command line use the following command:
nextflow pull epi2me-labs/wf-16s


#A demo dataset is provided for testing of the workflow. It can be downloaded and unpacked using the following commands:

wget https://ont-exd-int-s3-euwst1-epi2me-labs.s3.amazonaws.com/wf-16s/wf-16s-demo.tar.gz
tar -xzvf wf-16s-demo.tar.gz


#The workflow can then be run with the downloaded demo data using:


nextflow run epi2me-labs/wf-16s \
    --fastq 'wf-16s-demo/test_data' \
    --minimap2_by_reference \
    -profile standard

#For further information
#https://labs.epi2me.io/wfquickstart/
