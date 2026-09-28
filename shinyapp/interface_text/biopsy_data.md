-   11 datasets were collected from Gene Expression Omnibus

    -   10 of them were merged to form a dataset used for model training, containing 661 patient samples in total

    -   1 dataset with 82 samples was held out to evaluate the model's ability to classify new, unseen cases

-   Most datasets included a large number of genes (over 17,000), but 4 included fewer

-   2 of these smaller datasets were kept as they still covered at least half of the genes found to be statistically important in the others. The other 2, retaining only 4% of the key genes, were removed to ensure that valuable predictive signals weren't lost in the final analysis.

-   Across all biopsy datasets, more patients were stable than experiencing rejection, but both outcomes were well represented. This gave the model a strong foundation to distinguish between the two conditions.

-   To make sure that model selection and evaluation is robust not just on 1 group of patients but across many, the training data is split into 5 smaller groups - 4 is used to train the model while 1 is for performance evaluation. Each time, a different group was used for assessment. This practice ensures that the model actually learns general patterns - not merely memorizes specific cases - and thus could give reliable prediction in real-life scenario
