# TF_AWSCodePipeline
파이프라인 데모

[사전 환경 설정]
- IAM 보안자격 증명 탭에서 Access Key 및 CodeCommit 자격증명 생성
IAM 서비스 → 사용자 → 보안자격증명 탭 → 액세스키 만들기 and CodeCommit 자격증명만들기

- Cloud9 temporary credentials 해제
Cloud9 → 기어모양(Preferences) → AWS Settings → AWS managed temporary credentials 체크 해제

- Cloud9 CLI 환경 설정에 Access key 및 PATH 등록
$ echo "export AWS_ACCESS_KEY_ID=[키 ID 입력]" >> ~/.bash_profile
$ echo "export AWS_SECRET_ACCESS_KEY=[키 값 입력]" >> ~/.bash_profile
$ echo "export AWS_DEFAULT_REGION=[리전 ID 입력]" >> ~/.bash_profile
$ echo "export PATH=$PATH:~/environment" >> ~/.bash_profile
$ source ~/.bash_profile

- Terraform 소프트웨어 다운로드 및 압축 해제
브라우저에서 https://www.terraform.io/downloads.html 에 접속하여 Linux 64-bit 다운로드 링크 복사 
$ wget https://releases.hashicorp.com/terraform/0.13.3/terraform_0.13.3_linux_amd64.zip
$ unzip terraform_0.13.3_linux_amd64.zip

- 인스턴스 접속을 위한 키 페어 생성
$ cd ~/.ssh
$ ssh-keygen
엔터 3번하여 key 생성 완료


[Terraform 소스 적용]
$ cd ~/environment/[PJT명]
$ terraform init
$ terraform plan
$ terraform apply --auto-approve

[테스트]
- Windows Powershell Script (로드밸런서 DNS 주소(http주소)를 복사하여 wget 이후부터 ;start-sleep 전까지의 http 주소를 치환)
for($i=0;$i -lt 3600;$i++){wget [여기에 로드밸런서 DNS 주소(http로 시작하는 주소) 붙여넣기];start-sleep -Seconds 1}
- 아래 사례 참고
for($i=0;$i -lt 3600;$i++){wget http://user111a-alb-8080-1993274192.us-east-2.elb.amazonaws.com:8080;start-sleep -Seconds 1}
for($i=0;$i -lt 3600;$i++){wget http://user01-alb2-742064812.ap-northeast-2.elb.amazonaws.com;start-sleep -Seconds 1}
