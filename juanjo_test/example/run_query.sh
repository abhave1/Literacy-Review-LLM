#!/bin/bash
#SBATCH -p general
#SBATCH -q public
#SBATCH --time=0-00:15:00
#SBATCH --gres=gpu:a100:1

#set up the environment
module load mamba/latest
source activate genai23.10

python scripts/query.py example/llm-db example/questions.txt example/answers.txt
