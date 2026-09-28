library(shiny)
library(bslib)
library(shinydashboard)
library(shinyjs)
library(DT)
library(shinyBS)
library(emayili)
library(dplyr)
library(glue)
library(stringr)
library(httr)
library(jsonlite)
library(commonmark)
library(shinyWidgets)
library(xgboost)
library(caret)
library(ranger)

email_template_stable = readLines('email/stable_email.md') |>
  paste(collapse = '\n')
email_template_stable = glue(email_template_stable, .open = '{{', .close = '}}') |> markdown_html()

email_template_reject = readLines('email/reject_email.md') |>
  paste(collapse = '\n')
email_template_reject = glue(email_template_reject, .open = '{{', .close = '}}') |> markdown_html()

welcome_content = readLines('interface_text/welcome_page.md') |> 
  paste(collapse = '\n') |> 
  markdown_html()

user_instructions = readLines('interface_text/user_instructions.md') |> 
  paste(collapse = '\n') |> 
  markdown_html()

model_insights = readLines('interface_text/model_insights_intro.md') |> 
  paste(collapse = '\n') |> 
  markdown_html()

# Optional services are configured through the process environment only.
BREVO_API_KEY <- Sys.getenv("BREVO_API_KEY")
SENDER_EMAIL <- Sys.getenv("SENDER_EMAIL")
TINYMCE_API_KEY <- Sys.getenv("TINYMCE_API_KEY")
email_is_configured <- nzchar(trimws(BREVO_API_KEY)) && nzchar(trimws(SENDER_EMAIL))

send_email_brevo = function(to_email, to_name, subject, html_body) {
    # extract the API key and email address from environment variables
    api_key = BREVO_API_KEY
    from_email = SENDER_EMAIL
    # check if the API key and email address are set
    if (!email_is_configured) {
        stop("Email sending is disabled. Set BREVO_API_KEY and SENDER_EMAIL in the environment.")
    }
    # create email body as a list - expected by brevo's api
    email_data = list(
        sender = list(name = 'DATA3888-Biomed22 Team', email = from_email),
        to = list(list(email = to_email, name = to_name)),
        subject = subject,
        htmlContent = html_body
    )
    # the actual api call to send the email
    res = httr::POST(    # send a POST request to brevo's email endpoint
        url = "https://api.brevo.com/v3/smtp/email",
        httr::add_headers(
            `api-key` = api_key,   # add the api key for authorization
            `Content-Type` = "application/json",   # specify the content type - we are sending JSON
            Accept = "application/json"   # specify the expected response type
        ),
        body = jsonlite::toJSON(email_data, auto_unbox = TRUE),   # convert the email data to JSON
        encode = 'raw'
    )
    return(httr::status_code(res) == 201)
}

blood_model = readRDS('models/blood_model.RDS')
blood_de = read.csv('models/blood_de.csv', header = TRUE, row.names = 1)$x
blood_norm = read.csv('models/blood_normalize.csv', header = TRUE, row.names = 1)
blood_threshold = read.csv('models/blood_threshold.csv', header = TRUE, row.names = 1)[1,1]

biopsy_model = readRDS('models/biopsy_model.RDS')
biopsy_de = read.csv('models/biopsy_de.csv', header = TRUE, row.names = 1)$x
biopsy_norm = read.csv('models/biopsy_normalize.csv', header = TRUE, row.names = 1)
biopsy_threshold = read.csv('models/biopsy_threshold.csv', header = TRUE, row.names = 1)[1,1]

blood_data_text = readLines('interface_text/blood_data.md') |> 
  paste(collapse = '\n') |> 
  markdown_html()

biopsy_data_text = readLines('interface_text/biopsy_data.md') |> 
  paste(collapse = '\n') |> 
  markdown_html()

blood_fs_text = readLines('interface_text/blood_fs.md') |> 
  paste(collapse = '\n') |> 
  markdown_html()

biopsy_fs_text = readLines('interface_text/biopsy_fs.md') |>
  paste(collapse = '\n') |> 
  markdown_html()

blood_model_text = readLines('interface_text/blood_models.md') |> 
  paste(collapse = '\n') |> 
  markdown_html()

biopsy_model_text = readLines('interface_text/biopsy_models.md') |>
  paste(collapse = '\n') |> 
  markdown_html()

ui <- dashboardPage(
    dashboardHeader(title = 'Allograft Rejection Prediction', titleWidth = 270),
    
    dashboardSidebar(
        width = 270,
        useShinyjs(),
        sidebarMenu(
          id = 'menu',
            menuItem("Home", tabName = "home", icon = icon("home")),
            
            menuItem('Risk Prediction', tabName = 'predict', icon = icon('heartbeat'),
                     menuSubItem('User Instructions', tabName = 'pred_instruct', icon = icon('book')),
                     menuSubItem('Data Upload', tabName = 'data_upload', icon = icon('upload')),
                     menuSubItem('Prediction Results', tabName = 'pred_results', icon = icon('check-circle'))),
            
            menuItem('Model Insights', tabName = 'insights', icon = icon('cogs'),
                     menuSubItem('Introduction', tabName = 'model_intro', icon = icon('info-circle')),
                     menuSubItem('Datasets', tabName = 'training_data', icon = icon('table')),
                     menuSubItem('Key Genes for Risk Prediction', tabName = 'feature_selection', icon = icon('wrench')),
                     menuSubItem('Model Construction', tabName = 'model_construction', icon = icon('dna')),
                     menuSubItem('Model Performance', tabName = 'model_performance', icon = icon('bullseye')))
        )
    ),
    
    dashboardBody(
      # set up so that users can modify email contents and formats
      tags$head(
        if (nzchar(TINYMCE_API_KEY)) {
          tags$script(
            src = paste0("https://cdn.tiny.cloud/1/", TINYMCE_API_KEY, "/tinymce/7/tinymce.min.js"),
            referrerpolicy = "origin"
          )
        },
        tags$script(HTML("
                         Shiny.addCustomMessageHandler('initTinyMCE', function(id) {
                            if (typeof tinymce === 'undefined') return;
                           setTimeout(function() {
                             if (tinymce.get(id)) {
                               tinymce.get(id).remove();
                             }
                            tinymce.init({
                              selector: '#' + id,
                              menubar: true,
                              plugins: 'lists link image table code',
                              toolbar: 'undo redo | styles | bold italic underline | alignleft aligncenter alignright | bullist numlist outdent indent | link image | code',
                              setup: function(editor) {
                                editor.on('Change KeyUp', function() {
                                  Shiny.setInputValue(id, editor.getContent());
                                });
                              }
                            });
                         }, 300);
                        });"))
      ),
        # for doctors to predict allograft risk of patients
        tabItems(
            uiOutput('data_switch'),
            # home tab
            tabItem(tabName = 'home',
                    h2('Welcome to the Allograft Rejection Prediction App'),
                    HTML(welcome_content),
                    fluidRow(
                      column(width = 6,
                             actionButton(inputId = 'risk_predict', 
                                          label = 'Risk Prediction', icon = icon('heartbeat'), width = '100%')
                    ),
                      column(width = 6,
                             actionButton(inputId = 'model_insights',
                                          label = 'Model Insights', icon = icon('cogs'), width = '100%'))
            )),
            
            # risk prediction tab
            tabItem(tabName = 'pred_instruct', 
                    h2('User Instructions'),
                    HTML(user_instructions),
                    tags$div(
                      style = "
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                    width: 100%;
                    margin-top: 20px;",
                      actionButton(
                        inputId = "back_from_user_instructions",
                        label = "Home page",
                        icon = icon("arrow-left"),
                        width = "150px",
                        style = "padding: 6px 12px;"
                      ),
                      actionButton(
                        inputId = "next_from_user_instructions",
                        label = "Next",
                        icon = icon("arrow-right"),
                        width = "150px",
                        style = "padding: 6px 12px;"
                      )
                    )
            ),
            
            # tab to upload blood/biopsy result data
            tabItem(
                tabName = 'data_upload', 
                h2('Data Upload'),
                # choose whether to predict allograft risk based on blood test or biopsy
                radioButtons(inputId = 'data_type',
                             label = 'Please choose your test type',
                             choices = c('Blood', 'Biopsy'),
                             selected = character(0)),
                # data upload panel
                ## only allow to upload when the type of test is chosen
                conditionalPanel(
                    condition = "input.data_type == 'Blood' || input.data_type == 'Biopsy'",
                    
                    tags$div(
                        style = "display: flex; align-items: center; gap: 6px;",
                        
                        tags$label("Upload your gene expression data file (CSV format)"),

                        actionLink("matrix_help", NULL,
                                   icon = icon("info-circle"),
                                   style = "color: #6c757d; font-size: 14px; padding-top: 2px;")
                    ),
                    # tooltip for the help icon to describe more in depth what is expected for the input data
                    ## assumed knowledge for doctors, so put in tooltip so that they can refer to it if unsure
                    bsTooltip("matrix_help",
                              title = "Matrix format:<br>• Rows = gene symbols <br>(e.g., TP53)<br>• Columns = patient IDs<br>• First column = gene names<br>• First row = patient IDs.",
                              placement = "right",
                              trigger = "hover focus"),
                    ## place for inputting data file
                    ### only accept csv or text files
                    div(id = 'uploaded_data', fileInput(
                        inputId = 'eMat',
                        label = NULL,
                        accept = c('text/csv', 'text/comma-separated-values,text/plain', '.csv')
                    ),
                    # add a warning
                    HTML('<p style="color: red; font-size: 14px;">
                         Please ensure that your uploaded file is in the correct format before pressing the <strong> Next </strong> button.</p>
                         '),
                    HTML('<p> The correct format is suggested in the icon next to the upload button. Please hover above it for more details</p>')
                    )
                ),
                # print out the input data to confirm
                dataTableOutput('eMat_dt'),
                tags$div(
                  style = "
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                    width: 100%;
                    margin-top: 20px;",
                  actionButton(
                    inputId = "back_from_data_upload",
                    label = "Back",
                    icon = icon("arrow-left"),
                    width = "150px",
                    style = "padding: 6px 12px;"
                  ),
                  actionButton(
                    inputId = "next_from_data_upload",
                    label = "Next",
                    icon = icon("arrow-right"),
                    width = "150px",
                    style = "padding: 6px 12px;",
                    disabled = TRUE
                  )
                )
            ),
            # tab to output prediction results
            tabItem(
                tabName = 'pred_results', 
                h2('Prediction Results'),
                HTML('<p> <li> Select <strong> Results (with Download option) </strong> to view and download the preliminary prediction results.</li> </p>'),
                HTML('<p> <li> Select <strong> Communicate the prediction results with your patients </strong> to send the preliminary predictions to your patients.</li></p>'),
                bsCollapse(
                    id = "pred_results_collapse",
                    multiple = FALSE,
                    open = 'Results (with Download option)',
                    bsCollapsePanel(
                        title = "Results (with Download option)", 
                        p('Please find your patients\' preliminary prediction results below'),
                        # output the prediction results
                        dataTableOutput('pred_dt'),
                        ## a button for doctors to download patients' prediction results
                        downloadButton(outputId = 'download_button',
                                       label = 'Download',
                                       icon = icon('download'),
                                       style = 'background-color: #007bff; color: white; border: none;')
                    ),
                    
                    bsCollapsePanel(
                        title = "Communicate the prediction results with your patients",
                        ## input patients' name and email to send prediction result to
                        tags$label('Upload your patients\' name and email address (CSV format)'),
                        HTML('<p> Please make sure that your uploaded file has <strong> at least 3 columns </strong>:'),
                        HTML('<p> <li> <code>id</code> : patients\' ID in the previously uploaded gene expression data</li></p>'),
                        HTML('<p> <li> <code>name</code> : patients\' full name</li></p>'),
                        HTML('<p> <li> <code>email</code> : patients\' email address</li></p>'),
                        div(
                            id = 'patients_email_wrapper',
                            fileInput(
                                inputId = 'patients_email',
                                label = NULL, 
                                accept = c('text/csv', 'text/comma-separated-values,text/plain', '.csv')
                            )
                        ),
                        dataTableOutput('patients_dt'),
                        tags$hr(),
                        uiOutput('send_email_ui'))
                        ),
                tags$div(
                  style = "
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                    width: 100%;
                    margin-top: 20px;",
                  actionButton(
                    inputId = "back_from_pred_results",
                    label = "Back",
                    icon = icon("arrow-left"),
                    width = "150px",
                    style = "padding: 6px 12px;"
                  ),
                  actionButton(
                    inputId = "next_from_pred_results",
                    label = "Model Insights",
                    icon = icon("arrow-right"),
                    width = "150px",
                    style = "padding: 6px 12px;"
                  )
                )),
            tabItem(
                tabName = 'model_intro',
                h2('Model Introduction'),
                HTML(model_insights),
                tags$div(
                  style = "
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                    width: 100%;
                    margin-top: 20px;",
                  actionButton(
                    inputId = "back_from_model_intro",
                    label = "Home page",
                    icon = icon("arrow-left"),
                    width = "150px",
                    style = "padding: 6px 12px;"
                  ),
                  actionButton(
                    inputId = "next_from_model_intro",
                    label = "Next",
                    icon = icon("arrow-right"),
                    width = "150px",
                    style = "padding: 6px 12px;"
                  )
                )
            ),
            tabItem(
                tabName = 'training_data',
                h2('Dataset'),
                conditionalPanel(condition = 'input.data_switch == true',
                                 HTML(blood_data_text),
                                 tags$img(src = 'blood_dataset.png', width = '100%')),
                conditionalPanel(condition = 'input.data_switch == false',
                                 HTML(biopsy_data_text),
                                 tags$img(src = 'biopsy_dataset.png', width = '100%')),
                tags$div(
                  style = "
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                    width: 100%;
                    margin-top: 20px;",
                  actionButton(
                    inputId = "back_from_training_data",
                    label = "Back",
                    icon = icon("arrow-left"),
                    width = "150px",
                    style = "padding: 6px 12px;"
                  ),
                  actionButton(
                    inputId = "next_from_training_data",
                    label = "Next",
                    icon = icon("arrow-right"),
                    width = "150px",
                    style = "padding: 6px 12px;"
                  )
                )
            ),
            tabItem(
              tabName = 'model_construction',
              h2('Model Construction'),
              conditionalPanel(
                condition = 'input.data_switch == true',
                HTML(blood_model_text),
                tags$img(src = 'blood_models.png', width = '100%')),
              conditionalPanel(
                condition = 'input.data_switch == false',
                HTML(biopsy_model_text),
                tags$img(src = 'biopsy_models.png', width = '100%')),
              tags$div(
                style = "
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                    width: 100%;
                    margin-top: 20px;",
                actionButton(
                  inputId = "back_from_model_construction",
                  label = "Back",
                  icon = icon("arrow-left"),
                  width = "150px",
                  style = "padding: 6px 12px;"
                ),
                actionButton(
                  inputId = "next_from_model_construction",
                  label = "Next",
                  icon = icon("arrow-right"),
                  width = "150px",
                  style = "padding: 6px 12px;"
                )
              )
            ),
            tabItem(
                tabName = 'feature_selection',
                h2('Key Genes for Risk Prediction'),
                conditionalPanel(
                  condition = 'input.data_switch == true',
                  HTML(blood_fs_text),
                  tags$img(src = 'blood_feature_selection.png', width = '100%'),
                  HTML('The following table shows the <b>50 key genes</b> selected for the blood test model.'),
                  dataTableOutput('blood_de')
                ),
                conditionalPanel(
                  condition = 'input.data_switch == false',
                  HTML(biopsy_fs_text),
                  tags$img(src = 'biopsy_feature_selection.png', width = '100%'),
                  HTML('The following table shows the <b>50 key genes</b> selected for the biopsy test model.'),
                  dataTableOutput('biopsy_de')
                  ),
                tags$div(
                  style = "
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                    width: 100%;
                    margin-top: 20px;",
                  actionButton(
                    inputId = "back_from_feature_selection",
                    label = "Back",
                    icon = icon("arrow-left"),
                    width = "150px",
                    style = "padding: 6px 12px;"
                  ),
                  actionButton(
                    inputId = "next_from_feature_selection",
                    label = "Next",
                    icon = icon("arrow-right"),
                    width = "150px",
                    style = "padding: 6px 12px;"
                  )
                )
            ),
            tabItem(
                tabName = 'model_performance',
                h2('Model Performance'),
                conditionalPanel(
                  condition = 'input.data_switch == true',
                  dataTableOutput('blood_confmat'),
                  tags$br(),
                  uiOutput('blood_perf')
                ),
                conditionalPanel(
                  condition = 'input.data_switch == false',
                  dataTableOutput('biopsy_confmat'),
                  tags$br(),
                  uiOutput('biopsy_perf')
                ),
                tags$div(
                  style = "
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                    width: 100%;
                    margin-top: 20px;",
                  actionButton(
                    inputId = "back_from_model_performance",
                    label = "Back",
                    icon = icon("arrow-left"),
                    width = "150px",
                    style = "padding: 6px 12px;"
                  ),
                  actionButton(
                    inputId = "next_from_model_performance",
                    label = "Risk Prediction",
                    icon = icon("arrow-right"),
                    width = "150px",
                    style = "padding: 6px 12px;"
                  )
                )
            )
        )
    )
)

server <- function(input, output, session) {
    patients_data = reactiveVal(NULL)
    pred_result = reactiveVal(NULL)
    valid_patients_input = reactiveVal(FALSE)
    sent_data = reactiveValues(data = NULL)
    switch_blood = reactiveVal(TRUE)
    eMat_data = reactiveVal(NULL)
    is_blood = reactive({
      req(input$data_type)
      input$data_type == 'Blood'
    })
    email_data = reactive({
        req(patients_data())
        req(pred_result())
        merge(patients_data(), pred_result(), by = 'id', all.x = TRUE, all.y = TRUE)
    })
    stable_email = reactive({
        req(input$email_content_stable)
        input$email_content_stable
    })
    reject_email = reactive({
      req(input$email_content_reject)
      input$email_content_reject
    })
    
    # change tabset from the welcome page
    # to risk prediction page
    observeEvent(input$risk_predict, {
        updateTabItems(session, 'menu', selected = 'pred_instruct')
    })
    
    # to model insights page
    observeEvent(input$model_insights, {
        updateTabItems(session, 'menu', selected = 'model_intro')
    })
    
    # navigate to next page from user instructions tab
    observeEvent(input$next_from_user_instructions, {
        req(input$next_from_user_instructions)
        updateTabItems(session, 'menu', selected = 'data_upload')
    })
    
    # navigate back to the home page from user instructions tab
    observeEvent(input$back_from_user_instructions, {
        req(input$back_from_user_instructions)
        updateTabItems(session, 'menu', selected = 'home')
    })
    
    # if users re-enter data type information, all other information and the corresponding value would be reset
    observeEvent(input$data_type, {
        req(input$data_type)
        reset('uploaded_data')
        reset('patients_email_wrapper')
        patients_data(NULL)
        valid_patients_input(FALSE)
        eMat_data(NULL)
        sent_data$data = NULL
    })
    
    # each time the input eMat file is re-entered, the value of eMat_data would be updated accordingly
    # for later use in the server
    observeEvent(input$eMat, {
        req(input$eMat)
        df = read.csv(input$eMat$datapath, header = TRUE, row.names = 1)
        eMat_data(df)
        patients_data(NULL)
        valid_patients_input(FALSE)
        sent_data$data = NULL
    })
    
    # enable the next button only if the input eMat file is uploaded
    observeEvent(input$eMat,{
        req(input$eMat)
        if (is.null(input$eMat)) {
          updateActionButton(inputId = 'next_from_data_upload', disabled = TRUE)
        }
        else {
          showModal(modalDialog(title = 'Data uploaded successfully!',
                                  easyClose = TRUE,
                                  HTML('We have printed out the first few rows and columns of your input data. Please make sure that you have upload the correct file before pressing the <b> Next </b> button to confirm and generate predictions.')))
          updateActionButton(inputId = 'next_from_data_upload', disabled = FALSE)
        }
    })
    
    # output the input eMat as a data table
    output$eMat_dt = renderDataTable({
        req(eMat_data())
        datatable(head(eMat_data()), rownames = TRUE)
    })
    
    # navigate to the prediction tab after the next button is clicked on the data upload tab
    observeEvent(input$next_from_data_upload, {
      req(input$next_from_data_upload)
      req(eMat_data())
      req(input$data_type)
      if (is_blood()) {
        if (length(intersect(blood_de, rownames(eMat_data()))) != length(blood_de)) {
          not_included = blood_de[!blood_de %in% rownames(eMat_data())]
          gene_string = paste(not_included, collapse = ", ")
          showModal(modalDialog(
            title = 'Error',
            HTML(paste0("The uploaded data does not contain all the required genes for the blood test model. 
                 Please ensure that your data contains the following genes: <b>", gene_string,"</b>")),
            easyClose = FALSE
          ))
          return(NULL)
        }
        # feature selection
        blood_norm_de = blood_norm[blood_de,]
        eMat_de = eMat_data()[blood_de,]
        # normalize
        eMat_normed = eMat_de[match(rownames(eMat_de), rownames(blood_norm_de)),] |> 
          sweep(1, blood_norm_de$mean, '-') |> 
          sweep(1, blood_norm_de$sd, '/')
         dtest = xgb.DMatrix(data = t(eMat_normed))
         pred_prob = predict(blood_model, dtest)
         pred_class = ifelse(pred_prob > blood_threshold, 'reject', 'stable') |> 
           factor(levels = c('stable', 'reject'))
      }
      else {
        if (length(intersect(biopsy_de, rownames(eMat_data()))) != length(biopsy_de)) {
          not_included = biopsy_de[!biopsy_de %in% rownames(eMat_data())]
          gene_string = paste(not_included, collapse = ", ")
          showModal(modalDialog(
            title = 'Error',
            HTML(paste0("The uploaded data does not contain all the required genes for the blood test model. 
                 Please ensure that your data contains the following genes: <b>", gene_string,"</b>")),
            easyClose = FALSE
          ))
          return(NULL)
        }
        # feature selection
        biopsy_norm_de = biopsy_norm[biopsy_de,]
        eMat_de = eMat_data()[biopsy_de,]
        # normalize
        eMat_normed = eMat_de[match(rownames(eMat_de), rownames(biopsy_norm_de)),] |> 
          sweep(1, biopsy_norm_de$mean, '-') |> 
          sweep(1, biopsy_norm_de$sd, '/')
        pred_prob = predict(biopsy_model, eMat_normed |> t() |> data.frame(), 
                            type = 'response')$predictions[,'reject']
        pred_class = ifelse(pred_prob > biopsy_threshold, 'reject', 'stable') |> 
          factor(levels = c('stable', 'reject'))
      }
      pred_df = data.frame(`id` = colnames(eMat_data()),
                            `pred` = pred_class)
      pred_result(pred_df)
      updateTabItems(session, 'menu', selected = 'pred_results')
    })
    
    # navigate back to the user instructions tab from the data upload tab
    observeEvent(input$back_from_data_upload, {
        req(input$back_from_data_upload)
        updateTabItems(session, 'menu', selected = 'pred_instruct')
    })
    
    # each time the patients email file is re-entered, the value of patients_data would be updated accordingly
    ## for later use in the server
    observeEvent(input$patients_email, {
        req(input$patients_email)
        df = read.csv(input$patients_email$datapath, header = TRUE)
        patients_data(df)
        valid_patients_input(FALSE)
        sent_data$data = NULL
    })
    
    # detect some fatal errors in patients email input
    observeEvent(patients_data(), {
        req(patients_data())
        id = 'id' %in% colnames(patients_data())
        name = 'name' %in% colnames(patients_data())
        email = 'email' %in% colnames(patients_data())
        if (ncol(patients_data()) < 3) {
            showModal(modalDialog(
                title = 'Error',
                HTML("Your CSV file contains too little information. 
                     For the task to run smoothly, please ensure that your file has at least 3 columns called <b>id</b>, 
                     <b>name</b>, and <b>email</b>, indicating each patient's ID, full name, and email address, respectively"),
                easyClose = FALSE
            ))
            valid_patients_input(FALSE)
        }
        else if (id == FALSE & name == FALSE & email == FALSE) {
            showModal(modalDialog(
                title = 'Error',
                HTML("The columns <b>id</b>, <b>name</b>, and <b>email</b> could not be found in your CSV file"),
                easyClose = FALSE
            ))
            valid_patients_input(FALSE)
        }
        else if (id == FALSE & name == FALSE) {
            showModal(modalDialog(
                title = 'Error',
                HTML("The columns <b>id</b> and <b>name</b> could not be found in your CSV file"),
                easyClose = FALSE
            ))
            valid_patients_input(FALSE)
        }
        else if (id == FALSE & email == FALSE) {
            showModal(modalDialog(
                title = 'Error',
                HTML("The columns <b>id</b> and <b>email</b> could not be found in your CSV file"),
                easyClose = FALSE
            ))
            valid_patients_input(FALSE)
        }
        else if (name == FALSE & email == FALSE) {
            showModal(modalDialog(
                title = 'Error',
                HTML("The columns <b>name</b> and <b>email</b> could not be found in your CSV file"),
                easyClose = FALSE
            ))
            valid_patients_input(FALSE)
        }
        else if (id == FALSE) {
            showModal(modalDialog(
                title = 'Error',
                HTML("The columns <b>id</b> could not be found in your CSV file"),
                easyClose = FALSE
            ))
            valid_patients_input(FALSE)
        }
        else if (name == FALSE) {
            showModal(modalDialog(
                title = 'Error',
                HTML("The columns <b>name</b> could not be found in your CSV file"),
                easyClose = FALSE
            ))
            valid_patients_input(FALSE)
        }
        else if (email == FALSE) {
            showModal(modalDialog(
                title = 'Error',
                HTML('The columns <b>email</b> could not be found in your CSV file'),
                easyClose = FALSE
            ))
            valid_patients_input(FALSE)
        }
        else {
            valid_patients_input(TRUE)
        }
    })
    
    # output data table for prediction results
    output$pred_dt = renderDataTable({
      req(pred_result())
      datatable(pred_result() |> arrange(desc(pred)), rownames = TRUE, 
                colnames = c('Patient ID', 'Preliminary Prediction')) |> 
        formatStyle(
          columns = 1:ncol(pred_result()),
          valueColumns = 'pred',
          backgroundColor = styleEqual(
            c('stable', 'reject'),
            c('#d4edda', '#f8d7da')
          )
        )
    })
    
    # enable email sending only if patients' information have been provided
    observeEvent(valid_patients_input(), {
        req(input$patients_email)
        if (valid_patients_input()) {
            updateActionButton(inputId = 'send_button', disabled = FALSE)
        }
        else {
            updateActionButton(inputId = 'send_button', disabled = TRUE)
        }
        df1 = read.csv(input$patients_email$datapath, header = TRUE)
        patients_data(df1)
        df2 = email_data()
        df2$send_status = ifelse(complete.cases(df2), 'Pending', 'Not applicable')
        sent_data$data = df2
    })
    
    # output the input patients info as a data table
    output$patients_dt = renderDataTable({
        req(sent_data$data)
        datatable(sent_data$data, rownames = TRUE) |> 
          formatStyle(
            columns = 1:ncol(sent_data$data),
            valueColumns = 'send_status',
            backgroundColor = styleEqual(
              c('Sent', 'Failed', 'Pending', 'Not applicable'),
              c('#d4edda', '#f8d7da', '#fff3cd', '#f8d7da')
            )
          )
    })
    
    # ui output for users to send the email via clicking the button
    output$send_email_ui = renderUI({
        req(patients_data())
        tagList(
          if (!email_is_configured) {
            p('Email sending is disabled. You can still edit and preview the templates.')
          },
          actionButton(
            inputId = 'send_button',
            label = 'Edit / preview email',
            icon = icon('envelope'),
            width = '100%',
            disabled = !valid_patients_input())
        )
    })
    
    # show modal for users to confirm the email content
    observeEvent(input$send_button, {
      req(input$send_button)
      req(sent_data$data)
      showModal(modalDialog(
        title = 'Edit and preview email templates',
        size = 'l',
        easyClose = TRUE,
        if (!nzchar(TINYMCE_API_KEY)) {
          p('Edit the HTML text below. The preview updates as you edit; {name} is filled when sending.')
        },
        if (!email_is_configured) {
          p('Sending is disabled because BREVO_API_KEY and SENDER_EMAIL are not configured.')
        },
        tabsetPanel(
          tabPanel('For Stable Patients',
                   textAreaInput('email_content_stable', 'Edit your email', 
                                 width = '100%', height = '400px', value = email_template_stable),
                   session$sendCustomMessage('initTinyMCE', 'email_content_stable'),
                    h4('Preview'), uiOutput('stable_email_preview')),
          tabPanel('For Rejected Patients',
                   textAreaInput('email_content_reject', 'Edit your email',
                                 width = '100%', height = '400px', value = email_template_reject),
                   session$sendCustomMessage('initTinyMCE', 'email_content_reject'),
                    h4('Preview'), uiOutput('reject_email_preview'))
        ),
        footer = tagList(
          modalButton('Cancel'),
          actionButton('send_confirmed', 'Send', icon = icon('paper-plane'),
                       disabled = !email_is_configured, 
                       style = 'background-color: #007bff; color: white; border: none;')
        )
      ))
      session$sendCustomMessage('initTinyMCE', 'email_content_stable')
      session$sendCustomMessage('initTinyMCE', 'email_content_reject')
    })
    
    # Sandboxed previews remain available without a cloud editor or email credentials.
    output$stable_email_preview = renderUI({
      req(input$email_content_stable)
      tags$iframe(srcdoc = input$email_content_stable, sandbox = "",
                  title = "Stable email preview", style = "width: 100%; height: 350px; border: 1px solid #ddd;")
    })
    output$reject_email_preview = renderUI({
      req(input$email_content_reject)
      tags$iframe(srcdoc = input$email_content_reject, sandbox = "",
                  title = "Rejection email preview", style = "width: 100%; height: 350px; border: 1px solid #ddd;")
    })

    # send the email to patients
    observeEvent(input$send_confirmed, {
        req(input$send_confirmed)
        if (!email_is_configured) {
          showNotification('Email sending is disabled. Configure BREVO_API_KEY and SENDER_EMAIL first.', type = 'error')
          return(NULL)
        }
        req(sent_data$data)
        req(stable_email())
        req(reject_email())
        updateActionButton(inputId = 'send_button', label = 'Sent', icon = icon('check'), disabled = TRUE)
        template = ifelse(email_data()$pred == 'stable', 
                          stable_email(), 
                          reject_email())
        customized_email = character(length = length(template))
        for (i in 1:length(template)) {
            customized_email[i] = glue(template[i], 
                                       name = email_data()$name[i],
                                       pred = email_data()$pred[i], 
                                       conf_percent = email_data()$conf_percent[i])
        }
        for (i in 1:nrow(sent_data$data)) {
            status = send_email_brevo(
                    to_email = email_data()$email[i],
                    to_name = email_data()$name[i],
                    subject = 'Your Preliminary Kidney Transplant Risk Prediction',
                    html_body = (customized_email[i])
                )
            sent_data$data$send_status[i] = ifelse(status == TRUE, 'Sent', 'Failed')
            sent_data$data = sent_data$data
            Sys.sleep(0.3)
        }
        showModal(modalDialog(
            title = 'Success',
            'The emails have been sent. You can now check the sending status in the displayed table',
            easyClose = TRUE
        ))
    })
    
    # download prediction when the download button is clicked
    output$download_button = downloadHandler(
      filename = function() {
        paste0('prediction_results_', Sys.Date(), '.csv')},
      content = function(file) {
        write.csv(pred_result(), file = file, row.names = FALSE)})
    
    # navigate back to the data upload page from the prediction results tab
    observeEvent(input$back_from_pred_results, {
        req(input$back_from_pred_results)
        updateTabItems(session, 'menu', selected = 'data_upload')
    })
    
    # navigate to the model insights page from the prediction results tab
    observeEvent(input$next_from_pred_results, {
        req(input$next_from_pred_results)
        updateTabItems(session, 'menu', selected = 'model_intro')
    })
    
    # navigate to the model insights data training page from the model insights tab
    observeEvent(input$next_from_model_intro, {
        req(input$next_from_model_intro)
        updateTabItems(session, 'menu', selected = 'training_data')
    })
    
    # navigate back to welcome page from the model insights tab
    observeEvent(input$back_from_model_intro, {
        req(input$back_from_model_intro)
        updateTabItems(session, 'menu', selected = 'home')
    })
    
    # navigate to feature selection from training data tab
    observeEvent(input$next_from_training_data, {
        req(input$next_from_training_data)
        updateTabItems(session, 'menu', selected = 'feature_selection')
    })
    
    # navigate back to model intro from training data tab
    observeEvent(input$back_from_training_data, {
        req(input$back_from_training_data)
        updateTabItems(session, 'menu', selected = 'model_intro')
    })
    
    # navigate to model construction from feature selection tab
    observeEvent(input$next_from_feature_selection, {
        req(input$next_from_feature_selection)
        updateTabItems(session, 'menu', selected = 'model_construction')
    })
    
    # navigate back to training data from feature selection tab
    observeEvent(input$back_from_feature_selection, {
        req(input$back_from_feature_selection)
        updateTabItems(session, 'menu', selected = 'training_data')
    })
    
    # navigate to model performance from model construction tab
    observeEvent(input$next_from_model_construction, {
        req(input$next_from_model_construction)
        updateTabItems(session, 'menu', selected = 'model_performance')
    })
    
    # navigate back to feature selection from model construction tab
    observeEvent(input$back_from_model_construction, {
        req(input$back_from_model_construction)
        updateTabItems(session, 'menu', selected = 'feature_selection')
    })
    
    # navigate back to model construction from model performance tab
    observeEvent(input$back_from_model_performance, {
        req(input$back_from_model_performance)
        updateTabItems(session, 'menu', selected = 'model_construction')
    })
    
    # navigate to risk prediction from model performance tab
    observeEvent(input$next_from_model_performance, {
        req(input$next_from_model_performance)
        updateTabItems(session, 'menu', selected = 'pred_instruct')
    })
    
    # data switch input in model insights tabs
    output$data_switch = renderUI({
      req(input$menu)
      if(input$menu %in% c('training_data', 'feature_selection', 'model_construction', 'model_performance')) {
        tagList(
          tags$div(
            style = 'display: flex; align-items: centerl; gap: 6px',
            actionLink('data_switch_help', NULL,
                       icon = icon('info-circle'),
                       style = 'color: #6c757d; font-size: 14px; margin-top: 5px'),
            switchInput(inputId = 'data_switch', label = NULL,
                        onLabel = 'Blood', offLabel = 'Biopsy', size = 'small', value = switch_blood())
          ),
          bsTooltip('data_switch_help',
                    title = 'Click to switch between different sample sources <br><em>(Blood ↔ Biopsy).</em></br>',
                    placement = 'right', trigger = 'hover focus')
        )
      }
    })
    
    # set value for switch input for consistency
    observeEvent(input$data_switch, {
      switch_blood(input$data_switch)
    })
    # data table of top predictive genes for blood
    output$blood_de = renderDataTable({
      req(blood_de)
      blood_dt = data.frame(gene = blood_de)
      datatable(blood_dt |> head(50), rownames = TRUE, 
                colnames = c('Predictive Genes'))
    })
    
    # data table of top predictive genes for biopsy
    output$biopsy_de = renderDataTable({
      req(biopsy_de)
      biopsy_dt = data.frame(gene = biopsy_de)
      datatable(biopsy_dt |> head(50), rownames = TRUE,
                colnames = c('Predictive Genes'))
    })
    
    # confusion matrix for blood data
    output$blood_perf = renderUI({
        HTML("
    • The model makes correct predictions for <b>about 59%</b> of patients.<br>
    • It successfully identifies <b>86%</b> of patients who are actually experiencing kidney rejection.<br>
    • It is better at detecting rejection than confirming stability.<br>
    • These results are based on testing the model on new, unseen patient data, providing a realistic estimate of how the model may perform in practice.
  ")
      
    })
    
    output$blood_confmat = renderDataTable({
      df = data.frame(
        `Actual Stable` = c(8, 18),
        `Actual Reject` = c(4, 24)
      )
      rownames(df) = c("Predicted Stable", "Predicted Reject")
      colnames(df) = c('Actual Stable', 'Actual Reject')
      datatable(df, options = list(
        dom = 't',
        ordering = FALSE,
        pageLength = 2
      )) |> 
        formatStyle(
          columns = names(df),
          target = 'cell',
          border = '1px solid black'
        ) |> 
        formatStyle(
          columns = 0,
          target = 'row',
          border = '1px solid black'
        )
    })
    
    # model evaluation for biopsy
    output$biopsy_perf = renderUI({
      HTML("
    • The model makes correct predictions for <b>about 77%</b> of patients.<br>
    • It successfully identifies <b>93%</b> of patients who are actually experiencing kidney rejection.<br>
    • It is better at detecting rejection than confirming stability.<br>
    • These results are based on testing the model on new, unseen patient data, providing a realistic estimate of how the model may perform in practice.
  ")
    })
    
    output$biopsy_confmat = renderDataTable({
      df = data.frame(
        `Actual Stable` = c(21, 12),
        `Actual Reject` = c(2, 26)
      )
      rownames(df) = c("Predicted Stable", "Predicted Reject")
      colnames(df) = c('Actual Stable', 'Actual Reject')
      datatable(df, options = list(
        dom = 't',
        ordering = FALSE,
        pageLength = 2
      )) |> 
        formatStyle(
          columns = names(df),
          target = 'cell',
          border = '1px solid black'
        ) |> 
        formatStyle(
          columns = 0,
          target = 'row',
          border = '1px solid black'
        )
    })
}
# run the shiny app
shinyApp(ui = ui, server = server)