# Demo Provisioning 
ECR_REPOSITORY=docker-ecs-demo
ACCOUNT=752419465350
REGION=us-east-1

# AWS provisioning
# - ECR repositories
# - RDS MySQL database
aws:
	echo "Provisioning supporting AWS resources..."
	aws ecr create-repository --repository-name ${ECR_REPOSITORY}-frontend
	aws ecr create-repository --repository-name ${ECR_REPOSITORY}-backend
	aws rds create-db-instance \
		--db-instance-identifier db-rds \
		--db-instance-class db.t3.micro \
		--engine mysql \
		--master-username root \
		--master-user-password db-btf5q \
		--allocated-storage 20 \
		--db-name example_rds

# Build docker images locally and up the dev environment
dev-up:
	docker-compose --context default -f docker-compose.local.yaml up --build -d
	#docker --context default compose -f docker-compose.local.yaml up -d

# Tear down the dev environment
dev-down:
	docker-compose --context default -f docker-compose.local.yaml down
	#docker --context default compose -f docker-compose.local.yaml down

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
	echo "Cleaning up supporting AWS resources..."
	aws ecr delete-repository --repository-name ${ECR_REPOSITORY}-frontend --force
	aws ecr delete-repository --repository-name ${ECR_REPOSITORY}-backend --force
	aws rds delete-db-instance \
		--db-instance-identifier db-rds \
		--skip-final-snapshot \
		--delete-automated-backups
