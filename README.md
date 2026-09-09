# Kidney Allograft Rejection Prediction

An R machine learning and Shiny group project for **DATA3888 Biomedical Data Science**. It investigates whether gene expression from blood or kidney biopsies can distinguish transplant rejection from graft stability, then packages the selected models into an interactive demonstration.

The main result is a comparison of two complete prediction pathways: a biopsy model with stronger held-out discrimination and a less invasive blood-based alternative whose high sensitivity comes with substantial false positives. This is a coursework research prototype, with **no clinical validation**.

## The problem and what made it difficult

**Combining separate studies.** Gene expression measurements came from multiple Gene Expression Omnibus datasets, with different platforms, gene coverage, and batch effects. Cleaning and harmonising these studies was necessary before a classifier could learn rejection-related signals. The reported workflow examines coverage, combines compatible data, and applies batch correction; a separate dataset is reserved for evaluation.

**Many genes, relatively few samples.** Thousands of candidate genes made overfitting a central concern. The team compared six feature-selection approaches and different gene counts, then used five-fold cross-validation to compare and tune candidate models. The final pathways use **200 genes selected by mutual information for biopsy** and **400 genes selected by a t-test for blood**.

**Balancing missed rejection against false alarms.** Accuracy alone can hide clinically relevant errors. The selected thresholds favour sensitivity, and the held-out results make the resulting specificity trade-off explicit. The blood model catches most rejection cases but also flags many stable samples.

**Delivering the analysis as an application.** The Shiny interface accepts an expression matrix, checks the required genes, applies saved training statistics and model parameters, and presents downloadable patient-level labels. Model-insight pages explain the data and methodology. Optional editable email templates demonstrate a communication workflow.

## Historical evaluation results

These values are taken from the submitted report and its held-out confusion matrices. **They have not been reproduced by rerunning training or evaluation for this repository publication.** Rejection is the positive class.

| Input | Feature selection | Model | Evaluated samples | Accuracy | Sensitivity | Specificity |
|---|---|---|---:|---:|---:|---:|
| Biopsy | Mutual information, 200 genes | Random Forest | 61 | 0.7705 | 0.9286 | 0.6364 |
| Blood | t-test, 400 genes | XGBoost | 54 | 0.5926 | 0.8571 | 0.3077 |

The biopsy confusion matrix has 26 true positives, 21 true negatives, 2 false negatives, and 12 false positives. The blood matrix has 24 true positives, 8 true negatives, 4 false negatives, and 18 false positives. Thus, the biopsy model missed fewer rejection samples and made fewer false alarms in these evaluation cohorts; these are separate cohorts, not a paired comparison on the same patients.

Stored classification thresholds are **0.3 for biopsy** and **0.4 for blood**; the app predicts `reject` only when the model output is strictly greater than the relevant threshold. Its result table exports class labels, not calibrated clinical risk estimates.

## Run the Shiny demonstration

Use R 4.1 or later and start R from the repository root:

```r
source("setup.R")
shiny::runApp("shinyapp")
```

Select **Blood** or **Biopsy**, upload `shinyapp/examples/eMat_example.csv`, review the matrix, then generate and download predictions. The matrix has genes in rows and sample IDs in columns. The optional contact example uses fictional names and `example.com` addresses.

Prediction and email-template editing/preview do not require service credentials. Email sending is disabled until `BREVO_API_KEY` and `SENDER_EMAIL` are configured. A TinyMCE cloud editor is optional; the default provides a local HTML text editor and preview. See [setup and limitations](docs/SETUP.md).

## Explore the project

| Material | Contents |
|---|---|
| [Final report](reports/final-report.html) | Study motivation, methods, findings, and discussion |
| [Technical appendix](reports/appendix.html) | Detailed analysis and model development |
| [Appendix source](analysis/appendix.qmd) | Quarto analysis source extracted from the submission |
| [Presentation](reports/presentation.pptx) | Group presentation; private embedded demo recording removed |
| [Shiny application](shinyapp/app.R) | Prediction, explanation, downloads, and optional email UI |
| [Saved model assets](shinyapp/models/) | Models, selected genes, normalisation statistics, and thresholds |

The reported training workflow includes batch correction. The deployed prediction path performs gene selection and standardisation with saved means and standard deviations; it does **not** implement a new-upload batch-correction workflow. An arbitrary expression file is therefore not automatically compatible with the original training measurements.

## Team and contribution

This is the work of **Celine, Boyi, Minh, Rishi, Yuanfeng, and Zhiyuan**, DATA3888 Biomed Group 22. Model development, analysis, reporting, and application delivery were group efforts.

Yuanfeng's documented contributions include biopsy data cleaning, feature-selection implementation, initial biopsy models, cross-validation and tuning with Minh, simplification of explanatory diagrams, and the presentation. These contributions should be read in the context of the full team's work, rather than as sole authorship of the project.

## Scope of this release

The submission's pre-trained model assets are preserved. Publication preparation removes private service configuration and deployment metadata, replaces example contact details, adds environment-based optional service settings, and documents setup and historical results. The welcome-page metric summary is aligned with the reported confusion matrices.

No R execution, model retraining, package installation, email delivery, or live deployment was performed during preparation. There is no original dependency lockfile, so compatibility of the archived RDS models with newly installed package versions remains unverified. This application and its inherited communication templates are for research demonstration, not diagnosis or patient-care decisions.

## 中文简介

本项目解决跨研究基因表达数据难以直接合并、基因数量多而样本有限，以及漏检和误报需要权衡的问题。团队完成数据清洗、批次校正、特征选择和五折模型调优，并将结果交付为 Shiny 演示应用。活检分支使用 200 个基因和随机森林，血液分支使用 400 个基因和 XGBoost。历史独立评估中，活检模型在 61 个样本上的准确率为 77.05%、敏感度为 92.86%；血液模型在 54 个样本上的准确率为 59.26%、敏感度为 85.71%。血液模型特异度只有 30.77%，说明误报仍多。这是小组课程研究原型，尚未经过临床验证。
