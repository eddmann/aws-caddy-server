data "template_file" "caddy" {
  template = "${file("./provision.tpl")}"

  vars {
    domain = "${var.caddy_domain}"
    email  = "${var.caddy_email}"
  }
}

resource "aws_key_pair" "caddy" {
  key_name   = "caddy"
  public_key = "${var.caddy_ssh_key}"
}

resource "aws_instance" "caddy" {
  ami                    = "${var.caddy_ami_id}"
  instance_type          = "t2.nano"
  availability_zone      = "${var.caddy_availability_zone}"
  key_name               = "${aws_key_pair.caddy.key_name}"
  vpc_security_group_ids = ["${aws_security_group.caddy.id}"]
  subnet_id              = "${aws_subnet.caddy.id}"
  user_data              = "${data.template_file.caddy.rendered}"

  tags {
    Name      = "Caddy-Server"
    Terraform = "Yes"
  }
}

resource "aws_eip_association" "caddy" {
  instance_id   = "${aws_instance.caddy.id}"
  allocation_id = "${var.caddy_eip_id}"
}

resource "aws_volume_attachment" "caddy" {
  device_name = "/dev/xvdg"
  volume_id   = "${var.caddy_volume_id}"
  instance_id = "${aws_instance.caddy.id}"
}
