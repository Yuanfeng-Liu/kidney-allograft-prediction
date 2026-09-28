Thank you for using our **Allograft Rejection Prediction** app — a clinical decision support tool designed to assist in the early identification of kidney allograft rejection risk.

This app uses statistical models to help predict the **risk of kidney allograft rejection** based on **gene expression data**. You can insert either the **blood** or **biopsy** data of your patients for predictions, depending on the availability of data.

Based on experimental testing, biopsy data has shown higher predictive accuracy than blood data, though it is also more invasive and less frequently collected.

⚠️ **Disclaimer**

This tool is intended for research and clinical support purposes only. It does not replace diagnostic procedures and should only be used as a preliminary reference by qualified clinicians. We suggest using this application to take note of the patients that need close monitor.

This model was constructed through:

-   A merged set of different blood and biopsy datasets obtained from **Gene Expression Omnibus** with batch correction

-   The determinant genes were selected through **T-test** for blood data and **Mutual Information** for biopsy data

-   The chosen modelling method was **XGBoost** and **Random Forest** for blood and biopsy result, respectively

✅ **Historical held-out model performance**

-   Predictions from blood result are accurate **59.3%** of the time, and the model correctly identifies patients with kidney allograft rejection in **86%** of cases

-   Predictions from biopsy result are accurate approximately **77.0%** of the time, correctly identifying patients with kidney allograft rejection in **93%** of cases

*(**Note**: These results come from testing the model on a separate group of patients that were not used when building the model. While they give us a good indication of how the model might perform in practice, they should not be taken as a guarantee of accuracy in every case)*

To explore more about the model's methodology and evaluation results, visit the **Model Insights** tab.

To generate patient-level predictions, go to the **Risk Prediction** tab and follow the guided steps.

All tabs are accessible via the sidebar menu.
