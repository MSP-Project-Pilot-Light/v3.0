#!/bin/bash
# Lambda 패키징 스크립트

set -e

echo "Building Lambda functions..."

# Seoul Lambdas
cd lambda/cognito-pre-signup-seoul
npm install --production
zip -r ../cognito-pre-signup-seoul.zip .
cd ../..

cd lambda/cognito-user-migration-seoul
npm install --production
zip -r ../cognito-user-migration-seoul.zip .
cd ../..

cd lambda/cognito-pre-auth-seoul
npm install --production
zip -r ../cognito-pre-auth-seoul.zip .
cd ../..

# Tokyo Lambdas
cd lambda/cognito-pre-signup-tokyo
npm install --production
zip -r ../cognito-pre-signup-tokyo.zip .
cd ../..

cd lambda/cognito-user-migration-tokyo
npm install --production
zip -r ../cognito-user-migration-tokyo.zip .
cd ../..

cd lambda/cognito-pre-auth-tokyo
npm install --production
zip -r ../cognito-pre-auth-tokyo.zip .
cd ../..

echo "Lambda functions built successfully!"
echo "Zip files created in lambda/ directory"
