resource "aws_ecr_repository" "this" {
  name                 = "${var.env}-${var.name_prefix}-fluentbit"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "this" {
  policy = jsonencode(
    {
      "rules" : [
        {
          rulePriority : 1,
          description : "Hold only ${var.holding_count} images",
          selection : {
            "tagStatus" : "any",
            "countType" : "imageCountMoreThan",
            "countNumber" : var.holding_count
          },
          action : {
            "type" : "expire"
          }
        }
      ]
    }
  )

  repository = aws_ecr_repository.this.name
}

