//stage('GitCheckout & Build') {
//    // The first milestone step starts tracking concurrent build order
//    milestone()
//    node {
//        echo "Building"
//        checkout scm
//        app = docker.build("419466290453.dkr.ecr.sa-east-1.amazonaws.com/rampup-repo:frontend")
//        //apply the dockerfile and push the image, nothing else needed
//    }
//}
stage('Push & Deploy') {
    milestone()
    environment {
        ssh_key = credentials('ssh_keypair')
    }
    node {
    //    echo "Deploying"
    //    docker.withRegistry("https://419466290453.dkr.ecr.sa-east-1.amazonaws.com", "ecr:sa-east-1:aws_credentials"){
    //        app.push()
    //    }
        sh 'ansible-playbook -i inventory.yaml -u ec2-user --private-key ${ssh_key} deploy_containers.yaml'
    }
}
