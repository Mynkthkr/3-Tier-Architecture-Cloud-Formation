# <u><b>Spring Boot application :- 3 tier architectue</b></u>
------------------------------------------------------------------------------------------------------------------------

![image](https://user-images.githubusercontent.com/54767390/205398429-eb9b1c89-9a9b-419f-96a6-bb0e3499b66c.png)


### Steps For deploying on AWS ECS

Step1:

Make a docker image using following command 
```
docker build -t <image name> -f Dockerfile .
```

Step2:

Push image on AWS ECR

Follow   ![image](https://user-images.githubusercontent.com/54767390/205375295-155c87a7-687e-4301-bb6d-f3547fc7cbcd.png) or 

Retrieve an authentication token and authenticate your Docker client to your registry.

Use the AWS CLI:
```
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 4xxxxxxxxxx5.dkr.ecr.us-east-1.amazonaws.com
```
<b> Note: If you receive an error using the AWS CLI, make sure that you have the latest version of the AWS CLI and Docker installed. </b>

Build your Docker image using the following command. You can skip this step if your image is already built:
```
docker build -t <name> . 
```
After the build completes, tag your image so you can push the image to this repository:
```
docker tag spring:latest 4xxxxxxxxx5.dkr.ecr.us-east-1.amazonaws.com/spring:latest
```
Run the following command to push this image to your newly created AWS repository:
```
docker push 4xxxxxxxx5.dkr.ecr.us-east-1.amazonaws.com/<name>:latest
```

-----------------------------------------------------------------------------------------------------------------------------------------------
### Now run cloud formtion template for creating VPC
```
aws cloudformation create-stack --stack-name vpc --template-body file://vpc-CloudFormation.yml  --capabilities CAPABILITY_NAMED_IAM
```
By this stack, get some Export value
So, use that values to any resource from this VPC
```
Outputs:
  VPCid:
    Description: The VPCid
    Value: !Ref VPC
    Export:
      Name: VPC

  PublicSub1:
    Description: public subnet 1
    Value: !Ref PublicSubnet1
    Export:
      Name: PublicSubnet1

  PublicSub2:
    Description: public subnet  2
    Value: !Ref PublicSubnet2
    Export:
      Name: PublicSubnet2

  PrivateSub1:
    Description: private subnet 1
    Value: !Ref PrivateSubnet1
    Export:
      Name: PrivateSubnet1

  PrivateSub2:
    Description: private subnet 2
    Value: !Ref PrivateSubnet2
    Export:
      Name: PrivateSubnet2
```
### Run another cloud formation for RDS 
```
aws cloudformation create-stack --stack-name vpc --template-body file://vpc-CloudFormation.yml  --capabilities CAPABILITY_NAMED_IAM
```
From this , got the Endpoint of RDS and store that in Export
```
  DBEndpoint:
    Description: The connection endpoint for the database.
    Value: !GetAtt  DBinstance.Endpoint.Address
    Export:
      Name: DBEndPoint 
```
### Now Run the final stack for deploying the ECS Infra using following CLI command 
```
aws cloudformation create-stack --stack-name vpc --template-body file://ecs-CloudFormation.yml  --capabilities CAPABILITY_NAMED_IAM
```
___________________________________________________________________________________________________________________________________
-----------------------------------------------------------------------------------------------------------------------------------
## Build CI/CD Pipeline :
Copy the code and paste it in pipeline
```
pipeline {
    agent any
     stages {
        stage('Git checkout1') {
          steps{
                git branch: 'main', credentialsId: '', url: 'https://github.com/Mynkthkr/java-springboot.git'
            }
        }
         stage('build image') {
          steps{
              sh'docker build -t 4xxxxxxxxxx5.dkr.ecr.us-east-1.amazonaws.com/spring:${BUILD_NUMBER} . '
                }
        }
        stage('push image') {
          steps{
             sh'aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 45xxxxxx5.dkr.ecr.us-east-1.amazonaws.com'
             sh'docker push 45xxxxxx55.dkr.ecr.us-east-1.amazonaws.com/spring:${BUILD_NUMBER}'
                }
        }  
        stage('validation') {
          steps{
               
              sh'aws cloudformation validate-template --template-body file://ecs-CloudFormation.yml'              
            }
        }
        stage('submit stack') {
          steps{               
              sh'aws cloudformation create-stack --stack-name ecs --template-body file://ecs-CloudFormation.yml --parameters ParameterKey=ContainerPort,ParameterValue=8090 ParameterKey=Image1,ParameterValue=${image}:${BUILD_NUMBER} --capabilities CAPABILITY_NAMED_IAM'
            }
        }                
    }
}

```
