provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

resource "aws_instance" "example" {
  ami           = "ami-aad1e0cf"
  instance_type = "t2.micro"
  key_name   = "ay_key_dev"
  
  provisioner "file" {
	source      = "conf"
    destination = "~/"
	connection {
		type = "ssh"
		user = "ubuntu"
		private_key = "${file("${var.private_key}")}"
	}
  }
  
  provisioner "remote-exec" {
    inline = [
		"sudo apt-get update",
		"sudo apt-get install nginx -y",
		"sudo openssl req -x509 -subj /CN=localhost -days 365 -set_serial 2 -newkey rsa:4096 -keyout /etc/nginx/cert.key -nodes -out /etc/nginx/cert.pem",
		"sudo cp ~/conf/ /etc/",
		"sudo rm /etc/nginx/sites-enabled/default",
		"sudo ln -s /etc/nginx/sites-available/aspnetcoredemo.conf /etc/nginx/sites-enabled/aspnetcoredemo.conf",
		"sudo systemctl restart nginx",
		"mkdir aspnetcoredemo",
		"cd aspnetcoredemo",
		"dotnet new mvc",
		"dotnet publish",
		"sudo cp -a ~/aspnetcoredemo/bin/Debug/netcoreapp2.0/publish/ /var/aspnetcoredemo/",
		"sudo systemctl enable kestrel-aspnetcoredemo.service",
		"sudo systemctl start kestrel-aspnetcoredemo.service"
	]
	connection {
		type = "ssh"
		user = "ubuntu"
		private_key = "${file("${var.private_key}")}"
	}
  }
}

output "ip" {
  value = "${aws_instance.example.private_ip}"
}