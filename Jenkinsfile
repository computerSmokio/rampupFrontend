pipeline{
    agent any
    environment{
        backend_url = credentials('backend_url')
        frontend_port = credentials('frontend_port')
    }
    stages{
        stage('GitCheckout & Build') {
            steps{
                checkout scm
                script{
                    app = docker.build("419466290453.dkr.ecr.sa-east-1.amazonaws.com/rampup-fronten:latest")
                }
            }
        }
        stage('Push & Deploy') {
            steps {
                script{
                    docker.withRegistry("https://419466290453.dkr.ecr.sa-east-1.amazonaws.com", "ecr:sa-east-1:aws_credentials"){
                        app.push()
                    }

                }
                sh "docker rmi $(docker image ls --filter reference='*/rampup-frontend:*' --format {{.ID}})"
                sh "docker rmi $(docker image ls --filter 'dangling=true' --format {{.ID}})"
                script{
                    withCredentials([aws(credentialsId: 'aws_credentials', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                        writeFile file: 'inventory.ini', text: "[ec2]\n"
                        sh "aws ec2 describe-instances --filter Name=instance.group-name,Values=sg_frontend --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text >> inventory.ini"
                        untaggedImages  = sh(
                            script: "aws ecr list-images --region sa-east-1 --repository-name rampup-frontend --filter tagStatus=UNTAGGED --query 'imageIds[*]' --output json ",
                            returnStdout: true)
                        sh "aws ecr batch-delete-image --region sa-east-1 --repository-name rampup-frontend --image-ids '${untaggedImages}' || true"
                    }
                    withCredentials([file(credentialsId:'ssh_keypair', variable:'ssh_key')]){
                        sh "ansible-playbook -i inventory.ini -u ec2-user --private-key $ssh_key deploy_containers.yaml --extra-vars 'frontend_port=$frontend_port backend_url=$backend_url'"
                    }
                }
            }
        }
    }
}