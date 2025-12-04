## Project Infra

This repository contains the codes and scripts for provisioning and updating the infrastructure of Itsavirus client project using terraform.

## Overview

This repository consist of the following directories of interest:

- [key-pairs](key-pairs/): The key pairs for creating or managing EC2 instance.
- [projects](projects/): List of the project, including the environment's terraform code (staging, production, etc)
- [terraform-modules](terraform-modules/): List of AWS services as available terraform modules to be used in projects/.

## Requirement

This infra repository specifically for projects to be deployed in **AWS Cloud Platform**. Before set up the infra, please follow these requirements below:

- [AWS CLI >= 2.0](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [Terraform >= 1.2.9](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [Taskfile >= 3.23.0](https://taskfile.dev/installation/)

### Security Scanning Tools (Optional)

For security scanning capabilities:

- [tfsec](https://aquasecurity.github.io/tfsec/latest/) - Fast security scanner for Terraform
- [checkov](https://www.checkov.io/) - Static code analysis tool for infrastructure

You can install these tools using:

```sh
$ task security:install-tools
```

## Setup

### Clone the repository

```sh
$ git clone git@github.com:Itsavirus-com/project-infra.git
$ cd project-infra
```

### Decrypt key-pairs

```sh
$ task key-pairs:decrypt
```

### Initialize terraform

```sh
$ task infra:init
```

## Usage

### List all available task

```sh
$ task --list
```

### Planning infra

```sh
$ task infra:plan -- ${PROJECT_NAME}/${ENVIRONMENT_NAME}
```

e.g

```sh
$ task infra:plan -- myproject/staging
```

### Applying infra

```sh
$ task infra:apply -- ${PROJECT_NAME}/${ENVIRONMENT_NAME}
```

e.g

```sh
$ task infra:apply -- myproject/staging
```

## Security Scanning

### Running Security Scans

Run all security scans (tfsec and checkov):

```sh
$ task security:scan
```

### Run tfsec only

```sh
$ task security:tfsec
```

### Run checkov only

```sh
$ task security:checkov
```

### Install Security Tools

Install tfsec and checkov:

```sh
$ task security:install-tools
```
