# Retrieval-Augmented Generation Using LLM on Sol

## Description
This README provides instructions on how to run Python scripts for Retrieval-Augmented
Generation (RAG) using Large Language Models (LLMs) on ASU's Sol supercomputer.
The process involves preparing data, creating the database, preparing questions,
and running queries.

## Table of Contents
1. [Prepare Your Data](#prepare-your-data)
2. [Usage](#usage)
   1. [Create the Database](#create-the-database)
   2. [Query](#query)
3. [Prepare the Questions](#prepare-the-questions)
4. [Change Default Parameters](#change-default-parameters)
5. [Available Models](#available-models)
6. [FAQ](#faq)

---

## Prepare Your Data
The RAG can ingest text files as plain text (`.txt`), portable document format
(`.pdf`), and comma-separated values (`.csv`).
It can process any combination of those three formats and, in fact, will search
for all the files matching that extension.
These files can be provided by a containing directory, as a compressed file
(`.zip`), or as a URL pointing to a `.zip` file.
The script will recursively search for all supported files inside existing
subdirectories.

---

## Usage

The recommended pipeline to run RAG on your data is using Sol's batch scheduler
-- more information
[here](https://asurc.atlassian.net/wiki/spaces/RC/pages/1734180881/Using+the+Slurm+Scheduler+SBATCH).
The workflow is divided into two steps.

### Create the Database

Create the database with `scripts/run_db.sh` -- schedules a job to create a
database given three input parameters: (1) a set of input data, (2) a destination
directory where to store the database, and (3) an *optional* path to the
configuration file (please refer to the [changing default parameters](#change-default-parameters)
section for more information).

By default, the sbatch script asks for 15 minutes of allocated runtime, in a general
partition located in a public node.
Substitute the arguments for your own and, if appropriate, modify the time and
resources parameters to meet the demands of your data.
Arguments between `<>` are required, while arguments inside `[]` are optional.

**scripts/run_db.sh**:
```bash {.numberLines}
#!/bin/bash
#SBATCH -p general
#SBATCH -q public
#SBATCH --time=0-00:15:00
#SBATCH --gres=gpu:a100:1

#set up the environment
module load mamba/latest
source activate genai23.10

python scripts/create_db.py <data> <db_destionation_dir> [config_file.yaml]
```

Then submit the sbatch job:
```bash {.numberLines}
sbatch scripts/run_db.sh
```

### Query

Run the queries with `scripts/run_query.sh` -- schedules a job to query the
database given four input parameters: (1) a database, (2) a list of questions,
(3) a destination file where the responses will be stored, and (4) an *optional*
path to the configuration file (please refer to the
[changing default parameters](#change-default-parameters) section for more
information).

By default, the sbatch script asks for 15 minutes of allocated runtime, in a general
partition located in a public node.
Substitute the arguments for your own and, if appropriate, modify the time and
resources parameters to meet the demands of your data.
Arguments between `<>` are required, while arguments inside `[]` are optional.

The answers (output) will be generated as plain text and stored into a `.txt` file.

**scripts/run_query.sh**:
```bash {.numberLines}
#!/bin/bash
#SBATCH -p general
#SBATCH -q public
#SBATCH --time=0-00:30:00
#SBATCH --gres=gpu:a100:1

#set the environment PATH
module load mamba/latest
source activate genai23.10
python scripts/query.py <db_dir> <questions_file.txt> <answers.txt> [config_file.yaml]
```

Then submit the sbatch job:
```bash {.numberLines}
sbatch scripts/run_query.sh
```

### Example

To run the example using the provided materials and the default configuration,
modify the sbatch scripts as as follows:

**scripts/run_db.sh**:
```bash {.numberLines}
#!/bin/bash
#SBATCH -p general
#SBATCH -q public
#SBATCH --time=0-00:15:00
#SBATCH --gres=gpu:a100:1

#set up the environment
module load mamba/latest
source activate genai23.10

python scripts/create_db.py example/llm_papers/ example/llm-db
```
**scripts/run_query.sh**:
```bash {.numberLines}
#!/bin/bash
#SBATCH -p general
#SBATCH -q public
#SBATCH --time=0-00:30:00
#SBATCH --gres=gpu:a100:1

#set the environment PATH
module load mamba/latest
source activate genai23.10
python scripts/query.py example/llm-db example/questions.txt example/answers.txt
```

Then you can run submit the job to create the database:
```bash {.numberLines}
sbatch scripts/create_db.sh
```

Once the job finishes, it will have created a database located in `example/llm-db`.
Now you can submit the example queries:
```bash {.numberLines}
sbatch scripts/run_query.sh
```

Upon completion, you will have a new file located in `example/answers.txt`.

---

## Prepare the Questions
The questions or queries are provided as a plain text file (`.txt`) where each
line is a standalone question.

---

## Change Default Parameters
The default parameters, including what model (LLM) to use are in `scripts/config.yaml`.
This file is YAML formatted, more information [here](https://yaml.org/).

Important parameters include:

- LLM: `model_id`, default is **Llama-2 13b**.
- Search model: `search_type`, default is [**MMR algorithm**](https://python.langchain.com/docs/modules/model_io/prompts/example_selector_types/mmr).
- Amount of sources per query: `search_kwargs["k"]`, default is **5**.
- Amount of documents to pass to the search model, default is **50**.
- Language model load: `load_in8bit`, default is set to **True**.
- Question max length: `q_max_length`, default is **1024** tokens.
- Response max length: `r_max_length`, default is **2450** tokens.

---

## Available Models

| Model Name   | Original Model | `dtype=bfloat16` | `load_in_8bits=True` |
|--------------|----------------|------------------|----------------------|
| Llama-2 7b   | 26 GiB          | 13 GiB          | 7 GiB                |
| Llama-2 13b  | 49 GiB          | 24 GiB          | 13 GiB               |
| Llama-2 70b  | 257 GiB         | 128 GiB         | 67 GiB               |
| Falcon 180b  | 360 GiB         | 180 GiB         | 90 GiB               |

