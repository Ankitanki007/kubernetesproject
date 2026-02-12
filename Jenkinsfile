pipeline {
    agent any
    
    environment {
        // Change this to your DockerHub username
        DOCKERHUB_USERNAME = 'ankitdevops02'
        IMAGE_NAME = 'k8s-cicd-demo'
        IMAGE_TAG = "${BUILD_NUMBER}" // Uses the Jenkins Build ID (1, 2, 3...)
    }
    
    stages {
        stage('Checkout Code') {
            steps {
                git 'https://github.com/Ankitanki007/kubernetesproject.git'
            }
        }
        
        stage('Build & Test') {
            steps {
                script {
                    // Builds the image AND runs the 'RUN npm test' line in Dockerfile
                    sh "docker build -t ${DOCKERHUB_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG} ."
                }
            }
        }
        
        stage('Push Artifacts') {
            steps {
                script {
                    // Requires 'dockerhub-creds' to be set in Jenkins Credentials
                    withCredentials([usernamePassword(credentialsId: 'Dockeraccess', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                        sh "echo $PASS | docker login -u $USER --password-stdin"
                        sh "docker push ${DOCKERHUB_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}"
                    }
                }
            }
        }
        
        stage('Deploy to Staging') {
            steps {
                script {
                    // 1. Update the Manifest with the new Image Tag
                    sh "sed -i 's/REPLACE_ME_IMAGE_TAG/${DOCKERHUB_USERNAME}\\/${IMAGE_NAME}:${IMAGE_TAG}/g' deployment.yaml"
                    
                    // 2. Deploy to Staging Namespace
                    sh "kubectl apply -f deployment.yaml -n staging"
                    
                    echo "Deployed to Staging! Verifying..."
                }
            }
        }
        
        stage('Test Staging') {
            steps {
                script {
                    // Wait for pod to be ready
                    sh "kubectl rollout status deployment/my-web-app -n staging"
                    
                    // Simple Curl Test (Internal check)
                    // In a real pipeline, you would run a test suite here
                    echo "Staging Environment is stable."
                }
            }
        }
        
        stage('Deploy to Production') {
            // Manual approval button in Jenkins UI
            input {
                message "Staging looks good. Deploy to Production?"
                ok "Deploy"
            }
            steps {
                script {
                    // Deploy to Production Namespace using the SAME file
                    sh "kubectl apply -f deployment.yaml -n production"
                    
                    echo "Successfully deployed Build #${IMAGE_TAG} to Production!"
                }
            }
        }
    }
}
