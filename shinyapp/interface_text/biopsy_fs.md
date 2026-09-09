-   7 different feature selection methods are implemented on 4 subsets of the training set to rank the genes by how differently they express on stable and reject patients

-   A model was built on the 4 subsets with their n top genes from the above ranking, for n being various different number of genes from 10 to 500

-   By applying the model on the remaining subset of the training data, we asses its ability to separate reject patients from stable ones

-   The above process was repeated 5 times, each with a different last-step test set to ensure that the overall evaluation is robust

-   The optimal value of n for each feature selection method is selected from the average performance across different iterations to maximize the potential predictive power

-   From this, we have found **Mutual Information** with **200 genes** as the optimal feature selection method for the biopsy dataset
