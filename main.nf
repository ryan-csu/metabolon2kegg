#!/usr/bin/env nextflow
OUTDIR = params.outdir
INFILE = params.infile

// overidable defualts
params.cols_metadata = 13
params.rows_metadata = 27
params.infiletab = "OrigScale"
params.help = false

// DATE = new java.util.Date()
println "Git info: $workflow.repository - $workflow.revision [$workflow.commitId]"
println "Cmd line: $workflow.commandLine"
println "Start time: $workflow.start"

// get base filename as well for setting title
infiles = Channel
                .fromPath(params.infile)
                .map { file -> tuple(file.baseName, file) }

// Display help
if(params.help) {
        log.info ''
        log.info 'Metabolon2kegg'
        log.info ''
        log.info 'Usage: '
        log.info "    nextflow run ryan-csu/metabolon2kegg -profile singularity --infile=INFILE.xlsx --outdir OUTDIR [other options]"
        log.info ''
        log.info 'See: https://github.com/ryan-csu/metabolon2kegg for more info'
        log.info ''
        return
}

// hack to prevent having to rebuild container for each test, yet still using github remote nextflow and current github notebook

process get_notebook {

    output:
        file "analyses/metabolon2kegg_notebook.ipynb" into current_notebook

'''
    git init && git remote add origin https://github.com/ryan-csu/metabolon2kegg.git && git fetch -f && git branch master origin/master && git checkout master
    
'''


}

//This is a jupyter notebook in Python run with reportsrender via papermill
process generate_data {
    def id = "metabolon2kegg_notebook"

    publishDir "$OUTDIR", mode: 'copy', overwrite: false

    input:
        set filename, file(infile) from infiles
        //file notebook from Channel.fromPath("analyses/${id}.ipynb")
        file notebook from current_notebook

    output:
        file "*.tsv" into generate_data_csv 
        file "*.html" into generate_data_html 

    """
    reportsrender ${notebook} \
        ${id}.html \
        --cpus=${task.cpus} \
        --params="cols_metadata=${params.cols_metadata} \
                  rows_metadata=${params.rows_metadata} \
                  infile='${filename}'.xlsx \
                  infiletab='${params.infiletab}'
                  "
    """
}

