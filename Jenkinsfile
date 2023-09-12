pipeline {
    agent {
        node {
            label 'maven'
        }
    }
    environment {
        PATH = "/home/ubuntu/apache-maven-3.9.4/bin:$PATH"
    }
    stages {
        stage("build") {
            steps {
                sh 'mvn clean deploy'
            }
        }
        stage('SonarQube analysis') {
            environment {
                scannerHome = tool 'oayanda-sonar-scanner'
            }
            steps{
                withSonarQubeEnv('oayanda-sonarqube-server') { // If you have configured more than one global server connection, you can specify its name
                sh "${scannerHome}/bin/sonar-scanner"

                }
            }
        }
    }
}