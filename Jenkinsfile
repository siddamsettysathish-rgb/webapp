pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "yourdockerhubuser/website"
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        REGISTRY_CREDENTIALS = "dockerhub-creds"
        GIT_CREDENTIALS = "github-creds"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/yourusername/website.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${DOCKER_IMAGE}:${IMAGE_TAG} ."
            }
        }

        stage('Trivy Scan') {
            steps {
                sh """
                    trivy image --severity HIGH,CRITICAL --exit-code 1 \
                    --format table ${DOCKER_IMAGE}:${IMAGE_TAG}
                """
            }
        }

        stage('Push Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: "${REGISTRY_CREDENTIALS}",
                        usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh """
                        echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                        docker push ${DOCKER_IMAGE}:${IMAGE_TAG}
                    """
                }
            }
        }

        stage('Update Manifest for ArgoCD') {
            steps {
                withCredentials([usernamePassword(credentialsId: "${GIT_CREDENTIALS}",
                        usernameVariable: 'GIT_USER', passwordVariable: 'GIT_PASS')]) {
                    sh """
                        sed -i 's|image: .*|image: ${DOCKER_IMAGE}:${IMAGE_TAG}|' k8s/deployment.yaml
                        git config user.email "ci@jenkins.local"
                        git config user.name "jenkins-ci"
                        git add k8s/deployment.yaml
                        git commit -m "Update image to ${IMAGE_TAG}" || echo "No changes"
                        git push https://${GIT_USER}:${GIT_PASS}@github.com/yourusername/website.git main
                    """
                }
            }
        }
    }
}
