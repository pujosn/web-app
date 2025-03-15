pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "pujosn/web-app2"
        DOCKER_TAG = "1.1.0"
        GKE_CLUSTER = "cluster-development"
        GCP_PROJECT = "sanji-453509"
        DEPLOYMENT_NAME = "app1"
        CONTAINER_NAME = "app1"
        ZONE = "asia-southeast2-a"
        EXTERNAL_IP = "34.101.226.26"
        DOMAIN_NAME = "web1.takoples.my.id"

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
                        kubectl apply -f deployment.yaml
                        kubectl apply -f services.yaml
                        kubectl apply -f ingress.yaml
                        '''
                    }
                }          
            }
        }

        stage('Configure Domain') {
            steps {
                script {
                    def zoneExists = sh(script: "gcloud dns managed-zones list --format='value(name)' | grep -w $DNS_ZONE || echo ''", returnStdout: true).trim()
                    if (zoneExists) {
                        sh "gcloud dns record-sets transaction start --zone=$DNS_ZONE"
                        sh "gcloud dns record-sets transaction add $EXTERNAL_IP --name=$DOMAIN_NAME --ttl=300 --type=A --zone=$DNS_ZONE"
                        sh "gcloud dns record-sets transaction execute --zone=$DNS_ZONE"
                    } else {
                        error("DNS Zone $DNS_ZONE not found. Please verify the zone exists in Google Cloud DNS.")
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