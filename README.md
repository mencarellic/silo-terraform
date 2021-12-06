# README

## Requirements

* Terraform v1.0.0

## Deployments

Deployments and validations are done with [Scalr.io](https://scalr.io) which is a Terraform automation and collaboration tool, similar to Hashicorp's Terraform Cloud. It does speculative planning on PRs, cost checking, and state management from a UI that is able to be shared and security to team members.

## Resources

### Providers and Variables

I only have a single provider defined, AWS in us-east-1. I opted for using default tags since I'm using a modern version of Terraform

For variables, I only ended up defining two local variables one for region and one for account id. In hindsight, I probably could have defined a couple surrounding the app name and domain name. If this were to turn into a production module, I would probably do just that for namespacing purposes. 

### ACM

There's just two resources here: The certificate and the certificate validation. The create-before-destroy here is pretty key since it prevents a possible time period where there is no certificate under this resource to be used.

If I had a certificate, say from GoDaddy or DigiCert, I would probably be managing the TLS cert via Terraform as well so I would be able to import the private certificate directly into the ACM resource.

### Cloudfront

There are two Cloudfront distributions defined here: One for the assets of the main application and a second to handle the apex to www redirect.

The main distribution points to an S3 origin and uses the ACM certificate. It enforces HTTPS primarily. If this were to be a production configuration, I would likely add Geo based restrictions and attach a web application firewall to it. Tuning the cache behavior on static assets like images, stylesheets, and scripts would also happen.

The second distribution is for rerouting apex or naked domain visits to the www domain. There are a few ways to accomplish this, I opted for a pattern I have done before. This leverages another S3 bucket that forwards to the Cloudfront origin above.

### IAM

I create a couple of resources here for the deployment user. The IAM policy is scoped very tightly which follows latest guidance from Amazon and others to approach IAM with a least-privileged mindset.

### Route53

Since I had the domain in an account already and this created the zone automatically, I use a data block to import it so I can reference the zone ID and zone name without having to type it anywhere.

In this I create the ACM validation records, this is so my certificate can be verified. It leverages a for loop to create all of the records that are needed by the ACM validation resource.

I also create two alias records for the apex and www endpoints. In Terraform these are assigned as an A record, though the alias block tells Amazon to create an alias record instead. There's a lot of benefits to using alias records including no cost when calling them from Amazon resources and very fast propagation across Amazon's DNS.

### S3

The S3 file creates resources for three buckets.

The artifacts bucket is where the code goes and what Cloudfront points to. It sets up basic CORS policies, enables versioning and logging, and sets basic parameters for it to serve web traffic.

The redirect bucket is a bucket that has a website configuration that points to the www/non-apex Cloudfront distribution.

The logging bucket is where all logs for the artifacts bucket are stored. I would probably end up putting some lifecycle rules in place on this to move to IA and eventually glacier storage classes, but didn't seem needed at this time.
