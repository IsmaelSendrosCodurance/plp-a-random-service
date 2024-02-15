data "aws_subnet" "subnet_1" {
  id ="subnet-075cbc4a"
}
data "aws_subnet" "subnet_2" {
  id ="subnet-72b47f09"
}
data "aws_subnet" "subnet_3" {
  id ="subnet-e060d189"
}
data "aws_security_group" "sg_1" {
  id ="sg-951261fc"
}
data "aws_security_group" "sg_2" {
  id ="sg-0b4207a15d05501c6"
}
data "aws_vpc" "vcp_1"{
  id="vpc-f3ff439a"
}