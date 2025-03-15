pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "pujosn/web-app2"
        DOCKER_TAG = "1.1.0"
        GKE_CLUSTER = "cluster-development"
        GCP_PROJECT = "sanji-453509"
        DEPLOYMENT_NAME = "app1-web"
        CONTAINER_NAME = "app1"
        ZONE = "asia-southeast2-a"
        EXTERNAL_IP = "34.50.70.47"
        DOMAIN_NAME = "web1@takoples.my.id"

    }

    stages {
        stage('Checkout Code') {
            steps {
                git 'git@github.com:pujosn/app1.git'
            }
        }
        // update IP publik

        stage('Build Docker Image and Test') {
            steps {
                script {
                    sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
                    sh "docker run --rm ${DOCKER_IMAGE}:${DOCKER_TAG} /bin/sh -c echo 'Running Tests'"
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withDockerRegistry([credentialsId: 'docker-hub-credentials', url: '']) {
                    sh "docker push ${DOCKER_IMAGE}:${DOCKER_TAG}"
                }
            }
        }

            stage('Deploy to GKE') {
                steps {
                    script {
                        withCredentials([file(credentialsId: 'gcp-service-account', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) { 
                        sh '''
                        gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS
                        gcloud container clusters get-credentials cluster-development --zone asia-southeast2-a --project sanji-453509
                        kubectl apply -f services.yaml
                        kubectl apply -f deployment.yaml
                        kubectl apply -f ingress.yaml
                        '''
                    }
                }          
            }
        }

            stage('Get External IP') {
                steps {
                    script {
                        def externalIp = sh(script: "kubectl get service web-app-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}'", returnStdout: true).trim()
                        if (!externalIp) {
                            error("External IP not assigned yet. Please check GKE Load Balancer.")
                        } else {
                            echo "Application is available at http://${externalIp}"
                        }
                    }
                }
            }
        }


    post {
       success {
           echo 'Deployment berhasil!'
       }
       failure {
           echo 'Deployment gagal!'
       }
    }
}

        