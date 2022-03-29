pipeline{
    agent any
    environment{
        bk_url=credentials('bk_url')
        fr_port=credentials('fr_port')
    }
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
                        master_node_ip  = sh(
                            script: "aws ec2 describe-instances --region sa-east-1  --filter Name=instance.group-name,Values=master-node-sg --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text",
                            returnStdout: true)
                        master_node_ip=master_node_ip.substring(0,master_node_ip.indexOf('\n'))
                        sh "aws ecr batch-delete-image --region sa-east-1 --repository-name rampup-frontend --image-ids '${untaggedImages}' || true"
                    }
                }
            }
        }
        stage('Deploy') {
            steps {
                    withCredentials([file(credentialsId:'ssh_keypair', variable:'ssh_key')]){
                        sh "ssh -o StrictHostKeyChecking=no -i ${ssh_key} ec2-user@${master_node_ip} sudo chef-client -o deploy_instances::deploy_frontend"
                        sh "ssh -o StrictHostKeyChecking=no -i ${ssh_key} ec2-user@${master_node_ip} kubectl create secret generic frontend-secrets --from-literal=fr.port=${fr_port} --from-literal=bk.url=${bk_url} -n rampup-frontend-ns"
                    }
            }
        }
    }
}
