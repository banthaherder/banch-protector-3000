from github import Github
import json
import boto3
import os

def set_protections():
    try:
        master_branch = repo.get_branch("master")
    except github.GithubException.GithubException:
        print("Repo was created without a master branch")
    
    master_branch.edit_protection(required_approving_review_count=1,
    dismiss_stale_reviews=True,
    require_code_owner_reviews=True)

    msg = """
    ## Master Branch Protection Has Been Enabled

    ### Summary
    * Required Approval Count: 1
    * Dismiss Stale Reviews
    * Require Code Owner Reviews

    @{0} 
    """.format(os.environ['NOTIFY_USER'])

    repo.create_issue(title="Branch Protections Updated", body=msg)

def verify_create(e):
    resp = json.loads(e['body'])
    if resp['action'] == 'created':
        repo = resp['repository']

def init_github():
    ssm = boto3.client('ssm', os.environ['REGION'])
    git_token_path = "/{0}GitHubToken".format(os.environ['SSM_PREFIX'])
    git_token = format(ssm.get_parameter(Name=git_token_path, WithDecryption=True)['Parameter']['Value'])
    return Github(git_token)

def lambda_handler(event, context):
    verify_create(event)
    gh = init_github()
    repo = gh.get_repo(repo['id'])

    return {
        'statusCode': 200,
        'body': json.dumps(event['body'])
    }
