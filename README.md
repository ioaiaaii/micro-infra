# micro-infra

micro-infra is a lightweight, cloud-native infrastructure designed to manage and deploy microservices.

```shell
micro-infra/
├── docs/                                 # Documentation files
├── gitops/                               # GitOps resources for ArgoCD
├── iac/                                  # Infrastructure-as-Code with Terragrunt
├── meta-charts/                          # Meta Helm charts for for gitops
├── repo-operator/                        # Submode repository operator for managing and automating workflows
├── runbooks                              # Runbooks for operations and alerts
└── scripts                               # Automation scripts for repo scope
```

- **Terragrunt Configuration**:

   - Remote state management with Google Cloud Storage (GCS).
   - DRY State and providers management across different assets
   - Automated security scanning using **Trivy**, with hooks
   - Centralized variable management with project and location-specific configuration files in /iac

- **GitOps Managed**:

   - Apps linked to HEAD, defined in /gitops, using /meta-charts.
   - `pullRequest` generators for products CI/CD, upon PRs with GitHub label "preview"

## Architecture Overview

The infrastructure is organized into distinct namespaces, each serving a specific purpose.
Below is the architecture diagram illustrating the components and their interactions:

![Micro-Infra Architecture](./docs/arch.svg)

## Platform

Deployment and continuous integration/continuous deployment (CI/CD) solutions.

- **ArgoCD**: A declarative, GitOps continuous delivery tool for Kubernetes.

## Observability

### Visualization and Reporting
### Monitoring
Tools and services for Monitoring and Telemetry data collection and storage.

- **Grafana**: Provides dashboards and visualizations for metrics and logs, configured with
- **Tempo**: A distributed tracing backend compatible with OpenTelemetry.
- **OpenTelemetry Collector**: Collects and exports telemetry data (metrics, logs, traces) to backends.
- **Prometheus Operator**: Manages Prometheus instances for monitoring Kubernetes clusters.
- **Prometheus**: Time-series database for storing metrics.
- **AlertManager**: Handles alerts sent by Prometheus and routes them to appropriate channels.

### Telemetry

- [OTEL Enabled Ingress NGINX](https://kubernetes.github.io/ingress-nginx/user-guide/third-party-addons/opentelemetry/)

## Infrastructure

Core components that support the cluster's operations.

- **Cert-Manager**: Automates the management and issuance of TLS certificates.
- **Cluster Autoscaler**: Automatically adjusts the number of nodes in the cluster based on resource utilization.
- **Ingress NGINX**: Manages external HTTP/S traffic and load balancing within the cluster.


### Products

This namespace is reserved for deploying user-defined microservices and applications.

## Security

### Operations

[Trivy Terraform](https://trivy.dev/v0.57/tutorials/misconfiguration/terraform/) scanning with [Terragrunt After Hook](https://github.com/ioaiaaii/micro-infra/blob/main/iac/gcp/terragrunt.hcl)

### Runtime

[Falco](https://falco.org/) TBD

### Network

#### WAF

[ModSecurity Addon](https://kubernetes.github.io/ingress-nginx/user-guide/third-party-addons/modsecurity/#modsecurity-web-application-firewall)

```json
{"transaction":{"client_ip":"X.X.X.X","time_stamp":"Tue Nov 26 14:42:00 2024","server_id":"XXXX","client_port":34769,"host_ip":"X.X.X.X","host_port":80,"unique_id":"XXX.XXX","request":{"method":"GET","http_version":1.1,"uri":"/geoserver/web/","headers":{"Host":"X.X.X.X","User-Agent":"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36","Accept":"*/*","Accept-Encoding":"gzip"}},"response":{"body":"<html>\r\n<head><title>404 Not Found</title></head>\r\n<body>\r\n<center><h1>404 Not Found</h1></center>\r\n<hr><center>nginx</center>\r\n</body>\r\n</html>\r\n<!-- a padding to disable MSIE and Chrome friendly error page -->\r\n<!-- a padding to disable MSIE and Chrome friendly error page -->\r\n<!-- a padding to disable MSIE and Chrome friendly error page -->\r\n<!-- a padding to disable MSIE and Chrome friendly error page -->\r\n<!-- a padding to disable MSIE and Chrome friendly error page -->\r\n<!-- a padding to disable MSIE and Chrome friendly error page -->\r\n","http_code":404,"headers":{"Server":"","Server":"","Date":"Tue, 26 Nov 2024 14:42:00 GMT","Content-Length":"548","Content-Type":"text/html","Connection":"keep-alive"}},"producer":{"modsecurity":"ModSecurity v3.0.12 (Linux)","connector":"ModSecurity-nginx v1.0.3","secrules_engine":"Enabled","components":["OWASP_CRS/4.4.0\""]},"messages":[{"message":"Host header is a numeric IP address","details":{"match":"Matched \"Operator `Rx' with parameter `(?:^([\\d.]+|\\[[\\da-f:]+\\]|[\\da-f:]+)(:[\\d]+)?$)' against variable `REQUEST_HEADERS:Host' (Value: `X.X.X.X' )","reference":"o0,13o0,13v35,13","ruleId":"920350","file":"/etc/nginx/owasp-modsecurity-crs/rules/REQUEST-920-PROTOCOL-ENFORCEMENT.conf","lineNumber":"772","data":"X.X.X.X","severity":"4","ver":"OWASP_CRS/4.4.0","rev":"","tags":["application-multi","language-multi","platform-multi","attack-protocol","paranoia-level/1","OWASP_CRS","capec/1000/210/272","PCI/6.5.10"],"maturity":"0","accuracy":"0"}}]}}
```

#### Ingress Controller Hardening

Hardening Ingress Controller with official [NGINX Hardening Guide](https://kubernetes.github.io/ingress-nginx/deploy/hardening-guide/#hardening-guide)

#### Ingresses

Rate limiting annotations for public exposed ingresses
