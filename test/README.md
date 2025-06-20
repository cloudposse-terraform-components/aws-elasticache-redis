# `elasticache-redis` Component Tests

To run the component tests, ensure that you the following dependencies are installed:

- **Terraform** or **OpenTofu**
- **Atmos**, installed locally
- **Go** (required for running tests). Download and install it from the [official Go website](https://go.dev/) and set up your Go environment correctly.
- **AWS credentials**, configured on your machine for authentication to a test or development account.

Then change directories into the component's `test` directory and run:

```sh
go test -v -timeout 1h
```
