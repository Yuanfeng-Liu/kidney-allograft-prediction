send_email_brevo = function(to_email, to_name, subject, html_body) {
  library(httr)   # used to send HTTP POST request
  library(jsonlite)   # used to convert R objects into JSON
  # extract the API key and email address from environment variables
  api_key = Sys.getenv("BREVO_API_KEY")
  from_email = Sys.getenv("SENDER_EMAIL")
  if (!nzchar(trimws(api_key)) || !nzchar(trimws(from_email))) {
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
      `Accept` = "application/json"   # specify the expected response type
    ),
    body = jsonlite::toJSON(email_data, auto_unbox = TRUE)   # convert the email data to JSON
  )
  if (httr::status_code(res) == 201) {
    message("✅ Email sent to ", to_email)
    return(TRUE)
  } else {
    warning("❌ Failed to send to ", to_email, ": ", httr::content(res, as = "text"))
    return(FALSE)
  }
}