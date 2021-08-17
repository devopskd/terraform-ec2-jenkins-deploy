# EC2 Instance ##
resource "aws_instance" "web" {
  ami                    = lookup(var.ami_id, var.region)
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.terraform_private_sg.id]
  subnet_id              = aws_subnet.terraform-subnet_1.id
  key_name               = var.key_name
  count                  = 1
  #  associate_public_ip_address = true

  provisioner "remote-exec" {
    inline = [
      "wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -",
      "sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'",
      "sudo apt update -qq",
      "sudo apt install -y openjdk-8-jdk",
      "sudo apt install -y jenkins",
      "sudo systemctl start jenkins",
      "sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8080",
      "sudo sh -c \"iptables-save > /etc/iptables.rules\"",
      "echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections",
      "echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections",
      "sudo apt-get -y install iptables-persistent",
      "sudo ufw allow 8080",
    ]
  }

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file("~/devops-test.pem")
  }
  tags = {
    Name = "Jenkins"
  }
}

resource "aws_key_pair" "class" {
  key_name   = var.key_name
  public_key = file("~/devops-test.pub")
}

