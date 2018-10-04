data "aws_ecs_task_definition" "microsoftiis" {
 task_definition = "${aws_ecs_task_definition.microsoftiis.family}"

depends_on = [ "aws_ecs_task_definition.microsoftiis" ]
}
resource "aws_ecs_task_definition" "microsoftiis" {
  family                = "hello_world"

/* ##### Networking mode specified - uncomment will allow network_config but cause problems with the IAM role attachment and load balancer #####  
  network_mode             = "awsvpc"
*/
  container_definitions = <<DEFINITION
[
 {
   "name": "microsoftiis",
   "image": "microsoft/iis",
   "essential": true,
   "portMappings": [
     {
       "containerPort": 80,
       "hostPort": 80
     }
   ],
   "memory": 500,
   "cpu": 10,
   "Command": ["C:\\ServiceMonitor.exe w3svc"]
 }
]
DEFINITION
}