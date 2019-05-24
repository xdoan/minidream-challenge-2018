# Use rpy2 if you have R scoring functions
import rpy2.robjects as robjects
import os

##-----------------------------------------------------------------------------
##
## challenge specific code and configuration
##
##-----------------------------------------------------------------------------


## A Synapse project will hold the assetts for your challenge. Put its
## synapse ID here, for example
## CHALLENGE_SYN_ID = "syn1234567"
CHALLENGE_SYN_ID = "syn18813072"

## Name of your challenge, defaults to the name of the challenge's project
CHALLENGE_NAME = "2019 CSBC PS-ON mini-DREAM Challenge"

## Synapse user IDs of the challenge admins who will be notified by email
## about errors in the scoring script
ADMIN_USER_IDS = [3382314, 3376089]

## Each question in your challenge should have an evaluation queue through
## which participants can submit their predictions or models. The queues
## should specify the challenge project as their content source. Queues
## can be created like so:
##   evaluation = syn.store(Evaluation(
##     name="My Challenge Q1",
##     description="Predict all the things!",
##     contentSource="syn1234567"))
## ...and found like this:
##   evaluations = list(syn.getEvaluationByContentSource('syn3375314'))
## Configuring them here as a list will save a round-trip to the server
## every time the script starts and you can link the challenge queues to
## the correct scoring/validation functions.  Predictions will be validated and

module_config = [
    {
        "fileName":"activity-0.yml",
        "module": 0
    },
    {
        "fileName": "activity-1.yml",
        "module": 1
    },
    {
        "fileName": "activity-2.yml",
        "module": 2
    },
    {
        "fileName": "activity-3.yml",
        "module": 3
    },
    {
        "fileName": "activity-4.yml",
        "module": 4
    },
    {
        "fileName": "activity-5.yml",
        "module": 5
    },
    {
        "fileName": "activity-6.yml",
        "module": 6
    },
    {
        "fileName": "activity-7.yml",
        "module": 7
    },
]


module_by_name = {q['fileName']:q for q in module_config}

def score(submission):
    fileName = os.path.basename(submission.filePath)
    fileNameSplit = fileName.split("_")
    moduleName = fileNameSplit[1]
    moduleNo = module_by_name[moduleName]["module"]
    userName = fileNameSplit[0]
    filePath = os.path.join(os.path.dirname(os.path.abspath(__file__)),'../modules/module%s/.eval/eval_fxn.R' % moduleNo)
    robjects.r("source('%s')" % filePath)
    scoring_func = robjects.r('score_submission')

    if moduleNo == 6:
        entity_annots = submission.entity['annotations']
        with open(submission.filePath, 'w') as f:
            f.write(entity_annots['yaml'][0])
    
    results = scoring_func(submission.filePath)
    annotations = {key:value[0] for key, value in zip(results.names, results)}
    annotations['module'] = "Module %s" % moduleNo
    annotations['userName'] = userName
    return(annotations)

evaluation_queues = [
    {
        'id':9614247,
        'scoring_func':score,
    }
]
evaluation_queue_by_id = {q['id']:q for q in evaluation_queues}



## define the default set of columns that will make up the leaderboard
LEADERBOARD_COLUMNS = [
    dict(name='objectId',      display_name='ID',      columnType='STRING', maximumSize=20),
    dict(name='userId',        display_name='User',    columnType='STRING', maximumSize=20, renderer='userid'),
    dict(name='entityId',      display_name='Entity',  columnType='STRING', maximumSize=20, renderer='synapseid'),
    dict(name='versionNumber', display_name='Version', columnType='INTEGER'),
    dict(name='name',          display_name='Name',    columnType='STRING', maximumSize=240),
    dict(name='team',          display_name='Team',    columnType='STRING', maximumSize=240)]

## Here we're adding columns for the output of our scoring functions, score,
## rmse and auc to the basic leaderboard information. In general, different
## questions would typically have different scoring metrics.
leaderboard_columns = {}
for q in evaluation_queues:
    leaderboard_columns[q['id']] = LEADERBOARD_COLUMNS + [
        dict(name='score',         display_name='Score',   columnType='DOUBLE'),
        dict(name='rmse',          display_name='RMSE',    columnType='DOUBLE'),
        dict(name='auc',           display_name='AUC',     columnType='DOUBLE')]

## map each evaluation queues to the synapse ID of a table object
## where the table holds a leaderboard for that question
leaderboard_tables = {}


def validate_submission(evaluation, submission):
    """
    Find the right validation function and validate the submission.

    :returns: (True, message) if validated, (False, message) if
              validation fails or throws exception
    """
    config = evaluation_queue_by_id[int(evaluation.id)]
    validated, validation_message = config['validation_func'](submission, config['goldstandard_path'])

    return True, validation_message


def score_submission(evaluation, submission):
    """
    Find the right scoring function and score the submission

    :returns: (score, message) where score is a dict of stats and message
              is text for display to user
    """
    config = evaluation_queue_by_id[int(evaluation.id)]
    score = config['scoring_func'](submission)
    return (score, "You did fine!")
