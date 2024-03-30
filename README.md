#### ・github push 

git add -A  
git status  
git commit -m "init commit"  
git diff origin/main main  
git push -u origin main  

#### ・リポジトリの巻き戻し

git log  
git reset --soft HEAD^  

  
  
####  ・ロールのIAM ポリシー
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::1234567890:oidc-provider/token.actions.githubusercontent.com"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
                    "token.actions.githubusercontent.com:sub": "repo:1110025y/github-action:ref:refs/heads/main"
                }
            }
        }
    ]
}