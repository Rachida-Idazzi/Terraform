output "WordPress-server_public_ip" {
    description = "the public ip of the WordPress server"
    value = aws_instance.Wordpress_instance.public_ip
}

output "website_url" {
    description = "The url to access the WordPress server"
    value = "http://${aws_instance.Wordpress_instance.public_ip}"
}