@Library('analitica-library') _

def general = [
    repoName: 'iac-analitica-datalake-niif'
]

def envParams = [
    develop: [
        tfWorkspace: 'dev',
        awsCredentialId: 'aws-datalake-dev'
    ],
    quality: [
        tfWorkspace: 'qa',
        awsCredentialId: 'aws-datalake-qa'
    ],
    main: [
        tfWorkspace: 'prd'
    ]
]

iacPipeline(general, envParams)
