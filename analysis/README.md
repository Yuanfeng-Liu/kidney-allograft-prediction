# Analysis source

These Quarto files were extracted from the source embedded in the submitted HTML reports:

- `appendix.qmd`: data cleaning and merging, batch correction, feature selection, cross-validation, model tuning, and held-out evaluation.
- `final-report.qmd`: the study's main findings, figures, discussion, and team contributions.

The rendered versions are in [reports/](../reports/) and can be read without running R.

## Rerunning the analysis

The files preserve the submitted analysis, including some original data paths and working-directory assumptions. In `final-report.qmd`, the two screenshot paths now point to `../assets/`, and saved report objects are read from `../reports/`.

To run the analysis, you will need Quarto, the R packages used in each section (including Bioconductor packages), and the referenced GEO data and intermediate files. The appendix uses `GEOquery::getGEO` to download public study data; downloads and model fitting can take considerable time.

The submission did not include a package lockfile or all intermediate inputs. Check the file paths and dependencies before running sections or rendering a report. The root `setup.R` installs Shiny application dependencies only. Training and report computation have not been rerun for this public version.
