-   6 datasets were collected from **Gene Expression Omnibus**

    -   5 of them were merged to form a dataset used for model training, containing 213 patient samples in total

    -   1 dataset with 54 samples was held out to evaluate the model's ability to classify new, unseen cases

-   Most datasets included a large number of genes *(over 20,000)*, though 1 had significantly fewer

-   Investigation on the fewer-gene dataset shows that it includes all the genes that are statistically important in the other datasets, hence being retained in the analysis

-   Overall, the blood datasets offer a balanced view of patient outcomes: roughly half of the patients were experiencing rejection, while the other half were stable. This balance allowed the model to learn from both outcomes equally

-   To make sure that model selection and evaluation is robust not just on 1 group of patients but across many, the training data is split into 5 smaller groups - 4 is used to train the model while 1 is for performance evaluation. Each time, a different group was used for assessment. This practice ensures that the model actually learns general patterns - not merely memorizes specific cases - and thus could give reliable prediction in real-life scenario
