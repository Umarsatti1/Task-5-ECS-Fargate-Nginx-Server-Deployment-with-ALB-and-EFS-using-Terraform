resource "aws_efs_file_system" "efs" {
  creation_token = "efs-nginx"
  encrypted      = true

  tags = {
    Name = "efs-nginx"
  }
}

resource "aws_efs_mount_target" "efs_mount" {
  for_each = {
    subnet_1 = var.private_subnet_ids[0]
    subnet_2 = var.private_subnet_ids[1]
  }

  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = each.value
  security_groups = [var.security_group_id]
}

resource "aws_efs_access_point" "efs_access" {
  file_system_id = aws_efs_file_system.efs.id

  posix_user {
    gid = "1000"
    uid = "1000"
  }

  root_directory {
    creation_info {
      owner_uid = "1000"
      owner_gid = "1000"
      permissions = "777"
    }

    path = "/"
  }

  tags = {
    Name = "efs-nginx-access-point"
  }
}