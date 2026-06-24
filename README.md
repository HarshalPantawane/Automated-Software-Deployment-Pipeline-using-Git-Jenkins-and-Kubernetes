# Zero Touch Deploy – Automated Deployment Pipeline

## Overview

This project presents a complete implementation of an automated software deployment pipeline using Git, Jenkins and Kubernetes. It is designed to demonstrate how an application can be built, containerized, stored in a registry, and deployed to an AWS EKS cluster through a continuous integration and continuous deployment workflow.

## Purpose

The main purpose of this project is to automate the lifecycle of a application from source code to a running Kubernetes deployment. The implementation focuses on:

- Source code versioning (Git)
- Build and test (Maven)
- Containerization (Docker)
- Image storage (Amazon ECR)
- Deployment (Kubernetes on AWS EKS)

## Implementation Summary

The implementation is organized around a Jenkins pipeline that performs the following operations:

1. Checks out the source code from the Git repository.
2. Builds the application using Maven.
3. Runs the test phase.
4. Creates a Docker image from the application.
5. Pushes the image to Amazon ECR.
6. Updates Kubernetes manifests with environment values.
7. Applies the deployment to the target namespace in the AWS EKS cluster.

This makes the deployment process repeatable and reduces the need for manual intervention.

## Architecture

The overall flow is as follows:

Developer -> Git Repository -> Jenkins Pipeline -> Docker Build -> Amazon ECR -> Kubernetes Deployment

### Project Structure

```text
.
├── k8s/
│   ├── deployment.yml
│   ├── namespace.yml
│   └── svc.yml
├── src/
│    ├── main/
│    │   ├── java/
│    │   │   └── com/demo/app/
│    │   │       └── DemoApplication.java
│    │   └── resources/
│    │       └── application.properties
│    └── test/
│        └── java/com/demo/app/
├── target/
│    └── ci-cd-demo-1.0.0.jar
├── Dockerfile
├── Jenkinsfile
├── pom.xml
└── README.md

```

## Tech Stack
- Git & GitHub
- Jenkins (CI/CD Orchestration)
- Maven (Build Tool)
- Docker (Containerization)
- Amazon ECR (Image Registry)
- Kubernetes (AWS EKS)

## Prerequisites

To use and extend this project, the following components are required:

- Git repository access
- Jenkins server with pipeline support
- Docker installed on the build environment
- Amazon ECR repository configured
- AWS EKS cluster access configured for Jenkins
- Maven build tool available in the pipeline environment

## Configuration Requirements

The pipeline relies on Jenkins credentials to securely access external services. These credentials should be configured in Jenkins before running the pipeline.

Recommended credentials include:

- github personel access token
- aws-creds for AWS authentication
- ecr-registry-id for the ECR endpoint
- k8s-namespace-id for the target namespace

## CI/CD Deployment Workflow

The deployment workflow is executed in stages:

The Jenkins pipeline is configured to poll the Git repository for changes and to run the core build, containerization, and deployment stages in a straightforward way. The configuration remains clear and easier to maintain for a single deployment target.

### 1. Source Checkout
The pipeline retrieves the latest version of the repository from the configured Git branch.

### 2. Build and Test
The application is compiled and tested using Maven so that only validated code proceeds.

### 3. Containerization
A Docker image is created using the application build output and the provided Dockerfile.

### 4. Image Publishing
The image is tagged and pushed to Amazon ECR for centralized storage.

### 5. Kubernetes Deployment
The deployment manifests are rendered with environment variables and applied to the AWS EKS namespace.

## Security Best Practices
- No hardcoded credentials in code
- Jenkins Credentials Manager used for all secrets
- IAM roles follow least privilege access
- Separate AWS permissions for ECR and EKS
- Docker images tagged using build numbers for traceability

## Benefits of the Implementation

This implementation provides several benefits:

- reduced manual deployment effort
- consistent build and deployment behavior
- faster delivery of application updates
- a clear example of infrastructure automation
- easier scaling of deployment practices across environments

## Summary
This project demonstrates a complete CI/CD automation pipeline using Jenkins and Kubernetes, following industry DevOps practices for continuous delivery, scalability, and reliability.
