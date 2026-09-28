# Analysis source recovered from the submission

The original ZIP contains rendered HTML documents with embedded Quarto source. `appendix.qmd` and `final-report.qmd` recover that source so readers can inspect the analysis without searching through HTML markup.

The appendix covers data cleaning and merging, batch correction, feature selection, cross-validation, model tuning, and held-out evaluation for blood and biopsy inputs. The source is an archive of the submitted analysis, not a newly executed pipeline.

`final-report.qmd` has its two screenshot references redirected to the matching files in `../assets/`, and its saved report objects redirected to `../reports/`. Other analysis code retains its original data and working-directory assumptions.

The Shiny `setup.R` installs application dependencies only. Rerunning the analysis also requires Quarto, analysis packages including Bioconductor packages, the GEO data, and intermediate files referenced by the source. The submission does not provide a version lock or all intermediate analysis inputs. Inspect and reconstruct those dependencies before running individual sections; do not expect a clean-machine render to reproduce training automatically.

The pre-rendered reports remain available in `../reports/` without running the analysis. No model training or report computation was rerun during publication preparation.

The appendix obtains public study data with `GEOquery::getGEO`. Running it can download substantial data and perform lengthy model fitting. Its saved-output paths are inherited from the original working directory, while the recovered final report reads the bundled files under `reports/`; align those paths before rebuilding.
