# DevOps Assignment - AWS Infrastructure

This repository contains a **Terraform Proof of Concept (POC)** for deploying a system on AWS, as part of a DevOps assignment. The system includes services like ECS, ALB, CloudFront, and SQS, and demonstrates infrastructure management with Terraform. Please note that this POC is not fully functional and contains mocked resources such as applications.

## System Description

The system is an **AWS deployment** consisting of the following components:

- **CloudFront Distribution**: Points to an **Application Load Balancer (ALB)**, serving as the entry point for the frontend.
- **Next.js Frontend Service on ECS**: A **Next.js** application running as a service on ECS (Fargate).
- **Backend Services on ECS**:
  - **Service A**: A backend service using **gRPC communication**.
  - **Service B**: A backend service that communicates via **SQS** (Simple Queue Service).
- **MongoDB Atlas**: A **managed MongoDB** database that is accessed by both backend services.
- **ECS Cluster**: Using the **Fargate capacity provider** for serverless container orchestration.

## Architecture

An **approximate diagram** of the infrastructure is included in the repository to visualize the components and their interactions. While the diagram provides a high-level view, it is not fully operational and contains mock configurations.

## Features

- **ECS Fargate**: Running containerized services for both frontend and backend services.
- **Application Load Balancer (ALB)**: Routing traffic between CloudFront and ECS services.
- **CloudFront Distribution**: Serving the Next.js frontend via ALB.
- **gRPC and SQS Communication**: Mocked services with gRPC (Service A) and SQS (Service B) for backend communication.
- **MongoDB Atlas**: Mocked configuration for backend services accessing MongoDB Atlas.
- **Auto-scaling**: Configurations based on various metrics like latency and number of messages in flight in SQS.
- **IAM Roles and Security Groups**: Basic access controls to secure services.
- **CloudWatch Metrics**: Set up for monitoring backend service performance and scaling actions.

## Infrastructure Diagram

An **approximate diagram** of the architecture is included in the `/diagrams` folder. This diagram shows how the various components are connected.
