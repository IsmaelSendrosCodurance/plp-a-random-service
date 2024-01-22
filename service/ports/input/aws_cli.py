import sh

s3 = sh.bash.bake("aws ecs")
s3.put("file","s3n://bucket/file")