# CRRateLimitTester

Simple Clash Royale Rate Limit Tester Written Using HummingBird and Swift.

# Why?

There is no official word on the Clash Royale API's rate limits, so I thought I'd test it myself.

# How to test

1- Run the app.   
2- Provide your Clash Royale API token as the 'token' environment variable.   
3- Call the testing route with a rate and a Clash Royale API endpoint url `localhost:8080/test-rate?rate=[rate]&url=[url]`   

# Example

Testing the `https://api.clashroyale.com/v1/cards` endpoint at `40` requests per second rate:    
`curl localhost:8080/test-rate?rate=40&url=https://api.clashroyale.com/v1/cards`

# Results

The rate limit seems to be set at `80`.   
Testing with rate set at `80` or less will always succeed, and with `81` and above you'll always get the `429 Too Many Requests` error.

# Bonus

You can test other APIs rate limits as well as long as they use a Bearer token for authorization.  
You'll just need to enter the other API's url in the tester route.
