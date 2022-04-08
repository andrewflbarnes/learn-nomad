job "docs" {
  datacenters = ["dc1"]

  group "echo" {
    count= "2"

    network {
      port "http" {
        to = "5678"
      }
    }

    task "server" {
      driver = "docker"

      resources {
        memory = 50
        cpu = 50
      }

      config {
        image = "hashicorp/http-echo"
        ports = ["http"]
        args = [
          "-listen",
          ":${NOMAD_PORT_http}",
          "-text",
          "hello world",
        ]
      }
    }
  }
}
