# 1. Agrupamos tus subredes de Intranet para la Base de Datos
resource "aws_db_subnet_group" "this" {
  name       = "rds-intranet-subnet-group"
  subnet_ids = var.intranet_subnet_ids

  tags = {
    Name = "rds-intranet-subnet-group"
  }
}

# 2. Tu instancia RDS económica
resource "aws_db_instance" "db" {
  allocated_storage      = 20
  max_allocated_storage  = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  
  identifier             = "mydb"
  db_name                = "appdb"
  username               = "dbpragma"
  password               = "Pr4Gm42024*"

  vpc_security_group_ids = var.security_group_ids
  
  # 🔗 Conectamos el grupo de subredes que acabamos de crear arriba
  db_subnet_group_name   = aws_db_subnet_group.this.name

  backup_retention_period = 0
  skip_final_snapshot     = true

  monitoring_interval          = 0
  performance_insights_enabled = false

  publicly_accessible = false
}