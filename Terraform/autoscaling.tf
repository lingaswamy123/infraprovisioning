resource "aws_launch_configuration" "as_conf" {
  name          = "apache2-lc"
  image_id      = "${data.aws_ami.amicall.id}"
  instance_type = "t2.micro"
  key_name      = "pakcerpractice"
  security_groups = ["${data.aws_security_group.sg.id}"]
  associate_public_ip_address = true
}
resource "aws_autoscaling_group" "auto-scaling" {
  desired_capacity   = 2
  max_size           = 3
  min_size           = 1
  vpc_zone_identifier = ["subnet-7501530c", "subnet-77924c5c", "subnet-c2abd789", "subnet-e00b26ba"]
  launch_configuration = "${aws_launch_configuration.as_conf.id}"
  target_group_arns = ["${aws_alb_target_group.alb_targetgroup.arn}"]
}
resource "aws_alb" "alb" {
  name                             = "LB-Apache"
  internal                         = false
  security_groups                  = ["${data.aws_security_group.sg.id}"]
  subnets                          = ["subnet-7501530c", "subnet-77924c5c", "subnet-c2abd789", "subnet-e00b26ba"]
  enable_deletion_protection       = false
  enable_cross_zone_load_balancing = true
}
resource "aws_alb_target_group" "alb_targetgroup" {
  name     = "target-group"
  port     = "80"
  protocol = "HTTP"
  vpc_id   = "${data.aws_vpc.vpc_select.id}"

  health_check {
    port                = "80"
    protocol            = "HTTP"
    path                = "/index.html"
    interval            = "300"
    timeout             = "40"
    unhealthy_threshold = "2"
  }
}

#Create ALB Listener
resource "aws_alb_listener" "alb_listener" {
  load_balancer_arn = "${aws_alb.alb.arn}"
  port              = "80"
  protocol          = "HTTP"
  default_action {
    target_group_arn = "${aws_alb_target_group.alb_targetgroup.arn}"
    type             = "forward"
  }
}