job "docs" {
  datacenters = ["dc1"]

  group "echo" {
    count  = 2
    network {
      port "http" {
      }
      port "dummy"{
      }
    }

    task "server" {
      driver = "raw_exec"

      config {
        command = "/usr/local/bin/http-echo"

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
