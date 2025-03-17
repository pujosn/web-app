pipeline {
    agent any

    environment {
        DOCKER_IMAGE      = "pujosn/web-app2"
        IMAGE_TAG         = "1.1.2"
        GKE_CLUSTER       = "cluster-prod"
        GCP_PROJECT       = "chopper-453920"
        STAGING_NAMESPACE = "staging-ns"
        PROD_NAMESPACE    = "production-ns"
    }

    stages {
        stage('Checkout Code') {
            steps {
                git 'git@github.com:pujosn/web-app.git'
            }
        }

        stage('Testing') {
            steps {
                sh 'echo "Running HTML Validation"'
                sh 'tidy -errors index.html || true' // Contoh validasi HTML
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${DOCKER_IMAGE}:${IMAGE_TAG} ."
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withDockerRegistry([credentialsId: 'docker-hub-credentials', url: '']) {
                    sh "docker push ${DOCKER_IMAGE}:${IMAGE_TAG}"
                }
            }
        }

            stage('Deploy to Staging') {
                steps {
                    script {
                        withCredentials([file(credentialsId: 'gcp-key-jenkins', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                        sh '''
                        gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS
                        gcloud container clusters get-credentials $GKE_CLUSTER --zone asia-southeast1-a --project chopper-453920
                        kubectl config set-context --current --namespace=$STAGING_NAMESPACE
                        kubectl apply -f staging-deployment.yaml
                        '''
                    }
                }
            }
        }

        stage('Approval for Production') {
            steps {
                input message: 'Deploy to Production?', ok: 'Deploy'
                // stage manual approval
            }
        }

        stage('Deploy to Production') {
            steps {
                sh '''
                gcloud container clusters get-credentials $GKE_CLUSTER --zone asia-southeast1-a
                kubectl config set-context --current --namespace=$PROD_NAMESPACE
                kubectl apply -f prod-deployment.yaml
                '''
            }
        }
    }
}