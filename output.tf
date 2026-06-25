output "jenkins-server" {
  value = aws_instance.team-1-jenkins.public_ip
}

output "ansible-server" {
  value = aws_instance.team-1-ansible_server.public_ip
}

output "sonarqube-server" {
  value = aws_instance.team-1-sonarqube.public_ip
}

output "bastion-server" {
  value = aws_instance.team-1-bastion_server.public_ip
}

output "docker-server" {
  value = aws_instance.team-1-docker-server.private_ip
}

output "nexus-server" {
  value = aws_instance.nexus.public_ip

}