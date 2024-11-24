# micro-infra

micro-infra is a lightweight, cloud-native infrastructure designed to manage and deploy microservices 

## Architecture Overview

The infrastructure is organized into distinct namespaces, each serving a specific purpose:

- **Observability**: Tools and services for monitoring and tracing.
- **Infrastructure**: Core components that support the cluster's operations.
- **Platform**: Deployment and continuous integration/continuous deployment (CI/CD) solutions.
- **Products**: User-defined microservices and applications.

Below is the architecture diagram illustrating the components and their interactions:

![Micro-Infra Architecture](./docs/arch.svg)

## Key Components

### Observability

- **Grafana**: Provides dashboards and visualizations for metrics and logs.
- **Tempo**: A distributed tracing backend compatible with OpenTelemetry.
- **OpenTelemetry Collector**: Collects and exports telemetry data (metrics, logs, traces) to various backends.
- **Prometheus Operator**: Manages Prometheus instances for monitoring Kubernetes clusters.
- **Prometheus**: Time-series database for storing metrics.
- **AlertManager**: Handles alerts sent by Prometheus and routes them to appropriate channels.

### Infrastructure

- **Cert-Manager**: Automates the management and issuance of TLS certificates.
- **Cluster Autoscaler**: Automatically adjusts the number of nodes in the cluster based on resource utilization.
- **Ingress NGINX**: Manages external HTTP/S traffic and load balancing within the cluster.

### Platform

- **ArgoCD**: A declarative, GitOps continuous delivery tool for Kubernetes.

### Products

This namespace is reserved for deploying user-defined microservices and applications.

