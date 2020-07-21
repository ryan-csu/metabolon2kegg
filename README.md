# Metabolon2kegg

One step pipeline used to convert Metabolon xlsx files with inconsistant structure into feature metadata, sample metadata, and measurment  tsv files and merge with kegg identifiers

Built using Jupyter lab, pandas, Nextflow, [reportsrender](https://github.com/grst/reportsrender/), and the "Universal data analysis pipeline".

## Publication / Grant blurb:

Metabolon compound IDs matched to KEGG identifiers using API and a reproducable nextflow pipeline avaliable at: https://github.com/ryan-csu/metabolon2kegg

Citations: 

Kanehisa, Minoru, and Susumu Goto. "KEGG: kyoto encyclopedia of genes and genomes." Nucleic acids research 28, no. 1 (2000): 27-30.

Di Tommaso, P., Chatzou, M., Floden, E. W., Barja, P. P., Palumbo, E., & Notredame, C. (2017). Nextflow enables reproducible computational workflows. Nature Biotechnology, 35(4), 316–319. doi:10.1038/nbt.3820

reportsrender https://github.com/grst/reportsrender/


## How to run

See `T:\Rsch-Ryan\Metabolon\Metabolon\Human Studies\BENEFICIAL\Stool\COSU-0115-17VWBL+ CDT  sent to the client 05-10-2019.xlsx` for the exspected format of the excell file. 

1. Copy excell file from Metabolon to new directory on the `V:/` drive that will serve as the input and output location. Record source location lab notebook and README.txt in the directory on the `V:/` drive you are using to preserve data provinance. 

2. If needed, change filename to remove non-alphanumerics (including spaces), or escape them in the command line with quotes or backslashes.  Review number of rows and columns of metadata and tab name for matching to exspected format (see command below), check for unusual non-unicode characters or changes in formatting. Record all manual changes in lab notebook and README.txt in the directory on the `V:/` drive you are using to preserve data provinance. 

3. Log in to server, or any system with nextflow (and singularity), preferably in `tmux` (see below or the [CLI SOP](https://github.com/ryan-csu/RyanLab-Protocols/blob/master/SOP/cvmrit03_CLI_SOP.md) for details):

4. Move file from `V:` drive A.K.A `/lab_data/ryan_lab/` to working (home) directory. Replace `test.xlsx` with your file name in the examples below

        cp /lab_data/ryan_lab/jamesrh/metabolon2kegg/EXAMPLE/test.xlsx ./

5. Run pipeline (update cache first):

        nextflow pull ryan-csu/metabolon2kegg

        nextflow run ryan-csu/metabolon2kegg \
            -profile singularityHPC \
            --infile='test.xlsx' \
            --outdir metabolon2kegg_`date -I`_$USER \
            --cols_metadata=13 \
            --rows_metadata=27 \
            --infiletab='OrigScale'

The last 4 peramiters are optional. The output are in the `outdir` folder unless you specify an `--outdir` peramiter. 

The first time this is run on a server will take some time to pull down the container (5 min with no network traffic). On each run the kegg database is retrieved, which also takes several minues, and can cause delays or failers if the API is down (see below for manually interacting with notebook for cached version). The merging of data takes only seconds. 

6. Move back to `V:` drive A.K.A `/lab_data/ryan_lab/` and cleanup the copy of the file you started with

        mv -v metabolon2kegg_2020-07-20_jamesrh /lab_data/ryan_lab/jamesrh/metabolon2kegg/EXAMPLE/
        
        rm test.xlsx

## Results interpretation

### Information

The file [kegg/merged_crk.tsv](kegg/merged_crk.tsv) has a cached version of KEGG's DB accessed under the academic lisence public API of merged reactions, compounds, and orthologs that can be used to track identifiers.

Core compounds are not usefull to track gene occurance. Following common practice in metabolic network modeling, the following 17 compound IDs are dropped before merging (or else all genes are pulled in as involved). 

        cpd	    cpd_description
        
        C00001	H2O; Water
        C00002	ATP; Adenosine 5'-triphosphate
        C00003	NAD+; NAD; Nicotinamide adenine dinucleotide; ...
        C00004	NADH; DPNH; Reduced nicotinamide adenine dinuc...
        C00005	NADPH; TPNH; Reduced nicotinamide adenine dinu...
        C00006	NADP+; NADP; Nicotinamide adenine dinucleotide...
        C00007	Oxygen; O2
        C00008	ADP; Adenosine 5'-diphosphate
        C00009	Orthophosphate; Phosphate; Phosphoric acid; Or...
        C00010	CoA; Coenzyme A; CoA-SH
        C00011	CO2; Carbon dioxide
        C00012	Peptide
        C00013	Diphosphate; Diphosphoric acid; Pyrophosphate;...
        C00014	Ammonia; NH3
        C00015	UDP; Uridine 5'-diphosphate
        C00016	FAD; Flavin adenine dinucleotide
        C00017	Protein

The following files in the output directory contain your output:

1. Files that have details of pipeline run, versions, etc: `report.html`, `timeline.html`

2. Jupyter notebook file rendered into html showing steps involved and summery details: `metabolon2kegg_notebook.html`

See the cell after "percent of peaks with the following IDs" to understand how much of data has KEGG IDs at all (less than 50% is typical).


3. Output tab-seperated files:

The metadata in the row and collumn headers in the selected tab:

        [infile name]_[infile tab]_metabolitesMETADATA.tsv

        [infile name]_[infile tab]_sampleMETADATA.tsv

The occurance values from the main part of the table, with row and column headers of 'BIOCHEMICAL' and 'CLIENT_IDENTIFIER'

        [infile name]_[infile tab]_occurance.tsv

The files that link KEGG ortholog data and Metabolon data with all metadata:

        [infile name]_[infile tab]_metabolitesMETADATA_filtered_KEGGmerge.tsv

and just the identifiers: 

        [infile name]_[infile tab]_metabolitesCHEMICALID_filtered_KEGG_ko.tsv

        
## Information for developing / programming pipeline

### Directory structure of repo

- `analyses`: The actual analysis steps (i.e. jupyter notebooks, Rmarkdown
  documents, bash scripts) go here.
- `envs`: conda environment files go here. Create one file per notebook,
  or re-use environments for multiple notebooks -- it's up to you.
- `results`: final results generated by the pipeline go here. Concept: one can
  always delete the results directory and re-generate it from `data` using the
  pipeline.
- `main.nf`: The nextflow workflow that ties everything together.
- `nextflow.config`: Contains configuration options for the pipeline
  (e.g. output directory). You can also set options here to run the
  pipeline on a HPC grid engine (e.g. SGE or SLURM).

## Setup

May not be nessesary if you have set this up on your account previously. 

### Connect to server


1. connect to server, and use `tmux` to prevent being logged off if you are discnnected.

        ssh jamesrh@cvmrit03.cvmbs.colostate.edu

        tmux attach || tmux new


2. Do work. If you are diosconnected, just repeat the prior step to reattach. 


When it is time to log off:

3. Log out, one to stop tmux, again to disconnect, and a third time to close your local terminal or PowerShell:

        exit

        exit

        exit


### Set up pipeline tool for workflows

how to setup nextflow with singularity on 

0. Use the `Connect to server` protocol above to log in. 

1. Check that singularity is installed for your user

        singularity --version 

        singularity run --containall shub://vsoch/hello-world 


Tested with singularity version 3.5.0

If you see a silly responce about avacados, this is set up and ready to run!

2. Install Nextflow in your home directory and set up PATH

        wget -qO- https://get.nextflow.io | bash

        mkdir -p ~/bin & mv nextflow bin & echo PATH=$PATH:$HOME >> ~/.bashrc & source ~/.bashrc 


3. Test prequisites

        nextflow -version

        nextflow run hello 

tested with nextflow version 20.01.0

If you see a silly greeting in three languages, everything is set up and ready to run!

4. Log out, one to stop tmux, again to disconnect, and a third time to close your local terminal or PowerShell

        exit

        exit

        exit

## update pipeline

        nextflow pull ryan-csu/metabolon2kegg

        singularity pull docker://ryancsu/metabolon2kegg


## How to setup for development

Note that jupyter notebook has examples of interactive searching and merging with metadata output. See 

1. Install nextflow
   In this case, we use conda. See conda website for install, check the nextflow webiste for other options.

```
conda create -n nextflow -c conda-forge -c bioconda nextflow
conda activate nextflow
```

2. Clone this repository

```
git clone git@github.com:ryan-csu/metabolon2kegg.git
cd metabolon2kegg
```

3. Run the pipeline

```
    nextflow ./main.nf \
            --infile='test.xlsx' \
            --outdir metabolon2kegg_`date -I`_$USER
```

4. You can build or run the docker env, see Dockerfile

        docker build --no-cache -t ryancsu/metabolon2kegg:latest envs/

        singularity shell docker-daemon://ryancsu/metabolon2kegg:latest

        # OR 
        
        docker run -it --rm -v "${PWD}":"${PWD}" ryancsu/metabolon2kegg:latest
        
_OR_ 

Use the Docker hub where the pipeline pulls from with `-profile singularityHPC`

        docker login -u ryancsu 

        docker push ryancsu/metabolon2kegg:latest

        singularity shell docker://ryancsu/metabolon2kegg:latest

        # OR 
        
        docker run -it --rm -v "${PWD}":"${PWD}" ryancsu/metabolon2kegg:latest


Notebook (but not nextflow) runs in docker container jupyter/datascience-notebook:ea01ec4d9f57

        docker run -it --rm -v "${PWD}":/home/jovyan/work jupyter/datascience-notebook:ea01ec4d9f57

This can be used to interact with the notebook in the pipeline in order to update it. 

