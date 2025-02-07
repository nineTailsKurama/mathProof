mathproof
==============================

We explore the application of transformer-based Language Models (LM) to automated theorem proving. We specifically use a GPT-3 based neural network fine-tuned on mathlib code to generate math sequences. Our LMs acts as an automated prover and proof assistant. We further combine couple of language models and re-ranker to select for the best results. Overall this improves the results from 0.322 to 0.3627 for out GPT-3 based ADA model and 0.4592 for our combined GPT-3 and GPT-NEO model. Our github code is on.

# Data


A large part of our code involves and build upon the work done at OpenAI. We further go a  step ahead and add all the packages heres. Please open the processed folder in the data folder and unzip for the priocessed data.

You can download the files with the proceesed data from the link below.

```
https://drive.google.com/file/d/1rD1GC8OLTKimUiatjFWhCwsh_DaZGur6/view?usp=sharing
```

We use the following Libraries to help us with out code. All our data is prepared in the  folder and processed. All the data can be downloaded with the link above. The code takes a while to run therefore download it from the link above.

The libraries which help our code are:
```
https://github.com/leanprover-community/mathlib.git
https://github.com/openai/miniF2F.git
https://github.com/jasonrute/lean_proof_recording.git
https://github.com/jesse-michael-han/lean-gptf.git
https://github.com/jesse-michael-han/lean-step-public.git
https://github.com/jesse-michael-han/lean-tpe-public.git
```


# Model

As discussed in the model, we have three different models. The first is the GPT-3 model which is a fine-tuned model on the mathlib code. The second is the GPT-NEO model which is a model which is trained on the mathlib code. The third is the combined model which is a combination of the GPT-3 and GPT-NEO model and reranked. The combined model is the best model for our project. 

Please check the GPT-3 Folder under src/gpt3/ for how to train the model.




### OpenAI GPT-3 Fine Tuning


OpenAI uses their own platform for fine tuning. We use command line application called `openai` to train the model. The command line application is available in the link below.


We will first have to download the package
```
pip install openai
```

Then set your OPENAI_API_KEY environment variable by adding the following line into your shell initialization script (e.g. .bashrc, zshrc, etc.) or running it in the command line before the fine-tuning command:
```
export OPENAI_API_KEY=<your_api_key>
```


Unzip the folder in data/processed/ for the data. We will have the prepare the data in the following way:
```
openai tools fine_tunes.prepare_data -f data/processed/files_upload/data_test.jsonl
openai tools fine_tunes.prepare_data -f data/processed/files_upload/data_train.jsonl
openai tools fine_tunes.prepare_data -f data/processed/files_upload/data_valid.jsonl
```

It will generate the following files:
* data_test_prepared.jsonl
* data_train_prepared.jsonl
* data_valid_prepared.jsonl


We finally train our model using the following command:
```
fine_tunes.create  -t  data/processed/data_train_prepared.jsonl -v data/processed/data_valid_prepared.jsonl -m  ada 
```

The code will train an model and give you a fine tuning id. Store the finetune id and use it to get the model. We train an ada model feel free to change your model to babbage, curie or davinci.

Check your results of the fine  tuning by running the following command:
```
openai api fine_tunes.follow -i <finetuneid>
```

Our resuls were:

```
openai api fine_tunes.follow -i <finetuneid>
```

```
[2022-04-14 15:38:19] Created fine-tune: <finetuneid>
[2022-04-14 15:39:29] Fine-tune costs $66.57
[2022-04-14 15:39:29] Fine-tune enqueued. Queue number: 1
[2022-04-14 15:41:02] Fine-tune is in the queue. Queue number: 0
[2022-04-14 15:43:39] Fine-tune started
[2022-04-15 13:03:02] Completed epoch 2/4
[2022-04-15 23:30:17] Completed epoch 3/4
[2022-04-16 09:57:36] Completed epoch 4/4
[2022-04-16 09:58:10] Uploaded model: ada:<name>
[2022-04-16 09:58:26] Uploaded result file: file-vsW2IzVozGU4dQ6IAWOzZgLl
[2022-04-16 09:58:26] Fine-tune succeeded

Job complete! Status: succeeded 🎉
Try out your fine-tuned model:

openai api completions.create -m ada:ft-personal-<name> -p <YOUR_PROMPT>

```



### GPT-NEO Model

The GPT-Neo training file is located on [gpt_neo.ipynb](./src/models/gpt_neo/gpt_neo.ipynb)
The evaluation file is located on [gpt_neo_eval.ipynb](./src/models/gpt_neo/gptNEO_eval.ipynb), [neo_process.ipynb](./src/models/gpt_neo/neo_process.ipynb) and [neo_process_eval.ipynb](./src/models/gpt_neo/neo_process_eval.ipynb)

The models weights and all the information can be found at:
```
https://drive.google.com/drive/folders/16A34CAxlvwBXNH733zFESogzx8WeA1ty?usp=sharing
```

We have also uploaded all the code 

### ReRanker Training 

We have uploaded the fine tuned modelt o huggingface. Use the tage Saisam/gpt-neo-math-small 

The ReRanker training file is located on [reranker_train.ipynb](./src/models/reranker/reranker-train.ipynb)
The ReRanker evaluation is located on [reranker_show.ipynb](./src/models/reranker/reranker-show.ipynb) 


# Results

In our process, we started by evaluating our model on MathBERT, based on our initial studies we have a loss of 3.15 and an training accuracy of 0.13 on our test set. Accuracy here refers the getting the tactic right. We had training loss as 3.164 and a loss of accuracy of 0.14 on the validation set. 

To better see our process, please take a look at Figure 1 and Figure 2. Given the low accuracy of MathBERT, we selected GPT-3 and GPT-NEO to further fine-tune with the tactic proof dataset we selected. The training accuracy displayed below?? shows the GPT-adaMath model we trained achieved the highest accuracy of 36.27%. GPT-3 training result is more refined and have more similar queries while GPT- neo on average have worse accuracy but the result have high variance. We come up with the intuition to combine both to leverage the variance, at at the same time apply re-ranker to select the first 6 queries to improve the frequency. The combined model end up getting the highest accuracy of 45.92% compare to the benchmark from GPT-f with accuracy 32.2%.




Project Organization
------------

    ├── LICENSE
    ├── Makefile           <- Makefile with commands like `make data` or `make train`
    ├── README.md          <- The top-level README for developers using this project.
    ├── data
    │   ├── external       <- Data from third party sources.
    │   ├── interim        <- Intermediate data that has been transformed.
    │   ├── processed      <- The final, canonical data sets for modeling.
    │   └── raw            <- The original, immutable data dump.
    │
    │
    ├── models             <- Trained and serialized models, model predictions, or model summaries
    │
    ├── notebooks          <- Jupyter notebooks. Naming convention is a number (for ordering),
    │                         the creator's initials, and a short `-` delimited description, e.g.
    │                         `1.0-jqp-initial-data-exploration`.
    │
    ├── references         <- Data dictionaries, manuals, and all other explanatory materials.
    │
    ├── reports            <- Generated analysis as HTML, PDF, LaTeX, etc.
    │   └── figures        <- Generated graphics and figures to be used in reporting
    │
    ├── requirements.txt   <- The requirements file for reproducing the analysis environment, e.g.
    │                         generated with `pip freeze > requirements.txt`
    │
    ├── setup.py           <- makes project pip installable (pip install -e .) so src can be imported
    ├── src                <- Source code for use in this project.
    │   ├── __init__.py    <- Makes src a Python module
    │   │
    │   │
    │   ├── models         <- Scripts to train models and then use trained models to make
    │   │   │                 predictions
    │   │   ├── predict_model.py
    │   │   └── train_model.py
    │   │
    │
    └── tox.ini            <- tox file with settings for running tox; see tox.readthedocs.io


--------

<p><small>Project based on the <a target="_blank" href="https://drivendata.github.io/cookiecutter-data-science/">cookiecutter data science project template</a>. #cookiecutterdatascience</small></p>
