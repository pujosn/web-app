pipeline {
    agent any

    environment {
        DOCKER_IMAGE      = "pujosn/web-app2"
        IMAGE_TAG         = "1.1.1"
        GKE_CLUSTER       = "cluster-development"
        GCP_PROJECT       = "sanji-453509"
        STAGING_NAMESPACE = "staging-ns"
        PROD_NAMESPACE    = "production-ns"
    }

    stages {
        stage('Checkout Code') {
            steps {
                git 'git@github.com:pujosn/app1.git'
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
                sh '''
                gcloud container clusters get-credentials ${GKE_CLUSTER} --zone asia-southeast2-a
                kubectl config set-context --current --namespace=${STAGING_NAMESPACE}
                kubectl apply -f k8s/staging-deployment.yaml
                '''
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
                gcloud container clusters get-credentials ${GKE_CLUSTER} --zone asia-southeast2-a
                kubectl config set-context --current --namespace=$PROD_NAMESPACE
                kubectl apply -f k8s/production-deployment.yaml
                '''
            }
        }
    }
}
