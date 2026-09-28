# Setup notes

## Start the application

Use R 4.1 or later and start R from the repository root:

```r
source("setup.R")
shiny::runApp("shinyapp")
```

`setup.R` installs missing application packages from CRAN. It does not train models or install all packages needed for the analysis. Shiny runs the app from `shinyapp/`, where its relative paths to models, templates, and interface text resolve.

The original submission has no dependency lockfile. The saved XGBoost and ranger models may require package versions compatible with their original RDS files. Installation and inference have not been tested for this public version, so the setup script does not guarantee a working environment on every machine.

## Try the example data

1. Open **Risk Prediction**, then **Data Upload**.
2. Choose **Blood** or **Biopsy**.
3. Upload `shinyapp/examples/eMat_example.csv` and inspect the preview.
4. Press **Next** to generate labels, then **Download** to save the results CSV.

The example contains 23,307 gene rows and seven sample columns, including the genes required by both models. The app selects 400 genes for blood or 200 for biopsy and standardises them with saved training means and standard deviations. Model outputs strictly above **0.4 for blood** or **0.3 for biopsy** receive the `reject` label; the rest receive `stable`.

Use a numeric expression matrix compatible with the training measurements, not raw sequencing reads. The app does not perform the training analysis's harmonisation or batch correction on new uploads. Its performance summaries come from the submitted evaluation, not from a fresh evaluation of the uploaded file.

## Optional email features

Prediction and template preview need no service credentials. To try the contact-upload interface, use `shinyapp/examples/patients_example.csv`, which contains fictional names and `example.com` addresses matching the expression sample IDs.

Sending is disabled until you supply both a Brevo API key and a sender address. Use `shinyapp/.Renviron.example` as a reference and place your private `.Renviron` in the repository root before starting R, or set these variables in your process or hosting environment:

```text
BREVO_API_KEY=
SENDER_EMAIL=
TINYMCE_API_KEY=
```

- `BREVO_API_KEY`: your Brevo sending credential.
- `SENDER_EMAIL`: a sender address configured for that service.
- `TINYMCE_API_KEY`: optional configuration for the cloud text editor. This value is included in a browser script URL; use a TinyMCE key only.

Restart R after changing `.Renviron`. The repository ignores `.Renviron`, `secrets.R`, and deployment configuration.

Without TinyMCE, the app provides an HTML text area and preview. Placeholders such as `{name}` are filled during the sending action. Starting the app or generating predictions does not send email. The example addresses are for previewing the interface, not for delivery.

## Results and limitations

The saved models and reported results come from the original coursework submission. File checks confirmed that the example includes the selected genes and that their saved normalisation statistics have non-zero standard deviations. These checks do not establish runtime compatibility; R inference, email delivery, and deployment have not been tested for this public version.

The biopsy source-cohort overview lists 82 samples, while its final confusion matrix contains 61 evaluated samples. The blood confusion matrix contains 54. The README uses those final evaluation counts and derives its metrics from the matrices; the report and appendix provide the surrounding analysis.

The application is a research demonstration without clinical validation. Its labels and inherited email templates are not intended for diagnosis or treatment decisions. See [analysis/README.md](../analysis/README.md) for what is needed to rerun the analysis.
