pipeline {
    agent any

    parameters {
        choice(name: 'ENV', choices: ['dev', 'stage', 'prod'], description: 'Target Environment')
    }

    environment {
        TFVARS_FILE = "${params.ENV}.tfvars"
    }

    stages {
        stage('Terraform Init') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials-id']]) {
                    dir('terraform-infra') {
                        sh 'terraform init'
                    }
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials-id']]) {
                    dir('terraform-infra') {
                        sh "terraform plan -var-file=${TFVARS_FILE}"
                    }
                }
            }
        }

        stage('Approval Stage') {
            when {
                allOf {
                    expression { params.ENV in ['stage', 'prod'] }
                    expression { env.BRANCH_NAME == 'main' }
                }
            }
            steps {
                input message: "Deploy to ${params.ENV}?", ok: 'Proceed'
            }
        }

        stage('Terraform Apply') {
            when {
                anyOf {
                    allOf {
                        expression { params.ENV == 'dev' }
                        expression { env.BRANCH_NAME == 'main' }
                    }
                    expression { env.BRANCH_NAME == 'main' && params.ENV in ['stage', 'prod'] }
                }
            }
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials-id']]) {
                    dir('terraform-infra') {
                        sh "terraform apply -auto-approve -var-file=${TFVARS_FILE}"
                    }
                }
            }
        }

        stage('Docker Build') {
            when {
                allOf {
                    expression { params.ENV == 'dev' }
                    expression { env.BRANCH_NAME == 'main' }
                }
            }
            steps {
                sh 'docker build -t myapp:latest ./app'
            }
        }

        stage('Docker Push to DockerHub') {
            when {
                allOf {
                    expression { params.ENV == 'dev' }
                    expression { env.BRANCH_NAME == 'main' }
                }
            }
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                    sh 'echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin'
                    sh 'docker tag myapp:latest $DOCKER_USERNAME/myapp:latest'
                    sh 'docker push $DOCKER_USERNAME/myapp:latest'
                }
            }
        }
    }

    post {
        success { echo "Pipeline executed successfully for environment: ${params.ENV}" }
        failure { echo "Pipeline execution failed!" }
    }
}