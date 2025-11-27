pipeline {
    agent {
        label 'jenkins-agent-02'
    }
    
    environment {
        REGISTRY_URL = '192.168.56.1:5000'
        IMAGE_NAME = 'ubuntu-ssh'
        VERSION = "1.0.${BUILD_NUMBER}"
    }
    
    stages {
        stage('Build') {
            steps {
                script {
                    echo "Building ${IMAGE_NAME}:${VERSION}"
                    
                    sh """
                        docker build -t ${IMAGE_NAME}:${VERSION} .
                        docker tag ${IMAGE_NAME}:${VERSION} ${IMAGE_NAME}:latest
                        docker tag ${IMAGE_NAME}:${VERSION} ${REGISTRY_URL}/${IMAGE_NAME}:${VERSION}
                        docker tag ${IMAGE_NAME}:${VERSION} ${REGISTRY_URL}/${IMAGE_NAME}:latest
                    """
                }
            }
        }
        
        stage('Push') {
            steps {
                script {
                    echo "Pushing to registry ${REGISTRY_URL}"
                    
                    sh """
                        docker push ${REGISTRY_URL}/${IMAGE_NAME}:${VERSION}
                        docker push ${REGISTRY_URL}/${IMAGE_NAME}:latest
                    """
                }
            }
        }
        
        stage('Verify') {
            steps {
                sh "curl -s http://${REGISTRY_URL}/v2/${IMAGE_NAME}/tags/list"
            }
        }
    }
    
    post {
        success {
            echo "Build e Push completati: ${REGISTRY_URL}/${IMAGE_NAME}:${VERSION}"
        }
        failure {
            echo "Build fallita"
        }
    }
}
