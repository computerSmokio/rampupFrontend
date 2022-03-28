pipeline{
    agent any
    stages{
        stage('GitCheckout, Build & Push') {
            steps{
                checkout scm
                script{
                    app = docker.build("419466290453.dkr.ecr.sa-east-1.amazonaws.com/rampup-frontend:latest")
                    docker.withRegistry("https://419466290453.dkr.ecr.sa-east-1.amazonaws.com", "ecr:sa-east-1:aws_credentials"){
                        app.push()
                    }
                    sh "docker rmi \$(docker image ls --filter 'dangling=true' --format {{.ID}})|| true"
                    sh "docker rmi \$(docker image ls --filter reference='*/rampup-frontend:*' --format {{.ID}})|| true"
                    withCredentials([aws(credentialsId: 'aws_credentials', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                        untaggedImages  = sh(
                            script: "aws ecr list-images --region sa-east-1 --repository-name rampup-frontend --filter tagStatus=UNTAGGED --query 'imageIds[*]' --output json ",
                            returnStdout: true)
                        sh "aws ecr batch-delete-image --region sa-east-1 --repository-name rampup-frontend --image-ids '${untaggedImages}' || true"
                    }
                }
            }
        }
        stage('Deploy') {
            steps {
                    withCredentials([file(credentialsId:'ssh_keypair', variable:'ssh_key')]){
                        sh "chef-run master-node /cookbooks/deploy_instances/recipes/deploy_frontend.rb -i ${ssh_key} --chef-license"
                    }
            }
        }
    }
}
