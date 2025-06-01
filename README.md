> O demo do lab permite validarmos algumas hipoteses principalmente em relação ao terraform, vultr, aws e outros componentes da arquitetura do lab antes de implementar no repo principal. Veja as branch do repo.

# Informações:
* AWS -> para armazenar as informações de estado da infra provisionada ([S3 Backend](https://developer.hashicorp.com/terraform/language/backend/s3)). Região: `us-east-1`
* VULTR Cloud -> provedor IAAS (infra as service) onde os recursos computacionais serão provisionados

# Acessos
* A conta AWS utilizada é uma conta de Laboratório
* Os dados de acesso do usuário `ACCESS_KEY_ID`, `SECRET_ACCESS_KEY` e `VULTR_API_KEY` aws estão armazenados no [Secrets](https://docs.github.com/en/actions/security-for-github-actions/security-guides/using-secrets-in-github-actions) do repositório Github

# O que fizemos na demo:

1. Seguindo a doc do [Terraform Backend](https://developer.hashicorp.com/terraform/language/backend) definimos um backend para armazenar as informações do estado da infra.
    1. Criamos o usuário AWS IAM `kubernetes-labs-aws-user`
    2. Criamos o grupo `kubernetes-labs-aws-group` e associamos o usuário `kubernetes-labs-aws-user` ao grupo
    3. Criamos o bucket s3 `kubernetes-labs-tf-backend-aws-s3bucket` para armazenar o arquivo de estado da infra `terraform.tflock`
    4. Criamos uma policy `kubernetes-labs-aws-s3bucket-policy` com as permissões `s3` para o bucket e o objeto (arquivo de estado) que será criado pelo tf:
        * `s3:ListBucket`
        * `s3:GetObject`
        * `s3:PutObject`
        * `s3:DeleteObject`
    5. Vinculamos a `policy` ao grupo do lab da conta
2. No Github action criamos 2 workflows (manuais):
    1. 0-workflow_dispatch_manual_start_infra.yaml:
        * _Demo Manual - Start Infrastructure (AWS, Vultr, Terraform)_
        * Com a branch `main` selecionada, é possível iniciar o provisionamento da infra, utilizando o fluxo manual do Github Actions, veja a [doc](https://docs.github.com/en/actions/managing-workflow-runs-and-deployments/managing-workflow-runs/manually-running-a-workflow)
        * Para executar: Página inicial do Repo > Actions > All workflows > (Escolha o Workflow Start Infra) > Run workflow (lado direito) > (Escolha a branch `demo_start_manually`) > Run

    2. 0-workflow_dispatch_manual_destroy_infra.yaml:
        * _Demo Manual - Destroy Infrastructure (AWS, Vultr, Terraform)_
        * Com a branch `main` selecionada, é possível iniciar o provisionamento da infra, utilizando o fluxo manual do Github Actions, veja a [doc](https://docs.github.com/en/actions/managing-workflow-runs-and-deployments/managing-workflow-runs/manually-running-a-workflow)
        * Para executar: Página inicial do Repo > Actions > All workflows > (Escolha o Workflow Destroy Infra) > Run workflow (lado direito) > (Escolha a branch `demo_destroy_manually`) > Run



> [!IMPORTANT]  
> Os recursos AWS: `kubernetes-labs-aws-user`, `kubernetes-labs-aws-group`, `kubernetes-labs-aws-s3bucket-policy` e `kubernetes-labs-tf-backend-aws-s3bucket` não serão removidos, podendo ser utilizado durante os labs

*kubernetes-labs-aws-s3bucket-policy*
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:ListBucket",
            "Resource": "arn:aws:s3:::kubernetes-labs-tf-backend-aws-s3bucket"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject"
            ],
            "Resource": [
                "arn:aws:s3:::kubernetes-labs-tf-backend-aws-s3bucket/lab/state/*"
            ]
        }
    ]
}

```