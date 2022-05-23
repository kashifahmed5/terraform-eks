def tfCmd(String command, String options = '') {
    ACCESS = "export AWS_PROFILE=${params.PROFILE} && export TF_ENV_profile=${params.PROFILE}"
    sh ("cd $WORKSPACE/kubernetes && ${ACCESS} && terraform init")
    sh ("echo ${command} ${options}")
    sh ("ls && pwd")
    sh ("cd $WORKSPACE/kubernetes && ${ACCESS} && terraform init && terraform ${command} ${options} && terraform show -no-color > show-${ENV_NAME}.txt")
}

pipeline {
    agent any 

    environment {
        PROJECT_DIR = "eks-terraform/kubernetes"
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        // timestamps()
        timestamps()
        timeout(time: 30, unit: 'MINUTES')
        disableConcurrentBuilds()
    }

    parameters {
        
        choice (name_prefix: 'AWS_REGION', choices: [ 'us-east-1', 'ap-northeast-1', 'us-east-2'], description: 'Pick a Region. Defaults to ap-northeast-1')
        
        choice (name_prefix: 'ACTION', choices: ['plan', 'apply', 'destroy'], description: 'Run terraform plan / apply / destroy')

        string (name_prefix: 'PROFILE', defaultValue: 'sohail', description: 'Optional, Target AWS Profile')

        string (name_prefix: 'ENV_NAME', defaultValue: 'tf-AWS', description: 'Env name.')

        string (name_prefix: 'CLUSTER_NAME', defaultValue: 'EKS_CLUSTER', description: 'Name of EKS cluster.')

        choice (name_prefix: 'CLUSTER_VERSION', choices: [ '1.20', '1.21', '1.19'], description: 'Kubernetes version in EKS.')

        string (name_prefix: 'VPC_ID', defaultValue: 'vpc-36f4fd53', description: 'VPC ID on which the cluster will be on.')

        string (name_prefix: 'INSTANCE_TYPES', defaultValue: '["t2.medium"]', description: 'List of the instance type to create the nodegroup.')

        string (name_prefix: 'API_SUBNET', defaultValue: '["subnet-76a41c7a", "subnet-0abc2c6f"]', description: 'List of subnet for API server.')

        string (name_prefix: 'WORKER_SUBNETS', defaultValue: '["subnet-7513612c"]', description: 'List of subnets for worker node.')

        string (name_prefix: 'DESIRED_SIZE', defaultValue: '2', description: 'Desired size of the worker nodes.')

        string (name_prefix: 'MAX_SIZE', defaultValue: '3', description: 'Maximum number of the worker nodes.')

        string (name_prefix: 'MIN_SIZE', defaultValue: '2', description: 'Minimum number of the worker nodes.')

        string (name_prefix: 'ROOT_VOLUME_SIZE', defaultValue: '50', description: 'Size of Root Volume in worker nodes.')

        choice (name_prefix: 'API_PUBLIC_ACCESS', choices: [ 'true', 'false'], description: 'Allow api server to be accessed using public endpoint.')

        choice (name_prefix: 'API_PRIVATE_ACCESS', choices: [ 'true', 'false',], description: 'Allow API server to be accessed using private endpoint.')

        choice (name_prefix: 'ISTIO_LOADBALANCER', choices: [ 'external', 'internal',], description: 'Allow API server to be accessed using private endpoint.')

        string (name_prefix: 'GRAFANA_DOMAIN_NAME', defaultValue: 'grafana.test.com', description: 'Domain Name for grafana dashboard.')

        string (name_prefix: 'KIALI_DOMAIN_NAME', defaultValue: 'kiali.test.com', description: 'Domain Name for grafana dashboard.')

    }

    stages {

        stage('Set Environment Variable'){
            steps {
                script {
                    env.PROFILE = "${params.PROFILE}"
                    env.ACTION = "${params.ACTION}"
                    env.AWS_DEFAULT_REGION = "${params.AWS_REGION}"
                    env.ENV_NAME = "${params.ENV_NAME}"
                    env.CLUSTER_NAME = "${params.CLUSTER_NAME}"
                    env.DESIRED_SIZE = "${params.DESIRED_SIZE}"
                    env.CLUSTER_VERSION = "${params.CLUSTER_VERSION}"
                    env.VPC_ID = "${params.VPC_ID}"
                    env.INSTANCE_TYPES = "${params.INSTANCE_TYPES}"
                    env.API_SUBNET = "${params.API_SUBNET}"
                    env.WORKER_SUBNETS = "${params.WORKER_SUBNETS}"
                    env.MAX_SIZE = "${params.MAX_SIZE}"
                    env.MIN_SIZE = "${params.MIN_SIZE}"
                    env.ROOT_VOLUME_SIZE = "${params.ROOT_VOLUME_SIZE}"
                    env.API_PUBLIC_ACCESS = "${params.API_PUBLIC_ACCESS}"
                    env.API_PRIVATE_ACCESS = "${params.API_PRIVATE_ACCESS}"
                    env.ISTIO_LOADBALANCER = "${params.ISTIO_LOADBALANCER}"
                    env.GRAFANA_DOMAIN_NAME = "${params.GRAFANA_DOMAIN_NAME}"
                    env.KIALI_DOMAIN_NAME = "${params.KIALI_DOMAIN_NAME}"
                }
            }
        }

        stage('Checkout & Environment Prep'){
            steps{
                script {
                    wrap([$class: 'AnsiColorBuildWrapper', colorMapName: 'xterm']){
                        withCredentials([
                            [ $class: 'AmazonWebServicesCredentialsBinding',
                                accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                                secretKeyVariable: 'AWS_SECRET_ACCESS_KEY',
                                credentialsId: 'AWS-Access',

                            ]])
                        {
                            try {
                                currentBuild.displayName += "[$AWS_REGION]::[$ACTION]"
                                sh ("""
                                        aws configure --profile ${params.PROFILE} set aws_access_key_id ${AWS_ACCESS_KEY_ID}
                                        aws configure --profile ${params.PROFILE} set aws_secret_access_key ${AWS_SECRET_ACCESS_KEY}
                                        aws configure --profile ${params.PROFILE} set region ${AWS_REGION}
                                        export AWS_PROFILE=${params.PROFILE}
                                        export TF_ENV_profile=${params.PROFILE}
                                """)
                                tfCmd('version')
                            } catch (ex) {
                                echo 'Err: Build Failed with Error: ' + ex.toString()
                                currentBuild.result = "UNSTABLE"
                            }
                        }
                        
                    }
                }
            }
        }
        stage('Terraform Plan'){
                when { anyOf
                            {
                                environment name: 'ACTION', value: 'plan';
                                environment name: 'ACTION', value: 'apply';
                            }

                }
                steps {

                        dir("${PROJECT_DIR}"){
                                script {
                                        wrap([$class: 'AnsiColorBuildWrapper', colorMapName: 'xterm']) {
                                                withCredentials([
                                                    [ $class: 'AmazonWebServicesCredentialsBinding',
                                                            accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                                                            secretKeyVariable: 'AWS_SECRET_ACCESS_KEY',
                                                            credentialsId: 'AWS-Access'
                                                    ]])
                                                {
                                                    try {
                                                        sh ("""
                                                        touch $WORKSPACE/kubernetes/terraform.tfvars
                                                        echo 'CLUSTER_NAME = "${CLUSTER_NAME}"' >> $WORKSPACE/kubernetes/terraform.tfvars
                                                        echo 'DESIRED_SIZE = "${DESIRED_SIZE}"'  >> $WORKSPACE/kubernetes/terraform.tfvars
                                                        echo 'CLUSTER_VERSION = "${CLUSTER_VERSION}"' >> $WORKSPACE/kubernetes/terraform.tfvars
                                                        echo 'VPC_ID = "${VPC_ID}"' >> $WORKSPACE/kubernetes/terraform.tfvars
                                                        echo 'INSTANCE_TYPES = ${INSTANCE_TYPES}' >> $WORKSPACE/kubernetes/terraform.tfvars
                                                        echo 'API_SUBNET = ${API_SUBNET}' >> $WORKSPACE/kubernetes/terraform.tfvars
                                                        echo 'WORKERS_SUBNETS = ${WORKER_SUBNETS}' >> $WORKSPACE/kubernetes/terraform.tfvars
                                                        echo 'MAX_SIZE = "${MAX_SIZE}"' >> $WORKSPACE/kubernetes/terraform.tfvars
                                                        echo 'MIN_SIZE = "${MIN_SIZE}"' >> $WORKSPACE/kubernetes/terraform.tfvars
                                                        echo 'ROOT_VOLUME_SIZE = "${ROOT_VOLUME_SIZE}"' >> $WORKSPACE/kubernetes/terraform.tfvars
                                                        echo 'API_PUBLIC_ACCESS = "${API_PUBLIC_ACCESS}"' >> $WORKSPACE/kubernetes/terraform.tfvars
                                                        echo 'API_PRIVATE_ACCESS = "${API_PRIVATE_ACCESS}"' >> $WORKSPACE/kubernetes/terraform.tfvars
                                                        cat $WORKSPACE/kubernetes/terraform.tfvars
                                                        """)
                                                        tfCmd('plan', '-detailed-exitcode -var AWS_REGION=${AWS_DEFAULT_REGION} -var-file=terraform.tfvars -out plan.out')
                                                    } catch (ex) {
                                                        if(ex == 2 && "${ACTION}" == 'apply'){
                                                            currentBuild.result = "UNSTABLE"
                                                        } else if (ex == 2 && "${ACTION}" == 'plan') {
                                                            echo "Update found in plan.out"
                                                        } else {
                                                            echo "Try Running terrafom in debug mode."
                                                        }
                                                    }
                                                }
                                        }
                                }
                        }
                }
        }

        stage('Terraform Apply'){
                when { anyOf
                            {
                                environment name: 'ACTION', value: 'apply';
                            }

                }

                steps {
                        dir("${PROJECT_DIR}") {
                                script {
                                        wrap([$class: 'AnsiColorBuildWrapper', colorMapName: 'xterm']) {
                                                withCredentials([
                                                    [ $class: 'AmazonWebServicesCredentialsBinding',
                                                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                                                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY',
                                                        credentialsId: 'AWS-Access',
                                                        ]])
                                                    {
                                                    try {
                                                        tfCmd('apply', 'plan.out')
                                                    } catch (ex) {
                                                        currentBuild.result = "UNSTABLE"
                                                    }
                                                }
                                        }
                                }
                        }
                }
        }
        stage('Install Components'){
            when { anyOf
                {
                    environment name: 'ACTION', value: 'apply';
                }

            }
            steps {
                dir("${PROJECT_DIR}"){
                    script {
                        wrap([$class: 'AnsiColorBuildWrapper', colorMapName: 'xterm']) {
                            withCredentials([
                                [ $class: 'AmazonWebServicesCredentialsBinding',
                                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY',
                                    credentialsId: 'AWS-Access',
                                ]]){
                                    try {
                                            sh("""
                                            
                                            mkdir -p ~/.kube
                                            cp $WORKSPACE/kubernetes/scripts/kubeconfig ~/.kube/config
                                            """)
                                            if (env.ISTIO_LOADBALANCER == 'internal' ) {
                                                sh("""
                                                
                                                kubectl create ns istio-system
                                                kubectl apply -f $WORKSPACE/istio/services/service-internal.yaml
                                                """)
                                            } else {
                                                sh("""
                                                kubectl create ns istio-system
                                                kubectl apply -f $WORKSPACE/istio/services/service-external.yaml
                                                """)
                                            }

                                            sh("""

                                            kubectl get nodes
                                            kubectl create ns prometheus
                                            kubectl apply -f $WORKSPACE/istio/applications/crd.yaml
                                            kubectl apply -f $WORKSPACE/istio/applications/
                                            kubectl apply -f $WORKSPACE/istio/applications/kiali.yaml
                                            kubectl apply -f $WORKSPACE/prometheus/
                                            export DOMAIN_NAME=${env.GRAFANA_DOMAIN_NAME}
                                            export DOMAIN_NAME_KIALI=${env.KIALI_DOMAIN_NAME}
                                            envsubst < $WORKSPACE/virtualservices/grafana-vs.yaml | kubectl apply -f -
                                            kubectl get svc -n istio-system
                                            """)
                                    } catch (ex) {
                                        currentBuild.result = "UNSTABLE"
                                    }
                                }
                            }
                    }
                }
            }
        }
        stage('Terraform Destroy') {
                when { anyOf 
                            {
                                environment name: 'ACTION', value: 'destroy';
                            }
                }
                steps {
                        script {
                            def IS_APPROVED = input(
                                    message: "Destroy ${ENV_NAME} !?!",
                                    ok: 'Yes',
                                    parameters: [
                                        string(name: 'IS_APPROVED', defaultValue: 'No', description: 'Think again!!!')
                                    ]
                                )
                                if (IS_APPROVED != 'Yes') {
                                        currentBuild.result = "ABORTED"
                                        error "User cancelled"
                                }
                        }

                        dir("${PROJECT_DIR}") {
                            script {

                                    wrap([$class: 'AnsiColorBuildWrapper', colorMapName: 'xterm']) {
                                            withCredentials([
                                                [ $class: 'AmazonWebServicesCredentialsBinding',
                                                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                                                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY',
                                                    credentialsId: 'AWS-Access',
                                                    ]])
                                                {
                                                    try {
                                                        sh("""
                                                        kubectl delete ns istio-system
                                                        kubectl delete ns prometheus
                                                        """)
                                                        tfCmd('destroy', '-auto-approve')
                                                    } catch (ex) {
                                                        currentBuild.result = "UNSTABLE"
                                                    }
                                                }
                                        }
                                }
                        }
                }
        }
    }
    post { 
        always { 
            deleteDir()
        }
    }
}