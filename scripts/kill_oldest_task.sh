task_arns=$(aws ecs list-tasks --cluster isendros-plp-ecs-cluster-tf --desired-status 'RUNNING' --query 'taskArns' --output text)
echo $task_arns
task_arns_spaces=${task_arns//$'\t'/ }
echo $task_arns_spaces
task_to_kill=$(aws ecs describe-tasks --cluster isendros-plp-ecs-cluster-tf --tasks  ${task_arns_spaces} --query "tasks[] | reverse(sort_by(@, &createdAt)) | [-1].[taskArn]" --output text)
echo $task_to_kill

aws ecs stop-task --cluster isendros-plp-ecs-cluster-tf --task ${task_to_kill} 2>&1 > /dev/null