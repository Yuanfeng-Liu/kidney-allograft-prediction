# Kidney Allograft Rejection Prediction

This **DATA3888 Biomedical Data Science** group project examined whether gene-expression measurements could distinguish kidney transplant rejection from graft stability. We compared models built from blood and biopsy data and developed a Shiny application to demonstrate the predictions.

The biopsy model had higher sensitivity and specificity in its evaluation cohort. The blood model detected most rejection cases, but its low specificity meant that many stable samples were also flagged.

## My contribution — Yuanfeng Liu

I cleaned six of the 12 study datasets, contributed to feature-selection code, and wrote and debugged the biopsy modelling code. I worked with Member C on cross-validation and parameter tuning. I also helped with parts of the Shiny code, explanatory diagrams, and the presentation.

This was a six-person project. The other contributors are listed as **Member A–E** for privacy, and the [report](reports/final-report.html) retains the team's contribution table.

## Analysis and results

The analysis combined compatible GEO studies, addressed batch effects, and compared six feature-selection methods. We used five-fold cross-validation to compare and tune models, with separate datasets reserved for evaluation. The selected models were a random forest using 200 biopsy genes and XGBoost using 400 blood genes.

The following results are calculated from the submitted report's held-out confusion matrices, with rejection as the positive class:

| Input | Feature selection | Model | Evaluated samples | Accuracy | Sensitivity | Specificity |
|---|---|---|---:|---:|---:|---:|
| Biopsy | Mutual information, 200 genes | Random forest | 61 | 0.7705 | 0.9286 | 0.6364 |
| Blood | t-test, 400 genes | XGBoost | 54 | 0.5926 | 0.8571 | 0.3077 |

The biopsy model missed 2 of 28 rejection cases and flagged 12 of 33 stable samples. The blood model missed 4 of 28 rejection cases and flagged 18 of 26 stable samples. These results come from **different cohorts**, so they are not a paired comparison of blood and biopsy measurements from the same patients.

The repository includes the submitted models and results; training and evaluation have not been rerun for this public version. This is a coursework research prototype without clinical validation.

## Browse the work

- [Final report](reports/final-report.html): methods, findings, discussion, and team contributions.
- [Technical appendix](reports/appendix.html): data preparation, feature selection, and model development.
- [Analysis source](analysis/): Quarto source for both reports.
- [Presentation](reports/presentation.pptx): the group's 20-slide presentation.
- [Shiny application](shinyapp/app.R): expression-matrix upload, predictions, model summaries, and downloads.

Download the HTML reports and open them in a browser to view the formatted pages.

## Run the demonstration

With R 4.1 or later, start R from the repository root:

```r
source("setup.R")
shiny::runApp("shinyapp")
```

Choose **Blood** or **Biopsy** and upload `shinyapp/examples/eMat_example.csv`. The file has genes in rows and sample IDs in columns. The app selects the required genes, standardises them using saved training statistics, and returns `reject` or `stable` labels. The stored thresholds are **0.4 for blood** and **0.3 for biopsy**, with `reject` assigned only above the threshold.

New uploads must already be compatible with the training data: the app does not repeat the analysis's batch-correction workflow. Its outputs are class labels, not calibrated clinical risk estimates.

Email-template preview is available with fictional example contacts; sending requires your own service settings. See [setup notes](docs/SETUP.md) for configuration, model compatibility, and analysis dependencies.
