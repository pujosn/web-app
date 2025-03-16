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
                withDockerRegistry([credentialsId: 'docker-hub-credentials', url: 'https://index.docker.io/v1/']) {
                    sh "docker push $IMAGE_NAME:$IMAGE_TAG"
                }
            }
        }

        stage('Deploy to Production') {
            steps {
                withKubeConfig([credentialsId: 'kubeconfig']) {
                    sh "kubectl apply -f deployment.yaml"
                    // sh "kubectl apply -f service.yaml"
                    // sh "kubectl apply -f ingress.yaml"
                }
            }
        }
    }
}
