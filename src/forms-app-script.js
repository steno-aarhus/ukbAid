/*
  This is actually a Google Script, not JavaScript. But RStudio has syntax
  highlighting for JS, so will keep the extension to be JS for now.

  The code here is only kept to be tracked by Git. It should be copied to
  the Google Form's/Sheet's App Script Editor in order for it to be connected
  and used for the specific Sheet.

  You will need to replace the `gh_token` with the actual token that you create
  on GitHub, preferably using the new token format that has specific permissions.

  This code will create a new Issue in the ukbAid repo whenever a new project
  proposal is submitted through the Form.

*/
var gh_token = "YOUR_PERSONAL_ACCESS_TOKEN";
var handle = "steno-aarhus"
var repo = "ukbAid"

function onFormSubmit(event) {

  var responses = event.response.getItemResponses();
  var full_name = responses[2].getResponse();
  var github_user = responses[3].getResponse();
  var job_position = responses[5].getResponse();
  var phd_supervisor = responses[6].getResponse();
  var affiliation = responses[7].getResponse();
  var project_title = responses[8].getResponse();
  var project_abbrev = responses[9].getResponse();
  var project_description = responses[10].getResponse();

  var issue_title = "Proposal: " + project_title;

    "\n- **Position**:" + job_position +
    "\n- **Supervisor (if PhD student)**:" + phd_supervisor +
    "\n- **Affiliation**:" + affiliation +
  var issue_body =
    "- **Submitted By**: " + full_name + " (@" + github_user + ")" +
    "\n\n## Project description" +
    "\n\n" + project_title + " (" + project_abbrev + ")" +
    "\n\n" + project_description +
    "\n\n"

  var issue_contents = {
    "title": issue_title,
    "body": issue_body,
    "labels": [
      "proposal"
     ]
  };

  var issue_creation_commands = {
    "method": "POST",
    // Header is used to send the token as authentication.
    "headers": {
      "authorization": "token " + gh_token,
      "Accept": "application/vnd.github.v3+json",
    },
    "contentType": "application/json",
    "payload": JSON.stringify(issue_contents)
    };

  Logger.log(issue_contents)

  var response = UrlFetchApp.fetch("https://api.github.com/repos/" + handle + "/" + repo + "/issues", issue_creation_commands);
}
