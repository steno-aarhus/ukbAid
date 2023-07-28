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
var owner = "steno-aarhus"
var repo = "ukbAid"
var workflow_file = "download-proposals.yaml"

function onFormSubmit(event) {
  var inputs_for_gh = {
    "ref": "main"
  };

  var download_proposals_trigger = {
    "method": "POST",
    // Header is used to send the token as authentication.
    "headers": {
      "authorization": "Bearer " + gh_token,
      "accept": "application/vnd.github+json",
      "X-GitHub-Api-Version": "2022-11-28",
    },
    "contentType": "application/json",
    "payload": JSON.stringify(issue_contents)
    };

  var github_api_url = "https://api.github.com/repos/" + owner + "/" + repo + "/actions/workflows/" + workflow_file + "/dispatches"

  var response = UrlFetchApp.fetch(
    github_api_url,
    download_proposals_trigger
  );

  console.log(res.getContextText())
}
