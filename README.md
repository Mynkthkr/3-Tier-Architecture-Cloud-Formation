## <u><b>Spring Boot Application : 3-tier Architectue</b></u>


![image](https://user-images.githubusercontent.com/54767390/205426044-40d9c537-2fe5-4f43-b4bb-a32d3da42c23.png)


### Steps For deploying on AWS ECS

Use Region <b>us-east-1</b> or you can change accordingly

Step1:

Make a docker image using following command 
```
docker build -t <image name> -f Dockerfile .
```

Step2:

Create AWS ECR Repositories

Search <b>Amazon ECR</b> > Create repositories 

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
aws cloudformation create-stack --stack-name vpc --template-body file://vpc-CloudFormation.yml --region=us-east-1
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
aws cloudformation create-stack --stack-name rds --template-body file://rds-CloudFormation.yml  --region=us-east-1 --capabilities CAPABILITY_NAMED_IAM
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
## Note
------------------------------------------------------------------------------
Please change the ``` arn ``` for database name ,database username and database password with your aws account number in ecs-cloudformation template [Ecs-Template].(https://github.com/Mynkthkr/java-springboot/blob/main/ecs-CloudFormation.yml)

aws cloudformation create-stack --stack-name ecs --template-body file://ecs-CloudFormation.yml --parameters ParameterKey=ImageUrl,ParameterValue=<image> --capabilities CAPABILITY_NAMED_IAM --region=us-east-1
```
### Hit the DNS , result will show like this

![image](https://user-images.githubusercontent.com/54767390/208317697-1b7a81c5-de64-4a49-97d4-98839d87421a.png)

### Add  ``` /swagger-ui.html ``` 

```     <DNS>/swagger-ui.html  ``` , and Final result

![image](https://user-images.githubusercontent.com/54767390/208317833-808b591f-1c2c-4adf-b57e-729a6af953ba.png)




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
