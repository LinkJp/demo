# Kurzdemo zu Terraform und Ansible.

Automatisiertes Aufsetzen einer kleinen Ubuntu VM mit einem nginx Webserver und einer kleinen statischen Bildergallerie.

## Erforderliche Software:

[Hashicorp - Terraform](https://developer.hashicorp.com/terraform/install)

[Terraform Provider für Hetzner - hcloud](https://registry.terraform.io/providers/hetznercloud/hcloud/latest)

[Red Hat - Ansible](https://docs.ansible.com/ansible/latest/installation_guide/installation_distros.html)

---
Terraform, der Provider für den Cloudanbieter (hier Hetzner) sowie Ansible müssen Lokal auf dem Laptop installiert sein. Auf der erstellten VM in der Cloud muss nur ein SSH Zugang mit Sudo Rechten vorliegen.

Bei [Hetzner](https://accounts.hetzner.com/login) muss ein Account vorhanden sein und eine Kreditkarte hinterlegt werden :D

---
Anschließend wird ein Projekt angelegt und im Reiter Sicherheit -> API-Tokens ein Token mit Lese- und Schreibrechten generiert. 
**Dieser Token ist ein Zugangsschlüssel und sollte niemals mit irgendwem geteilt werden, bei dessen Nutzung entstehen Kosten.**

Anschließend muss der Token als Umgebungsvariable **_hcloud_token1_** initialisiert werden, unter Linux & Mac geht das im Terminal via

`
export hcloud_token1=<token>
`

---

Außerdem muss ein SSH Key erzeugt werden und der Pfad zum **Public**key in [Zeile 12](https://github.com/LinkJp/demo/blob/f46d671ee9cd16ebbe87654315d84f73c579dfdf/terraform.tf#L12) angepasst werden.

Ist man hier angekommen, öffnet man ein Terminal (unter Windows _sollte/könnte_ die Powershell funktionieren) im hcloud-terraform Ordner und kann via
`
terraform init
`
Terraform initialisieren. Kommen dabei keine Fehler sollte alles ready to go sein. 

Nun kann via 
`
terraform plan
`
eine Ausführung der terraform.tf Datei "geplant" werden, als Ausgabe sollte eine Beschreibung der Zielinfrastruktur rauspurzeln:

```
terraform plan

Terraform used the selected providers to generate the following execution plan. Resource actions are
indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # hcloud_primary_ip.primary_ip_1 will be created
  + resource "hcloud_primary_ip" "primary_ip_1" {
      + assignee_id       = (known after apply)
      + assignee_type     = "server"
      + auto_delete       = true
      + datacenter        = "fsn1-dc14"
      + delete_protection = false
      + id                = (known after apply)
      + ip_address        = (known after apply)
      + ip_network        = (known after apply)
      + labels            = {
          + "hallo" = "systema"
        }
      + name              = "primary_ip_test"
      + type              = "ipv4"
    }

  # hcloud_server.server_test will be created
  + resource "hcloud_server" "server_test" {
      + allow_deprecated_images    = false
      + backup_window              = (known after apply)
      + backups                    = false
      + datacenter                 = "fsn1-dc14"
      + delete_protection          = false
      + firewall_ids               = (known after apply)
      + id                         = (known after apply)
      + ignore_remote_firewall_ids = false
      + image                      = "ubuntu-22.04"
      + ipv4_address               = (known after apply)
      + ipv6_address               = (known after apply)
      + ipv6_network               = (known after apply)
      + keep_disk                  = false
      + labels                     = {
          + "hallo" = "systema"
        }
      + location                   = (known after apply)
      + name                       = "test-server-please-ignore"
      + primary_disk_size          = (known after apply)
      + rebuild_protection         = false
      + server_type                = "cx11"
      + shutdown_before_deletion   = false
      + ssh_keys                   = [
          + "main ssh key",
        ]
      + status                     = (known after apply)

      + public_net {
          + ipv4         = (known after apply)
          + ipv4_enabled = true
          + ipv6         = (known after apply)
          + ipv6_enabled = false
        }
    }

  # hcloud_ssh_key.default will be created
  + resource "hcloud_ssh_key" "default" {
      + fingerprint = (known after apply)
      + id          = (known after apply)
      + name        = "main ssh key"
      + public_key  = <<-EOT
            These are not the droids you are lookinng for, continue.
        EOT
    }

Plan: 3 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + public_ip4 = (known after apply)
```

Ist dies der Fall, kann die VM via `terraform apply` hochgezogen werden. 

**Ab dieser Stelle entstehen Kosten. Der ausgewählte Servertyp cx11 liegt bei 3,92€/mo (bei stundengenauer Abrechnung!), eine öffentliche IPv4 bei 0,001€/h.
Zur Einordnung, das mehrfache aufbauen und wieder abreißen sowie die Live Demo haben insgesamt Kosten von etwa 1,47€ erzeugt.**

Ist nun der Server in hoch, ist die öffentliche IPv4 die zugewiesen wurde ersichtlich. Diese muss nun in die [inventory](https://github.com/LinkJp/demo/blob/main/inventory) Datei geschrieben werden.

Nun muss lediglich noch ansible aufgerufen werden um den NginX zu installieren, die Demoseite und die Webserver Konfiguration zu kopieren und die Firewall auf Port 80 zu öffnen.

`ansible-playbook playbook.yml -i inventory -u root`

Das kopieren der Seite dauert aufgrund der Bilder ein paar Minuten, im anschluss kann man die Seite direkt via der IP im Brauser aufrufen, fertig. :)

Will man alles wieder einreißen, ist das mit `terraform destroy` möglich.

#### Diese Demo ist nicht für produktiven oder längeren Betrieb mit öffentlichem Zugang gedacht, Härtungsmaßnahmen sind kein Teil der Skripte.