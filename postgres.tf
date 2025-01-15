resource "aws_db_subnet_group" "boundary_demo_db_subnet_group" {
  subnet_ids = [aws_subnet.boundary_db_demo_subnet.id, aws_subnet.boundary_db_demo_subnet2.id]

  tags = {
    "Name" = "Boundary DB Demo"
  }

}

resource "aws_db_instance" "boundary_demo" {
  identifier             = "boundary-brokered-demo"
  db_name                = var.db_name
  instance_class         = "db.t3.micro"
  allocated_storage      = 5
  engine                 = "postgres"
  engine_version         = "13.15" #"16.1"
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.boundary_demo_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  //parameter_group_name   = aws_db_parameter_group.boundary_demo_db_subnet_group.name
  publicly_accessible = true
  skip_final_snapshot = true
}
