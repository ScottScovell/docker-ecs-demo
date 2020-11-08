# Demo Provisioning 
ECR_REPOSITORY=docker-ecs-demo
ACCOUNT=<your aws account>
REGION=<your aws region>

# Provision supporting AWS resources...
aws:
	aws ecr create-repository --repository-name ${ECR_REPOSITORY}-frontend
	aws ecr create-repository --repository-name ${ECR_REPOSITORY}-backend

# Build docker images locally and up the dev environment
dev-up:
	docker-compose --context default -f docker-compose.local.yaml up --build -d

# Tear down the dev environment
dev-down:
	docker-compose --context default -f docker-compose.local.yaml down

# Push latest images to ECR and up the ECS environment
ecs-up:
	# Login into ECR
	aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com
	# Tag latest images with ECR repository name
	docker --context default tag react-express-mysql_frontend:latest ${ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com/${ECR_REPOSITORY}-frontend:latest
	docker --context default tag react-express-mysql_backend:latest ${ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com/${ECR_REPOSITORY}-backend:latest
	# Push images to ECR
	docker --context default push ${ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com/${ECR_REPOSITORY}-frontend:latest
	docker --context default push ${ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com/${ECR_REPOSITORY}-backend:latest
	# Up our ECS environment
	docker --context aws compose -f docker-compose.ecs.yaml up

# Tear down the ECS environment
ecs-down:
	docker --context aws compose -f docker-compose.ecs.yaml down

# Output resulting CloudFormation template
ecs-convert:
	docker --context aws compose convert -f docker-compose.ecs.yaml

# Clean up supporting AWS resources
clean:
	aws ecr delete-repository --repository-name ${ECR_REPOSITORY}-frontend --force
	aws ecr delete-repository --repository-name ${ECR_REPOSITORY}-backend --force