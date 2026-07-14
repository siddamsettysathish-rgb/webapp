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
        stage('Check Commit Author') {
            steps {
                script {
                    def author = sh(
                        script: "git log -1 --pretty=format:'%an'",
                        returnStdout: true
                    ).trim()
                    echo "Commit author: ${author}"
                    if (author == 'jenkins-ci') {
                        currentBuild.result = 'NOT_BUILT'
                        error("Skipping build — triggered by Jenkins own commit")
                    }
                }
            }
        }

        stage('SonarQube Analysis') {
            // ... rest of your stages
        }
    }
}
