pipeline {
    agent any

    environment {
        SKIP_BUILD = 'false'
    }

    stages {
        stage('Check Commit') {
            steps {
                script {
                    def commitAuthor = sh(
                        script: 'git log -1 --pretty=format:%an',
                        returnStdout: true
                    ).trim()

                    def commitMessage = sh(
                        script: 'git log -1 --pretty=format:%B',
                        returnStdout: true
                    ).trim()

                    echo "Commit author: ${commitAuthor}"
                    echo "Commit message: ${commitMessage}"

                    if (commitAuthor == 'jenkins-ci' ||
                        commitMessage.contains('[skip ci]')) {
                        env.SKIP_BUILD = 'true'
                        currentBuild.description = 'Skipped Jenkins automation commit'
                        echo 'Jenkins automation commit detected. Remaining stages will be skipped.'
                    }
                }
            }
        }

        stage('SonarQube Analysis') {
    when {
        expression {
            env.SKIP_BUILD != 'true'
        }
    }

    steps {
        script {
            def scannerHome = tool 'SonarScanner'

            withSonarQubeEnv('SonarQube') {
                sh """
                    ${scannerHome}/bin/sonar-scanner
                """
            }
        }
    }
}

stage('Quality Gate') {
    when {
        expression {
            env.SKIP_BUILD != 'true'
        }
    }

    steps {
        timeout(time: 10, unit: 'MINUTES') {
            waitForQualityGate abortPipeline: true
        }
    }
}

        stage('Build Docker Image') {
            when {
                expression {
                    env.SKIP_BUILD != 'true'
                }
            }
            steps {
                sh 'docker build -t your-image:${BUILD_NUMBER} .'
            }
        }

        stage('Push Image') {
            when {
                expression {
                    env.SKIP_BUILD != 'true'
                }
            }
            steps {
                echo 'Push Docker image here'
            }
        }

        stage('Update Manifest for ArgoCD') {
            when {
                expression {
                    env.SKIP_BUILD != 'true'
                }
            }
            steps {
                echo 'Update Kubernetes manifest here'
            }
        }
    }

    post {
        always {
            script {
                if (env.SKIP_BUILD == 'true') {
                    currentBuild.result = 'NOT_BUILT'
                }
            }
        }
    }
}
