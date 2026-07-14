pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "sathishsiddamsetty/webapp"
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        REGISTRY_CREDENTIALS = "dockerhub-creds"
        GIT_CREDENTIALS = "Github-Token"
        SONAR_SCANNER_HOME = tool 'SonarScanner'
    }

    stages {

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh """
                        ${SONAR_SCANNER_HOME}/bin/sonar-scanner \
                        -Dsonar.projectKey=webapp \
                        -Dsonar.sources=app \
                        -Dsonar.host.url=http://sonarqube:9000
                    """
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 2, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${DOCKER_IMAGE}:${IMAGE_TAG} ."
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
                        git push https://${GIT_USER}:${GIT_PASS}@github.com/siddamsettysathish-rgb/webapp.git main
                    """
                }
            }
        }
    }
}
