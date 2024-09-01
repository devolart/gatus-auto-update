# gatus-auto-update
Deploy Gatus monitoring to PaaS easily with auto-update config

## How to use
1. Create a secret gist on Github Gist, copy the contents of `config.example` file, and modify it as you wish
2. Get the raw gist URL without commit id (<a href="https://gist.github.com/atenni/5604615" target="_blank">how?</a>)
3. Fill `CONFIG_URL` environment variable with that URL

## How to deploy
Use this repository for the deployment and fill `CONFIG_URL` environment variable. Either building with Docker or buildpack will work. Make sure to use the right port in the config.

## Limitations
1. It will check any updates on the gist raw file every 1 minute but it may take more than a minute to see the changes because of caching
2. Github Gist's caching makes it slow to update most of the times. Although, it has been mitigated with a custom query to make a single fresh request every minute. Still, you may experience slow config updates and there may be request throttling because of constant requests. I'm not responsible for any anomalies happening to your Github account when using this repository
3. Request limits may occur for Github Gist, I didn't test it that far
4. Using another platform than Github Gist may remove these limitations and/or add other limitations