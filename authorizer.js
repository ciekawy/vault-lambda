exports.handler = async (event) => {
    // console.log(event);
    console.log('cookies', event.headers.cookie);
    const token = event.headers?.authorization?.replace('Bearer ', '')
    const routeArn = event.routeArn;


    if(process.env.OBSCURITY_TOKEN === token || (
        process.env.COOKIE_AUTH === 'true' && event.headers?.cookie?.match(`auth=${process.env.OBSCURITY_TOKEN}`))
    ) {
        console.log('Token is valid');
        // Call getCallerIdentity to validate the token
        return generatePolicy('user', 'Allow', routeArn);
    } else {
        console.warn('Token is invalid');
        return generatePolicy('user', 'Deny', routeArn);
    }
};

const generatePolicy = (principalId, effect, resource) => {
    return {
        principalId: principalId,
        policyDocument: {
            Version: '2012-10-17',
            Statement: [
                {
                    Action: 'execute-api:Invoke',
                    Effect: effect,
                    Resource: resource
                }
            ]
        }
    };
};

