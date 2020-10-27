# Demo Provisioning 
ECR_REPOSITORY=docker-ecs-demo

# AWS provisioning
# - ECR repository
# - RDS MySQL database
aws-provision:
	echo "Provisioning required AWS resources..."
	aws ecr create-repository --repository-name ${ECR_REPOSITORY}-frontend
	aws ecr create-repository --repository-name ${ECR_REPOSITORY}-backend

# Build docker images locally
build-docker:
	docker-compose --context default -f docker-compose.local.yaml up --build

deploy-docker:

convert-docker:

clean:
