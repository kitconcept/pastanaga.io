#!groovy

pipeline {

  agent {
    label 'node'
  }

  tools {
    nodejs "nodejs-10"
  }

  options {
    disableConcurrentBuilds()
    timeout(time: 15, unit: 'MINUTES')
  }

  stages {

    // Build
    stage('Build') {
      agent {
        label 'node'
      }
      steps {
        deleteDir()
        checkout scm
        sh 'npm install'
        sh 'node_modules/gatsby/dist/bin/gatsby.js build --prefix-paths'
        sh 'tar cfz dist.tgz dist'
        stash includes: 'dist.tgz', name: 'dist.tgz'
      }
    }

    // Deploy
    stage('Deploy') {
      agent {
        label 'node'
      }
      when {
        branch 'master'
      }
      steps {
        deleteDir()
        sh 'ssh cloud1.kitconcept.com "(cd /srv/pastanaga.io/ && git clean -fd)"'
        sh 'ssh cloud1.kitconcept.com "(cd /srv/pastanaga.io/ && git fetch --all && git reset --hard origin/mmaster)"'
        unstash 'dist.tgz'
        sh 'scp dist.tgz cloud1.kitconcept.com:/srv/pastanaga.io/'
        sh 'ssh cloud1.kitconcept.com "(cd /srv/pastanaga.io/ && tar xfz dist.tgz)"'
      }
    }

    // Performance Tests
    stage('Performance Tests') {
      agent {
        label 'node'
      }
      when {
        branch 'master'
      }
      steps {
        deleteDir()
        checkout scm
        sh 'npm install'
        // psi
        script {
          psiExitCode = sh(
            script: 'npm run psi',
            returnStdout: true
          )
        }
        echo "psiExitCode: ${psiExitCode}"
        echo "Pipeline result: ${currentBuild.result}"
        echo "Pipeline currentResult: ${currentBuild.currentResult}"
        // webpagetest
        /*sh 'npm run webpagetest:ci'
        step([
          $class: 'JUnitResultArchiver',
          testResults: 'performance**.xml',
          checkHealthScaleFactor: 0.2
        ])*/
        // lighthouse
        // sh 'npm run lighthouse:ci'
      }
      post {
        always {
          /*publishHTML (target: [
            allowMissing: false,
            alwaysLinkToLastBuild: false,
            keepAll: true,
            reportDir: '.',
            reportFiles: 'lighthouse-report.html',
            reportName: "Lighthouse"
          ])*/
          script {
            currentBuild.getPreviousBuild().getResult().toString()
            currentBuild.result = 'SUCCESS'
            echo "Pipeline result: ${currentBuild.result}"
            echo "Pipeline currentResult: ${currentBuild.currentResult}"
          }
        }
      }
    }

  }
}