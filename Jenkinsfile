node {

    checkout scm

    env.DOCKER_API_VERSION="1.23"
    sh "git rev-parse --short HEAD > commit-id"

    tag = readFile('commit-id').replace("\n", "").replace("\r", "")
    appName = "sample-app-staging"
    registryHost = "127.0.0.1:30400/"
    imageName = "${registryHost}${appName}:${tag}"
    env.BUILDIMG=imageName
    env.BUILD_TAG=tag

    stage "Build"

        sh "docker build -t ${imageName} -f src/Dockerfile src/"

    stage "Push"

        sh "docker push ${imageName}"
}
