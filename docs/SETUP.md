# Setup and reproducibility notes

## 1. Install application dependencies

Start R from the repository root. R 4.1 or later is required because the source uses the native `|>` pipe.

```r
source("setup.R")
```

This installs missing packages from CRAN; it does not retrain the models. Package availability and operating-system build requirements may vary. The original submission did not include a dependency lockfile or a recorded compatible package set. In particular, the archived XGBoost and ranger RDS files may need package versions compatible with their original serialisation. Do not interpret the installation helper as a verified reconstruction of the original environment.

## 2. Launch and inspect the sample

```r
shiny::runApp("shinyapp")
```

Shiny runs the application with `shinyapp/` as its working directory, where the relative `models/`, `email/`, and `interface_text/` paths resolve.

1. Open **Risk Prediction**, then **Data Upload**.
2. Choose **Blood** or **Biopsy**.
3. Upload `shinyapp/examples/eMat_example.csv` and inspect the preview.
4. Press **Next** to generate labels and use **Download** for the results CSV.

The bundled expression example contains 23,307 gene rows and seven sample columns. Both model-specific gene lists are present. Every selected gene has saved normalisation statistics and a non-zero saved standard deviation. These are static file checks, not a successful R inference run.

The application selects 400 blood genes or 200 biopsy genes, standardises with saved training means and standard deviations, and loads the corresponding pre-trained RDS model. It applies a strict `>` threshold of 0.4 for blood or 0.3 for biopsy. The input must be a numeric expression matrix compatible with the original training representation, not sequencing reads. The app does not reproduce training-time harmonisation or batch correction for new uploads.

## 3. Optional email configuration

Prediction works without credentials. You can upload the fictional contact example to edit and preview email templates; sending remains disabled without both required settings.

Use `shinyapp/.Renviron.example` as a reference. Place a private `.Renviron` in the repository root before starting R, or configure the equivalent environment variables in your process or hosting environment:

```text
BREVO_API_KEY=
SENDER_EMAIL=
TINYMCE_API_KEY=
```

- `BREVO_API_KEY`: your own Brevo API credential, only needed for sending.
- `SENDER_EMAIL`: your own sender address configured for that service.
- `TINYMCE_API_KEY`: optional TinyMCE cloud editor configuration. It is sent to the browser as part of that editor's script URL; never substitute an unrelated private credential.

Restart R after changing a startup `.Renviron`, or load your private environment configuration before launching the app. The repository ignores `.Renviron`, `secrets.R`, and deployment configuration. No original service credential is included.

Without TinyMCE configuration, the modal uses an HTML text area and a sandboxed preview. Placeholder text such as `{name}` is filled when the optional sending action runs. Without email configuration, both the send control and server-side send action are disabled. No email is sent merely by starting the application or generating predictions.

`examples/patients_example.csv` preserves the expression sample IDs but uses `Example Patient` names and `example.com` addresses. It is for demonstrating the UI; those addresses are not delivery targets. The inherited email workflow is a coursework demonstration and has not been validated for operational use.

## 4. What has and has not been checked

Publication preparation statically checks the archive paths, model/normalisation assets, preserved sample IDs, configuration removal, and unchanged prediction code. Saved model bytes are retained. R was not executed, dependencies were not installed, and neither the email service nor a deployment was contacted.

The README reports historical held-out results: biopsy 61 evaluated samples, accuracy 0.7705, sensitivity 0.9286, specificity 0.6364; blood 54 samples, accuracy 0.5926, sensitivity 0.8571, specificity 0.3077. The original dataset overview mentions 82 samples in the held-out biopsy source cohort; the reported final confusion matrix contains 61 evaluated samples. Use the report and appendix for the analysis cohort definition rather than treating these two counts as interchangeable.

The application shows stored performance summaries, not a fresh evaluation of an uploaded file. It has no clinical validation, and its outputs and inherited communication templates should not be used to make diagnosis or treatment decisions.
