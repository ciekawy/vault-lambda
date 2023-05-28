**WARNING** this project is missing currently one final step to push docker image to aws ECR

# Vault Lambda - Simple Serverless Vault on AWS

Vault Lambda is a project that allows you to deploy and manage Hashicorp Vault as a Docker container running as an AWS
Lambda function. It uses a simple authorization mechanism to control access to the Vault service. The project also makes
use of AWS Key Management Service (KMS) for auto unsealing the vault and stores vault data in an Amazon S3 bucket.

## Prerequisites

- AWS Account
- AWS CLI installed and configured
- Serverless Framework installed
- Docker installed
- Node.js and NPM installed
- envsubst command (from the gettext package) installed

## Getting Started

1. Clone the repository.
2. Install the dependencies by running `npm install`.
3. Update the `.env` file with your AWS configuration

## Deploying the Application

To deploy the application, run the following command:

```
npm run deploy
```

## Initializing the Vault

After deployment, the Vault will be empty. You will need to initialize it using the following command:

```
./init-vault-image.sh
```

The response from `vault operator init` command should be securely stored in a safe place. From this moment, you can use `vault` cli to interact with the vault using:

```
VAULT_ADDR=https://<aws endpoint returned by deploy> VAULT_TOKEN=<token> vault <command> -header=Authorization=<obscurity_token>
```

The handling of unseal keys and the root key should follow strict security measures. Please refer to the HashiCorp's [official documentation](https://www.vaultproject.io/docs/concepts/seal) for guidance on dealing with these keys.

## Useful Commands

- Set maximum lease TTL:
  ```
  vault write sys/auth/token/tune max_lease_ttl=36500d
  ```

## Project Structure

The main files of the project are:

- `authorizer.js`: The authorizer function.
- `Dockerfile`: Defines the Docker image used for the Lambda function.
- `config/`: Contains configuration templates for the Vault server and KMS policy.
- `init-vault-image.sh`: Shell script to initialize the Vault.
- `build.sh`: Builds the Docker image and pushes it to AWS ECR.
- `serverless.yml`: Defines the Serverless Framework service.

## Authorizer

The authorizer used in this project is a simple "obscurity" authorizer using an environment variable `OBSCURITY_TOKEN`. This is just to prevent random requests from the internet. It checks if the `OBSCURITY_TOKEN` matches the token in the request's authorization header or cookie.

## Data Resiliency / Recovery

There should be a backup strategy for the data stored in the Vault. HashiCorp provides [guidance](https://www.vaultproject.io/docs/concepts/backup) on this topic. In case of data loss or no access to KMS, you should have a recovery plan in place.

## Monitoring / Auditing

Vault AWS Lambda allows you to track and manage any suspicious activities with built-in monitoring and auditing features. It provides visibility into access and changes to your secrets. Check out the [Vault Audit Log documentation](https://www.vaultproject.io/docs/audit) to learn more about this feature.

## Future Development

Here are some enhancements that can be made to evolve this project further:

1. Implement a more advanced authorizer that supports various authentication mechanisms such as OAuth, SAML, JWT, etc.
2. Implement automated backups of the Vault data in S3.
3. Support other function cloud providers such as GCP, Azure.
4. Consider adding support for Vault's various secret engines and authentication methods.

Remember that Vault AWS Lambda is designed to be an easy-to-deploy and manage solution for small-scale projects or teams that do not want to deal with the complexity of maintaining a full-fledged Vault setup. As your project grows and matures, you should consider migrating towards a more comprehensive and robust Vault infrastructure, or a cloud service provider's native secrets management service.

## Potential Considerations

1. **Security Awareness:** While Vault Lambda improves security by preventing sensitive data from being shared or stored insecurely, it's essential to educate your team about key risks and secure usage practices. Refer to HashiCorp's [official security model documentation](https://www.vaultproject.io/docs/internals/security) for comprehensive details.
2. **Scalability and Cost:** For smaller projects, Vault Lambda should provide sufficient scalability and low cost. However, as your project grows, you might need to consider more scalable and efficient solutions.
3. **Dependency on AWS:** Currently, Vault Lambda is designed to work with AWS services only. However, the same concept could be adapted for other cloud providers like Google Cloud Platform (GCP) and Azure.
4. **Token Rotation:** As an added security measure, consider implementing Vault token rotation. Here's the [official guide](https://www.vaultproject.io/docs/concepts/tokens) from HashiCorp on how to implement it.
5. **Secrets Structure:** For best practices on how to structure secrets within Vault, please refer to this [official guide](https://learn.hashicorp.com/tutorials/vault/paths-policies) from HashiCorp.

You're welcome to join the development of this project and help make it even more useful and secure. Feedback and contributions are most welcome!
