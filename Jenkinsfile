pipeline {
  agent {
    label "jenkins-jx-base"
  }
  environment {
    ORG = 'arturo-ai'
    APP_NAME = 'logzio-k8s'
  }
  stages {
    stage('Build and publish PR') {
      when {
        branch 'PR-*'
      }
      steps {
        container('jx-base') {
          script {
            sh "jx step git credentials"
            sh "git config credential.helper store"
            next_version = sh(script: 'jx-release-version', returnStdout: true)
            sh "docker build --no-cache -t $DOCKER_REGISTRY/$ORG/$APP_NAME:$next_version-$BRANCH_NAME-$BUILD_NUMBER ."
            sh "docker push $DOCKER_REGISTRY/$ORG/$APP_NAME:$next_version-$BRANCH_NAME-$BUILD_NUMBER"
          }
        }
      }
    }
    stage('Build and publish "master"') {
      when {
        branch 'master'
      }
      steps {
        container('jx-base') {
          sh '''
          jx step git credentials
          # ensure we're not on a detached head
          git checkout master

          # until we switch to the new kubernetes / jenkins credential implementation use git credentials store
          git config credential.helper store

          export VERSION="$(jx-release-version)"
          echo "Releasing version to ${VERSION}"

          docker build --no-cache -t $DOCKER_REGISTRY/$ORG/$APP_NAME:${VERSION} .
          docker push $DOCKER_REGISTRY/$ORG/$APP_NAME:${VERSION}
          docker tag $DOCKER_REGISTRY/$ORG/$APP_NAME:${VERSION} $DOCKER_REGISTRY/$ORG/$APP_NAME:latest
          docker push $DOCKER_REGISTRY/$ORG/$APP_NAME

          git tag -fa v${VERSION} -m "Release version ${VERSION}"
          git push origin v${VERSION}
          '''
        }
      }
    }
  }
  post {
    always {
      cleanWs()
    }
  }
}
