# Demo code for CloudFront Functions

This code rewrites the paths that go to an API Gateway origin.

## Requirements

* terraform

## Deploy

```terraform apply```

## Usage

The terraform module outputs the CloudFront URL. When you open it you'll see the event structure. The important part is the ```rawPath```. It shows as:

```
"rawPath": "/",
```

An API Gateway origin is mapped to /api/* without a CloudFront Function. You can see that the path is unaltered:

* ```/api/``` => ```/api/```
* ```/api/test``` => ```/api/test```

The same API Gateway with a CloudFront Function is mapped to /api_rewrite/*. The Function removes the first part from the path.

* ```/api_rewrite/``` => ```/```
* ```/api_rewrite/test``` => ```/test```

## Cleanup

```terraform destroy```
