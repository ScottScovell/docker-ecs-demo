# Demo Provisioning 
ECR_REPOSITORY=docker-ecs-demo

# AWS provisioning
# - ECR repository
# - RDS MySQL database
aws:
	echo "Provisioning required AWS resources..."
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
	aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 752419465350.dkr.ecr.us-east-1.amazonaws.com
	# Tag latest images with ECR repository name
	docker --context default tag react-express-mysql_frontend:latest 752419465350.dkr.ecr.us-east-1.amazonaws.com/${ECR_REPOSITORY}-frontend:latest
	docker --context default tag react-express-mysql_backend:latest 752419465350.dkr.ecr.us-east-1.amazonaws.com/${ECR_REPOSITORY}-backend:latest
	# Push images to ECR
	docker --context default push 752419465350.dkr.ecr.us-east-1.amazonaws.com/${ECR_REPOSITORY}-frontend:latest
	docker --context default push 752419465350.dkr.ecr.us-east-1.amazonaws.com/${ECR_REPOSITORY}-backend:latest
	# Up our ECS environment
	docker --context ecs compose -f docker-compose.ecs.yaml up

# Tear down the ECS environment
ecs-down:
	docker --context ecs compose -f docker-compose.ecs.yaml down

# Output resulting CloudFormation template
ecs-convert:
	docker --context ecs compose convert -f docker-compose.ecs.yaml

clean:
