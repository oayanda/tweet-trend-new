def registry = 'https://oluwadevops.jfrog.io/'
def imageName = 'oluwadevops.jfrog.io/oluwadevops-docker-local/ttrend'
def version   = '2.1.3'
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
                echo "------------- Build started-------------"
                sh 'mvn clean deploy -Dmaven.test.skip=true'
                echo "------------- Build Test completed-------------"
            }
        }
        stage('Test') {
            steps {
                echo "-------------Unit Test started-------------"
                sh 'mvn surefire-report:report'
                echo "-------------Unit Test completed-------------"
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
        stage("Quality Gate"){
            steps{
                script {
                    timeout(time: 1, unit: 'HOURS') { // Just in case something goes wrong, pipeline will be killed after a timeout
                    def qg = waitForQualityGate() // Reuse taskId previously collected by withSonarQubeEnv
                    if (qg.status != 'OK') {
                    error "Pipeline aborted due to quality gate failure: ${qg.status}"
                    }
                    }
                }
            }
        }
             
        stage("Jar Publish inn Artifactory") {
          steps {
            script {
                    echo '<--------------- Jar Publish Started --------------->'
                     def server = Artifactory.newServer url:registry+"/artifactory" ,  credentialsId:"jfrog-token"
                     def properties = "buildid=${env.BUILD_ID},commitid=${GIT_COMMIT}";
                     def uploadSpec = """{
                          "files": [
                            {
                              "pattern": "jarstaging/(*)",
                              "target": "libs-release-local/{1}",
                              "flat": "false",
                              "props" : "${properties}",
                              "exclusions": [ "*.sha1", "*.md5"]
                            }
                         ]
                     }"""
                     def buildInfo = server.upload(uploadSpec)
                     buildInfo.env.collect()
                     server.publishBuildInfo(buildInfo)
                     echo '<--------------- Jar Publish Ended --------------->'  
            
            }
          }   
        }
        stage(" Docker Build ") {
        steps {
            script {
            echo '<--------------- Docker Build Started --------------->'
            app = docker.build(imageName+":"+version)
            echo '<--------------- Docker Build Ends --------------->'
            }
        }
        }

        stage (" Docker Publish "){
            steps {
                script {
                echo '<--------------- Docker Publish Started --------------->'  
                    docker.withRegistry(registry, 'jfrog-token'){
                        app.push()
                    }    
                echo '<--------------- Docker Publish Ended --------------->'  
                }
            }
        }

        stage("Deploy app") {
            steps {
                script {
                    sh './deploy.sh'
                }
            }
        }
    }
}