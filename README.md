# nagios-check-jenkins-agent

Simple nagios script to verify if an Jenkins Swarm agent is connected to a controller by utilizing the REST API

# Usage

```
./check_jenkins_agent.rb -u jenkins.example.com -h fooagent -u foo -p bar
```

Or with full options:

```
./check_jenkins_agent.rb --help
Usage: check_jenkins_agent [options]
    -i, --instance [URL]             Base URL of the Jenkins Controller
    -h, --host [HOST]                Optionally override host to check. This is the hostname by default
    -u, --user [USER]                Authentication username
    -p, --password [PASSWORD]        Authentication password
    -t, --temp-offline-state [STATE] Report temporarily offline nodes as: OK, WARN or CRIT. Warning is default
```

# Contributing

I quickly hacked this script together for my own uses. Therefore, it does not cover all the available options and might still have a bug or two.
Feel free to send feedback and/or open a PR!
